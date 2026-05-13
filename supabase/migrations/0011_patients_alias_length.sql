-- Migración 0011 — Limitar longitud máxima de patients.alias (Fase 14.A.6)
-- Sin límite explícito, alias podría ser arbitrariamente largo y causar problemas
-- en la UI (overflow de texto) y en el backend (almacenamiento no acotado).
-- 255 caracteres es suficiente para cualquier alias clínico razonable.

alter table patients
  add constraint patients_alias_max_length check (length(alias) <= 255);
