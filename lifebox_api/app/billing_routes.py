from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Query
from typing import Optional

from .db import get_pool
from .auth_utils import CurrentUser, get_current_user

from .billing_models import Platform, PlanOut, SubscriptionOut, EntitlementOut, VerifyRequest, WebhookIn
from .billing_service import BillingService

router = APIRouter(prefix="/api/billing", tags=["billing"])


def _svc() -> BillingService:
    return BillingService(get_pool())


@router.get("/plans", response_model=list[PlanOut])
async def list_plans(
    platform: Optional[Platform] = Query(default=None),
):
    return await _svc().list_plans(platform)


@router.get("/subscription", response_model=SubscriptionOut)
async def get_subscription(current: CurrentUser = Depends(get_current_user)):
    return await _svc().get_subscription(current.user_id)


@router.get("/entitlements", response_model=list[EntitlementOut])
async def get_entitlements(current: CurrentUser = Depends(get_current_user)):
    return await _svc().list_entitlements(current.user_id)


@router.post("/verify", response_model=SubscriptionOut)
async def verify(req: VerifyRequest, current: CurrentUser = Depends(get_current_user)):
    try:
        return await _svc().verify_and_update(user_id=current.user_id, req=req, source="client")
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


# -----------------------------
# Webhooks：第一阶段只落库去重（以后再做 processed worker）
# 注意：真实上线建议加签名校验（Apple/Google）
# -----------------------------
@router.post("/webhook/{platform}")
async def webhook(platform: Platform, body: WebhookIn):
    await _svc().log_webhook(platform=platform, event_id=body.event_id, event_type=body.event_type, raw_payload=body.raw_payload)
    return {"ok": True}
