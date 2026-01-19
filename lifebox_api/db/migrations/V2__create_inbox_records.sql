create table if not exists inbox_records (
  id uuid primary key,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  client_id text,
  locale text,
  source_hint text,

  raw_text text not null,
  model text,
  model_raw text,

  title text not null,
  source text,
  assignee text,
  due_at text,
  amount double precision,
  currency text,

  phones text[] not null default '{}',
  urls text[] not null default '{}',

  risk text not null,
  status text not null,
  suggested_actions text[] not null default '{}',

  normalized jsonb not null
);
