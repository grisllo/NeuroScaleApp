-- Añade ABCD2 al enum de escalas (idempotente para CI/re-runs)
alter type scale_type add value if not exists 'abcd2';
