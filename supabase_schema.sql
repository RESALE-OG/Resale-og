-- RESALE OG database
-- Run this entire file in Supabase SQL Editor.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  avatar_url text,
  phone text,
  city text,
  created_at timestamptz not null default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  seller_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  description text not null default '',
  price numeric(12,2) not null check (price >= 0),
  category text not null default 'Other',
  condition text not null default 'Used',
  image_url text not null default '',
  status text not null default 'active' check (status in ('active','sold','hidden')),
  created_at timestamptz not null default now()
);

create table if not exists public.wishlists (
  user_id uuid not null references auth.users(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, product_id)
);

create table if not exists public.cart_items (
  user_id uuid not null references auth.users(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  quantity integer not null default 1 check (quantity > 0),
  created_at timestamptz not null default now(),
  primary key (user_id, product_id)
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  buyer_id uuid not null references auth.users(id) on delete cascade,
  total_amount numeric(12,2) not null check (total_amount >= 0),
  status text not null default 'pending',
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  seller_id uuid references auth.users(id) on delete set null,
  title text not null,
  price numeric(12,2) not null,
  quantity integer not null default 1 check (quantity > 0)
);

alter table public.profiles enable row level security;
alter table public.products enable row level security;
alter table public.wishlists enable row level security;
alter table public.cart_items enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own" on public.profiles for select using (auth.uid() = id);

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own" on public.profiles for insert with check (auth.uid() = id);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles for update using (auth.uid() = id);

drop policy if exists "products_public_read" on public.products;
create policy "products_public_read" on public.products for select using (status = 'active' or auth.uid() = seller_id);

drop policy if exists "products_insert_own" on public.products;
create policy "products_insert_own" on public.products for insert with check (auth.uid() = seller_id);

drop policy if exists "products_update_own" on public.products;
create policy "products_update_own" on public.products for update using (auth.uid() = seller_id);

drop policy if exists "products_delete_own" on public.products;
create policy "products_delete_own" on public.products for delete using (auth.uid() = seller_id);

drop policy if exists "wishlist_own" on public.wishlists;
create policy "wishlist_own" on public.wishlists for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "cart_own" on public.cart_items;
create policy "cart_own" on public.cart_items for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "orders_buyer_read" on public.orders;
create policy "orders_buyer_read" on public.orders for select using (auth.uid() = buyer_id);

drop policy if exists "orders_buyer_insert" on public.orders;
create policy "orders_buyer_insert" on public.orders for insert with check (auth.uid() = buyer_id);

drop policy if exists "order_items_buyer_read" on public.order_items;
create policy "order_items_buyer_read" on public.order_items for select
using (exists (select 1 from public.orders o where o.id = order_id and o.buyer_id = auth.uid()));

-- Profile auto-creation after signup.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name',''))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();
