-- Migración 0010 — Eliminar índices no utilizados (Fase 14.A.2)
-- Identificados por Supabase Performance Advisor como índices sin queries que los usen.
-- evaluations_patient_id_idx: creado en 0003 para FK lookup, pero las queries
--   de evaluaciones filtran por user_id (con RLS), no por patient_id en isolation.
-- evaluations_user_scale_created_idx: creado en 0005 para filtrado por scale_type,
--   pero tras simplificación del historial, el filtro por escala dejó de usarse.

drop index if exists evaluations_patient_id_idx;
drop index if exists evaluations_user_scale_created_idx;
