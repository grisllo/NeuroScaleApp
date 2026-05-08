# NeuroScale App — Metodología y Planificación

> Documento generado para la presentación del proyecto en clase.  
> Datos contrastables con el repositorio Git: https://github.com/grisllo/NeuroScaleApp

---

## 1. Descripción del proyecto

**NeuroScale App** es una aplicación multiplataforma (Android, iOS, web) para profesionales de la salud y estudiantes que permite aplicar escalas neurológicas estandarizadas (GCS, NIHSS, Rankin/mRS, Barthel), calcular puntuaciones, interpretar resultados clínicos y registrar evaluaciones de forma anonimizada.

**Stack tecnológico:**

| Capa | Tecnología |
|---|---|
| Frontend | Flutter 3.x (Dart), Material 3 |
| Estado | Riverpod (`AsyncNotifier`/`Notifier`) |
| Navegación | go_router (rutas declarativas, auth guard) |
| Backend | Supabase (Auth + PostgreSQL + RLS + Storage) |
| Internacionalización | intl + flutter_localizations (ARB files) |
| Testing | flutter_test, mockito |
| CI/CD | GitHub Actions (`flutter analyze` + `flutter test`) |
| Error tracking | Sentry (condicional, no bloquea sin clave) |

---

## 2. Metodología

### 2.1 Enfoque adoptado

**Desarrollo iterativo por fases con Clean Architecture y TDD obligatorio en dominio clínico.**

El proyecto se divide en fases de complejidad creciente, cada una con entregables definidos, criterios de aceptación verificables y commit(s) de cierre trazables en git. Dentro de cada fase, la unidad mínima es la subfase, que sigue el ciclo:

```
Diseño → Aprobación → Implementación → Tests → flutter analyze → Commit
```

No se escribe código sin aprobación previa del diseño. Esto evita retrabajo estructural y mantiene la coherencia arquitectónica a medida que el proyecto crece.

### 2.2 Arquitectura: Feature-first con Clean Architecture

```
lib/
├── core/              infraestructura compartida (theme, routing, env, errors)
├── features/
│   ├── auth/          data/ → domain/ → presentation/
│   ├── scales/
│   │   ├── shared/    entidades base (ScaleItem, ScaleResult, Severity)
│   │   ├── gcs/       calculadora + pantalla + tests
│   │   ├── rankin/    (Fase 2A)
│   │   ├── barthel/   (Fase 2A)
│   │   ├── abcd2/     (Fase 2A)
│   │   └── nihss/     (Fase 2B)
│   ├── evaluations/   persistencia de evaluaciones completadas
│   └── history/       listado + gráficos (Fase 2A)
└── l10n/              app_es.arb → generated/
```

**Flujo de datos** (nunca saltado): `UI → Provider → UseCase → Repository → DataSource → Supabase`

### 2.3 Justificación de decisiones clave

| Decisión | Alternativa descartada | Justificación |
|---|---|---|
| Feature-first sobre layer-first | Directorios `data/`, `domain/`, `presentation/` en raíz | Con 6+ features la cohesión por dominio escala mejor; cambios en una feature no tocan otras |
| TDD obligatorio en calculadoras | Tests opcionales o post-implementación | Contexto médico: un cálculo erróneo en GCS puede tener consecuencias clínicas reales. Funciones puras sin dependencias → tests triviales y exhaustivos |
| Supabase + RLS | Firebase, backend propio | Auth + PostgreSQL + RLS en un servicio; free tier suficiente para MVP; RLS garantiza aislamiento de datos por usuario incluso ante bugs en el frontend |
| i18n desde el inicio | Añadir después del MVP | En Flutter, añadir i18n post-hoc requiere tocar todos los widgets. Desde el inicio el coste es ~1 día; después, semanas |
| No `Either<L,R>` en MVP | fpdart / dartz | Simplifica el código sin perder correctitud; se puede añadir en refactor si la escala del proyecto lo exige |
| Plan → aprobación → implementación | Implementación directa | Reduce retrabajo; permite detectar problemas de diseño antes de escribir código |
| `env/dev.json` gitignoreado | Variables de entorno en CI | Secretos fuera del repo; `--dart-define-from-file` funciona en web/CI sin dependencias adicionales |

### 2.4 Control de calidad

- **Linting estricto**: `analysis_options.yaml` con reglas `flutter_lints` + `riverpod_lint`. El linter bloquea imports no relativos, strings hardcodeadas y patrones Riverpod incorrectos.
- **CI automático**: cada push ejecuta `dart format --set-exit-if-changed`, `flutter analyze` y `flutter test`. Un fallo bloquea el merge.
- **Cobertura de tests en dominio**: cada calculadora de escala cubre todos los umbrales clínicos y casos inválidos (inputs fuera de rango, mapas vacíos).

