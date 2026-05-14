# NeuroScale App — Metodología y Planificación

> Documento de presentación del proyecto. Todos los datos son contrastables con el repositorio Git: <https://github.com/grisllo/NeuroScaleApp>.

---

## Tabla de contenidos

- [1. Descripción del proyecto](#1-descripción-del-proyecto)
- [2. Metodología](#2-metodología)
  - [2.1 Enfoque adoptado](#21-enfoque-adoptado)
  - [2.2 Arquitectura: feature-first con Clean Architecture](#22-arquitectura-feature-first-con-clean-architecture)
  - [2.3 Justificación de decisiones clave](#23-justificación-de-decisiones-clave)
  - [2.4 Control de calidad](#24-control-de-calidad)
- [3. Planificación](#3-planificación)
  - [3.1 Estimación inicial](#31-estimación-inicial)
  - [3.2 Horas reales por fase](#32-horas-reales-por-fase)
  - [3.3 Análisis de desviaciones](#33-análisis-de-desviaciones)
  - [3.4 Conclusión](#34-conclusión)
- [4. Trazabilidad Git ↔ Issues ↔ Casos de uso](#4-trazabilidad-git--issues--casos-de-uso)
- [5. Referencias](#5-referencias)

---

## 1. Descripción del proyecto

**NeuroScale App** es una aplicación multiplataforma (Android, iOS, web) dirigida a profesionales de la salud y estudiantes de medicina. Permite aplicar escalas neurológicas estandarizadas (GCS, NIHSS, mRS, Barthel, ABCD2), calcular puntuaciones, interpretar resultados clínicos y registrar evaluaciones de forma anonimizada por paciente.

Estado actual: **versión 1.0.0** publicada el 2026-05-13 (tag `v1.0.0`), con **204 tests** verdes, **11 migraciones** SQL aplicadas y despliegue web automático en GitHub Pages.

### Stack tecnológico

| Capa | Tecnología | Versión |
|---|---|---|
| Lenguaje | Dart | SDK ^3.8.0 |
| Framework | Flutter (canal stable) | 3.41.9 |
| Sistema de diseño | Material 3 + Inter (`google_fonts`) | 6.2.1 |
| Gestión de estado | `flutter_riverpod` | 3.1.0 |
| Navegación | `go_router` + `StatefulShellRoute` | 17.2.3 |
| Backend (BaaS) | Supabase (Auth + PostgreSQL + RLS + Edge Functions) | SDK 2.12.4 |
| Persistencia local | `drift` + `drift_flutter` (SQLite) | 2.31.0 / 0.2.8 |
| Internacionalización | `intl` + `flutter_localizations` (ARB) | 0.20.2 |
| Gráficas | `fl_chart` | 1.2.0 |
| Conectividad | `connectivity_plus` | 6.1.1 |
| Error tracking | `sentry_flutter` (inicialización condicional) | 9.19.0 |
| Testing | `flutter_test` + `mocktail` | 1.0.5 |
| Linting | `flutter_lints` + `riverpod_lint` + `custom_lint` | 6.0.0 / 3.1.0 / 0.8.1 |
| CI/CD | GitHub Actions + GitHub Pages | — |

---

## 2. Metodología

### 2.1 Enfoque adoptado

**Desarrollo iterativo por fases con Clean Architecture y TDD obligatorio en el dominio clínico.**

El proyecto se divide en fases de complejidad creciente. Cada fase contiene entregables definidos, criterios de aceptación verificables y uno o varios commits de cierre trazables en Git. La unidad mínima de trabajo es la subfase, que sigue el ciclo siguiente:

```
Diseño → Aprobación → Implementación → Tests → flutter analyze → Commit
```

No se escribe código sin aprobación previa del diseño. Este principio reduce el retrabajo estructural y mantiene la coherencia arquitectónica a medida que el proyecto crece.

### 2.2 Arquitectura: feature-first con Clean Architecture

```
lib/
├── core/              infraestructura compartida (theme, routing, env, errors, providers, utils, widgets)
├── features/
│   ├── auth/          data/ → domain/ → presentation/
│   ├── scales/
│   │   ├── shared/    entidades base (ScaleItem, ScaleResult, Severity, ScaleDefinition)
│   │   ├── gcs/       Glasgow Coma Scale 3-15
│   │   ├── nihss/     NIHSS 0-42 con valor "Untestable" (UN = 9)
│   │   ├── rankin/    Modified Rankin Scale 0-6
│   │   ├── barthel/   Barthel Index 0-100 (10 ítems de AVD)
│   │   └── abcd2/     ABCD2 0-7 (riesgo post-AIT)
│   ├── evaluations/   persistencia de evaluaciones completadas (local + remoto)
│   ├── patients/      gestión de pacientes anonimizados + evolución temporal
│   └── algorithms/    árboles de decisión clínicos (Código Ictus, HTA, HSA)
└── l10n/              app_es.arb + app_en.arb → generated/
```

**Flujo de datos estricto** (nunca saltado):

```
UI → Provider (Riverpod) → UseCase → Repository → DataSource → Supabase / Drift
```

### 2.3 Justificación de decisiones clave

| Decisión | Alternativa descartada | Justificación |
|---|---|---|
| Feature-first sobre layer-first | Directorios `data/`, `domain/`, `presentation/` en la raíz | Con seis o más features, la cohesión por dominio escala mejor; un cambio en una feature no toca a las demás. |
| TDD obligatorio en calculadoras | Tests opcionales o posteriores a la implementación | Contexto médico: un cálculo erróneo en GCS puede tener consecuencias clínicas. Las funciones puras sin dependencias permiten tests triviales y exhaustivos. |
| Supabase + RLS | Firebase, backend propio | Auth, PostgreSQL y RLS en un único servicio; el plan gratuito es suficiente para MVP. La RLS garantiza el aislamiento de datos por usuario incluso ante errores del frontend. |
| i18n desde el inicio | Añadir tras el MVP | En Flutter, incorporar i18n a posteriori requiere modificar todos los widgets. Desde el inicio el coste es de un día; después, de semanas. |
| Repositorios lanzan `Failure` directamente | Patrón `Either<L,R>` con `fpdart` / `dartz` | Simplifica el código y se integra mejor con `AsyncValue.guard()` de Riverpod. Puede introducirse en refactor si el proyecto lo requiere. |
| Plan → aprobación → implementación | Implementación directa | Reduce el retrabajo y permite detectar problemas de diseño antes de escribir código. |
| `env/dev.json` gitignoreado | Variables de entorno definidas en el CI | Mantiene los secretos fuera del repositorio. `--dart-define-from-file` funciona en web/CI sin dependencias adicionales. |
| Calculadoras como funciones puras en `domain/` | Calculadoras como métodos de clase con estado | Imports limitados a Dart estándar (sin Flutter ni Supabase). Tests instantáneos y reutilización entre plataformas. |

### 2.4 Control de calidad

- **Linting estricto**: `analysis_options.yaml` activa las reglas de `flutter_lints`, `riverpod_lint` y `custom_lint`. El linter bloquea imports no relativos, cadenas literales hardcodeadas y patrones Riverpod incorrectos.
- **CI automático**: cada `push` ejecuta `dart format --set-exit-if-changed`, `flutter analyze`, `flutter test` y `osv-scanner` sobre `pubspec.lock`. Un fallo bloquea el merge.
- **Cobertura de tests en dominio**: cada calculadora de escala cubre todos los umbrales clínicos y los casos inválidos (inputs fuera de rango, mapas vacíos, ítems faltantes).

---

## 3. Planificación

### 3.1 Estimación inicial

Estimaciones realizadas antes de iniciar cada fase, basadas en la complejidad percibida. El alcance inicial del proyecto cubría únicamente hasta la **Fase 4** (40,0 h); las fases 5–14 surgieron durante la ejecución como respuesta a hallazgos de auditoría, despliegue real y feedback de uso.

| Tarea | Fase | Horas estimadas |
|---|---|---|
| Diseño arquitectónico y plan inicial | — | 1,0 |
| Scaffold Flutter + CI + i18n | 0 | 2,0 |
| Auth (login / register / disclaimer / guard) | 1 | 3,0 |
| GCS (calculadora + pantalla + tests) | 1 | 2,0 |
| Evaluations (guardado + RLS) | 1 | 2,0 |
| Migración Supabase + smoke test E2E | 1 | 1,0 |
| GitHub setup + conexión remoto | — | 0,5 |
| **Subtotal Fases 0 + 1** | | **11,5** |
| 2A.1 Refactor + History básica | 2A | 3,0 |
| 2A.2 Filtros + búsqueda + paginación | 2A | 2,0 |
| 2A.3 Gráficos fl_chart | 2A | 2,5 |
| 2A.4 mRS 0-6 | 2A | 1,5 |
| 2A.5 Barthel Index | 2A | 2,0 |
| 2A.6 ABCD2 | 2A | 1,5 |
| **Subtotal Fase 2A** | | **12,5** |
| NIHSS (15 ítems, lógica condicional) | 2B | 6,0 |
| Algoritmos + Offline + Perfil | 3* | 10,0 |
| **Total estimado inicialmente** | | **40,0** |

\* La fase "Algoritmos + Offline + Perfil" se renumeró a **Fase 4** durante la ejecución; la nueva Fase 3 pasó a contener el shell de navegación y el modelo de pacientes.

### 3.2 Horas reales por fase

Horas reconstruidas a partir de los timestamps de commits de Git y las sesiones de trabajo documentadas. El tiempo registrado corresponde a sesión activa del desarrollador (revisión de salidas, testing manual, decisiones de diseño y redirección del agente Claude Code), no al tiempo total de ejecución del agente.

| Fase / Tarea | Commit(s) representativos | Fecha | Horas reales |
|---|---|---|---|
| Diseño arquitectónico inicial | — | 2026-04-25/26 | ~2,0 |
| Fase 0 — Scaffold (104 archivos, +3 157 líneas) | `94193df` | 2026-04-26 | ~1,5 |
| Fase 1 — Auth completa | `6d677db` | 2026-04-26 | ~2,0 |
| Fase 1 — GCS + entidades base | `6d677db` | 2026-04-26 | ~1,5 |
| Fase 1 — Evaluations + ResultScreen + disclaimer | `6d677db` | 2026-04-26 | ~1,0 |
| Fase 1 — Migración Supabase + smoke test | `a127711` | 2026-04-27 | ~1,5 |
| GitHub setup + issues + documentación | — | 2026-04-27 | ~1,0 |
| Fase 2A.1 — Refactor + History | `4c1706a` | 2026-04-27 | ~3,0 |
| Fase 2A.2 — Filtros + búsqueda + paginación | `c822d01` | 2026-04-27 | ~2,0 |
| Fase 2A.3 — Gráficos fl_chart | `6cde524` | 2026-04-27 | ~2,5 |
| Fase 2A.4 — mRS 0-6 | `2e10959` | 2026-04-27 | ~1,5 |
| Fase 2A.5 — Barthel Index | `7ced22c` | 2026-04-27 | ~2,0 |
| Fase 2A.6 — ABCD2 + migración SQL | `902594c` | 2026-04-27 | ~1,5 |
| Fase 2B.1 — NIHSS dominio + UN=9 + 27 tests | `70d2a59` | 2026-04-28 | ~3,0 |
| Fase 2B.2 — NIHSS UI + advisory coma | `f94c775` | 2026-04-28 | ~2,0 |
| Fase 3.1 — UX shell + back buttons + polish M3 | `6ddfe80` | 2026-04-28 | ~3,5 |
| Fase 3.2 — Modelo de pacientes + CRUD | `c8e6845` | 2026-04-29 | ~5,5 |
| Fase 3.3 — Patient detail + evolución | `fb55092` | 2026-04-30 | ~2,0 |
| Fase 4.1 — Algoritmos clínicos | `884ff0c`, `01846f7` | 2026-04-30 | ~1,5 |
| Fase 4.2 — Modo offline (Drift) | `14a2b31` | 2026-04-30 | ~2,0 |
| Fase 4.3 — Multilenguaje EN | `b025b43` | 2026-04-30 | ~2,5 |
| Fase 4.4 — Pantalla de perfil | `ea1a77c` | 2026-04-30 | ~0,5 |
| Fase 5 — Design System + UX visual | `b16f6cf`..`e68975b` | 2026-05-05 | ~1,0 |
| Fase 6.1 — Seguridad y release | `6b325ec`..`1741626` | 2026-05-08 | ~2,0 |
| Fase 6.2 — Optimización backend | `b81adf9`..`0aeae5f` | 2026-05-08 | ~1,0 |
| Fase 6.3 — Refactor i18n + arquitectura | `d3c6e3f`..`009a499` | 2026-05-08 | ~0,5 |
| Fase 6.4 — Rendimiento web + tests + a11y | `e466851`..`9aa2087` | 2026-05-08 | ~0,5 |
| Fase 7.1 — Indicador modo sin conexión | `8f5f442`..`c9f5066` | 2026-05-08 | ~0,5 |
| Fase 7.2 — Web/tablet responsive | `67b8645`..`bcbf1dc` | 2026-05-08 | ~1,0 |
| Fase 7.3 — Modo tutorial botón "?" | `bb65acb`..`5a6c667` | 2026-05-08 | ~1,0 |
| Fase 8.1 — Auditoría post-Fase 7 | `652d7bf`..`ca8c430` | 2026-05-08 | ~1,0 |
| Fase 8.2 — Auth hardening + migración 0006 | `0a46992`..`c383032` | 2026-05-09 | ~2,0 |
| Fase 9.1 — Flujo de recuperación de contraseña | `c97bfe5` | 2026-05-09 | ~2,0 |
| Fase 9.2 — Despliegue web inicial (Netlify → GitHub Pages) | `5ab5478`..`9985c7a` | 2026-05-09 | ~1,0 |
| Fase 9.3 — APK Android firmado | — | 2026-05-09 | ~0,5 |
| Mantenimiento 2026-05-11 — borrado, admin cuenta, tema oscuro, UI/UX global | `5b5fb73`..`a7c6dbe` | 2026-05-11 | ~9,5 |
| Fase 10 — Polish (errores, ValidationException, RadioGroup, LICENSE) | varios | 2026-05-12 | ~3,0 |
| Fase 11 — UX visual (hash avatar, layout web, auth card, tema cálido, icono) | varios | 2026-05-12 | ~4,5 |
| Fase 12 — Animaciones (transiciones, FadeSlideItem, AnimatedCheck, algoritmos) | varios | 2026-05-12 | ~4,5 |
| Fase 13 — Fixes UX evaluaciones + producción web | varios | 2026-05-13 | ~3,0 |
| Fase 14 — Auditoría y producción v1.0.0 (RLS, tokens, a11y, tests, docs) | `92b2157`..`ccb29d0` | 2026-05-13 | ~4,0 |
| Mantenimiento post-v1.0.0 — docs, licencia, auth UI dark mode | `3025a25`..`d3fefde` | 2026-05-14 | ~2,0 |
| **TOTAL ACUMULADO** | | | **~87,0 h** |

### 3.3 Análisis de desviaciones

Comparación entre estimación y horas reales para las fases con estimación previa (0 a 4). Las fases 5 a 14 surgieron durante la ejecución y no disponen de estimación contrastable.

| Tarea | Estimado | Real | Desviación | Causa |
|---|---:|---:|---:|---|
| Diseño arquitectónico | 1,0 h | 2,0 h | +1,0 h | Más capas de las previstas (errores, extensiones, providers de Supabase). |
| Fase 0 — Scaffold | 2,0 h | 1,5 h | −0,5 h | Automatización con Claude Code más eficiente de lo esperado. |
| Fase 1 — Auth | 3,0 h | 2,0 h | −1,0 h | Clean Architecture bien definida; implementación directa. |
| Fase 1 — GCS | 2,0 h | 1,5 h | −0,5 h | Función pura + entidades base reutilizables. |
| Fase 1 — Evaluations | 2,0 h | 1,0 h | −1,0 h | El repositorio y el datasource siguieron el patrón de auth. |
| Fase 1 — Supabase | 1,0 h | 1,5 h | +0,5 h | Problemas de autenticación MCP que requirieron sesión adicional. |
| GitHub setup | 0,5 h | 1,0 h | +0,5 h | `gh` CLI no estaba en `PATH`; configuración de credenciales HTTPS. |
| Fase 2A.1 — Refactor + History | 3,0 h | 3,0 h | 0,0 h | En línea con la estimación. |
| Fase 2A.2 — Filtros + búsqueda + paginación | 2,0 h | 2,0 h | 0,0 h | Estimación precisa. |
| Fase 2A.3 — Gráficos fl_chart | 2,5 h | 2,5 h | 0,0 h | Pequeña incompatibilidad de versiones; sin impacto neto. |
| Fase 2A.4 — mRS 0-6 | 1,5 h | 1,5 h | 0,0 h | La skill `create-scale` ejecutó el patrón directamente. |
| Fase 2A.5 — Barthel Index | 2,0 h | 2,0 h | 0,0 h | Validación por conjunto añadió complejidad de tests; compensada. |
| Fase 2A.6 — ABCD2 | 1,5 h | 1,5 h | 0,0 h | Patrón idéntico a Barthel. |
| **Subtotal Fases 0–2A** | **24,0 h** | **23,0 h** | **−1,0 h** | **−4,2 %** |
| Fase 2B — NIHSS | 6,0 h | 5,0 h | −1,0 h | La lógica condicional resultó ser `UN=9` por ítem (sin reglas inter-ítem). |
| **Subtotal Fase 2B** | **6,0 h** | **5,0 h** | **−1,0 h** | **−16,7 %** |
| Fase 3 — UX shell + pacientes (3 subfases) | 10,5 h | 11,0 h | +0,5 h | Ampliación de scope con patient picker + ARB completo. |
| **Subtotal Fase 3** | **10,5 h** | **11,0 h** | **+0,5 h** | **+4,8 %** |
| Fase 4.1 — Algoritmos clínicos | 4,0 h | 1,5 h | −2,5 h | Sealed classes Dart 3 + travesía pura simplificaron el dominio. |
| Fase 4.2 — Modo offline (Drift) | 3,0 h | 2,0 h | −1,0 h | Incompatibilidad menor de versiones drift / drift_flutter. |
| Fase 4.3 — Multilenguaje EN | 1,0 h | 2,5 h | +1,5 h | Traducción de ~300 claves (contenido clínico de algoritmos) más costosa. |
| Fase 4.4 — Pantalla de perfil | 2,0 h | 0,5 h | −1,5 h | Patrón sencillo + lógica de idioma ya preparada en 4.3. |
| **TOTAL fases con estimación (0–4)** | **50,5 h** | **45,5 h** | **−5,0 h** | **−9,9 %** |

### 3.4 Conclusión

El balance de las **fases con estimación previa (0 a 4)** es de **−5,0 h** (−9,9 %): la planificación fue ligeramente pesimista en implementación y optimista en contenido.

Las **fases 5 a 14**, no estimadas inicialmente, sumaron ~31,5 h adicionales repartidas en saneamiento técnico, despliegue beta, polish, animaciones, fixes de producción y auditoría final. El **mantenimiento intermedio** (2026-05-11) aportó otras 9,5 h de mejoras de UX y administración de cuenta. El **mantenimiento post-v1.0.0** (2026-05-14) añadió 2,0 h de pulido documental y de UI.

**Total acumulado del proyecto**: **~87 h** de sesión activa, distribuidas en 19 días de trabajo efectivo (2026-04-26 a 2026-05-14).

---

## 4. Trazabilidad Git ↔ Issues ↔ Casos de uso

Las **fases 0 a 9** se gestionaron a través de issues numerados en GitHub (`#1` a `#23`). Las **fases 10 a 14** y los mantenimientos posteriores se cerraron directamente mediante commits, dado el ritmo intensivo de iteración y la trazabilidad ya garantizada por el Gantt y el ROADMAP.

| Issue GitHub | Commit(s) | Caso de uso cubierto |
|---|---|---|
| [`#1`](https://github.com/grisllo/NeuroScaleApp/issues/1) | `94193df` | CU-00: arrancar la aplicación sin credenciales. |
| [`#2`](https://github.com/grisllo/NeuroScaleApp/issues/2) | `6d677db` | CU-01: registrarse · CU-02: iniciar sesión · CU-03: aceptar disclaimer. |
| [`#3`](https://github.com/grisllo/NeuroScaleApp/issues/3) | `6d677db` | CU-04: completar escala GCS · CU-05: ver resultado interpretado. |
| [`#4`](https://github.com/grisllo/NeuroScaleApp/issues/4) | `6d677db` | CU-06: guardar evaluación con descripción de caso. |
| [`#5`](https://github.com/grisllo/NeuroScaleApp/issues/5) | `a127711` | CU-07: persistencia en servidor con aislamiento por usuario (RLS). |
| [`#6`](https://github.com/grisllo/NeuroScaleApp/issues/6) | `4c1706a` | CU-08: ver historial · CU-08b: borrar evaluación. |
| [`#7`](https://github.com/grisllo/NeuroScaleApp/issues/7) | `c822d01` | CU-09: filtrar historial · CU-09b: buscar por caso · CU-09c: paginación. |
| [`#8`](https://github.com/grisllo/NeuroScaleApp/issues/8) | `6cde524` | CU-10: ver evolución temporal de una escala. |
| [`#9`](https://github.com/grisllo/NeuroScaleApp/issues/9) | `2e10959` | CU-11: completar escala mRS (incluye grado 6, fallecido). |
| [`#10`](https://github.com/grisllo/NeuroScaleApp/issues/10) | `7ced22c` | CU-12: completar Barthel Index (validación por conjunto). |
| [`#11`](https://github.com/grisllo/NeuroScaleApp/issues/11) | `902594c` | CU-13: completar ABCD2 (riesgo post-AIT). |
| [`#12`](https://github.com/grisllo/NeuroScaleApp/issues/12) | `70d2a59`, `f94c775` | CU-14: completar NIHSS (UN=9, advisory coma). |
| [`#13`](https://github.com/grisllo/NeuroScaleApp/issues/13) | `884ff0c`, `01846f7` | CU-16: algoritmos clínicos (Código Ictus, HTA, HSA). |
| [`#14`](https://github.com/grisllo/NeuroScaleApp/issues/14) | `6ddfe80`, `c8e6845`, `fb55092` | CU-15: shell de navegación + pacientes (CRUD + evolución por paciente). |
| [`#15`–`#21`](https://github.com/grisllo/NeuroScaleApp/issues?q=is%3Aissue+is%3Aclosed) | varios | Fases 6 y 7 (seguridad, optimización, responsive, tutorial). |
| [`#22`](https://github.com/grisllo/NeuroScaleApp/issues/22) | `652d7bf`..`ca8c430` | CU-17: auditoría post-Fase 7 (tutorial, PII, autoDispose). |
| [`#23`](https://github.com/grisllo/NeuroScaleApp/issues/23) | `c97bfe5`..`9985c7a` | CU-18: password reset · CU-19: despliegue web · CU-20: distribución APK. |
| _Sin issue (commits directos)_ | varios | Fases 10–14 + Mantenimientos: polish, animaciones, fixes UX, auditoría v1.0.0 y pulido documental. Trazabilidad en el Gantt del README y en el ROADMAP. |

---

## 5. Referencias

- **Repositorio**: <https://github.com/grisllo/NeuroScaleApp>.
- **Issues y milestones**: <https://github.com/grisllo/NeuroScaleApp/issues>.
- **Release v1.0.0**: <https://github.com/grisllo/NeuroScaleApp/releases/tag/v1.0.0>.
- [`docs/ROADMAP.md`](ROADMAP.md) — fases, decisiones de diseño y criterios de aceptación.
- [`docs/SECURITY.md`](SECURITY.md) — modelo de seguridad y gestión de PII.
- [`docs/RELEASE_GUIDE.md`](RELEASE_GUIDE.md) — guía de release y despliegue.
- [`docs/CONTRIBUTING.md`](CONTRIBUTING.md) — guía de contribución.
- [`supabase/README.md`](../supabase/README.md) — migraciones SQL numeradas y versionadas.
- [`CLAUDE.md`](../CLAUDE.md) — stack, comandos y convenciones para el agente Claude Code.
- [`.github/workflows/ci.yaml`](../.github/workflows/ci.yaml) — pipeline de CI con format, analyze, test y `osv-scanner`.
