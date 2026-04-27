# NeuroScale App — Roadmap estratégico

Documento de referencia para el equipo y para Claude Code. Refleja el estado y los objetivos de cada fase.

---

## Visión

Aplicación multiplataforma (Android, iOS, web) que permite a profesionales de la salud y estudiantes aplicar escalas neurológicas (GCS, NIHSS, Rankin, Barthel), calcular puntuaciones, interpretar resultados y registrar evaluaciones de forma anónima.

---

## Estado actual

**Fase activa: Fase 2A** — iniciada 2026-04-27.

---

## Fases

### Fase 0 — Bootstrap ✅ Completada (2026-04-26)

**Objetivo**: esqueleto productivo listo para implementar features.

**Entregables completados**:
- `flutter create` con org `com.neuroscale`, plataformas android/ios/web.
- Estructura `lib/features/` feature-first (auth, scales, evaluations, history).
- `core/` con theme (Material 3), routing (go_router), env (--dart-define-from-file), errors (sealed Failure + AppException).
- i18n: `l10n.yaml` + `app_es.arb` + `AppLocalizations` generado.
- Inicio condicional de Supabase y Sentry (app arranca sin credenciales).
- `analysis_options.yaml` estricto + `riverpod_lint`.
- CI: `.github/workflows/ci.yaml` con format check, analyze y test.
- `.claude/settings.json` con permissions válidas + skill `create-scale`.
- `CLAUDE.md` con stack, comandos y convenciones.

---

### Fase 1 — MVP: Auth + GCS + Guardado ✅ Completada (2026-04-27)

**Objetivo end-to-end**: un médico se registra, calcula un GCS, ve el resultado interpretado con disclaimer médico y guarda la evaluación de forma anonimizada.

**Entregables**:
- SQL migration (`evaluations` con enum `scale_type`, RLS de 4 políticas).
- Feature `auth`: login/register con Supabase, auth guard en el router, disclaimer de primer arranque.
- Feature `scales/shared`: entidades base (ScaleItem, ScaleResult, Severity, ScaleDefinition).
- Feature `scales/gcs`: calculadora pura con tests de frontera exhaustivos + pantalla de escala + pantalla de resultado.
- Feature `evaluations`: guardado en Supabase con `case_description` libre y warning anti-PII.
- i18n completa para todas las pantallas de Fase 1.
- Tests: calculadora GCS (fronteras), usecases auth, usecase guardar evaluación.

**Criterios de aceptación**:
- `flutter analyze` 0 issues.
- `flutter test` 100% pasando.
- Flujo manual completo: `/disclaimer` → `/login` → `/` → `/scales/gcs` → resultado → guardar.
- Fila en Supabase `evaluations` después de guardar.
- RLS verificado: usuario B no ve evaluaciones de usuario A.

**Decisiones de diseño para Fase 1**:
- No `Either<L,R>` — repositorios lanzan `Failure` directamente (simplifica MVP).
- `AppUser` (no `User`) para evitar colisión de nombres con supabase_flutter.
- `case_description` no puede ser PII — se muestra warning pero no bloquea técnicamente.
- Email confirm deshabilitado para dev, habilitado para producción.

---

### Fase 2A — Historial + mRS + Barthel + ABCD2 🚧 En curso

**Objetivo**: el usuario puede ver su historial de evaluaciones, filtrar y ver gráficos de evolución. Se añaden tres escalas sencillas.

**Entregables**:
- Feature `history`: lista de evaluaciones, filtros por escala/fecha, búsqueda por `case_description`.
- Gráficos de evolución temporal con `fl_chart` (línea por escala).
- Escala **mRS** (Modified Rankin Scale 0-6, incluye 6 = fallecido) con tests.
- Escala **Barthel** (10 ítems, suma 0-100) con tests.
- Escala **ABCD2** (0-7, estratificación de riesgo post-AIT) con tests. Requiere migración `0002_add_abcd2.sql`.
- Ruta `/history` con UI real (reemplaza `_PlaceholderScreen`).
- Paginación scroll infinito.

**Progreso de subfases**:
- ✅ 2A.1 — Refactor ResultScreen + feature History básica (2026-04-27) — commit `4c1706a`
- ✅ 2A.2 — Filtros, búsqueda y paginación (2026-04-27) — commit `c822d01`
- ✅ 2A.3 — Gráficos de evolución fl_chart (2026-04-27) — commit `6cde524`
- 🚧 2A.4 — mRS 0-6
- 📅 2A.3 — Gráficos fl_chart
- 📅 2A.4 — mRS 0-6
- 📅 2A.5 — Barthel Index
- 📅 2A.6 — ABCD2

