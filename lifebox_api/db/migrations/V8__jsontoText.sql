ALTER TABLE public.subscription_receipts ALTER COLUMN raw_response TYPE text USING raw_response::text;
ALTER TABLE public.subscription_events ALTER COLUMN payload TYPE text USING payload::text;
ALTER TABLE public.billing_webhook_logs ALTER COLUMN raw_payload TYPE text USING raw_payload::text;