---

## 3. Planificación

### 3.1 Planificación inicial (estimación previa)

Estimaciones realizadas antes de iniciar cada fase, basadas en complejidad percibida.

| Tarea | Fase | Horas estimadas |
|---|---|---|
| Diseño arquitectónico y plan inicial | — | 1,0 h |
| Fase 0: Scaffold Flutter + CI + i18n | 0 | 2,0 h |
| Fase 1: Auth (login/register/disclaimer/guard) | 1 | 3,0 h |
| Fase 1: GCS (calculadora + pantalla + tests) | 1 | 2,0 h |
| Fase 1: Evaluations (guardado + RLS) | 1 | 2,0 h |
| Fase 1: Migración Supabase + smoke test E2E | 1 | 1,0 h |
| GitHub setup + conexión remoto | — | 0,5 h |
| **Total Fase 0 + Fase 1** | | **11,5 h** |
| Fase 2A.1: Refactor + History básica | 2A | 3,0 h |
| Fase 2A.2: Filtros + búsqueda + paginación | 2A | 2,0 h |
| Fase 2A.3: Gráficos fl_chart | 2A | 2,5 h |
| Fase 2A.4: mRS 0-6 | 2A | 1,5 h |
| Fase 2A.5: Barthel Index | 2A | 2,0 h |
| Fase 2A.6: ABCD2 | 2A | 1,5 h |
| **Total Fase 2A** | | **12,5 h** |
| Fase 2B: NIHSS (15 ítems, lógica condicional) | 2B | 6,0 h |
| Fase 3: Algoritmos + Offline + Perfil | 3 | 10,0 h |
| **TOTAL PROYECTO (estimado)** | | **40,0 h** |

### 3.2 Planificación real (tiempo dedicado — fases completadas)

Reconstruida a partir de commits git y sesiones de trabajo documentadas.

| Tarea | Commit(s) | Fecha | Horas reales |
|---|---|---|---|
| Diseño arquitectónico y plan inicial | — | 2026-04-25/26 | ~2,0 h |
| Fase 0: Scaffold (104 archivos, +3.157 líneas) | `94193df` | 2026-04-26 15:43 | ~1,5 h |
| Fase 1: Auth completa | `6d677db` | 2026-04-26 15:43→17:08 | ~2,0 h |
| Fase 1: GCS + entidades base + 124 líneas test | `6d677db` | 2026-04-26 | ~1,5 h |
| Fase 1: Evaluations + ResultScreen + disclaimer | `6d677db` | 2026-04-26 | ~1,0 h |
| Fase 1: Migración Supabase + E2E smoke test | `a127711` | 2026-04-27 13:00 | ~1,5 h |
| GitHub setup + issues + documentación | — | 2026-04-27 | ~1,0 h |
| **Total Fase 0 + Fase 1 (real)** | | | **~10,5 h** |
| Fase 2A.1: Refactor ResultScreen + History básica | `4c1706a` | 2026-04-27 | ~3,0 h |
| Fase 2A.2: Filtros, búsqueda y paginación | `c822d01` | 2026-04-27 | ~2,0 h |
| Fase 2A.3: Gráficos evolución fl_chart | `6cde524` | 2026-04-27 | ~2,5 h |
| Fase 2A.4: mRS 0-6 | `2e10959` | 2026-04-27 | ~1,5 h |
| Fase 2A.5: Barthel Index 0-100 | `7ced22c` | 2026-04-27 | ~2,0 h |
| Fase 2A.6: ABCD2 + migración SQL | `902594c` | 2026-04-27 | ~1,5 h |
| **Total acumulado Fase 2A (real)** | | | **~23,0 h** |
| Fase 2B.1: NIHSS dominio + UN=9 + 27 tests | `70d2a59` | 2026-04-28 | ~3,0 h |
| Fase 2B.2: NIHSS pantalla + advisory coma + wiring | `f94c775` | 2026-04-28 | ~2,0 h |
| **Total acumulado Fase 2B (real)** | | | **~28,0 h** |

### 3.3 Análisis de desviaciones (Fases 0, 1, 2A, 2B y 3)

