from __future__ import annotations

import hashlib
import secrets
from datetime import datetime, timedelta, timezone
from uuid import UUID, uuid4

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field

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


# =============================
# Internal helpers
# =============================
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


async def _assert_group_owner(conn, *, group_id: UUID, user_id: UUID) -> None:
    row = await conn.fetchrow(
        """
        select owner_user_id
        from groups
        where id = $1
        """,
        group_id,
    )
    if not row:
        raise HTTPException(status_code=404, detail="Group not found")

    if row["owner_user_id"] != user_id:
        raise HTTPException(status_code=403, detail="Owner only")


async def _get_group_row(conn, *, group_id: UUID):
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
    return g


# =============================
# Requests for new endpoints
# =============================
class PatchGroupRequest(BaseModel):
    name: str = Field(..., min_length=1, max_length=200)


class TransferOwnerRequest(BaseModel):
    new_owner_user_id: UUID


class PatchMemberRoleRequest(BaseModel):
    role: str = Field(..., pattern=r"^(owner|admin|member)$")


# =============================
# Existing endpoints
# =============================
@router.post("/groups", response_model=GroupOut)
async def create_group(
    req: CreateGroupRequest,
    user: CurrentUser = Depends(get_current_user),
):
    gid = uuid4()
    pool = get_pool()
    async with pool.acquire() as conn:
        async with conn.transaction():
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

    return GroupOut(
        id=str(gid),
        name=req.name,
        group_type=req.group_type,
        owner_user_id=str(user.user_id),
    )


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
async def create_invite(
    group_id: UUID,
    req: CreateInviteRequest,
    user: CurrentUser = Depends(get_current_user),
):
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
        async with conn.transaction():
            inv = await conn.fetchrow(
                """
                select id, group_id, invitee_email
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

            # 可选：如果 invitee_email 非空，则要求与当前用户邮箱一致（看你 auth 里是否有 email）
            # if inv["invitee_email"] and (user.email or "").lower() != inv["invitee_email"].lower():
            #     raise HTTPException(status_code=403, detail="Invite email mismatch")

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


# =============================
# New endpoints (for your UI)
# =============================

@router.patch("/groups/{group_id}", response_model=GroupOut)
async def patch_group(
    group_id: UUID,
    req: PatchGroupRequest,
    user: CurrentUser = Depends(get_current_user),
):
    """
    修改 group 名称
    - 你 UI 里是 owner 才能改：这里也按 owner-only
    - 如果你想 owner/admin 都能改，把 _assert_group_owner 换成 role check 即可
    """
    pool = get_pool()
    async with pool.acquire() as conn:
        await _assert_group_owner(conn, group_id=group_id, user_id=user.user_id)

        await conn.execute(
            """
            update groups
            set name = $2
            where id = $1
            """,
            group_id,
            req.name.strip(),
        )

        g = await _get_group_row(conn, group_id=group_id)

    return GroupOut(**dict(g))


@router.delete("/groups/{group_id}")
async def delete_group(group_id: UUID, user: CurrentUser = Depends(get_current_user)):
    """
    删除 group（仅 owner）
    - groups ON DELETE CASCADE 会把 memberships、invites 都删掉（你表里 memberships / invites 都引用 groups 并 cascade）
    """
    pool = get_pool()
    async with pool.acquire() as conn:
        await _assert_group_owner(conn, group_id=group_id, user_id=user.user_id)

        r = await conn.execute(
            """
            delete from groups
            where id = $1
            """,
            group_id,
        )

    # asyncpg execute 返回 "DELETE n"
    return {"ok": True, "result": r}


@router.delete("/groups/{group_id}/members/{member_user_id}")
async def remove_member(
    group_id: UUID,
    member_user_id: UUID,
    user: CurrentUser = Depends(get_current_user),
):
    """
    移除成员（仅 owner）
    - 禁止移除 owner（必须先 transfer_owner）
    """
    pool = get_pool()
    async with pool.acquire() as conn:
        async with conn.transaction():
            await _assert_group_owner(conn, group_id=group_id, user_id=user.user_id)

            g = await conn.fetchrow(
                "select owner_user_id from groups where id = $1",
                group_id,
            )
            if not g:
                raise HTTPException(status_code=404, detail="Group not found")

            if g["owner_user_id"] == member_user_id:
                raise HTTPException(status_code=400, detail="Cannot remove owner. Transfer owner first.")

            existed = await conn.fetchrow(
                """
                select 1 from group_memberships
                where group_id = $1 and user_id = $2
                """,
                group_id,
                member_user_id,
            )
            if not existed:
                raise HTTPException(status_code=404, detail="Member not found")

            await conn.execute(
                """
                delete from group_memberships
                where group_id = $1 and user_id = $2
                """,
                group_id,
                member_user_id,
            )

    return {"ok": True}


@router.post("/groups/{group_id}/transfer-owner", response_model=GroupOut)
async def transfer_owner(
    group_id: UUID,
    req: TransferOwnerRequest,
    user: CurrentUser = Depends(get_current_user),
):
    """
    转让 owner（仅 owner）
    - new_owner 必须是当前 group member
    - 更新 groups.owner_user_id
    - 同步 memberships：new_owner.role=owner；old_owner.role=member
    """
    pool = get_pool()
    async with pool.acquire() as conn:
        async with conn.transaction():
            await _assert_group_owner(conn, group_id=group_id, user_id=user.user_id)

            if req.new_owner_user_id == user.user_id:
                raise HTTPException(status_code=400, detail="Already owner")

            # 确保新 owner 是成员
            row = await conn.fetchrow(
                """
                select role from group_memberships
                where group_id = $1 and user_id = $2
                """,
                group_id,
                req.new_owner_user_id,
            )
            if not row:
                raise HTTPException(status_code=404, detail="Target user is not a member")

            # 1) 更新 groups.owner_user_id
            await conn.execute(
                """
                update groups
                set owner_user_id = $2
                where id = $1
                """,
                group_id,
                req.new_owner_user_id,
            )

            # 2) 更新 memberships 角色
            await conn.execute(
                """
                update group_memberships
                set role = 'owner'
                where group_id = $1 and user_id = $2
                """,
                group_id,
                req.new_owner_user_id,
            )

            await conn.execute(
                """
                update group_memberships
                set role = 'member'
                where group_id = $1 and user_id = $2
                """,
                group_id,
                user.user_id,
            )

            g = await _get_group_row(conn, group_id=group_id)

    return GroupOut(**dict(g))


@router.patch("/groups/{group_id}/members/{member_user_id}/role")
async def patch_member_role(
    group_id: UUID,
    member_user_id: UUID,
    req: PatchMemberRoleRequest,
    user: CurrentUser = Depends(get_current_user),
):
    """
    可选：修改成员 role（仅 owner）
    - 不允许把别人设为 owner（owner 只能通过 transfer-owner 流程）
    - 不允许修改 owner 自己的 role（避免误操作）
    """
    if req.role == "owner":
        raise HTTPException(status_code=400, detail="Use transfer-owner to set owner role")

    pool = get_pool()
    async with pool.acquire() as conn:
        async with conn.transaction():
            await _assert_group_owner(conn, group_id=group_id, user_id=user.user_id)

            g = await conn.fetchrow(
                "select owner_user_id from groups where id = $1",
                group_id,
            )
            if not g:
                raise HTTPException(status_code=404, detail="Group not found")

            if member_user_id == g["owner_user_id"]:
                raise HTTPException(status_code=400, detail="Cannot change owner's role")

            existed = await conn.fetchrow(
                """
                select 1 from group_memberships
                where group_id = $1 and user_id = $2
                """,
                group_id,
                member_user_id,
            )
            if not existed:
                raise HTTPException(status_code=404, detail="Member not found")

            await conn.execute(
                """
                update group_memberships
                set role = $3
                where group_id = $1 and user_id = $2
                """,
                group_id,
                member_user_id,
                req.role,
            )

    return {"ok": True}
