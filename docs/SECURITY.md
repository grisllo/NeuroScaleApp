# Security — NeuroScale App

## Modelo de seguridad

NeuroScale es una herramienta de apoyo clínico. **No almacena datos identificativos de pacientes** (PII). El modelo de seguridad prioriza:

1. **Confidencialidad de datos**: RLS en Supabase garantiza que cada usuario solo accede a sus propios datos.
2. **Ausencia de PII**: el campo `case_description` tiene validación en la UI que bloquea el guardado si detecta DNI o emails.
3. **Autenticación robusta**: contraseñas mínimo 8 caracteres con letras y números. Leaked Password Protection requiere plan Supabase Pro (no disponible en plan gratuito).

---

## Row Level Security (RLS)

Todas las tablas tienen RLS habilitado. Las políticas usan `(select auth.uid())` (evaluación una vez por sentencia, no por fila) para minimizar overhead:

```sql
-- evaluations
create policy "select_own" on evaluations
  for select using ((select auth.uid()) = user_id);

-- patients (igual)
create policy "select_own" on patients
  for select using ((select auth.uid()) = user_id);
```

Migrations: `0001_init.sql`, `0003_add_patients.sql`, `0009_optimize_rls_auth_calls.sql`.

## Gestión de PII

- `alias` de paciente: identificador libre elegido por el médico (ej. "P-001"). **Nunca** nombre real.
- `case_description` / `notes`: texto libre. La UI detecta y bloquea guardado si encuentra patrones de DNI español (`\d{8}[A-Z]`) o email.
- El detector está en `lib/core/utils/pii_detector.dart` con tests exhaustivos en `test/core/utils/pii_detector_test.dart`.

## Secrets y configuración

- Las credenciales (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SENTRY_DSN`) se pasan mediante `--dart-define-from-file` en tiempo de build.
- Nunca se incluyen en el repositorio. El fichero `env/dev.json` está en `.gitignore`.
- En producción se configuran como GitHub Actions secrets.

La clase `Env` en `lib/core/env/env.dart` limpia caracteres BOM y sufijos `/rest/v1` de la URL para prevenir errores silenciosos en producción.

## Sesiones y autenticación

- Supabase Auth gestiona sesiones con JWT. Los tokens se almacenan en `SharedPreferences` de forma segura por el SDK de Supabase.
- El guard de autenticación en `go_router` redirige usuarios no autenticados al login.
- La pantalla de cambio de contraseña revalida la contraseña actual antes de actualizar.

## Sentry (error tracking)

El filtro `beforeSend` en `lib/main.dart` descarta eventos Sentry que contengan patrones de email o DNI en los stack traces, para evitar filtración accidental de PII en el sistema de error tracking.

## Reporte de vulnerabilidades

Si encuentras una vulnerabilidad de seguridad, reporta vía [GitHub Issues](https://github.com/grisllo/NeuroScaleApp/issues) marcando el issue como **confidencial** o contacta directamente al mantenedor.

**No uses el tracker público para vulnerabilidades críticas** — envía un email privado al mantenedor antes de la divulgación pública.
