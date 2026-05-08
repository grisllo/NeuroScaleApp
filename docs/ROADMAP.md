# NeuroScale App — Roadmap estratégico

Documento de referencia para el equipo y para Claude Code. Refleja el estado y los objetivos de cada fase.

---

## Visión

Aplicación multiplataforma (Android, iOS, web) que permite a profesionales de la salud y estudiantes aplicar escalas neurológicas (GCS, NIHSS, Rankin, Barthel), calcular puntuaciones, interpretar resultados y registrar evaluaciones de forma anónima.

---

## Estado actual

**Proyecto completado: Fase 5** ✅ — Fase 5 completada 2026-05-05. Rediseño visual completo (design system, animaciones, colores clínicos).

**Renumeración de fases** (decisión 2026-04-28): la Fase 3 original (Algoritmos + Offline) se ha desplazado a **Fase 4**. La nueva Fase 3 (UX + Pacientes) quedó completada el 2026-04-30.

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

### Fase 2A — Historial + mRS + Barthel + ABCD2 ✅ Completada (2026-04-27)

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
- ✅ 2A.4 — mRS 0-6 (2026-04-27) — commit `2e10959`
- ✅ 2A.5 — Barthel Index 0-100 (2026-04-27) — commit `7ced22c`
- ✅ 2A.6 — ABCD2 riesgo post-AIT (2026-04-27) — commit `902594c`
- 📅 2A.3 — Gráficos fl_chart
- 📅 2A.4 — mRS 0-6
- 📅 2A.5 — Barthel Index
- 📅 2A.6 — ABCD2

**Decisiones de diseño para Fase 2A**:
- **mRS 0-6** (no 0-5): el estándar clínico actual incluye el grado 6 (fallecido). Diverge del spec original.
- **ABCD2 añadida a esta fase**: complejidad similar a Barthel (5 ítems con pesos directos, sin lógica condicional).
- **GoRouter extras codec resuelto**: `scaleType` ya pasa como tercer elemento del extra tuple en subfase 2A.1.

---

### Fase 2B — NIHSS aislada ✅ Completada (2026-04-28)

**Objetivo**: añadir la escala NIHSS con su lógica condicional.

**Entregables completados**:
- 2B.1: Dominio NIHSS — `nihss_calculator.dart` función pura, `nihss_definition.dart` 15 ítems. Soporte Untestable (UN=9) en 6 ítems (motores, ataxia, disartria): excluido del total, sentinel registrado en `itemScores`. Commit `70d2a59`.
- 2B.2: UI NIHSS — pantalla con 15 cards, opción UN en gris/cursiva, chip "UN", banner advisory al detectar coma (1a=3). Commit `f94c775`.
- `ScaleItem` extendido con campo `untestableValue` (retrocompatible).
- 27 tests: fronteras 0/1/4/5/15/16/20/21/42, UN combinado, validación por ítem, 9 en ítem no permitido.
- Total tests: 81 → 108.

**Decisión de diseño clave** (revisada durante implementación): el plan original preveía un motor de reglas de bloqueo entre ítems. La revisión del protocolo oficial NIH/AHA mostró que NIHSS no tiene bloqueo inter-ítem — solo un código Untestable (9) por ítem donde aplica. Esto simplificó el dominio y la UI sin perder corrección clínica.

---

### Fase 3 — UX shell + Modelo de Pacientes ✅ Completada (2026-04-30)

**Objetivo**: reformulación de la experiencia de usuario + introducción del concepto de paciente anonimizado.

**Motivación**: la IA original mezcla escalas e historial en la misma pantalla, la navegación no tiene tabs persistentes, y la evolución agrupa por tipo de escala en lugar de por paciente — problemas detectados en uso real.

**Subfases**:

#### 3.1 — Shell de navegación + back buttons + polish M3 ✅ Completada (2026-04-28)
Commit `6ddfe80`. Tests: 108 → 109.

