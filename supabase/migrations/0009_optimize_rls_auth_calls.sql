-- Migración 0009 — Optimizar llamadas a auth.uid() en políticas RLS (Fase 14.A.1)
-- Problema: auth.uid() se evalúa una vez por fila en lugar de una vez por sentencia.
-- Solución: envolver en subquery escalar (select auth.uid()) → evaluación única por stmt.
-- Impacto: reduce el overhead de RLS en tablas con muchas filas por usuario.
-- Referencia: https://supabase.com/docs/guides/database/postgres/row-level-security#call-functions-with-select

-- ── evaluations ──────────────────────────────────────────────────────────────

drop policy "select_own" on evaluations;
drop policy "insert_own" on evaluations;
drop policy "update_own" on evaluations;
drop policy "delete_own" on evaluations;

create policy "select_own" on evaluations
  for select using ((select auth.uid()) = user_id);

create policy "insert_own" on evaluations
  for insert with check ((select auth.uid()) = user_id);

create policy "update_own" on evaluations
  for update using ((select auth.uid()) = user_id);

create policy "delete_own" on evaluations
  for delete using ((select auth.uid()) = user_id);

-- ── patients ─────────────────────────────────────────────────────────────────

drop policy "select_own" on patients;
drop policy "insert_own" on patients;
drop policy "update_own" on patients;
drop policy "delete_own" on patients;

create policy "select_own" on patients
  for select using ((select auth.uid()) = user_id);

create policy "insert_own" on patients
  for insert with check ((select auth.uid()) = user_id);

create policy "update_own" on patients
  for update using ((select auth.uid()) = user_id);

create policy "delete_own" on patients
  for delete using ((select auth.uid()) = user_id);
