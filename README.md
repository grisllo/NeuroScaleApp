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
    Scaffold Flutter + CI + i18n (~1.5h)      :done, f0,   2026-04-26, 1d

    section Fase 1 · MVP
    Auth (login / register / guard) (~1h)     :done, f1a,  2026-04-26, 1d
    GCS calculadora + tests (~1.5h)           :done, f1b,  2026-04-26, 1d
    Evaluations + ResultScreen (~1h)          :done, f1c,  2026-04-26, 1d
    Migración Supabase + smoke test (~1h)     :done, f1d,  2026-04-27, 1d

    section Fase 2A · Historial + Escalas
    Refactor + History básica (~2h)           :done, f2a1, 2026-04-27, 1d
    Filtros + búsqueda + paginación (~30m)    :done, f2a2, after f2a1, 1d
    Gráficos fl_chart (~45m)                  :done, f2a3, after f2a2, 1d
    mRS 0-6 (~20m)                            :done, f2a4, after f2a1, 1d
    Barthel Index 0-100 (~20m)                :done, f2a5, after f2a4, 1d
    ABCD2 riesgo post-AIT (~20m)              :done, f2a6, 2026-04-27, 1d

    section Fase 2B · NIHSS
    NIHSS 15 ítems condicionales (~4h)        :done, f2b,  2026-04-28, 1d

    section Fase 3 · UX + Pacientes
    3.1 Shell navegación + back (~2h)         :done, f3a,  2026-04-28, 1d
    3.2 Modelo pacientes BD + CRUD (~3h)      :done, f3b,  2026-04-29, 1d
    3.3 Patient detail + cleanup (~2h)        :done, f3c,  2026-04-30, 1d

    section Fase 4 · Algoritmos + Offline
    4.1 Algoritmos clínicos dom+UI (~3h)      :done, f4a,  2026-04-30, 1d
    4.2 Modo offline drift (~2h)              :done, f4b,  2026-04-30, 1d
    4.3 Multilenguaje EN (~1h)                :done, f4c,  2026-04-30, 1d
    4.4 Pantalla de perfil (~30m)             :done, f4d,  2026-04-30, 1d

    section Mantenimiento
    CI + compat. deps + i18n fixes (~2h)      :done, mnt,  2026-05-04, 1d
    CI format fix + UI tab cleanup (~0.5h)    :done, mnt2, 2026-05-11, 1d

    section Fase 5 · Design System & UX visual
    Design system + paleta + Inter (~30m)     :done, f5a,  2026-05-05, 1d
    Widgets animados + pantallas (~30m)       :done, f5b,  2026-05-05, 1d

    section Fase 6 · Saneamiento técnico
    6.1 Seguridad y release (~2h)             :done, f6a,  2026-05-08, 1d
    6.2 Optimización backend (~1h)            :done, f6b,  2026-05-08, 1d
    6.3 Refactor i18n + arquitectura (~0.5h)  :done, f6c,  2026-05-08, 1d
    6.4 Rendimiento web + tests + a11y (~0.5h):done, f6d,  2026-05-08, 1d

    section Fase 7 · Features de producto
    7.1 Indicador sin conexión (~0.5h)        :done, f7a,  2026-05-08, 1d
    7.2 Web/tablet responsive (~1h)           :done, f7b,  2026-05-08, 1d
    7.3 Modo tutorial por ítem (~1h)          :done, f7c,  2026-05-08, 1d
    section Fase 8 — Calidad
    8.1 Auditoría post-Fase 7 (~1h)           :done, f8a,  2026-05-08, 1d
    8.2 Auth hardening + nav fix (~2h)        :done, f8b,  2026-05-09, 1d
    section Fase 9 — Beta
    9.1 Password reset flow (~2h)             :done, f9a,  2026-05-09, 1d
    9.2 Despliegue web Netlify (~1h)          :done, f9b,  2026-05-09, 1d
    9.3 APK Android firmado (~0.5h)           :done, f9c,  2026-05-09, 1d
```

> Las estimaciones `(~Xh/m)` se derivan de los timestamps de los commits de git.
> Total acumulado: **~59h** de trabajo activo (Fases 0–9 + Mantenimiento).

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
