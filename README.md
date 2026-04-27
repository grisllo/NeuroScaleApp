# NeuroScale App

Aplicación multiplataforma (Android · iOS · Web) para aplicar, calcular e interpretar escalas neurológicas clínicas: GCS, NIHSS, mRS, Barthel e ABCD2.

Dirigida a profesionales de la salud y estudiantes. Backend: Supabase (Auth + PostgreSQL + RLS).

---

## Planificación real — Diagrama de Gantt

> Fechas contrastables con los commits de este repositorio.

```mermaid
gantt
    title NeuroScale App — Planificación real vs estimada
    dateFormat  YYYY-MM-DD
    axisFormat  %d/%m

    section Fase 0 · Bootstrap
    Scaffold Flutter + CI + i18n       :done, f0,  2026-04-26, 1d

    section Fase 1 · MVP
    Auth (login / register / guard)    :done, f1a, 2026-04-26, 1d
    GCS calculadora + tests            :done, f1b, 2026-04-26, 1d
    Evaluations + ResultScreen         :done, f1c, 2026-04-26, 1d
    Migración Supabase + smoke test    :done, f1d, 2026-04-27, 1d

    section Fase 2A · Historial + Escalas
    Refactor + History básica          :active, f2a1, 2026-04-27, 4d
    Filtros + búsqueda + paginación    :f2a2, after f2a1, 3d
    Gráficos fl_chart                  :f2a3, after f2a2, 3d
    mRS 0-6                            :f2a4, after f2a1, 2d
    Barthel Index 0-100                :f2a5, after f2a4, 2d
    ABCD2 riesgo post-AIT              :f2a6, after f2a5, 2d

    section Fase 2B · NIHSS
    NIHSS 15 ítems condicionales       :f2b,  2026-05-12, 10d

    section Fase 3 · Algoritmos + Offline
    Algoritmos + Offline + Perfil      :f3,   2026-05-25, 21d
```

---

## Stack

| Capa | Tecnología |
|---|---|
| Frontend | Flutter 3.x · Material 3 |
| Estado | Riverpod (`AsyncNotifier`) |
| Navegación | go_router |
| Backend | Supabase (Auth + PostgreSQL + RLS) |
| i18n | intl + ARB files |
| CI | GitHub Actions |

## Arquitectura

Feature-first con Clean Architecture. Flujo estricto:
`UI → Provider → UseCase → Repository → DataSource → Supabase`

Las calculadoras de escalas son **funciones puras** en `domain/` — sin imports Flutter/Supabase, testables de forma exhaustiva.

## Comandos

```powershell
# Instalar dependencias
flutter pub get

# Tests
flutter test

# Análisis estático
flutter analyze

# Ejecutar en Chrome (dev)
flutter run --dart-define-from-file=env/dev.json -d chrome
```

## Documentación

- [`docs/ROADMAP.md`](docs/ROADMAP.md) — fases, entregables y decisiones de diseño
- [`docs/METODOLOGIA_Y_PLANIFICACION.md`](docs/METODOLOGIA_Y_PLANIFICACION.md) — metodología, planificación estimada vs real, análisis de desviaciones
- [Issues y milestones](https://github.com/grisllo/NeuroScaleApp/issues) — trazabilidad completa de tareas
