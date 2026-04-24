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
  min_stock integer default 0,
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

alter table public.app_users disable row level security;
alter table public.products disable row level security;
alter table public.movements disable row level security;
alter table public.pending_labels disable row level security;

grant all on public.app_users to anon;
grant all on public.products to anon;
grant all on public.movements to anon;
grant all on public.pending_labels to anon;

grant all on public.app_users to authenticated;
grant all on public.products to authenticated;
grant all on public.movements to authenticated;
grant all on public.pending_labels to authenticated;

insert into public.app_users (name, username, password, role)
values ('Administrador', 'admin', '123456', 'admin')
on conflict (username) do nothing;

notify pgrst, 'reload schema';
