-- NeuroScale App — Migración inicial
-- Ejecutar en Supabase Studio → SQL Editor → New Query

-- Enum para tipo de escala
-- Añadir nuevos valores con: ALTER TYPE scale_type ADD VALUE 'nueva_escala';
create type scale_type as enum ('gcs', 'nihss', 'rankin', 'barthel');

-- Tabla principal de evaluaciones (MVP sin tabla patients)
-- case_description: texto libre anonimizado — NUNCA datos identificativos reales
create table evaluations (
  id               uuid        primary key default gen_random_uuid(),
  user_id          uuid        not null references auth.users(id) on delete cascade,
  scale_type       scale_type  not null,
  scale_version    smallint    not null default 1,
  case_description text        not null default '',
  total_score      integer     not null,
  interpretation   text        not null,
  detailed_scores  jsonb       not null default '{}',
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

-- Índice para consultas de historial por usuario
create index evaluations_user_id_created_at_idx
  on evaluations (user_id, created_at desc);

-- Trigger que actualiza updated_at automáticamente en cada UPDATE
create or replace function handle_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger set_updated_at
  before update on evaluations
  for each row execute function handle_updated_at();

-- Row Level Security: cada usuario solo accede a sus propios datos
alter table evaluations enable row level security;

create policy "select_own" on evaluations
  for select using (auth.uid() = user_id);

create policy "insert_own" on evaluations
  for insert with check (auth.uid() = user_id);

create policy "update_own" on evaluations
  for update using (auth.uid() = user_id);

create policy "delete_own" on evaluations
  for delete using (auth.uid() = user_id);
