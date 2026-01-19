from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Query
from typing import Optional, List
from uuid import UUID, uuid4

from .db import get_pool
from .auth_utils import CurrentUser, get_current_user
from .schemas_cloud import CloudSaveRequest, CloudSaveResponse, CloudListItem, CloudDetail

router = APIRouter(prefix="/api/cloud", tags=["cloud"])


async def _assert_group_member(*, group_id: UUID, user_id: UUID) -> None:
    pool = get_pool()
    async with pool.acquire() as conn:
        row = await conn.fetchrow(
            """
            select 1
            from group_memberships
            where group_id = $1 and user_id = $2
            """,
            group_id,
            user_id,
        )
    if not row:
        raise HTTPException(status_code=403, detail="Not a group member")


@router.post("/records", response_model=CloudSaveResponse)
async def save_record(
    req: CloudSaveRequest,
    user: CurrentUser = Depends(get_current_user),
):
    n = req.normalized or {}
    record_id = uuid4()

    if req.group_id is not None:
        await _assert_group_member(group_id=req.group_id, user_id=user.user_id)

    title = n.get("title") or "Untitled"
    source = n.get("source")
    assignee = n.get("assignee")
    due_at = n.get("due_at")
    amount = n.get("amount")
    currency = n.get("currency")
    phones = n.get("phones") or []
    urls = n.get("urls") or []
    risk = n.get("risk") or "low"
    status = n.get("status") or "pending"
    suggested_actions = n.get("suggested_actions") or []

    pool = get_pool()
    async with pool.acquire() as conn:
        try:
            await conn.execute(
                """
                insert into inbox_records (
                  id,
                  owner_user_id,
                  group_id,
                  client_id,
                  locale,
                  source_hint,
                  raw_text,
                  model,
                  model_raw,
                  title,
                  source,
                  assignee,
                  due_at,
                  amount,
                  currency,
                  phones,
                  urls,
                  risk,
                  status,
                  suggested_actions,
                  normalized
                ) values (
                  $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21
                )
                """,
                record_id,
                user.user_id,
                req.group_id,
                req.client_id,
                req.locale,
                req.source_hint,
                req.raw_text,
                req.model,
                req.model_raw,
                title,
                source,
                assignee,
                due_at,
                amount,
                currency,
                phones,
                urls,
                risk,
                status,
                suggested_actions,
                n,
            )
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"DB insert failed: {e}")

    return CloudSaveResponse(id=str(record_id))


@router.get("/records", response_model=List[CloudListItem])
async def list_records(
    user: CurrentUser = Depends(get_current_user),
    group_id: Optional[UUID] = Query(default=None),
    limit: int = Query(default=50, ge=1, le=200),
):
    if group_id is not None:
        await _assert_group_member(group_id=group_id, user_id=user.user_id)
        q = """
        select id::text as id,
               created_at::text as created_at,
               title,
               risk,
               status,
               due_at,
               source_hint,
               group_id::text as group_id
        from inbox_records
        where group_id = $1
        order by created_at desc
        limit $2
        """
        args = [group_id, limit]
    else:
        q = """
        select id::text as id,
               created_at::text as created_at,
               title,
               risk,
               status,
               due_at,
               source_hint,
               null::text as group_id
        from inbox_records
        where owner_user_id = $1 and group_id is null
        order by created_at desc
        limit $2
        """
        args = [user.user_id, limit]

    pool = get_pool()
    async with pool.acquire() as conn:
        rows = await conn.fetch(q, *args)

    return [CloudListItem(**dict(r)) for r in rows]


@router.get("/records/{record_id}", response_model=CloudDetail)
async def get_record(
    record_id: UUID,
    user: CurrentUser = Depends(get_current_user),
):
    pool = get_pool()
    async with pool.acquire() as conn:
        row = await conn.fetchrow(
            """
            select id::text as id,
                   created_at::text as created_at,
                   raw_text,
                   locale,
                   source_hint,
                   owner_user_id,
                   group_id,
                   normalized
            from inbox_records
            where id = $1
            """,
            record_id,
        )

    if not row:
        raise HTTPException(status_code=404, detail="Not found")

    owner_user_id = row["owner_user_id"]
    group_id = row["group_id"]

    if group_id is not None:
        await _assert_group_member(group_id=group_id, user_id=user.user_id)
    else:
        if owner_user_id != user.user_id:
            raise HTTPException(status_code=403, detail="Forbidden")

    return CloudDetail(
        id=row["id"],
        created_at=row["created_at"],
        raw_text=row["raw_text"],
        locale=row["locale"],
        source_hint=row["source_hint"],
        group_id=str(group_id) if group_id else None,
        normalized=row["normalized"],
    )
