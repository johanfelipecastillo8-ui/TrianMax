-- TRIAN MAX: esquema para Supabase (PostgreSQL).
-- Puede ejecutarse manualmente en el SQL Editor de Supabase; el servidor también
-- lo ejecuta de forma idempotente al arrancar con DATABASE_URL configurada.

CREATE SEQUENCE IF NOT EXISTS public.products_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.orders_id_seq START 1001;

CREATE TABLE IF NOT EXISTS public.products (
  id          bigint PRIMARY KEY DEFAULT nextval('public.products_id_seq'),
  name        text NOT NULL,
  category    text NOT NULL,
  price       bigint NOT NULL,
  old_price   bigint,
  stock       integer NOT NULL DEFAULT 0,
  description text NOT NULL DEFAULT '',
  image       text,
  images      jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.orders (
  id         bigint PRIMARY KEY DEFAULT nextval('public.orders_id_seq'),
  data       jsonb NOT NULL,
  status     text NOT NULL DEFAULT 'nuevo',
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.settings (
  key   text PRIMARY KEY,
  value text NOT NULL
);

CREATE TABLE IF NOT EXISTS public.tokens (
  token      text PRIMARY KEY,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS orders_created_at_idx ON public.orders (created_at DESC);
CREATE INDEX IF NOT EXISTS tokens_created_at_idx ON public.tokens (created_at DESC);
