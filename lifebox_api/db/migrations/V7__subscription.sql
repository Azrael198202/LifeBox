-- 套餐定义表
create table if not exists public.plans (
  id text primary key,                    -- product_id: lifebox_premium_monthly/yearly
  platform text not null check (platform in ('android','ios')),
  title text null,
  tier text not null default 'premium',   -- premium/pro/enterprise...
  duration_days int null,
  enabled boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_plans_enabled on public.plans(enabled, sort_order);
create index if not exists idx_plans_platform on public.plans(platform);

insert into public.plans(id, platform, title, duration_days, sort_order)
values
('lifebox_premium_monthly','android','Premium Monthly',30,10),
('lifebox_premium_yearly','android','Premium Yearly',365,20),
('lifebox_premium_monthly','ios','Premium Monthly',30,10),
('lifebox_premium_yearly','ios','Premium Yearly',365,20)
on conflict (id) do nothing;

-- 当前订阅状态表：权威读
create table if not exists public.user_subscriptions (
  id bigserial primary key,
  user_id uuid not null references public.users(id) on delete cascade,
  platform text not null check (platform in ('android','ios')),
  product_id text not null references public.plans(id),

  status text not null check (status in (
    'active','expired','canceled','refunded','grace','past_due','unknown'
  )),
  expires_at timestamptz null,
  auto_renew boolean null,

  -- Android / iOS 识别字段（可为空）
  original_transaction_id text null,      -- iOS
  transaction_id text null,               -- iOS/Android
  purchase_token text null,               -- Android

  last_verified_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  unique (user_id, platform)
);

create index if not exists idx_user_subscriptions_user on public.user_subscriptions(user_id);
create index if not exists idx_user_subscriptions_status on public.user_subscriptions(status);
create index if not exists idx_user_subscriptions_expires on public.user_subscriptions(expires_at);


-- 校验/审计表：只追加写入
create table if not exists public.subscription_receipts (
  id bigserial primary key,
  user_id uuid not null references public.users(id) on delete cascade,
  platform text not null check (platform in ('android','ios')),
  product_id text not null references public.plans(id),

  transaction_id text null,
  original_transaction_id text null,
  purchase_token text null,
  receipt text null,

  verified boolean not null default false,
  status text null,
  expires_at timestamptz null,
  raw_response jsonb null,

  created_at timestamptz not null default now()
);

create index if not exists idx_receipts_user on public.subscription_receipts(user_id, created_at desc);
create index if not exists idx_receipts_tx on public.subscription_receipts(transaction_id);
create index if not exists idx_receipts_otx on public.subscription_receipts(original_transaction_id);
create index if not exists idx_receipts_token on public.subscription_receipts(purchase_token);

-- 订阅事件流水：客服/追溯/对账
create table if not exists public.subscription_events (
  id bigserial primary key,
  user_id uuid not null references public.users(id) on delete cascade,
  platform text not null check (platform in ('android','ios')),

  event_type text not null check (event_type in (
    'verify','purchase','restore','renew','cancel','expire','refund','status_change','grant','revoke'
  )),
  product_id text null references public.plans(id),

  old_status text null,
  new_status text null,
  expires_at timestamptz null,

  source text not null check (source in ('client','webhook','cron','admin')),
  payload jsonb null,

  created_at timestamptz not null default now()
);

create index if not exists idx_events_user on public.subscription_events(user_id, created_at desc);
create index if not exists idx_events_type on public.subscription_events(event_type, created_at desc);

-- 权限表：业务最终判断点
create table if not exists public.user_entitlements (
  user_id uuid not null references public.users(id) on delete cascade,
  entitlement text not null,              -- cloud_sync, ai_analyze, group_manage...
  source text not null check (source in ('subscription','admin','promo','trial')),
  plan_id text null references public.plans(id),

  status text not null default 'active' check (status in ('active','revoked')),
  expires_at timestamptz null,

  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now(),

  primary key (user_id, entitlement)
);

create index if not exists idx_entitlements_user on public.user_entitlements(user_id);
create index if not exists idx_entitlements_exp on public.user_entitlements(expires_at);

-- 平台通知日志：可重放/去重
create table if not exists public.billing_webhook_logs (
  id bigserial primary key,
  platform text not null check (platform in ('android','ios')),
  event_id text not null,                 -- 平台事件ID
  event_type text not null,
  received_at timestamptz not null default now(),

  processed boolean not null default false,
  processed_at timestamptz null,
  error text null,

  raw_payload jsonb not null,

  unique(platform, event_id)
);

create index if not exists idx_webhook_processed on public.billing_webhook_logs(processed, received_at desc);



