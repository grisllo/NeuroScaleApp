-- Migración 0005 — Índice compuesto para filtrado por scale_type (Subfase 6.2, 2026-05-08).
-- La query de historial filtra con: user_id + IN(scale_types) + ORDER BY created_at DESC.
-- El índice existente (user_id, created_at DESC) cubre solo el caso sin filtro de escala.
-- Este índice compuesto cubre ambos casos eficientemente.

create index if not exists evaluations_user_scale_created_idx
  on evaluations (user_id, scale_type, created_at desc);
