-- Corvea waitlist table. Run in Supabase: SQL Editor → New query → paste → Run.

create table if not exists public.waitlist (
  id                uuid primary key default gen_random_uuid(),
  created_at        timestamptz not null default now(),
  name              text not null check (char_length(name) between 1 and 120),
  email             text not null check (email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$' and char_length(email) <= 200),
  business_type     text not null check (business_type in
                      ('lash_brow_pmu','hair','beauty_nails','fitness','pet','health','other')),
  marketing_consent boolean not null default false,
  source            text check (char_length(source) <= 80),
  landing_variant   text check (char_length(landing_variant) <= 40)
);

-- One signup per email address.
create unique index if not exists waitlist_email_unique on public.waitlist (lower(email));

-- The public page may ADD rows but never read, change or delete them.
alter table public.waitlist enable row level security;

drop policy if exists "Public can join the waitlist" on public.waitlist;
create policy "Public can join the waitlist"
  on public.waitlist
  for insert
  to anon
  with check (true);

-- Newer Supabase projects don't grant table access to the public role automatically.
grant insert on public.waitlist to anon;