| Tarea | Estimado | Real | Desviación | Causa |
|---|---|---|---|---|
| Diseño arquitectónico | 1,0 h | 2,0 h | +1,0 h | Se decidieron más capas de las previstas inicialmente (errores, extensions, providers de Supabase) |
| Fase 0 scaffold | 2,0 h | 1,5 h | −0,5 h | Automatización con Claude Code más eficiente de lo esperado |
| Fase 1 Auth | 3,0 h | 2,0 h | −1,0 h | Clean Architecture bien definida → implementación directa sin dudas |
| Fase 1 GCS | 2,0 h | 1,5 h | −0,5 h | Función pura + entidades base reutilizables simplificaron el trabajo |
| Fase 1 Evaluations | 2,0 h | 1,0 h | −1,0 h | El repositorio y datasource siguieron el mismo patrón de auth |
| Fase 1 Supabase | 1,0 h | 1,5 h | +0,5 h | Problemas de autenticación MCP en sesión anterior; requirió nueva sesión |
| GitHub setup | 0,5 h | 1,0 h | +0,5 h | gh CLI no estaba en PATH; configuración de credenciales HTTPS |
| Fase 2A.1: Refactor + History | 3,0 h | 3,0 h | 0,0 h | En línea con la estimación; la skill phase-close añadió overhead mínimo |
| Fase 2A.2: Filtros + búsqueda + paginación | 2,0 h | 2,0 h | 0,0 h | Estimación precisa; el patrón de named params en mocktail añadió ~15 min recuperados en el debounce |
| Fase 2A.3: Gráficos fl_chart | 2,5 h | 2,5 h | 0,0 h | Estimación precisa; incompatibilidad fl_chart 0.71→0.68 por Flutter 3.24 añadió ~20 min de diagnóstico |
| Fase 2A.4: mRS 0-6 | 1,5 h | 1,5 h | 0,0 h | create-scale skill ejecutó el patrón directamente; 0 correcciones en analyze |
| Fase 2A.5: Barthel Index | 2,0 h | 2,0 h | 0,0 h | Validación por conjunto (no rango) añadió complejidad de tests; import duplicado requirió fix menor |
| Fase 2A.6: ABCD2 + migración | 1,5 h | 1,5 h | 0,0 h | Patrón idéntico a Barthel; migración via MCP directa sin incidencias |
| **Total Fase 2A completa** | **24,0 h** | **23,0 h** | **−1,0 h** | **Desviación total: −4,2%** |
| Fase 2B: NIHSS (dominio + UI) | 6,0 h | 5,0 h | −1,0 h | Lógica condicional NIHSS resultó ser UN=9 por ítem (sin motor de reglas inter-ítem); simplificó dominio y UI. CI debugging/higiene git añadió ~1h no prevista que compensó parte del ahorro |
| **Total Fase 2B completa** | **6,0 h** | **5,0 h** | **−1,0 h** | **Desviación: −16,7%** |
| **TOTAL ACUMULADO Fases 0-2B** | **40,0 h** | **28,0 h** | **−12,0 h** | **Desviación acumulada: −30%** |
| Fase 3: UX shell + Patients (3 subfases) | 10,5 h | 11,0 h | +0,5 h | Diseño con Opus amplió el scope (skills, patient picker, ARB completo). Sesión de CI debugging en 3.1 añadió overhead. La implementación de fl_chart fue literalmente un rename de EvolutionTab, por lo que 3.3 fue muy rápida. Balance: prácticamente en estimación. |
| **Total Fase 3 completa** | **10,5 h** | **11,0 h** | **+0,5 h** | **Desviación: +4,8%** |
| **TOTAL ACUMULADO Fases 0-3** | **50,5 h** | **39,0 h** | **−11,5 h** | **Desviación acumulada: −22,8%** |
| Fase 4.1: Algoritmos clínicos | 4,0 h | 1,5 h | −2,5 h | Sealed classes Dart 3 + travesía pura simplificaron dominio. Extension method para lookup l10n sin infraestructura adicional. |
| Fase 4.2: Modo offline (drift) | 3,0 h | 2,0 h | −1,0 h | Incompatibilidad de versiones drift/drift_flutter añadió ~30 min de diagnóstico. Resto en línea con estimación. |
| Fase 4.3: Multilenguaje EN | 1,0 h | 2,5 h | +1,5 h | Traducción de ~300 claves (incluyendo contenido clínico extenso de algoritmos) más costosa de lo estimado. |
| Fase 4.4: Pantalla de perfil | 2,0 h | 0,5 h | −1,5 h | Patrón de pantalla sencillo + lógica de idioma ya preparada desde 4.3. |
| **TOTAL ACUMULADO Fases 0-4 (PROYECTO COMPLETO)** | **50,5 h** | **45,5 h** | **−5,0 h** | **Desviación acumulada: −9,9%** |
| Fase 3.1: UX shell + back buttons + polish M3 | `6ddfe80` | 2026-04-28 | ~3,5 h |
| Fase 3.2: Modelo pacientes + CRUD + save flow | `c8e6845` | 2026-04-29 | ~5,5 h |
| Fase 3.3: Evolution chart + cleanup history | `fb55092` | 2026-04-30 | ~2,0 h |
| **Total acumulado Fase 3 (real)** | | | **~39,0 h** |
| Fase 4.1: Algoritmos clínicos (dominio + UI) | `884ff0c`, `01846f7` | 2026-04-30 | ~1,5 h |
| Fase 4.2: Modo offline (drift — Android/iOS) | `14a2b31` | 2026-04-30 | ~2,0 h |
| Fase 4.3: Multilenguaje EN | `b025b43` | 2026-04-30 | ~2,5 h |
| Fase 4.4: Pantalla de perfil + selector idioma | `ea1a77c` | 2026-04-30 | ~0,5 h |
| **Total acumulado Fase 4 completa (real)** | | | **~45,5 h** |
| Fase 6.1: Seguridad y release (signing + PII + osv-scanner) | (commits subfase 6.1) | 2026-05-08 | TBD (calculado en `phase-close`) |

