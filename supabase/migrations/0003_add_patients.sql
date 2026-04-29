-- Migración 0003 — Tabla de pacientes anonimizados (Fase 3.2, 2026-04-29)
-- alias: identificador anonimizado elegido por el médico (ej. "P-001", "Caso A").
-- notes: notas libres SIN datos identificativos personales.
create table patients (
  id          uuid        primary key default gen_random_uuid(),
  user_id     uuid        not null references auth.users(id) on delete cascade,
  alias       text        not null check (length(trim(alias)) > 0),
  notes       text        not null default '',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Índice para listar pacientes del usuario por fecha de creación
create index patients_user_id_created_at_idx
  on patients (user_id, created_at desc);

-- Reusa la función handle_updated_at definida en 0001_init.sql
create trigger set_updated_at_patients
  before update on patients
  for each row execute function handle_updated_at();

-- RLS: cada usuario solo accede a sus propios pacientes
alter table patients enable row level security;

create policy "select_own" on patients
  for select using (auth.uid() = user_id);

create policy "insert_own" on patients
  for insert with check (auth.uid() = user_id);

create policy "update_own" on patients
  for update using (auth.uid() = user_id);

create policy "delete_own" on patients
  for delete using (auth.uid() = user_id);

-- FK opcional desde evaluations (nullable para retrocompatibilidad
-- con evaluaciones creadas antes de la introducción de pacientes).
-- on delete set null: si se borra el paciente, las evaluaciones
-- quedan en el bucket "Sin paciente asignado" en lugar de borrarse.
alter table evaluations
  add column patient_id uuid references patients(id) on delete set null;

-- Índice para consultar evaluaciones de un paciente concreto
create index evaluations_patient_id_idx on evaluations (patient_id);
