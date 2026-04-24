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
  username text,
  created_at timestamptz default now()
);

alter table public.product_docs disable row level security;
