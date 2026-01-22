ALTER TABLE public.inbox_records
ADD COLUMN color_value int4 NULL;

-- 可选：给默认值（“个人”的默认色）
ALTER TABLE public.inbox_records
ALTER COLUMN color_value SET DEFAULT 0xFF607D8B;
