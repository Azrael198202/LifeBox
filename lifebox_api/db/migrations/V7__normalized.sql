ALTER TABLE public.inbox_records
ALTER COLUMN normalized TYPE JSONB
USING normalized::jsonb;