#### 3.2 — Modelo de pacientes (BD + feature + integración save) ✅ Completada (2026-04-29)
Commit `c8e6845`. Tests: 109 → 118. Migración `0003_add_patients.sql` aplicada.

#### 3.3 — Patient detail con evolución + cleanup de `history/` ✅ Completada (2026-04-30)
Commit `fb55092`. Feature `history/` eliminada. `PatientEvolutionChart` con LineChart por escala.

---

### Fase 4 — Algoritmos + Offline + Perfil ✅ Completada (2026-04-30)

**Objetivo**: completar la propuesta de valor original con algoritmos clínicos y resiliencia offline.

**Subfases**:

#### 4.1 — Algoritmos clínicos (dominio + UI) ✅ Completada (2026-04-30)
Commits `884ff0c` (dominio + 47 tests) + `01846f7` (UI: tab Algoritmos + pantalla paso a paso).
Tests: 118 → 165. Tres algoritmos: Código Ictus tPA, HTA en Ictus Agudo, HSA Hunt-Hess/Fisher.

#### 4.2 — Modo offline ✅ Completada (2026-04-30)
Commit `14a2b31`. `AppDatabase` (drift 2.22.1) con tablas `evaluations` + `patients`. Cache-aside en repositorios: remote-first → SQLite local como fallback. Sin cambios en UI.

#### 4.3 — Multilenguaje (EN) ✅ Completada (2026-04-30)
Commit `b025b43`. `app_en.arb` con ~300 claves. `localeProvider` con persistencia en SharedPreferences. `MaterialApp.router` usa locale dinámico.

#### 4.4 — Pantalla de perfil ✅ Completada (2026-04-30)
Commit `ea1a77c`. Tab Perfil: email (solo lectura), `SegmentedButton` ES/EN, botón logout. Logout eliminado del AppBar de escalas.

Issue #13.

---

### Fase 5 — Design System & UX visual ✅ Completada (2026-05-05)

**Objetivo**: rediseño completo del sistema visual con paleta médica, tipografía profesional y animaciones sutiles que no distraigan en contexto clínico.

**Entregables**:
- `core/theme/app_colors.dart`: paleta teal médica desaturada (`#0F6F8A`), superficies neutras cálidas, semánticos clínicos (success/warning/danger/info) con par fg+surface
- `core/theme/app_typography.dart`: Inter vía `google_fonts`, escala 12–48, pesos 400/500/600/700
- `core/theme/app_spacing.dart`, `app_radii.dart`, `app_motion.dart`: tokens 4pt spacing, radios 8–24, duraciones 100–600ms con curvas Material 3
- `core/theme/clinical_colors.dart`: `ThemeExtension` que expone colores semánticos clínicos desde cualquier widget; elimina `Colors.red.shade700` hardcodeado en `ResultScreen`
- `core/theme/app_theme.dart` refactorizado: Card (borde 1px + r16, 0 elevation), Input (filled r12, focus 1.5px), Button (r12, h48), NavigationBar (h68), Dialog (r24), SnackBar flotante oscuro
- `core/widgets/animated_score.dart`: contador TweenAnimationBuilder 0→resultado (600ms, ease-out)
- `core/widgets/severity_badge.dart` + `SeverityDot`: chip clínico con surface tonal, entrada animada 240ms
- `core/widgets/app_empty_state.dart`: empty state con fade+scale 320ms
- `core/widgets/app_loading_skeleton.dart`: shimmer placeholder para listas >300ms
- Pantallas actualizadas: `ScalesTabScreen`, `PatientsTabScreen`, `ResultScreen`, `LoginScreen` (FadeTransition + SlideTransition en entrada)
- Hover restaurado en cards mediante `InkWell` dentro del `Card` (compatibilidad web/desktop)

**Commits**:
- `b16f6cf` — design system foundation (Inter, paleta, motion tokens)
- `117d1f4` — shared animation widgets
- `c1b4608` — apply design system to key screens
- `e68975b` — fix(ui): restore hover highlight on cards

**Tests**: 165 (sin cambios en dominio — únicamente UI).

