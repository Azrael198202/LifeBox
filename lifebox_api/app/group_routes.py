from __future__ import annotations

import hashlib
import secrets
from datetime import datetime, timedelta, timezone
from uuid import UUID, uuid4

from fastapi import APIRouter, Depends, HTTPException

from .db import get_pool
from .auth_utils import CurrentUser, get_current_user
from .schemas_groups import (
    CreateGroupRequest,
    GroupOut,
    GroupDetail,
    MembershipOut,
    CreateInviteRequest,
    CreateInviteResponse,
    AcceptInviteRequest,
    AcceptInviteResponse,
)

router = APIRouter(prefix="/api", tags=["groups"])


def _hash_token(token: str) -> str:
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


async def _assert_group_member(conn, *, group_id: UUID, user_id: UUID) -> str:
    row = await conn.fetchrow(
        """
        select role
        from group_memberships
        where group_id = $1 and user_id = $2
        """,
        group_id,
        user_id,
    )
    if not row:
        raise HTTPException(status_code=403, detail="Not a group member")
    return row["role"]


@router.post("/groups", response_model=GroupOut)
async def create_group(req: CreateGroupRequest, user: CurrentUser = Depends(get_current_user)):
    gid = uuid4()
    pool = get_pool()
    async with pool.acquire() as conn:
        await conn.execute(
            """
            insert into groups (id, name, group_type, owner_user_id)
            values ($1, $2, $3, $4)
            """,
            gid,
            req.name,
            req.group_type,
            user.user_id,
        )
        await conn.execute(
            """
            insert into group_memberships (group_id, user_id, role)
            values ($1, $2, 'owner')
            on conflict do nothing
            """,
            gid,
            user.user_id,
        )

    return GroupOut(id=str(gid), name=req.name, group_type=req.group_type, owner_user_id=str(user.user_id))


@router.get("/groups", response_model=list[GroupOut])
async def list_groups(user: CurrentUser = Depends(get_current_user)):
    pool = get_pool()
    async with pool.acquire() as conn:
        rows = await conn.fetch(
            """
            select g.id::text as id, g.name, g.group_type, g.owner_user_id::text as owner_user_id
            from group_memberships gm
            join groups g on g.id = gm.group_id
            where gm.user_id = $1
            order by g.created_at desc
            """,
            user.user_id,
        )
    return [GroupOut(**dict(r)) for r in rows]


@router.get("/groups/{group_id}", response_model=GroupDetail)
async def group_detail(group_id: UUID, user: CurrentUser = Depends(get_current_user)):
    pool = get_pool()
    async with pool.acquire() as conn:
        await _assert_group_member(conn, group_id=group_id, user_id=user.user_id)

        g = await conn.fetchrow(
            """
            select id::text as id, name, group_type, owner_user_id::text as owner_user_id
            from groups
            where id = $1
            """,
            group_id,
        )
        if not g:
            raise HTTPException(status_code=404, detail="Group not found")

        members = await conn.fetch(
            """
            select user_id::text as user_id, role
            from group_memberships
            where group_id = $1
            order by joined_at asc
            """,
            group_id,
        )

    return GroupDetail(
        id=g["id"],
        name=g["name"],
        group_type=g["group_type"],
        owner_user_id=g["owner_user_id"],
        members=[MembershipOut(**dict(m)) for m in members],
    )


@router.post("/groups/{group_id}/invites", response_model=CreateInviteResponse)
async def create_invite(group_id: UUID, req: CreateInviteRequest, user: CurrentUser = Depends(get_current_user)):
    token = secrets.token_urlsafe(32)
    token_hash = _hash_token(token)
    expires_at = datetime.now(timezone.utc) + timedelta(hours=req.expires_hours)
    invite_id = uuid4()

    pool = get_pool()
    async with pool.acquire() as conn:
        role = await _assert_group_member(conn, group_id=group_id, user_id=user.user_id)
        if role not in ("owner", "admin"):
            raise HTTPException(status_code=403, detail="Insufficient role")

        await conn.execute(
            """
            insert into group_invites (
              id, group_id, inviter_user_id, invitee_email, token_hash, expires_at
            ) values ($1,$2,$3,$4,$5,$6)
            """,
            invite_id,
            group_id,
            user.user_id,
            req.invitee_email,
            token_hash,
            expires_at,
        )

    return CreateInviteResponse(invite_id=str(invite_id), token=token)


@router.post("/invites/accept", response_model=AcceptInviteResponse)
async def accept_invite(req: AcceptInviteRequest, user: CurrentUser = Depends(get_current_user)):
    token_hash = _hash_token(req.token)
    now = datetime.now(timezone.utc)
    pool = get_pool()
    async with pool.acquire() as conn:
        inv = await conn.fetchrow(
            """
            select id, group_id
            from group_invites
            where token_hash = $1
              and accepted_at is null
              and expires_at > $2
            """,
            token_hash,
            now,
        )
        if not inv:
            raise HTTPException(status_code=400, detail="Invalid or expired invite")

        group_id = inv["group_id"]

        await conn.execute(
            """
            insert into group_memberships (group_id, user_id, role)
            values ($1, $2, 'member')
            on conflict (group_id, user_id) do nothing
            """,
            group_id,
            user.user_id,
        )

        await conn.execute(
            """
            update group_invites
            set accepted_at = $1, accepted_user_id = $2
            where id = $3
            """,
            now,
            user.user_id,
            inv["id"],
        )

    return AcceptInviteResponse(group_id=str(group_id), role="member")