**Decisiones de diseño para Fase 2A**:
- **mRS 0-6** (no 0-5): el estándar clínico actual incluye el grado 6 (fallecido). Diverge del spec original.
- **ABCD2 añadida a esta fase**: complejidad similar a Barthel (5 ítems con pesos directos, sin lógica condicional).
- **GoRouter extras codec resuelto**: `scaleType` ya pasa como tercer elemento del extra tuple en subfase 2A.1.

---

### Fase 2B — NIHSS aislada 📅 Planificada

**Objetivo**: añadir la escala NIHSS con su lógica condicional compleja.

**Nota de diseño**: NIHSS se separa de Fase 2A por su complejidad. Tiene 15 ítems con reglas condicionales (paciente intubado → ítem 9 no aplica; comatoso bloquea ítems de nivel superior, etc.). Requiere:
- Reglas de bloqueo entre ítems.
- UI dinámica que muestra/oculta ítems según respuestas anteriores.
- Tests exhaustivos por ítem Y por combinaciones de reglas.
- Validación de combinaciones imposibles.

---

### Fase 3 — Algoritmos + Offline + Perfil 📅 Planificada (alcance flexible)

**Objetivo**: completar la propuesta de valor original con algoritmos clínicos y resiliencia offline.

**Entregables candidatos** (se priorizan según feedback de usuarios reales de Fase 1):
- Algoritmos diagnósticos/terapéuticos: árbol decisional con la misma separación lógica/UI que las escalas.
- Modo offline: datasource local (`drift`) detrás del repositorio existente — UI sin cambios.
- Multilenguaje: añadir `app_en.arb` (las strings ya están externalizadas desde Fase 0).
- Pantalla de perfil de usuario.
- Tabla `patients` (si el feedback de Fase 1 demuestra necesidad real — evitar añadir PII sin demanda probada).

---

## Decisiones arquitectónicas clave

| Decisión | Justificación |
|---|---|
| Feature-first + Clean Architecture | Escala mejor que layer-first al añadir features; la cohesión es por dominio |
| Riverpod (`AsyncNotifier`/`Notifier`) | Estado reactivo sin boilerplate excesivo; integra bien con go_router |
| `go_router` | Rutas declarativas, deep linking, auth guard con `redirect` |
| Supabase | Auth + PostgreSQL + RLS sin servidor dedicado; free tier suficiente para MVP |
| i18n desde MVP (`intl` + `.arb`) | Añadir i18n post-hoc cuesta semanas; desde el inicio cuesta un día |
| Calculadoras de escala como funciones puras | Cero dependencias Flutter/Supabase → tests triviales; lógica clínica desacoplada de UI |
| No `Either<L,R>` en MVP | Simplifica el código; se puede añadir en refactor posterior si la escala lo exige |
| `env/dev.json` gitignoreado + `--dart-define-from-file` | Secretos fuera del repo; funciona en web/CI sin `flutter_dotenv` |
| RLS en todas las tablas | Defensa en profundidad; el frontend solo puede ver sus propios datos |
| Sentry para error tracking | Captura crashes con stacktrace; free tier suficiente para dev+beta |
| CI desde día 1 | `flutter analyze` + `flutter test` bloquea PRs con regresiones |

---

## Reglas de negocio no negociables

1. **Sin PII**: `case_description` es texto libre pero el usuario recibe warning. Nunca almacenar nombre real, DNI o datos identificativos.
2. **Disclaimer médico siempre visible**: en `ResultScreen` no se puede ocultar. La app es herramienta de apoyo, no diagnóstico.
3. **Lógica clínica en `domain/`**: los calculadores son funciones puras con tests de todos los umbrales. Un cálculo incorrecto puede tener consecuencias clínicas.
4. **RLS activado en todas las tablas de Supabase**.
5. **`flutter analyze` debe pasar en 0 issues antes de cada commit**.

---

## Estructura de referencia

```
lib/
├── core/            theme, routing, env, errors, utils
├── features/
│   ├── auth/        data/  domain/  presentation/
│   ├── scales/
│   │   ├── shared/  entidades base (ScaleItem, ScaleResult, Severity)
│   │   ├── gcs/
│   │   ├── nihss/   (Fase 2B)
│   │   ├── rankin/  (Fase 2A — mRS 0-6)
│   │   ├── barthel/ (Fase 2A)
│   │   └── abcd2/   (Fase 2A)
│   ├── evaluations/ data/  domain/  presentation/
│   └── history/     (Fase 2A)
└── l10n/            app_es.arb  →  generated/app_localizations.dart
```

---

## Documentos relacionados

- `CLAUDE.md` — instrucciones para Claude Code (stack, comandos, convenciones).
- `~/.claude/plans/wild-imagining-creek.md` — detalle táctico de la fase activa (fuera del repo, se sobreescribe cada fase).
- `supabase/migrations/` — migraciones SQL numeradas.
- `.github/workflows/ci.yaml` — pipeline de CI.