**Conclusión de desviaciones (proyecto completo, Fases 0-4)**: La planificación fue ligeramente pesimista en implementación y optimista en contenido. Balance final: −5,0 h sobre estimación (−9,9%). Las mayores ganancias vinieron de la arquitectura bien definida; la única desviación positiva fue la traducción de contenido clínico extenso (Fase 4.3), no prevista en su totalidad.

---

## 4. Trazabilidad Git — Issues — Casos de uso

| Issue GitHub | Commit(s) | Caso de uso cubierto |
|---|---|---|
| [#1](https://github.com/grisllo/NeuroScaleApp/issues/1) | `94193df` | CU-00: Arrancar la aplicación sin credenciales |
| [#2](https://github.com/grisllo/NeuroScaleApp/issues/2) | `6d677db` | CU-01: Registrarse; CU-02: Iniciar sesión; CU-03: Ver disclaimer |
| [#3](https://github.com/grisllo/NeuroScaleApp/issues/3) | `6d677db` | CU-04: Completar escala GCS; CU-05: Ver resultado interpretado |
| [#4](https://github.com/grisllo/NeuroScaleApp/issues/4) | `6d677db` | CU-06: Guardar evaluación con descripción de caso |
| [#5](https://github.com/grisllo/NeuroScaleApp/issues/5) | `a127711` | CU-07: Datos persistidos en servidor con aislamiento por usuario (RLS) |
| [#6](https://github.com/grisllo/NeuroScaleApp/issues/6) | `4c1706a` | CU-08: Ver historial de evaluaciones propias; CU-08b: Borrar evaluación |
| [#7](https://github.com/grisllo/NeuroScaleApp/issues/7) | `c822d01` | CU-09: Filtrar historial por escala y fecha; CU-09b: Buscar por caso; CU-09c: Paginación |
| [#8](https://github.com/grisllo/NeuroScaleApp/issues/8) | `6cde524` | CU-10: Ver evolución temporal de una escala (LineChart normalizado) |
| [#9](https://github.com/grisllo/NeuroScaleApp/issues/9) | `2e10959` | CU-11: Completar escala mRS (grados 0-6, incluye fallecido) |
| [#10](https://github.com/grisllo/NeuroScaleApp/issues/10) | `7ced22c` | CU-12: Completar Barthel Index (10 ítems AVD, validación por conjunto) |
| [#11](https://github.com/grisllo/NeuroScaleApp/issues/11) | `902594c` | CU-13: Completar ABCD2 (riesgo post-AIT, 0-7, 5 ítems) |
| [#12](https://github.com/grisllo/NeuroScaleApp/issues/12) | `70d2a59`, `f94c775` | CU-14: Completar NIHSS (15 ítems, Untestable UN=9, advisory coma) |
| [#14](https://github.com/grisllo/NeuroScaleApp/issues/14) | `6ddfe80`, `c8e6845`, `fb55092` | CU-15: NavigationBar shell + Pacientes (CRUD + evolución por paciente) |
| [#13](https://github.com/grisllo/NeuroScaleApp/issues/13) | `884ff0c`, `01846f7` | CU-16: Algoritmos clínicos (tPA, HTA ictus, HSA Hunt-Hess/Fisher); árbol de decisión paso a paso |

---

## 5. Referencias

- Repositorio: https://github.com/grisllo/NeuroScaleApp
- Issues y milestones: https://github.com/grisllo/NeuroScaleApp/issues
- Milestones (Gantt por fases): https://github.com/grisllo/NeuroScaleApp/milestones
- `docs/ROADMAP.md` — fases, decisiones de diseño y criterios de aceptación
- `CLAUDE.md` — stack, comandos, convenciones del proyecto
- `supabase/migrations/` — migraciones SQL numeradas y versionadas
- `.github/workflows/ci.yaml` — pipeline CI con format, analyze y test
