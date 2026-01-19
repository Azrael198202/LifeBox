from __future__ import annotations

import os
from fastapi import APIRouter, Depends, HTTPException
from uuid import uuid4, UUID
from typing import Any, List

from google.oauth2 import id_token as google_id_token
from google.auth.transport import requests as google_requests

from .db import get_pool
from .auth_utils import create_access_token, CurrentUser, get_current_user
from .schemas_auth import GoogleAuthRequest, AuthResponse, MeResponse, UserOut, GroupBrief

router = APIRouter(prefix="/api/auth", tags=["auth"])


def _google_client_id() -> str:
    cid = os.getenv("GOOGLE_CLIENT_ID")
    if not cid:
        raise RuntimeError("GOOGLE_CLIENT_ID is not set")
    return cid


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
