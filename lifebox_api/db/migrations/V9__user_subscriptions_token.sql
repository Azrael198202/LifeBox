drop index if exists uq_user_subscriptions_token;;

CREATE UNIQUE INDEX uq_user_subscriptions_token ON public.user_subscriptions USING btree (user_id,platform, purchase_token) WHERE (purchase_token IS NOT NULL)