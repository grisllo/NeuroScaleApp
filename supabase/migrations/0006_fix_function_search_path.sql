-- Corrige search_path mutable en handle_updated_at (security advisor WARN)
-- Un search_path no fijo permite ataques de schema injection desde funciones
-- que invocan este trigger. Fijar a 'public' elimina la vulnerabilidad.
alter function public.handle_updated_at() set search_path = public;
