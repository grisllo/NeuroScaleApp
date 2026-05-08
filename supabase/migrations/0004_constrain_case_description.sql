-- Migración 0004 — Refuerza límite de longitud de case_description
-- (Subfase 6.1, 2026-05-08).
-- Defensa server-side: el cliente ya valida con regex (DNI, NIE, email,
-- teléfono ES, fecha) y bloquea el guardado si detecta PII. Mantener regex
-- robustas en plpgsql sería más frágil, así que el servidor solo aplica
-- el límite duro de longitud (≤500) como segunda capa.

alter table evaluations
  add constraint case_description_max_length
  check (length(case_description) <= 500);
