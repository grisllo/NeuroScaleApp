# Modelo de seguridad — NeuroScale App

Este documento describe los controles de seguridad aplicados a NeuroScale App: aislamiento de datos, prevención de PII, gestión de secretos, sesiones, observabilidad y canal de reporte de vulnerabilidades.

---

## 1. Modelo de seguridad

NeuroScale App es una **herramienta de apoyo clínico** que no almacena datos identificativos de pacientes (PII). El modelo de seguridad prioriza, por orden:

1. **Confidencialidad por usuario**. Las políticas Row Level Security (RLS) de Supabase garantizan que cada usuario solo acceda a sus propios datos.
2. **Prevención de PII en datos libres**. El campo `case_description` (y el equivalente `notes` en pacientes) pasa por un detector cliente que bloquea el guardado si encuentra DNI, NIE, email, teléfono o fecha de nacimiento.
3. **Autenticación robusta**. Contraseñas con un mínimo de 8 caracteres, normalización de email, sesiones gestionadas por Supabase Auth. La protección de contraseñas filtradas (Leaked Password Protection) requiere plan Supabase Pro y, por tanto, no está disponible en el plan gratuito actual.
4. **Minimización de errores observables**. Sentry está integrado con un filtro `beforeSend` que descarta eventos cuyos `stack traces` contienen patrones de PII.

---

## 2. Row Level Security (RLS)

Todas las tablas de aplicación tienen RLS habilitado. Las cuatro operaciones (SELECT / INSERT / UPDATE / DELETE) están restringidas al `auth.uid()` que coincida con el `user_id` de la fila. La migración [`0009_optimize_rls_auth_calls.sql`](../supabase/migrations/0009_optimize_rls_auth_calls.sql) envuelve `auth.uid()` en una subquery escalar para que se evalúe **una vez por sentencia** en lugar de una vez por fila.

### Resumen de políticas activas

| Tabla | Política | Operación | Condición |
|---|---|---|---|
| `evaluations` | `select_own` | SELECT | `(select auth.uid()) = user_id` |
| `evaluations` | `insert_own` | INSERT | `(select auth.uid()) = user_id` |
| `evaluations` | `update_own` | UPDATE | `(select auth.uid()) = user_id` |
| `evaluations` | `delete_own` | DELETE | `(select auth.uid()) = user_id` |
| `patients` | `select_own` | SELECT | `(select auth.uid()) = user_id` |
| `patients` | `insert_own` | INSERT | `(select auth.uid()) = user_id` |
| `patients` | `update_own` | UPDATE | `(select auth.uid()) = user_id` |
| `patients` | `delete_own` | DELETE | `(select auth.uid()) = user_id` |

Total: **8 políticas activas** (cuatro por tabla, dos tablas).

### Ejemplo canónico

```sql
create policy "select_own" on evaluations
  for select using ((select auth.uid()) = user_id);
```

> Nota: el frontend nunca filtra por `user_id` explícitamente — confía en que la RLS aplique el filtro a nivel de base de datos. Esto garantiza que un error en el cliente nunca pueda exponer datos ajenos.

---

## 3. Gestión de PII

NeuroScale App utiliza dos campos de texto libre que un usuario podría rellenar con datos identificativos por descuido:

- `patients.alias` — identificador clínico libre (por ejemplo, `P-001`). Nunca debe contener el nombre real del paciente.
- `evaluations.case_description` y `patients.notes` — descripción anonimizada del caso o notas clínicas.

Para impedirlo, el módulo [`lib/core/utils/pii_detector.dart`](../lib/core/utils/pii_detector.dart) actúa como detector cliente. Si encuentra un patrón, la UI bloquea el guardado y muestra al usuario el tipo de PII detectado.

### Patrones detectados

| Tipo | Expresión regular | Acepta como PII | Rechaza (no PII) |
|---|---|---|---|
| DNI español | `\b\d{8}[\s\-]?[A-HJ-NP-TV-Z]\b` | `12345678A`, `12345678 A`, `12345678-A` | `12345678` (sin letra), `1234567A` (siete dígitos) |
| NIE | `\b[XYZ]\d{7}[\s\-]?[A-HJ-NP-TV-Z]\b` | `X1234567A`, `Y1234567-A` | `W1234567A` (prefijo inválido) |
| Email | `\b[\w.+-]+@[\w-]+\.[\w.-]+\b` | `juan.perez@example.com` | `no-arroba`, `usuario@` (sin dominio) |
| Teléfono ES | `\b[6-9]\d{8}\b` | `612345678`, `911234567` | `512345678` (no empieza por 6-9) |
| Fecha de nacimiento | `\b\d{1,2}[/\-.]\d{1,2}[/\-.](?:19\|20)\d{2}\b` | `15/03/1985`, `15-3-2020` | `15/03/85` (año ambiguo), `hace 3 días` |

La defensa en profundidad se completa con un `CHECK (length(case_description) <= 500)` en PostgreSQL (migración [`0004_constrain_case_description.sql`](../supabase/migrations/0004_constrain_case_description.sql)), que actúa como límite duro independientemente del cliente.

---

## 4. Filtro PII en Sentry

El SDK de Sentry se inicializa de forma condicional en [`lib/main.dart`](../lib/main.dart). El callback `beforeSend` inspecciona la representación textual del evento y lo descarta cuando detecta patrones de email o DNI, evitando la fuga accidental de PII al sistema de error tracking.

