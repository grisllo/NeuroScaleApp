# NeuroScale App — Roadmap estratégico

Documento de referencia que recopila el estado, los objetivos y las decisiones de cada fase del proyecto. Sirve de fuente única de verdad para el equipo de desarrollo y para el agente Claude Code.

---

## Tabla de contenidos

- [Visión](#visión)
- [Estado actual](#estado-actual)
- [Fases](#fases)
  - [Fase 0 — Bootstrap](#fase-0--bootstrap--completada-2026-04-26)
  - [Fase 1 — MVP: Auth + GCS + Guardado](#fase-1--mvp-auth--gcs--guardado--completada-2026-04-27)
  - [Fase 2A — Historial + mRS + Barthel + ABCD2](#fase-2a--historial--mrs--barthel--abcd2--completada-2026-04-27)
  - [Fase 2B — NIHSS aislada](#fase-2b--nihss-aislada--completada-2026-04-28)
  - [Fase 3 — UX shell + Modelo de Pacientes](#fase-3--ux-shell--modelo-de-pacientes--completada-2026-04-30)
  - [Fase 4 — Algoritmos + Offline + Perfil](#fase-4--algoritmos--offline--perfil--completada-2026-04-30)
  - [Fase 5 — Design System & UX visual](#fase-5--design-system--ux-visual--completada-2026-05-05)
  - [Fase 6 — Saneamiento técnico](#fase-6--saneamiento-técnico--completada-2026-05-08)
  - [Fase 7 — Features de producto](#fase-7--features-de-producto--completada-2026-05-08)
  - [Fase 8 — Mantenimiento y calidad post-product](#fase-8--mantenimiento-y-calidad-post-product--completada-2026-05-09)
  - [Fase 9 — Preparación Beta](#fase-9--preparación-beta--completada-2026-05-09)
  - [Fase 10 — Polish & Optimización](#fase-10--polish--optimización--completada-2026-05-12)
  - [Fase 11 — UX Visual](#fase-11--ux-visual--completada-2026-05-12)
  - [Fase 12 — Animaciones](#fase-12--animaciones--completada-2026-05-12)
  - [Fase 13 — Fixes UX evaluaciones](#fase-13--fixes-ux-evaluaciones--completada-2026-05-13)
  - [Fase 14 — Auditoría y producción v1.0.0](#fase-14--auditoría-y-producción-v100--completada-2026-05-13)
- [Mantenimiento post-v1.0.0](#mantenimiento-post-v100-2026-05-14)
- [Decisiones arquitectónicas clave](#decisiones-arquitectónicas-clave)
- [Reglas de negocio no negociables](#reglas-de-negocio-no-negociables)
- [Estructura de referencia](#estructura-de-referencia)
- [Deuda técnica y mejoras aplazadas](#deuda-técnica-y-mejoras-aplazadas)
- [Documentos relacionados](#documentos-relacionados)

---

## Visión

Aplicación multiplataforma (Android, iOS, web) que permite a profesionales de la salud y estudiantes aplicar escalas neurológicas estandarizadas (GCS, NIHSS, mRS, Barthel, ABCD2), calcular puntuaciones, interpretar resultados clínicos y registrar evaluaciones de forma anonimizada por paciente.

---

## Estado actual

**Último hito**: Fase 14 — Auditoría y producción v1.0.0 ✅ — Completada el 2026-05-13. Tag `v1.0.0` publicado en GitHub. **204 tests** verdes, `flutter analyze` en 0 issues, ~83 h acumuladas (incluyendo el mantenimiento post-v1.0.0). Producción web: <https://grisllo.github.io/NeuroScaleApp/>.

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

### Fase 6 — Saneamiento técnico ✅ Completada (2026-05-08)

#### 6.1 — Seguridad y release ✅

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

#### 6.2 — Optimización backend y rebuilds ✅

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

#### 6.3 — Refactor i18n + arquitectura ✅

**Objetivo**: cerrar deuda de i18n (títulos hardcodeados), mejorar mantenibilidad del resolutor de claves de escala y documentar el contrato arquitectónico de repositorios.

**Entregables**:
- 5 pantallas de escala (GCS, NIHSS, mRS, Barthel, ABCD2): AppBar `title` pasa de hardcode inglés a `l10n.xTitle`. Las claves ARB ya existían.
- `lib/core/extensions/scale_key_resolver.dart`: switch de 197 cases → `Map<String, String Function(AppLocalizations)>` estático con `assert` en fallback (captura claves faltantes en debug, fallback seguro en release).
- `CLAUDE.md`: contrato de repositorios clarificado — `throws Failure`, no `Either<L,R>`. Decisión documentada con justificación.

**Tests**: 183 (sin cambios — refactor puro, sin lógica de dominio nueva).

---

#### 6.4 — Rendimiento web + tests + a11y ✅

**Objetivo**: cerrar el bloque de saneamiento técnico con mejoras de rendimiento web, cobertura de widget tests y accesibilidad básica.

**Entregables**:
- `lib/main.dart`: `GoogleFonts.config.allowRuntimeFetching = false` — Inter se bundlea en el artefacto web, sin fetch a `fonts.gstatic.com` en cold start.
- `lib/core/widgets/animated_score.dart`: `Semantics(label: '$score de $maxScore')` en ambas rutas (con y sin animación) para TalkBack/VoiceOver.
- `lib/features/evaluations/presentation/screens/result_screen.dart`: `RepaintBoundary` alrededor de `AnimatedScore`; icono decorativo info_outline envuelto en `ExcludeSemantics`; bloque disclaimer con `Semantics(container: true, label: ...)`.
- `test/widget_test.dart`: 4 nuevos widget tests — `ResultScreen` (puntuación + guardar), `ResultScreen` (disclaimer), `ScalesTabScreen` (5 cards), `GcsScaleScreen` (ítems + reset).

**Tests**: 183 → **187** (+4 widget tests de pantallas complejas).

---

### Fase 7 — Features de producto ✅ Completada (2026-05-08)

#### 7.1 — Indicador visual de modo sin conexión ✅

**Objetivo**: dar feedback visual inmediato al usuario cuando el dispositivo pierde conectividad.

**Entregables**:
- `pubspec.yaml`: dependencia `connectivity_plus: ^6.1.1`.
- `lib/core/providers/connectivity_provider.dart`: `connectivityStreamProvider` + `isOfflineProvider` (true cuando todas las interfaces = none).
- `lib/core/widgets/offline_banner.dart`: banner `errorContainer` con icono `wifi_off_rounded` y texto `l10n.offlineBannerMessage`. SafeArea top.
- `lib/core/routing/app_shell.dart`: migrado a `ConsumerWidget`; banner con `AnimatedSize` encima del `navigationShell`.
- `app_es.arb` + `app_en.arb`: clave `offlineBannerMessage`.

**Tests**: 187 (sin cambios — conectividad es test de integración).

---

#### 7.2 — Web/tablet responsive ✅

**Objetivo**: adaptar el shell de navegación y las pantallas principales para tablet (≥600px) y desktop (≥1024px), priorizando el layout 2 columnas en la pantalla de detalle de paciente.

**Entregables**:
- `lib/core/utils/breakpoints.dart`: `Breakpoints.tablet` (600px) y `Breakpoints.desktop` (1024px).
- `lib/core/widgets/responsive_container.dart`: centra contenido con max-width 800px/960px.
- `AppShell`: `NavigationBar` (mobile) → `NavigationRail` compacto (tablet) → extendido (desktop).
- `ScalesTabScreen`: `GridView.count(2 cols, ratio 3.0)` en tablet + `ConstrainedBox(800px)`.
- `PatientsTabScreen`: `ConstrainedBox(800px)` en tablet.
- `PatientDetailScreen`: 2 columnas en tablet (lista 380px + gráfico); `DefaultTabController` en mobile.
- `AlgorithmsTabScreen` + `ProfileScreen`: `ConstrainedBox(800px)` en tablet.

**Tests**: 187 (sin cambios de dominio; widget test de navegación actualizado).

---

#### 7.3 — Modo tutorial: botón "?" por ítem ✅

**Objetivo**: añadir explicación clínica + referencia bibliográfica por ítem en GCS, NIHSS, Barthel y ABCD2, accesible mediante un botón `?` discreto sin interrumpir el flujo de evaluación.

**Entregables**:
- `ScaleItem.helpKey` (campo opcional): apunta a la clave ARB de la descripción clínica; cuando es null no aparece botón.
- 4 definiciones actualizadas: GCS (3 claves), NIHSS (15), Barthel (10), ABCD2 (5). mRS excluida deliberadamente.
- `lib/core/widgets/scale_item_help_button.dart`: botón `?` (IconButton 32px) + `DraggableScrollableSheet` con drag handle, título del ítem, descripción clínica y referencia en `Container` `surfaceContainerHighest`.
- 4 scale screens (`_ScaleItemCard`, `_NihssItemCard`, `_BarthelItemCard`, `_Abcd2ItemCard`): botón `?` entre el label y el chip de puntuación.
- 33 claves `*Help` en ES + 33 en EN + `tutorialButtonTooltip` (68 entradas ARB total).

**Tests**: 187 (el tutorial es UI pura sin lógica de dominio nueva).

---

### Fase 8 — Mantenimiento y calidad post-product ✅ Completada (2026-05-09)

#### 8.1 — Auditoría post-Fase 7 y correcciones ✅ Completada (2026-05-08)

**Objetivo**: auditoría completa en 4 dimensiones (integridad, funcionalidad, optimización, seguridad) tras la implementación intensiva de Fases 6–7, y corrección de los hallazgos detectados.

**Hallazgos críticos corregidos**:
- `lib/core/extensions/scale_key_resolver.dart`: 31 claves `*Help` no registradas → tutorial mostraba clave literal en runtime.
- `lib/core/providers/connectivity_provider.dart`: `StreamProvider` sin `autoDispose` → listener nativo activo fuera del AppShell.
- `lib/core/utils/pii_detector.dart`: DNI/NIE con espacio (`"12345678 A"`) no detectado → regex con `[\s\-]?`.
- `supabase/README.md`: faltaba migración 0005 → trazabilidad rota.
- `test/widget_test.dart`: test de navegación tautológico dividido en mobile/tablet con tamaños explícitos.
- `lib/core/routing/app_shell.dart`: comentario obsoleto eliminado.

**Tests**: 191 (+4 netos: 3 PII + 1 extra navegación, reemplazando 1 tautológico).

---

#### 8.2 — Auth hardening y correcciones post-deploy ✅ Completada (2026-05-09)

**Objetivo**: corregir los bugs de inicio de sesión detectados en el primer uso real con `env/dev.json` y aplicar hardening de seguridad al flujo de autenticación.

**Bugs corregidos**:
- `supabaseClientProvider` lanzaba `AssertionError` interno cuando Supabase no estaba configurado → ahora lanza `ConfigurationException` tipada.
- `AuthController` propagaba `ProviderException` crudo a la UI → `_requireRepo()` lo convierte a `ConfigFailure` con mensaje legible.
- Login/register mostraban stack trace técnico → `_authErrorMessage()` mapea tipos de `Failure` a mensajes localizados.
- `sessionProvider` con `StreamTransformer` interfería con la entrega de eventos del stream broadcast de Supabase → eliminado, vuelve al enfoque simple.
- Navegación post-login bloqueada → añadido `ref.listen(authControllerProvider, ...)` como vía directa de navegación.

**Hardening de seguridad**:
- `SocketException` en datasource → `ConnectionException` → `NetworkFailure` con mensaje "Sin conexión".
- `signUp` detecta `response.session == null` (email confirmation pending) → `EmailConfirmationPendingFailure` mostrado en color primario.
- Email normalizado a `toLowerCase()` antes de enviar a Supabase.
- `AuthFormField` expone `autofillHints`, `autocorrect`, `enableSuggestions` — gestores de contraseñas pueden autocompletar.
- Registro exige ≥8 chars + letra + número; login mantiene ≥6 por compatibilidad.
- Migración `0006_fix_function_search_path.sql` aplicada: `handle_updated_at()` con `search_path = public` (security advisor WARN resuelto).

**Nuevos tipos**: `ConfigurationException`, `EmailConfirmationPendingException`, `ConfigFailure`, `EmailConfirmationPendingFailure`. ARB: `backendUnavailableError`, `networkErrorMessage`, `emailConfirmationPendingMessage`, `passwordTooWeakError` (ES + EN).

**Commits**: `0a46992` (fix ProviderException) · `586b6df` (hardening) · `a36339b` (fix navegación post-login).

**Tests**: 191 (sin cambios — correcciones en capa de presentación e infraestructura, no en dominio).

---

### Fase 9 — Preparación Beta ✅ Completada (2026-05-09)

**Objetivo**: cerrar los gaps que bloquean una beta clínica real: flujo de recuperación de contraseña, despliegue web accesible y distribución Android directa.

#### 9.1 — Flujo "olvidé contraseña" ✅

- `ForgotPasswordScreen`: email input + estado de éxito con icono.
- `ResetPasswordScreen`: nueva contraseña + confirmación con validación ≥8 chars.
- `passwordRecoveryProvider`: detecta evento `PASSWORD_RECOVERY` de Supabase y redirige a `/reset-password`.
- `PasswordResetController`: `requestReset()` y `updatePassword()`.
- `RequestPasswordResetUseCase` + `UpdatePasswordUseCase`.
- `AuthRepository` ampliado con `requestPasswordReset` y `updatePassword`.
- Rutas `/forgot-password` y `/reset-password` añadidas como `publicRoutes`.
- Router: `isRecovery` tiene prioridad sobre `isLoggedIn`.
- `Env.redirectUrl` (SUPABASE_REDIRECT_URL) configurable por entorno.
- 11 claves ARB nuevas ES + EN.

**Commit**: `c97bfe5`

#### 9.2 — Despliegue web ✅

- `web/index.html` + `web/manifest.json`: título, descripción y colores actualizados a marca NeuroScale (`#0F6F8A`).
- `GoogleFonts.allowRuntimeFetching` condicional: `false` en móvil/desktop, runtime CDN en web.
- Desplegado inicialmente en Netlify (2026-05-09); migrado a **GitHub Pages** (2026-05-11).
- Deploy actual: `.github/workflows/deploy.yml` → `https://grisllo.github.io/NeuroScaleApp/`.
- Supabase redirect URLs configuradas para el dominio de GitHub Pages.

**Commits**: `5ab5478` · `9985c7a`

#### 9.3 — Distribución Android APK ✅

- Build release con keystore configurado en Fase 6: `flutter build apk --release`.
- APK firmado (66 MB) instalado y verificado en Redmi Note 9 Pro (Android 12).
- Distribución directa vía `flutter install --release`.

**Tests**: 191 (sin cambios de dominio).

---

### Fase 10 — Polish & Optimización ✅ Completada (2026-05-12)

**Objetivo**: elevar la calidad del código antes de la entrega definitiva. Sin features nuevas — sólo coherencia, robustez y presentación profesional.

#### POLISH-01 + POLISH-02 — Saneamiento de mensajes de error en UI ✅

- `lib/core/extensions/failure_l10n.dart`: helper `failureMessage(error, l10n)` que mapea cualquier `Failure` a string localizada. Nunca expone detalles técnicos internos ni stack traces.
- `lib/l10n/app_es.arb` + `app_en.arb`: clave `authInvalidCredentialsError`.
- 8 archivos UI corregidos: `result_screen`, `profile_screen`, `patient_edit_dialog`, `patient_detail_screen`, `patients_tab_screen`, `login_screen`, `register_screen` — eliminados todos los `e.toString()` y `error.message` hardcodeados.

#### POLISH-03 — Documentar migraciones 0006-0008 en supabase/README.md ✅

- Añadidas 3 filas faltantes: `0006` (search_path fix), `0007` (cascade delete), `0008` (normalización claves legacy).

#### POLISH-04 — LICENSE + version bump ✅

- `LICENSE`: MIT (copyright 2026 Arturo Ramos Reparaz).
- `pubspec.yaml` version: `0.1.0` → `1.0.0-beta+1`.

#### POLISH-06 — Consolidar `_kInterpSeverity` en shared domain ✅

- `lib/features/scales/shared/domain/scale_metadata.dart`: mapa `kInterpSeverity` como fuente única; elimina 26 líneas duplicadas de `patient_detail_screen.dart`.

#### POLISH-07 — `ValidationException` para calculadoras de dominio puro ✅

- `core/errors/exceptions.dart`: nuevo `ValidationException extends AppException`.
- 5 calculadoras (GCS, NIHSS, mRS, Barthel, ABCD2): sustituyen `import failures.dart` por `exceptions.dart` y lanzan `ValidationException`. Dominio puro ya no depende de la capa `Failure`.
- 5 tests de calculadoras actualizados a `isA<ValidationException>()`.

#### POLISH-08 — Migrar `RadioListTile` deprecated API ✅

- 4 pantallas: `groupValue`/`onChanged` sustituidos por `RadioGroup<int>` wrapper. De 9 `// ignore` a 1.

#### POLISH-09 — Fix O(n²) en breakdown ✅

- `result_screen.dart`: loop usa `entries.indexed` en lugar de `elementAt(i)` por índice.

#### POLISH-10 — Corregir `mockito` → `mocktail` en docs ✅

- `METODOLOGIA_Y_PLANIFICACION.md`: stack de testing corregido.

---

### Fase 11 — UX Visual ✅ Completada (2026-05-12)

**Objetivo**: pulir la identidad visual de la app: avatar de paciente robusto cross-platform, layout web de anchura controlada, pantalla de autenticación con marca propia e icono oficial en todas las plataformas.

**Entregables**:
- `PatientAvatar`: reemplazado `hashCode` (inconsistente entre plataformas) por `_stableHash` determinista — el color del avatar es idéntico en web, Android e iOS para el mismo alias.
- Layout web: `maxWidth` por breakpoint en `PatientDetailScreen` (desktop 1100/900px, grid 3 cols).
- `LoginScreen` / `RegisterScreen`: fondo `AuthCard` con navy `#0C1840` + logo PNG real del usuario (sustituye icono genérico de Flutter).
- Tema claro cálido: superficies crema `F2EDE8` en lugar de frío `F7F9FB` — reduce fatiga visual en uso clínico prolongado.
- Unificación estilos dark/light en auth screens — sin divergencias visuales entre modos.
- Icono oficial Android/iOS/web mediante `flutter_launcher_icons` (logo NeuroScale real).
- Nombre "NeuroScale App" formalizado en ARB (`appTitle`) + `AndroidManifest.xml`.

**Commits**: `f11a` serie (hash avatar) · `f11b` (auth card) · `f11c` (icono oficial).

**Tests**: 191 (sin cambios — únicamente UI y assets).

---

### Fase 12 — Animaciones ✅ Completada (2026-05-12)

**Objetivo**: añadir movimiento con propósito: transiciones de ruta, entradas escalonadas y reveals de resultado que comunican jerarquía sin distraer en contexto clínico.

**Entregables**:
- `CustomTransitionPage` fade+slide en todas las rutas pushed (go_router) — transición consistente en Android, iOS y web.
- `_AnimatedEntrance` en círculo de severidad (`ResultScreen`) — scale+fade al aparecer el resultado (480ms emphasized).
- `FadeSlideItem` escalonado en listas de pacientes + grid de escalas — entrada progresiva por índice.
- `AnimatedCheck` en guardado de evaluación y forgot password — feedback visual de éxito.
- Algoritmos Q→Q: fade + slide 40% (más suave en pantallas anchas).
- Algoritmos Q→Result: scale+fade reveal (480ms emphasized).
- Fix parpadeo post-transición: `FadeSlideItem` redundante eliminado de `ScalesTabScreen`.
- Fix salto de layout resultado en PC: `SizedBox.expand` sustituido por constraint correcto.
- Fix `PasswordResetController.build() async` → síncrono (bug que causaba animación al abrir la pantalla).
- Algoritmos: pregunta con `primaryContainer` + borde teal, opciones thumb-friendly (altura mínima 56px).

**Tests**: 191 (sin cambios — animaciones son UI pura, no lógica de dominio).

---

### Fase 13 — Fixes UX evaluaciones ✅ Completada (2026-05-13)

**Objetivo**: corregir los problemas de UX detectados durante el primer uso real en producción web.

**Subfases**:

#### 13.1 — Paciente obligatorio + fix case_description ✅
- Eliminada opción "Sin paciente asignado" del picker — el paciente es obligatorio al guardar.
- Validación en picker: botón Guardar deshabilitado hasta seleccionar paciente.
- Bug `case_description` ausente del SELECT Supabase — corregido en datasource.

#### 13.2 — Disclaimer clínico como SnackBar por escala ✅
- Disclaimer aparece solo la primera vez que se completa cada escala — evita fatiga por repetición.
- Persistencia en SharedPreferences por `ScaleType`.

#### 13.3–13.8 — Fixes menores UI ✅
- `FilledButton` apagado: `backgroundColor` + `foregroundColor` explícitos — corrige bug de color en modo oscuro.
- Tab "Evaluaciones" móvil, cabecera "Evolución" web — etiquetas correctas según contexto.
- Toast disclaimer superior-derecha web + SnackBar swipe móvil.
- `NavigationRail`: fondo diferenciado claro/oscuro para jerarquía visual.
- Ordenación evaluaciones: reciente, antigua, por escala — `SortOrder` enum.
- `PatientAvatar` iniciales inteligentes: `P001` → `P1`, `P002` → `P2`.

#### 13.9–13.10 — Producción web ✅
- Spinner de carga web + homepage GitHub Pages.
- Fix crítico BOM (U+FEFF) y sufijo `/rest/v1` accidental en `SUPABASE_URL` — app web funcional en producción.

**Tests**: 191 (sin cambios de dominio; correcciones en datasource, UI y routing).

---

### Fase 14 — Auditoría y producción v1.0.0 ✅ Completada (2026-05-13)

**Objetivo**: llevar la app a un estado production-ready y entregable mediante auditoría multi-dimensional (arquitectura, seguridad, UI/UX, accesibilidad, datos, performance, testing, documentación).

#### 14.A — Críticos de producción ✅

- **Migración 0009**: 8 políticas RLS optimizadas con `(select auth.uid())` — evaluación una vez por sentencia, no por fila.
- **Migración 0010**: eliminados 2 índices no usados identificados por Supabase Performance Advisor.
- **Migración 0011**: constraint `patients.alias` max 255 chars.
- `lib/main.dart`: eliminado `PlatformDispatcher.onError` debug temporal.
- `lib/main.dart`: filtro `beforeSend` en Sentry que descarta eventos con patrones de email/DNI en stack traces.
- `login_screen.dart`: unificada validación password 6→8 chars (igual que register).
- `scales_tab_screen.dart`: `AppBar('NeuroScale')` hardcoded → `l10n.appTitle`.
- **Nota**: Leaked Password Protection requiere plan Supabase Pro — no disponible en plan gratuito.

#### 14.B — Sistema de tokens (consistencia visual) ✅

- `AppSpacing.xxs = 2` añadido al scale de 4pt.
- ~90 `SizedBox(height/width: N)` → `AppSpacing.{xxs,sm,md,lg,xl,xxl}` en 20 archivos.
- ~15 `BorderRadius.circular(N)` → `AppRadii.{sm,md,lg}` en 8 archivos.

#### 14.C — Accesibilidad ✅

- `PatientAvatar`: `Semantics(label: patient.alias, excludeSemantics: true)`.
- 5 `IconButton` sin etiqueta añadidos con `tooltip:`: show/hide password en login/register/reset/profile + editar paciente.
- ARB ES+EN: `showPasswordTooltip`, `hidePasswordTooltip`, `passwordHint`, `passwordTooShortError` (8 chars).

#### 14.D — Testing de presentación ✅

- **PatientAvatar (8 tests)**: iniciales multi-palabra, mixto letra+número, solo dígitos, vacío, semántica.
- **ProfileScreen (5 tests)**: email visible, SegmentedButtons tema/idioma, logout, delete_forever, dash sin sesión.
- **Tests totales: 191 → 204**.

#### 14.E — Documentación profesional ✅

- `docs/RELEASE_GUIDE.md`: build APK/web/iOS, secretos, CI/CD, checklist pre-release.
- `docs/SECURITY.md`: modelo RLS, PII, Sentry filter, sesiones, reporting.
- `docs/CONTRIBUTING.md`: flujo PR, Conventional Commits, i18n, checklist accesibilidad.
- `CLAUDE.md`: sección "Accessibility checklist" para features nuevos.
- `README.md`: badges CI+deploy+license, Fase 14 en Gantt.

#### 14.F — Cierre y entrega ✅

- `flutter analyze` — 0 issues.
- `flutter test` — 204 tests verdes.
- `dart format --set-exit-if-changed lib test` — 0 cambios.
- Supabase advisors: 0 WARN performance, 1 WARN security (Leaked Password Pro — plan gratuito).
- Tag `v1.0.0` creado y pusheado a GitHub.

**Commits clave**: `c1f07ce` (docs E) · `686c9e0` (tests D) · `5afd104` (a11y C) · `6890f0b` (tokens B) · `92b2157` (seguridad A).

---

## Mantenimiento post-v1.0.0 (2026-05-14)

Correcciones y mejoras de documentación y UI tras el lanzamiento. Total aportado: ~2 h de sesión activa.

### Documentación y licencia (mañana)

- **Reestructura del ROADMAP**: orden cronológico de fases 0→14 con tabla de contenidos navegable.
- **Auditoría documental inicial** (correcciones factuales): Leaked Password Protection en `SECURITY.md`, migraciones 0009-0011 en `supabase/README.md`, arquitectura actualizada en `CLAUDE.md`.
- **Licencia**: MIT → propietaria (preparación para una posible venta comercial a una empresa clínica).
- **Badge CI**: corregida la extensión `ci.yml` → `ci.yaml` (apuntaba a un archivo inexistente).
- **Favicon**: `web/favicon.png` reemplazado con el icono NeuroScale (queda pendiente optimizar el tamaño desde 1,14 MB a < 50 KB).

### Auth UI y dark mode (mediodía)

- **Auth screens**: eliminado el fondo navy hardcodeado (`#0C1840`) en favor del `colorScheme.surface` (crema en claro, oscuro en dark). Título `Colors.white` → `colorScheme.primary` (teal). Móvil y tablet/web alineados.
- **Dark mode inputs**: corregida la jerarquía visual a nivel global. El `fillColor` pasaba a `surfaceContainer` (`#161D24`, más oscuro que la propia card), haciendo que los inputs se "hundieran" visualmente. Cambiado a `colorScheme.outline` (`#2A333C`), un tono más claro que la card. Aplica a toda la app, no solo a auth.

### Pulido integral de los nueve documentos del proyecto (tarde)

Trabajo de elevación a calidad final, técnico-formal y consistente, sirviendo de base para la futura "biblia" del TFC:

- **`README.md`**: añadido bloque _Estado del proyecto_, tabla con stack y versiones reales de `pubspec.yaml`, diagrama Mermaid de arquitectura de capas, sección _Capturas de pantalla_ con placeholders, sección _Licencia_ explicativa.
- **`docs/ROADMAP.md`**: tabla de contenidos navegable, _Deuda técnica y mejoras aplazadas_ reorganizada en dos tablas (deuda + polish opcional).
- **`docs/METODOLOGIA_Y_PLANIFICACION.md`**: reescritura profunda de la sección 3 (Planificación) — tres tablas claramente delimitadas (estimación, horas reales, desviaciones). Trazabilidad extendida.
- **`docs/SECURITY.md`**: expansión completa — tabla de 8 políticas RLS, patrones PII detectados con regex y ejemplos, snippet real del filtro Sentry, diagrama Mermaid del flujo de autenticación, sección Edge Function `delete-account`.
- **`docs/RELEASE_GUIDE.md`**: nuevas secciones de versionado semántico, rollback (web / APK / base de datos), gestión de secretos en GitHub Actions, diagrama Mermaid de flujo CI/CD.
- **`docs/CONTRIBUTING.md`**: plantilla completa para añadir un algoritmo clínico, secciones de tests con filtros y debugging.
- **`supabase/README.md`**: diagrama ER Mermaid, verificación de migraciones aplicadas, buenas prácticas antes de producción, Edge Function `delete-account`.
- **`android/README.md`**: nuevas secciones sobre pérdida y cambio de keystore.
- **`CLAUDE.md`**: sincronización completa con el estado actual del proyecto y los 10 skills disponibles.

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
│   │   ├── nihss/
│   │   ├── rankin/  (mRS 0-6)
│   │   ├── barthel/
│   │   └── abcd2/
│   ├── evaluations/ data/  domain/  presentation/
│   └── patients/    data/  domain/  presentation/
└── l10n/            app_es.arb  app_en.arb  →  generated/app_localizations.dart
```

---

## Deuda técnica y mejoras aplazadas

Decisiones que se han tomado conscientemente para diferir trabajo. Cada elemento incluye motivación y condición de revisión.

### Deuda técnica

| Elemento | Decisión | Motivación | Cuándo revisar |
|---|---|---|---|
| Certificate pinning Supabase | Aplazado | Supabase rota certificados LetsEncrypt cada ~60 días; un pin caducado dejaría la app inservible hasta publicar hotfix. El ROI actual no compensa el riesgo operacional. | Cuando se requiera certificación clínica (HIPAA, ISO 13485). |
| `pubspec.yaml` vs tag | Versión `1.0.0-beta+1` en `pubspec.yaml` pese al tag `v1.0.0`. | Conservada para no romper `flutter pub get` ni cachés. | Cuando se prepare un release público en stores. |
| Leaked Password Protection | No activado | Requiere plan Supabase Pro; no disponible en plan gratuito. | Cuando se migre a plan de pago. |
| Cobertura de tests global 20,7 % | Aceptada | El dominio (calculadoras y algoritmos) está al 100 %. El resto es UI/datasource con poco valor en mock-tests. | Si se introducen flujos UI complejos con regresiones frecuentes. |

### Polish opcional

| Elemento | Estado | Acción pendiente |
|---|---|---|
| `POLISH-05` — capturas en README | Pendiente | Generar capturas finales de producción para sustituir los placeholders. |
| `favicon.png` de 1,14 MB | Pendiente | Optimizar a < 50 KB sin pérdida visible. |

---

## Documentos relacionados

- `CLAUDE.md` — instrucciones para Claude Code (stack, comandos, convenciones).
- `~/.claude/plans/wild-imagining-creek.md` — detalle táctico de la fase activa (fuera del repo, se sobreescribe cada fase).
- `supabase/migrations/` — migraciones SQL numeradas.
- `.github/workflows/ci.yaml` — pipeline de CI.
