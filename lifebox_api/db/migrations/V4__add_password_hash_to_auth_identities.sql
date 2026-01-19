alter table auth_identities
  add column if not exists password_hash text;

-- 建议加一个索引，便于用 email 查 password identity
create index if not exists idx_auth_identities_provider_email
on auth_identities (provider, lower(email));
