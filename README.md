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
    Refactor + History básica          :done, f2a1, 2026-04-27, 1d
    Filtros + búsqueda + paginación    :done, f2a2, after f2a1, 1d
    Gráficos fl_chart                  :done, f2a3, after f2a2, 1d
    mRS 0-6                            :done, f2a4, after f2a1, 1d
    Barthel Index 0-100                :done, f2a5, after f2a4, 1d
    ABCD2 riesgo post-AIT              :done, f2a6, 2026-04-27, 1d

    section Fase 2B · NIHSS
    NIHSS 15 ítems condicionales       :done, f2b, 2026-04-28, 1d

    section Fase 3 · UX + Pacientes
    3.1 Shell navegación + back         :done, f3a, 2026-04-28, 1d
    3.2 Modelo pacientes BD + CRUD      :done, f3b, 2026-04-29, 1d
    3.3 Patient detail + cleanup        :done, f3c, 2026-04-30, 1d

    section Fase 4 · Algoritmos + Offline
    4.1 Algoritmos clínicos (dom + UI)  :done, f4a, 2026-04-30, 1d
    4.2 Modo offline (drift)            :done, f4b, 2026-04-30, 1d
    4.3 Multilenguaje EN                :done, f4c, 2026-04-30, 1d
    4.4 Pantalla de perfil              :done, f4d, 2026-04-30, 1d

    section Mantenimiento
    CI + compat. deps + i18n fixes      :done, mnt, 2026-05-04, 1d

    section Fase 5 · Design System & UX visual
    Design system + paleta + Inter      :done, f5a, 2026-05-05, 1d
    Widgets animados + pantallas        :done, f5b, 2026-05-05, 1d
```

---

## Stack

| Capa | Tecnología |
|---|---|
| Frontend | Flutter 3.x · Material 3 · Inter (google_fonts) |
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
