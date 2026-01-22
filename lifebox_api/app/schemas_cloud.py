from __future__ import annotations

from pydantic import BaseModel, Field
from typing import Any, Optional, Literal
from uuid import UUID

Risk = Literal["high", "mid", "low"]
Status = Literal["pending", "done"]


class CloudSaveRequest(BaseModel):
    client_id: Optional[str] = None
    locale: Optional[str] = None
    source_hint: Optional[str] = None

    raw_text: str

    model: Optional[str] = None
    model_raw: Optional[str] = None

    # Optional: save into a shared group
    group_id: Optional[UUID] = None

    colorValue: Optional[str] = None

    normalized: dict[str, Any] = Field(default_factory=dict)


class CloudSaveResponse(BaseModel):
    id: str


class CloudListItem(BaseModel):
    id: str
    created_at: str
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
