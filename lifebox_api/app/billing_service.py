from __future__ import annotations

from datetime import datetime, timezone, timedelta
from typing import Any, Dict, List, Optional

import asyncpg

from .billing_models import (
    VerifyRequest,
    VerifyResult,
    Platform,
    PlanOut,
    SubscriptionOut,
    EntitlementOut,
)

PREMIUM_ENTITLEMENTS = [
    "cloud_sync",
    "ai_analyze",
    "group_manage",
]


def _now() -> datetime:
    return datetime.now(timezone.utc)


def _is_subscribed(status: str, expires_at: Optional[datetime]) -> bool:
    if status != "active":
        return False
    if expires_at is None:
        return True
    return expires_at > _now()


class BillingService:
    def __init__(self, pool: asyncpg.Pool):
        self.pool = pool

    async def list_plans(self, platform: Optional[Platform] = None) -> List[PlanOut]:
        async with self.pool.acquire() as conn:
            if platform:
                rows = await conn.fetch(
                    """
                    select id, platform, title, tier, duration_days, enabled, sort_order
                    from public.plans
                    where enabled=true and platform=$1
                    order by sort_order asc, id asc
                    """,
                    platform,
                )
            else:
                rows = await conn.fetch(
                    """
                    select id, platform, title, tier, duration_days, enabled, sort_order
                    from public.plans
                    where enabled=true
                    order by platform asc, sort_order asc, id asc
                    """
                )
        return [PlanOut(**dict(r)) for r in rows]

    async def get_subscription(self, user_id) -> SubscriptionOut:
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(
                """
                select platform, product_id, status, expires_at, auto_renew
                from public.user_subscriptions
                where user_id=$1
                order by updated_at desc
                limit 1
                """,
                user_id,
            )

        if not row:
            return SubscriptionOut(subscribed=False, status="none")

        status = row["status"]
        expires_at = row["expires_at"]
        return SubscriptionOut(
            subscribed=_is_subscribed(status, expires_at),
            status=status,
            platform=row["platform"],
            product_id=row["product_id"],
            expires_at=expires_at.isoformat() if expires_at else None,
            auto_renew=row["auto_renew"],
        )

    async def list_entitlements(self, user_id) -> List[EntitlementOut]:
        async with self.pool.acquire() as conn:
            rows = await conn.fetch(
                """
                select entitlement, status, source, plan_id, expires_at
                from public.user_entitlements
                where user_id=$1
                order by entitlement asc
                """,
                user_id,
            )

        out: List[EntitlementOut] = []
        for r in rows:
            exp = r["expires_at"]
            out.append(
                EntitlementOut(
                    entitlement=r["entitlement"],
                    status=r["status"],
                    source=r["source"],
                    plan_id=r["plan_id"],
                    expires_at=exp.isoformat() if exp else None,
                )
            )
        return out

    # ✅ 后续把这里替换为 Apple / Google 真校验
    async def verify_with_store(self, req: VerifyRequest) -> VerifyResult:
        token = req.purchase_token or req.receipt or ""
        if token == "test_ok":
            exp = _now() + timedelta(days=30)
            return VerifyResult(
                verified=True,
                status="active",
                expires_at=exp,
                auto_renew=True,
                transaction_id=req.transaction_id,
                original_transaction_id=req.original_transaction_id,
                purchase_token=req.purchase_token,
                raw_response={"mock": True, "rule": "test_ok"},
            )
        if token == "test_expired":
            exp = _now() - timedelta(days=1)
            return VerifyResult(
                verified=True,
                status="expired",
                expires_at=exp,
                auto_renew=False,
                transaction_id=req.transaction_id,
                original_transaction_id=req.original_transaction_id,
                purchase_token=req.purchase_token,
                raw_response={"mock": True, "rule": "test_expired"},
            )
        return VerifyResult(
            verified=False,
            status="unknown",
            expires_at=None,
            auto_renew=None,
            transaction_id=req.transaction_id,
            original_transaction_id=req.original_transaction_id,
            purchase_token=req.purchase_token,
            raw_response={"mock": True, "rule": "unmatched"},
        )

    async def verify_and_update(self, user_id, req: VerifyRequest, source: str = "client") -> SubscriptionOut:
        if req.platform == "android" and not req.purchase_token:
            raise ValueError("purchase_token is required for android")
        if req.platform == "ios" and not (req.receipt or req.transaction_id or req.original_transaction_id):
            raise ValueError("receipt/transaction_id/original_transaction_id is required for ios")

        v = await self.verify_with_store(req)

        async with self.pool.acquire() as conn:
            async with conn.transaction():
                # 1) plan 检查（必须存在且启用）
                plan = await conn.fetchrow(
                    "select id, enabled from public.plans where id=$1 and platform=$2",
                    req.product_id,
                    req.platform,
                )
                if not plan or not plan["enabled"]:
                    raise ValueError("Plan not found or disabled")

                # 2) old subscription (for events)
                old = await conn.fetchrow(
                    """
                    select status, expires_at
                    from public.user_subscriptions
                    where user_id=$1 and platform=$2
                    """,
                    user_id,
                    req.platform,
                )
                old_status = old["status"] if old else None

                # 3) receipts append
                await conn.execute(
                    """
                    insert into public.subscription_receipts
                    (user_id, platform, product_id, transaction_id, original_transaction_id, purchase_token, receipt,
                     verified, status, expires_at, raw_response)
                    values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
                    """,
                    user_id,
                    req.platform,
                    req.product_id,
                    req.transaction_id,
                    req.original_transaction_id,
                    req.purchase_token,
                    req.receipt,
                    v.verified,
                    v.status,
                    v.expires_at,
                    v.raw_response,
                )

                # 4) subscriptions upsert (only when verified)
                if v.verified:
                    await conn.execute(
                        """
                        insert into public.user_subscriptions
                        (user_id, platform, product_id, status, expires_at, auto_renew,
                         original_transaction_id, transaction_id, purchase_token, last_verified_at, updated_at)
                        values ($1,$2,$3,$4,$5,$6,$7,$8,$9,now(),now())
                        on conflict (user_id, platform)
                        do update set
                          product_id=excluded.product_id,
                          status=excluded.status,
                          expires_at=excluded.expires_at,
                          auto_renew=excluded.auto_renew,
                          original_transaction_id=excluded.original_transaction_id,
                          transaction_id=excluded.transaction_id,
                          purchase_token=excluded.purchase_token,
                          last_verified_at=now(),
                          updated_at=now()
                        """,
                        user_id,
                        req.platform,
                        req.product_id,
                        v.status,
                        v.expires_at,
                        v.auto_renew,
                        req.original_transaction_id,
                        req.transaction_id,
                        req.purchase_token,
                    )

                # 5) events
                await conn.execute(
                    """
                    insert into public.subscription_events
                    (user_id, platform, event_type, product_id, old_status, new_status, expires_at, source, payload)
                    values ($1,$2,'verify',$3,$4,$5,$6,$7,$8)
                    """,
                    user_id,
                    req.platform,
                    req.product_id,
                    old_status,
                    v.status,
                    v.expires_at,
                    source,
                    {"client_payload": req.client_payload, "verified": v.verified, "raw": v.raw_response},
                )

                if v.verified and old_status != v.status:
                    await conn.execute(
                        """
                        insert into public.subscription_events
                        (user_id, platform, event_type, product_id, old_status, new_status, expires_at, source, payload)
                        values ($1,$2,'status_change',$3,$4,$5,$6,$7,$8)
                        """,
                        user_id,
                        req.platform,
                        req.product_id,
                        old_status,
                        v.status,
                        v.expires_at,
                        source,
                        {"note": "status changed by verify"},
                    )

                # 6) entitlements
                if v.verified and _is_subscribed(v.status, v.expires_at):
                    for ent in PREMIUM_ENTITLEMENTS:
                        await conn.execute(
                            """
                            insert into public.user_entitlements
                            (user_id, entitlement, source, plan_id, status, expires_at, updated_at)
                            values ($1,$2,'subscription',$3,'active',$4,now())
                            on conflict (user_id, entitlement)
                            do update set
                              source='subscription',
                              plan_id=excluded.plan_id,
                              status='active',
                              expires_at=excluded.expires_at,
                              updated_at=now()
                            """,
                            user_id,
                            ent,
                            req.product_id,
                            v.expires_at,
                        )
                elif v.verified:
                    for ent in PREMIUM_ENTITLEMENTS:
                        await conn.execute(
                            """
                            update public.user_entitlements
                            set status='revoked', updated_at=now()
                            where user_id=$1 and entitlement=$2 and source='subscription'
                            """,
                            user_id,
                            ent,
                        )

        return await self.get_subscription(user_id)

    async def log_webhook(self, platform: Platform, event_id: str, event_type: str, raw_payload: Dict[str, Any]) -> None:
        async with self.pool.acquire() as conn:
            await conn.execute(
                """
                insert into public.billing_webhook_logs
                (platform, event_id, event_type, raw_payload)
                values ($1,$2,$3,$4)
                on conflict (platform, event_id) do nothing
                """,
                platform,
                event_id,
                event_type,
                raw_payload,
            )
