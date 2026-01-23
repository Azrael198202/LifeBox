from __future__ import annotations

import os
import random
from fastapi import APIRouter, Depends, HTTPException
from uuid import uuid4, UUID
from typing import Any, List

from google.oauth2 import id_token as google_id_token
from google.auth.transport import requests as google_requests

from .db import get_pool
from .auth_utils import create_access_token, CurrentUser, get_current_user
from .schemas_auth import GoogleAuthRequest, AuthResponse, MeResponse, UserOut, GroupBrief

import bcrypt
from .schemas_auth import EmailRegisterRequest, EmailLoginRequest

router = APIRouter(prefix="/api/auth", tags=["auth"])


def _google_client_id() -> str:
    cid = os.getenv("GOOGLE_CLIENT_ID")
    if not cid:
        raise RuntimeError("GOOGLE_CLIENT_ID is not set")
    return cid

def _norm_email(email: str) -> str:
    return email.strip().lower()

def _hash_password(password: str) -> str:
    # bcrypt 会自动生成 salt
    pw = password.encode("utf-8")
    hashed = bcrypt.hashpw(pw, bcrypt.gensalt(rounds=12))
    return hashed.decode("utf-8")

def _verify_password(password: str, password_hash: str) -> bool:
    try:
        return bcrypt.checkpw(password.encode("utf-8"), password_hash.encode("utf-8"))
    except Exception:
        return False



async def _get_user_groups(conn, user_id: UUID) -> List[GroupBrief]:
    rows = await conn.fetch(
        """
        select g.id::text as id,
               g.name,
               g.group_type,
               gm.role
        from group_memberships gm
        join groups g on g.id = gm.group_id
        where gm.user_id = $1
        order by g.created_at desc
        """,
        user_id,
    )
    return [GroupBrief(**dict(r)) for r in rows]


async def _ensure_default_family_group(conn, user_id: UUID) -> None:
    row = await conn.fetchrow(
        "select 1 from group_memberships where user_id = $1 limit 1",
        user_id,
    )
    if row:
        return

    gid = uuid4()
    await conn.execute(
        """
        insert into groups (id, name, group_type, owner_user_id)
        values ($1, $2, 'family', $3)
        """,
        gid,
        "My Family",
        user_id,
    )
    await conn.execute(
        """
        insert into group_memberships (group_id, user_id, role)
        values ($1, $2, 'owner')
        """,
        gid,
        user_id,
    )


@router.post("/google", response_model=AuthResponse)
async def auth_google(req: GoogleAuthRequest):
    try:
        claims: dict[str, Any] = google_id_token.verify_oauth2_token(
            req.id_token,
            google_requests.Request(),
            _google_client_id(),
        )
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid Google id_token")

    sub = claims.get("sub")
    if not sub:
        raise HTTPException(status_code=401, detail="Google token missing sub")

    email = claims.get("email")
    email_verified = bool(claims.get("email_verified"))
    name = claims.get("name")
    picture = claims.get("picture")

    pool = get_pool()
    async with pool.acquire() as conn:
        identity = await conn.fetchrow(
            """
            select user_id
            from auth_identities
            where provider = 'google' and provider_user_id = $1
            """,
            sub,
        )

        if identity:
            user_id: UUID = identity["user_id"]
            user = await conn.fetchrow(
                """
                select id::text as id, email, display_name, avatar_url
                from users
                where id = $1
                """,
                user_id,
            )
        else:
            user_id = uuid4()
            await conn.execute(
                """
                insert into users (id, email, email_verified, display_name, avatar_url)
                values ($1, $2, $3, $4, $5)
                """,
                user_id,
                email,
                email_verified,
                name,
                picture,
            )
            await conn.execute(
                """
                insert into auth_identities (id, user_id, provider, provider_user_id, email, profile)
                values ($1, $2, 'google', $3, $4, $5)
                """,
                uuid4(),
                user_id,
                sub,
                email,
                claims,
            )
            await _ensure_default_family_group(conn, user_id)
            user = {
                "id": str(user_id),
                "email": email,
                "display_name": name,
                "avatar_url": picture,
            }

        groups = await _get_user_groups(conn, UUID(user["id"]))

    token = create_access_token(user_id=UUID(user["id"]), email=user.get("email"), display_name=user.get("display_name"))
    return AuthResponse(
        access_token=token,
        user=UserOut(**user),
        groups=groups,
    )

