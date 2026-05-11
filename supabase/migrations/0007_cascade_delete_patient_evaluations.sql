-- Migración 0007 — ON DELETE CASCADE en evaluations.patient_id (2026-05-11)
-- Cambia SET NULL por CASCADE: al borrar un paciente se borran también
-- todas sus evaluaciones. Las evaluaciones sin paciente (patient_id IS NULL)
-- no se ven afectadas.
alter table evaluations
  drop constraint evaluations_patient_id_fkey;

alter table evaluations
  add constraint evaluations_patient_id_fkey
  foreign key (patient_id)
  references patients(id)
  on delete cascade;