```dart
options.beforeSend = (event, hint) {
  final raw = event.toString();
  final hasPii =
      RegExp(
        r'[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}',
      ).hasMatch(raw) ||
      RegExp(r'\b\d{8}[A-HJ-NP-TV-Z]\b').hasMatch(raw);
  return hasPii ? null : event;
};
```

> Limitación conocida: el filtro cubre los dos patrones más probables (email y DNI). NIE, teléfono y fechas se basan en la detección cliente del propio `PiiDetector` durante la captura.

---

## 5. Secretos y configuración de entorno

Las credenciales sensibles se inyectan en tiempo de build mediante `--dart-define-from-file`:

| Variable | Origen local | Origen CI/CD |
|---|---|---|
| `SUPABASE_URL` | `env/dev.json` (gitignored) | Secret de GitHub Actions |
| `SUPABASE_ANON_KEY` | `env/dev.json` | Secret de GitHub Actions |
| `SUPABASE_REDIRECT_URL` | `env/dev.json` | Secret de GitHub Actions |
| `SENTRY_DSN` | `env/dev.json` (opcional) | Secret de GitHub Actions |
| `FLAVOR` | `env/dev.json` (`dev` o `prod`) | Hardcodeado a `prod` en el workflow de deploy |

El fichero `env/dev.example.json` documenta el formato sin contener valores reales y sí está versionado.

La clase [`lib/core/env/env.dart`](../lib/core/env/env.dart) sanitiza la URL antes de inicializar Supabase: elimina el byte order mark (U+FEFF) y un eventual sufijo `/rest/v1`, fuente de bugs silenciosos detectados en producción durante la Fase 13.

---

## 6. Autenticación y gestión de sesiones

```mermaid
flowchart TD
    A[Usuario abre la app] --> B{Disclaimer aceptado?}
    B -- No --> C[/disclaimer]
    B -- Sí --> D{Sesión activa?}
    D -- No --> E[/login]
    D -- Sí --> F[App protegida]

    E --> G{Tiene cuenta?}
    G -- No --> H[/register]
    G -- Sí --> I[Sign-in Supabase]
    H --> J[Sign-up Supabase]

    I -- éxito --> F
    J -- éxito --> F
    J -- email pending --> K[Mostrar mensaje de confirmación]

    E -.-> L[¿Contraseña olvidada?]
    L --> M[/forgot-password]
    M --> N[Email con magic link]
    N --> O[Evento PASSWORD_RECOVERY]
    O --> P[/reset-password]
    P --> F

    F --> Q[Profile: borrar cuenta]
    Q --> R[Edge Function delete-account]
    R --> S[Auth.admin.deleteUser]
    S --> T[Datos eliminados por CASCADE]
```

Aspectos relevantes:

- Supabase Auth gestiona las sesiones con JWT. El SDK almacena el token de forma segura en `SharedPreferences` con cifrado de plataforma cuando está disponible.
- El guard de [`go_router`](../lib/core/routing/app_router.dart) redirige al usuario no autenticado a `/login` y al usuario en flujo de recuperación a `/reset-password`.
- El cambio de contraseña en `/profile` revalida la contraseña actual antes de actualizar.
- El email se normaliza a minúsculas antes de enviar a Supabase (evita duplicidades).

---

## 7. Edge Function `delete-account`

El borrado de cuenta requiere privilegios de administrador (`service_role`), por lo que no puede ejecutarse desde el cliente. Se delega en una Edge Function de Supabase publicada en [`supabase/functions/delete-account/index.ts`](../supabase/functions/delete-account/index.ts).

El flujo es el siguiente:

1. El cliente invoca la función enviando el JWT del usuario en la cabecera `Authorization`.
2. La función verifica la identidad con un cliente Supabase configurado con `anon_key` y el JWT.
3. Una vez identificado el usuario, se crea un segundo cliente con `service_role_key` (variable de entorno de la función, nunca expuesta al cliente).
4. Se invoca `auth.admin.deleteUser(user.id)`. La migración [`0007_cascade_delete_patient_evaluations.sql`](../supabase/migrations/0007_cascade_delete_patient_evaluations.sql) garantiza el borrado en cascada de pacientes y evaluaciones asociadas.

La función está configurada con `verify_jwt: true` en `supabase/config.toml`, lo que añade una validación adicional del JWT antes incluso de ejecutar el código.

---

## 8. Reporte de vulnerabilidades

Si detectas una vulnerabilidad de seguridad **no la publiques en el tracker público de issues**.

- **Vulnerabilidades críticas** (RCE, exfiltración de datos, bypass de RLS, exposición de secretos): contacto privado directo al mantenedor por correo electrónico.
- **Vulnerabilidades menores** (fortalecimiento de cabeceras HTTP, mejoras de validación, dependencias con CVE de baja severidad): pueden reportarse mediante issue público con la etiqueta `security`.

**Contacto del mantenedor**: Arturo Ramos Reparaz — `arturo.ramos.reparaz@gmail.com`.

Se compromete una respuesta inicial en un plazo razonable y la divulgación coordinada una vez aplicada la corrección.

---

## 9. Documentos relacionados

- [`../supabase/README.md`](../supabase/README.md) — migraciones SQL.
- [`RELEASE_GUIDE.md`](RELEASE_GUIDE.md) — gestión de secretos en CI/CD.
- [`../android/README.md`](../android/README.md) — gestión del keystore de release Android.
