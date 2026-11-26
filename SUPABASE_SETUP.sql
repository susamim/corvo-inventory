-- CORVO Inventory Hub : run once in Supabase > SQL Editor
-- 1) REPLACE admin@yourcompany.com with YOUR admin e-mail (3 places below)
create table if not exists public.corvo_state (
  id text primary key,
  ts bigint not null default 0,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
alter table public.corvo_state enable row level security;

-- everybody (viewers, not logged in) may READ
create policy "viewer read" on public.corvo_state for select to anon, authenticated using (true);
-- only YOUR admin e-mail may INSERT / UPDATE
create policy "admin insert" on public.corvo_state for insert to authenticated
  with check ((auth.jwt() ->> 'email') = 'admin@yourcompany.com');
create policy "admin update" on public.corvo_state for update to authenticated
  using ((auth.jwt() ->> 'email') = 'admin@yourcompany.com')
  with check ((auth.jwt() ->> 'email') = 'admin@yourcompany.com');

-- live updates for the viewer page
alter publication supabase_realtime add table public.corvo_state;

-- starting row
insert into public.corvo_state (id, ts, data) values ('main', 0, '{}') on conflict (id) do nothing;
