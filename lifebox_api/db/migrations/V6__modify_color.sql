ALTER TABLE public.inbox_records
ALTER COLUMN color_value TYPE BIGINT
USING color_value::BIGINT;

ALTER TABLE public.inbox_records
ALTER COLUMN color_value SET DEFAULT 4284513675;