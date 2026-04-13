-- ============================================================
-- LandlordOS — Supabase Migration
-- Adapted for African real estate context
-- Run this in: Supabase Dashboard > SQL Editor > New Query
-- ============================================================

-- Properties (immeubles, compounds, maisons)
create table if not exists properties (
  id uuid primary key default gen_random_uuid(),
  landlord_id uuid references auth.users not null,
  name text not null,                          -- e.g. "Immeuble Konaté"
  property_type text check (property_type in (
    'immeuble', 'compound', 'maison', 'studio', 'duplex',
    'villa', 'commercial', 'terrain', 'other'
  )) not null default 'immeuble',
  address text not null,
  quartier text,                               -- neighborhood/quartier
  city text not null,
  country text not null,
  floors int default 1,                        -- number of levels
  total_units int default 1,                   -- total rentable units
  purchase_price numeric,
  mortgage_monthly numeric,
  currency text not null default 'XOF',        -- ISO 4217 currency code
  notes text,
  photos text[],
  created_at timestamptz default now()
);

-- Units (individual rentable spaces within a property)
create table if not exists units (
  id uuid primary key default gen_random_uuid(),
  landlord_id uuid references auth.users not null,
  property_id uuid references properties on delete cascade not null,
  unit_label text not null,                    -- e.g. "Appt 3B", "Chambre 12", "Boutique 1"
  floor_number int default 0,                  -- 0 = rez-de-chaussée
  unit_type text check (unit_type in (
    'appartement', 'chambre', 'studio', 'boutique',
    'bureau', 'magasin', 'garage', 'other'
  )) not null default 'chambre',
  bedrooms int,
  bathrooms int,
  size_sqm numeric,
  rent_amount numeric not null default 0,      -- monthly rent for this unit
  is_occupied bool default false,
  notes text,
  created_at timestamptz default now()
);

-- Tenants (linked to a unit)
create table if not exists tenants (
  id uuid primary key default gen_random_uuid(),
  landlord_id uuid references auth.users not null,
  unit_id uuid references units on delete set null,
  full_name text not null,
  email text,
  phone text,                                  -- primary contact method in Africa
  id_number text,                              -- CNI / passport number
  lease_start date,
  lease_end date,
  rent_amount numeric not null,
  deposit_amount numeric,
  payment_frequency text check (payment_frequency in (
    'monthly', 'quarterly', 'biannual', 'annual'
  )) default 'monthly',
  lease_document_url text,
  notes text,
  created_at timestamptz default now()
);

-- Transactions (income + expenses)
create table if not exists transactions (
  id uuid primary key default gen_random_uuid(),
  landlord_id uuid references auth.users not null,
  property_id uuid references properties on delete cascade not null,
  unit_id uuid references units on delete set null,
  tenant_id uuid references tenants on delete set null,
  type text check (type in ('income', 'expense')) not null,
  category text not null,
  amount numeric not null,
  currency text not null default 'XOF',
  date date not null,
  description text,
  receipt_url text,
  created_at timestamptz default now()
);

-- Tenant file attachments (photo, ID, lease contract)
alter table tenants add column if not exists photo_url text;
alter table tenants add column if not exists id_photo_url text;

-- Payments (rent payments, deposits, tracking)
create table if not exists payments (
  id uuid primary key default gen_random_uuid(),
  landlord_id uuid references auth.users not null,
  tenant_id uuid references tenants on delete cascade not null,
  property_id uuid references properties on delete cascade not null,
  unit_id uuid references units on delete set null,
  type text check (type in ('rent', 'deposit', 'other')) not null default 'rent',
  amount numeric not null,
  currency text not null default 'XOF',
  date date not null,
  due_date date,
  period_label text,               -- e.g. "Avril 2026", "Deposit 3/6"
  payment_method text check (payment_method in (
    'cash', 'mobile_money', 'bank_transfer', 'cheque', 'other'
  )) default 'cash',
  notes text,
  receipt_url text,
  created_at timestamptz default now()
);

-- Maintenance requests
create table if not exists maintenance_requests (
  id uuid primary key default gen_random_uuid(),
  landlord_id uuid references auth.users not null,
  property_id uuid references properties on delete cascade not null,
  unit_id uuid references units on delete set null,
  tenant_id uuid references tenants on delete set null,
  title text not null,
  description text,
  status text check (status in ('open', 'in_progress', 'resolved')) default 'open',
  priority text check (priority in ('low', 'medium', 'high', 'urgent')) default 'medium',
  cost numeric,
  photos text[],
  created_at timestamptz default now(),
  resolved_at timestamptz
);

-- ============================================================
-- Row Level Security (RLS) — landlord can only see their own data
-- ============================================================
alter table properties enable row level security;
alter table units enable row level security;
alter table tenants enable row level security;
alter table transactions enable row level security;
alter table payments enable row level security;
alter table maintenance_requests enable row level security;

-- Properties
create policy "Landlords manage own properties" on properties
  for all using (landlord_id = auth.uid());

-- Units
create policy "Landlords manage own units" on units
  for all using (landlord_id = auth.uid());

-- Tenants
create policy "Landlords manage own tenants" on tenants
  for all using (landlord_id = auth.uid());

-- Transactions
create policy "Landlords manage own transactions" on transactions
  for all using (landlord_id = auth.uid());

-- Payments
create policy "Landlords manage own payments" on payments
  for all using (landlord_id = auth.uid());

-- Maintenance
create policy "Landlords manage own maintenance" on maintenance_requests
  for all using (landlord_id = auth.uid());
