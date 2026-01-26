from __future__ import annotations

from pydantic import BaseModel, Field
from typing import Any, Dict, Optional, Literal
from uuid import UUID

Risk = Literal["high", "mid", "low"]
Status = Literal["pending", "done"]


class CloudSaveRequest(BaseModel):
    # ---------- identity / routing ----------
    client_id: Optional[str] = None          # 前台本地 record.id（推荐传，用于幂等）
    group_id: Optional[UUID] = None

    # ---------- raw fields (来自前台 LocalInboxRecord) ----------
    locale: Optional[str] = None
    source_hint: Optional[str] = None
    raw_text: Optional[str] = None

    title: Optional[str] = None
    summary: Optional[str] = None            # 你可以写入 normalized.notes 或 normalized.summary
    due_at: Optional[str] = None             # "YYYY-MM-DD" or null（按你系统约定）
    amount: Optional[float] = None
    currency: Optional[str] = None
    risk: Optional[Literal["high", "mid", "low"]] = None
    status: Optional[Literal["pending", "done"]] = None
    color_value: Optional[int] = None

    # ---------- AI related (可选) ----------
    model: Optional[str] = None
    model_raw: Optional[str] = None

    normalized: Optional[Dict[str, Any]] = None


class CloudSaveResponse(BaseModel):
    id: str
    existed: bool = False  


class CloudListItem(BaseModel):
    id: str
    client_id: Optional[str] = None
    created_at: str
    locale:str
    title: str
    risk: Risk
    status: Status
    due_at: Optional[str] = None
    source_hint: Optional[str] = None
    group_id: Optional[str] = None
    colorValue: Optional[str] = None


class CloudDetail(BaseModel):
    id: str
    created_at: str
    raw_text: str
    locale: Optional[str] = None
    source_hint: Optional[str] = None
    group_id: Optional[str] = None
    normalized: dict[str, Any]
