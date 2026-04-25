create table if not exists public.app_users (
  id bigint generated always as identity primary key,
  name text not null,
  username text unique not null,
  password text not null,
  role text not null default 'operador',
  created_at timestamptz default now()
);

create table if not exists public.products (
  id bigint generated always as identity primary key,
  name text not null,
  barcode text,
  category text,
  price numeric default 0,
  stock integer default 0,
  internal_code text unique not null,
  stock_label text unique not null,
  created_at timestamptz default now()
);

create table if not exists public.movements (
  id bigint generated always as identity primary key,
  product_id bigint,
  product_name text,
  type text,
  quantity integer,
  source text,
  username text,
  details text,
  created_at timestamptz default now()
);

alter table public.app_users disable row level security;
alter table public.products disable row level security;
alter table public.movements disable row level security;

insert into public.app_users (name, username, password, role)
values ('Administrador', 'admin', '123456', 'admin')
on conflict (username) do nothing;


create table if not exists public.pending_labels (
  id bigint generated always as identity primary key,
  product_id bigint,
  product_name text,
  quantity_remaining integer default 0,
  status text default 'pendente',
  stock_label text,
  created_at timestamptz default now()
);

alter table public.pending_labels disable row level security;


create table if not exists public.product_docs (
  id bigint generated always as identity primary key,
  product_id bigint,
  product_name text,
  arrival_date date,
  expiration_date date,
  lot text,
  quantity integer default 0,
  username text,
  created_at timestamptz default now()
);

alter table public.product_docs disable row level security;

alter table public.product_docs add column if not exists quantity integer default 0;


-- GARANTIAS FINAIS
create table if not exists public.product_docs (
  id bigint generated always as identity primary key,
  product_id bigint,
  product_name text,
  arrival_date date,
  expiration_date date,
  lot text,
  quantity integer default 0,
  username text,
  created_at timestamptz default now()
);

alter table public.product_docs add column if not exists product_id bigint;
alter table public.product_docs add column if not exists product_name text;
alter table public.product_docs add column if not exists arrival_date date;
alter table public.product_docs add column if not exists expiration_date date;
alter table public.product_docs add column if not exists lot text;
alter table public.product_docs add column if not exists quantity integer default 0;
alter table public.product_docs add column if not exists username text;
alter table public.product_docs add column if not exists created_at timestamptz default now();

create table if not exists public.pending_labels (
  id bigint generated always as identity primary key,
  product_id bigint,
  product_name text,
  quantity_remaining integer default 0,
  status text default 'pendente',
  stock_label text,
  created_at timestamptz default now()
);

alter table public.products add column if not exists min_stock integer default 0;

alter table public.product_docs disable row level security;
alter table public.pending_labels disable row level security;
grant all on public.product_docs to anon;
grant all on public.pending_labels to anon;
grant all on public.product_docs to authenticated;
grant all on public.pending_labels to authenticated;
grant all on public.product_docs to service_role;
grant all on public.pending_labels to service_role;

notify pgrst, 'reload schema';


-- PERMISSÕES POR USUÁRIO
alter table public.app_users add column if not exists permissions jsonb default '[]'::jsonb;

update public.app_users
set permissions = '["account","users","novo_produto","entrada_estoque","baixa_manual","ver_estoque","documentar","exportar_excel","historico","graficos","etiquetas","fila_etiquetas","scanner"]'::jsonb
where role = 'admin' and (permissions is null or permissions = '[]'::jsonb);

update public.app_users
set permissions = '["account","novo_produto","entrada_estoque","baixa_manual","ver_estoque","documentar","exportar_excel","etiquetas","fila_etiquetas","scanner"]'::jsonb
where role = 'conferente' and (permissions is null or permissions = '[]'::jsonb);

update public.app_users
set permissions = '["account","ver_estoque"]'::jsonb
where role = 'operador' and (permissions is null or permissions = '[]'::jsonb);

alter table public.app_users disable row level security;
grant all on table public.app_users to anon;
grant all on table public.app_users to authenticated;
grant usage, select, update on all sequences in schema public to anon;
grant usage, select, update on all sequences in schema public to authenticated;
notify pgrst, 'reload schema';


-- CORREÇÃO EXTRA pending_labels
alter table public.pending_labels disable row level security;

drop policy if exists "Allow all pending_labels" on public.pending_labels;
create policy "Allow all pending_labels"
on public.pending_labels
for all
using (true)
with check (true);

grant usage on schema public to anon;
grant usage on schema public to authenticated;
grant usage on schema public to service_role;

grant all on table public.pending_labels to anon;
grant all on table public.pending_labels to authenticated;
grant all on table public.pending_labels to service_role;

grant usage, select, update on all sequences in schema public to anon;
grant usage, select, update on all sequences in schema public to authenticated;
grant usage, select, update on all sequences in schema public to service_role;

notify pgrst, 'reload schema';


-- NÍVEL SAC E PERMISSÕES PADRÃO
alter table public.app_users add column if not exists permissions jsonb default '[]'::jsonb;

update public.app_users
set permissions = '["account","ver_estoque","historico"]'::jsonb
where role = 'sac' and (permissions is null or permissions = '[]'::jsonb);

notify pgrst, 'reload schema';


-- GARANTIA DO NÍVEL SAC
alter table public.app_users add column if not exists permissions jsonb default '[]'::jsonb;

update public.app_users
set permissions = '["account","ver_estoque","historico"]'::jsonb
where role = 'sac' and (permissions is null or permissions = '[]'::jsonb);

notify pgrst, 'reload schema';