---

### Fase 6.1 — Seguridad y release ✅ Completada (2026-05-08)

**Objetivo**: cerrar los gaps de seguridad bloqueantes detectados en la auditoría completa de Fase 5: firma de release Android, validación de PII en `case_description`, vigilancia de CVEs en CI.

**Entregables**:
- `android/app/build.gradle`: `signingConfigs.release` cargado desde `key.properties` (gitignored), con fallback a debug + warning si no existe. Activado `minifyEnabled` + `shrinkResources` con `proguard-rules.pro` para Flutter, Sentry y Kotlin metadata.
- `android/key.example.properties` + `android/README.md` con instrucciones de generación del keystore (`keytool`).
- `lib/core/utils/pii_detector.dart`: detector puro de DNI/NIE/email/teléfono ES/fecha (con año explícito). 18 tests boundary cubren positivos y falsos positivos típicos (códigos paciente, edades, siglas médicas).
- `result_screen.dart`: `validator` + `maxLength: 500` en `case_description`; bloquea el guardado y muestra el tipo de PII detectado.
- `supabase/migrations/0004_constrain_case_description.sql`: `CHECK (length ≤ 500)` server-side como segunda capa.
- `supabase/README.md` con orden de migraciones y convenciones.
- `.github/workflows/ci.yaml`: nuevo job `vulnerability-scan` con `osv-scanner` sobre `pubspec.lock`.
- `.gitignore`: keystore (`*.jks`, `*.keystore`) y `android/key.properties`.

**Decisión aplazada**: certificate pinning Supabase — ver sección _Decisiones técnicas aplazadas_.

**Tests**: 165 + 18 nuevos del `PiiDetector` = **183**.

---

### Fase 6.2 — Optimización backend y rebuilds ✅ Completada (2026-05-08)

**Objetivo**: eliminar queries pesados, retención de memoria innecesaria y rebuilds de UI sobredimensionados detectados en la auditoría.

**Entregables**:
- `lib/core/constants/app_constants.dart`: constante `kEvaluationsPageSize = 20` compartida entre las 4 capas que antes duplicaban el literal.
- `supabase_evaluation_datasource.dart`: `select()` con columnas explícitas — excluye `detailed_scores` (JSONB) y `case_description` de los listados de historial.
- `EvaluationModel.fromJson()`: null-safe en `detailedScores` y `caseDescription` para soportar select parcial.
- `supabase_patient_datasource.dart`: columnas explícitas en `fetchAll()` y `findById()`.
- 5 providers de escalas (GCS, NIHSS, mRS, Barthel, ABCD2): `NotifierProvider` → `NotifierProvider.autoDispose` — estado liberado al salir de la pantalla.
- `ScalesTabScreen`: de `ConsumerWidget` a `StatelessWidget`; `sessionProvider` movido a `Consumer` granular que solo reconstruye el `Text` del email.
- `supabase/migrations/0005_add_scale_type_index.sql`: índice compuesto `(user_id, scale_type, created_at DESC)` aplicado en producción.

**Tests**: 183 (sin cambios — optimizaciones de infraestructura, no lógica de dominio).

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

## Decisiones técnicas aplazadas

**Certificate pinning Supabase** (revisado 2026-05-08, Fase 6.1): aplazado a Fase 7+ o cuando se requiera certificación clínica (HIPAA / ISO 13485). Razón: Supabase rota certificados LetsEncrypt cada ~60 días; un pin caducado dejaría la app inservible para todos los usuarios hasta que se publique un hotfix. El ROI actual no compensa el riesgo operacional.

---

## Documentos relacionados

- `CLAUDE.md` — instrucciones para Claude Code (stack, comandos, convenciones).
- `~/.claude/plans/wild-imagining-creek.md` — detalle táctico de la fase activa (fuera del repo, se sobreescribe cada fase).
- `supabase/migrations/` — migraciones SQL numeradas.
- `.github/workflows/ci.yaml` — pipeline de CI.
