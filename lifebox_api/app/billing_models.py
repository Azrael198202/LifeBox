from __future__ import annotations

from pydantic import BaseModel, Field
from typing import Optional, Literal, Any, Dict
from datetime import datetime

Platform = Literal["android", "ios"]


class PlanOut(BaseModel):
    id: str
    platform: Platform
    title: Optional[str] = None
    tier: str = "premium"
    duration_days: Optional[int] = None
    enabled: bool = True
    sort_order: int = 0


class SubscriptionOut(BaseModel):
    subscribed: bool
    status: str
    platform: Optional[Platform] = None
    product_id: Optional[str] = None
    expires_at: Optional[str] = None  # ISO
    auto_renew: Optional[bool] = None


class EntitlementOut(BaseModel):
    entitlement: str
    status: str
    source: str
    plan_id: Optional[str] = None
    expires_at: Optional[str] = None


class VerifyRequest(BaseModel):
    platform: Platform
    product_id: str

    # Android
    purchase_token: Optional[str] = None

    # iOS
    receipt: Optional[str] = None
    transaction_id: Optional[str] = None
    original_transaction_id: Optional[str] = None

    # Debug
    client_payload: Optional[Dict[str, Any]] = None


class VerifyResult(BaseModel):
    verified: bool
    status: str
    expires_at: Optional[datetime] = None
    auto_renew: Optional[bool] = None
    transaction_id: Optional[str] = None
    original_transaction_id: Optional[str] = None
    purchase_token: Optional[str] = None
    raw_response: Optional[Dict[str, Any]] = None


class WebhookIn(BaseModel):
    event_id: str = Field(..., description="Platform event id for dedupe")
    event_type: str
    raw_payload: Dict[str, Any]