@router.post("/register", response_model=AuthResponse)
async def register(req: EmailRegisterRequest):
    email = _norm_email(str(req.email))
    password = req.password or ""

    if len(password) < 8:
        raise HTTPException(status_code=400, detail="Password must be at least 8 characters")

    password_hash = _hash_password(password)

    pool = get_pool()
    async with pool.acquire() as conn:
        # 1) 如果已经有 password identity（说明注册过） -> 返回 409
        exist = await conn.fetchrow(
            """
            select 1
            from auth_identities
            where provider='password' and provider_user_id=$1
            """,
            email,
        )
        if exist:
            raise HTTPException(status_code=409, detail="Email already registered")

        # 2) 如果这个 email 之前是 Google 用户，允许“绑定密码登录”
        user_row = await conn.fetchrow(
            """
            select id
            from users
            where lower(email) = $1
            """,
            email,
        )

        if user_row:
            user_id: UUID = user_row["id"]
            # 若 users.email_verified 目前是 false，也没关系；邮箱登录是否需要验证你可以以后加流程
        else:
            user_id = uuid4()
            await conn.execute(
                """
                insert into users (id, email, email_verified, display_name, avatar_url)
                values ($1, $2, false, $3, null)
                """,
                user_id,
                email,
                str(random.randint(10_000_000, 99_999_999)),  # 默认显示名为随机数字
            )

        # 3) 创建 password identity
        await conn.execute(
            """
            insert into auth_identities (id, user_id, provider, provider_user_id, email, profile, password_hash)
            values ($1, $2, 'password', $3, $4, '{}'::jsonb, $5)
            """,
            uuid4(),
            user_id,
            email,   # provider_user_id
            email,   # email
            password_hash,
        )

        # 4) 默认 family group（如果没有任何 group）
        await _ensure_default_family_group(conn, user_id)

        # 5) 返回 user + groups
        user = await conn.fetchrow(
            """
            select id::text as id, email, display_name, avatar_url
            from users
            where id = $1
            """,
            user_id,
        )
        groups = await _get_user_groups(conn, user_id)

    token = create_access_token(
        user_id=UUID(user["id"]),
        email=user.get("email"),
        display_name=user.get("display_name"),
    )
    return AuthResponse(
        access_token=token,
        user=UserOut(**dict(user)),
        groups=groups,
    )

@router.post("/login", response_model=AuthResponse)
async def login(req: EmailLoginRequest):
    email = _norm_email(str(req.email))
    password = req.password or ""

    pool = get_pool()
    async with pool.acquire() as conn:
        identity = await conn.fetchrow(
            """
            select user_id, password_hash
            from auth_identities
            where provider='password' and provider_user_id=$1
            """,
            email,
        )
        if not identity:
            # 避免泄露“邮箱是否存在”
            raise HTTPException(status_code=401, detail="Invalid credentials")

        password_hash = identity["password_hash"]
        if not password_hash or not _verify_password(password, password_hash):
            raise HTTPException(status_code=401, detail="Invalid credentials")

        user_id: UUID = identity["user_id"]
        user = await conn.fetchrow(
            """
            select id::text as id, email, display_name, avatar_url
            from users
            where id = $1
            """,
            user_id,
        )
        if not user:
            raise HTTPException(status_code=401, detail="Invalid credentials")

        groups = await _get_user_groups(conn, user_id)

    token = create_access_token(
        user_id=UUID(user["id"]),
        email=user.get("email"),
        display_name=user.get("display_name"),
    )
    return AuthResponse(
        access_token=token,
        user=UserOut(**dict(user)),
        groups=groups,
    )



@router.get("/me", response_model=MeResponse)
async def me(current: CurrentUser = Depends(get_current_user)):
    pool = get_pool()
    async with pool.acquire() as conn:
        user = await conn.fetchrow(
            """
            select id::text as id, email, display_name, avatar_url
            from users
            where id = $1
            """,
            current.user_id,
        )
        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        rows = await conn.fetch(
            """
            select g.id::text as id,
                   g.name,
                   g.group_type,
                   gm.role
            from group_memberships gm
            join groups g on g.id = gm.group_id
            where gm.user_id = $1
            order by g.created_at desc
            """,
            current.user_id,
        )
        groups = [GroupBrief(**dict(r)) for r in rows]

    token = create_access_token(user_id=current.user_id, email=user.get("email"), display_name=user.get("display_name"))
    return MeResponse(
        access_token=token,
        user=UserOut(**dict(user)),
        groups=groups,
    )


@router.post("/logout")
async def logout(_: CurrentUser = Depends(get_current_user)):
    return {"ok": True}
