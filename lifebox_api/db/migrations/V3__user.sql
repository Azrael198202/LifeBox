-- users（用户主档）
create table if not exists users (
  id uuid primary key,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  display_name text,
  avatar_url text,
  email text,                               -- 可为空（只用 Google 时也可以保存 email）
  email_verified boolean not null default false,

  status text not null default 'active'     -- active/disabled/deleted
);

create unique index if not exists uq_users_email
on users (lower(email))
where email is not null;


-- 登录身份：Google/Apple/Email…
create table if not exists auth_identities (
  id uuid primary key,
  created_at timestamptz not null default now(),

  user_id uuid not null references users(id) on delete cascade,

  provider text not null,                   -- 'google' | 'apple' | 'password' ...
  provider_user_id text not null,           -- Google 的 sub（稳定唯一）
  email text,                               -- provider 给的 email（可冗余，方便查）
  profile jsonb not null default '{}'::jsonb,

  unique (provider, provider_user_id)
);

create index if not exists idx_auth_identities_user_id on auth_identities(user_id);


-- auth_sessions（登录会话，可控登出/多端管理）
create table if not exists auth_sessions (
  id uuid primary key,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null,

  user_id uuid not null references users(id) on delete cascade,

  refresh_token_hash text not null,
  user_agent text,
  ip inet,
  revoked_at timestamptz
);

create index if not exists idx_auth_sessions_user_id on auth_sessions(user_id);
create index if not exists idx_auth_sessions_expires_at on auth_sessions(expires_at);

-- 家族/共享组织模型（统一用 group） groups（家族/团队/共享空间）
create table if not exists groups (
  id uuid primary key,
  created_at timestamptz not null default now(),

  name text not null,
  group_type text not null default 'family',   -- family/team/other
  owner_user_id uuid references users(id) on delete set null
);

create index if not exists idx_groups_owner_user_id on groups(owner_user_id);

-- group_memberships（成员关系 + 角色）
create table if not exists group_memberships (
  group_id uuid not null references groups(id) on delete cascade,
  user_id uuid not null references users(id) on delete cascade,

  role text not null default 'member',          -- owner/admin/member/viewer
  joined_at timestamptz not null default now(),

  primary key (group_id, user_id)
);

create index if not exists idx_group_memberships_user_id on group_memberships(user_id);

-- group_invites（邀请加入共享组）
create table if not exists group_invites (
  id uuid primary key,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null,

  group_id uuid not null references groups(id) on delete cascade,
  inviter_user_id uuid references users(id) on delete set null,

  invitee_email text not null,                 -- 邀请的邮箱
  token_hash text not null,                    -- 邀请 token 的 hash
  accepted_at timestamptz,
  accepted_user_id uuid references users(id) on delete set null
);

create index if not exists idx_group_invites_group_id on group_invites(group_id);
create index if not exists idx_group_invites_email on group_invites(lower(invitee_email));

-- 修改 inbox_records（新增 owner/group）
alter table inbox_records
  add column if not exists owner_user_id uuid references users(id) on delete set null;

alter table inbox_records
  add column if not exists group_id uuid references groups(id) on delete set null;

create index if not exists idx_inbox_records_owner_user_id on inbox_records(owner_user_id);
create index if not exists idx_inbox_records_group_id on inbox_records(group_id);

-- record_shares（记录共享权限）
create table if not exists record_shares (
  id uuid primary key,
  created_at timestamptz not null default now(),

  record_id uuid not null references inbox_records(id) on delete cascade,
  shared_with_user_id uuid references users(id) on delete cascade,
  shared_with_group_id uuid references groups(id) on delete cascade,

  permission text not null default 'read'       -- read/write
);


