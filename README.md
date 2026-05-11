# NeuroScale App

Aplicación multiplataforma **(Android · iOS · Web)** para profesionales de la salud y estudiantes de medicina. Permite aplicar escalas neurológicas estandarizadas, calcular puntuaciones, interpretar resultados clínicos y registrar evaluaciones de forma anonimizada por paciente.

**Producción web:** [neuroscale.netlify.app](https://neuroscale.netlify.app)

---

## Funcionalidades

### Escalas neurológicas
| Escala | Rango | Uso clínico |
|---|---|---|
| GCS (Glasgow Coma Scale) | 3–15 | Nivel de consciencia |
| NIHSS | 0–42 | Gravedad del ictus isquémico |
| mRS (Modified Rankin Scale) | 0–6 | Discapacidad neurológica post-ictus |
| Barthel Index | 0–100 | Independencia funcional en AVD |
| ABCD2 | 0–7 | Riesgo de ictus tras AIT |

### Algoritmos clínicos
Árboles de decisión paso a paso con indicación de urgencia: Código Ictus, HTA en el ictus, HSA (Hunt-Hess / Fisher).

### Pacientes y evaluaciones
- Gestión de pacientes anonimizados (alias libre, sin PII)
- Evaluaciones vinculadas a paciente con notas clínicas
- Gráficos de evolución temporal por escala
- Borrado de pacientes y evaluaciones individuales

### Cuenta y preferencias
- Registro, login, recuperación y cambio de contraseña
- Borrado de cuenta con eliminación completa de datos
- Tema claro / oscuro / sistema (persistido)
- Idioma ES / EN (persistido)

### Calidad técnica
- **191 tests** — calculadoras cubren todos los umbrales clínicos
- Modo offline con SQLite (Drift) para Android e iOS
- Modo tutorial por ítem en escalas complejas
- Responsive: NavigationBar (móvil) / NavigationRail (tablet/web)

---

## Planificación real — Diagrama de Gantt

> Fechas contrastables con los commits de este repositorio.

```mermaid
gantt
    title NeuroScale App - Planificacion real vs estimada
    dateFormat  YYYY-MM-DD
    axisFormat  %d/%m

    section Fase 0 - Bootstrap
    Scaffold Flutter + CI + i18n (1.5h)      :done, f0,   2026-04-26, 1d

    section Fase 1 - MVP
    Auth login + register + guard (1h)       :done, f1a,  2026-04-26, 1d
    GCS calculadora + tests (1.5h)           :done, f1b,  2026-04-26, 1d
    Evaluations + ResultScreen (1h)          :done, f1c,  2026-04-26, 1d
    Migracion Supabase + smoke test (1h)     :done, f1d,  2026-04-27, 1d

    section Fase 2A - Historial + Escalas
    Refactor + History basica (2h)           :done, f2a1, 2026-04-27, 1d
    Filtros + busqueda + paginacion (30m)    :done, f2a2, after f2a1, 1d
    Graficos fl_chart (45m)                  :done, f2a3, after f2a2, 1d
    mRS 0-6 (20m)                            :done, f2a4, after f2a1, 1d
    Barthel Index 0-100 (20m)                :done, f2a5, after f2a4, 1d
    ABCD2 riesgo post-AIT (20m)              :done, f2a6, 2026-04-27, 1d

    section Fase 2B - NIHSS
    NIHSS 15 items condicionales (4h)        :done, f2b,  2026-04-28, 1d

    section Fase 3 - UX + Pacientes
    3.1 Shell navegacion + back (2h)         :done, f3a,  2026-04-28, 1d
    3.2 Modelo pacientes BD + CRUD (3h)      :done, f3b,  2026-04-29, 1d
    3.3 Patient detail + cleanup (2h)        :done, f3c,  2026-04-30, 1d

    section Fase 4 - Algoritmos + Offline
    4.1 Algoritmos clinicos dom+UI (3h)      :done, f4a,  2026-04-30, 1d
    4.2 Modo offline drift (2h)              :done, f4b,  2026-04-30, 1d
    4.3 Multilenguaje EN (1h)                :done, f4c,  2026-04-30, 1d
    4.4 Pantalla de perfil (30m)             :done, f4d,  2026-04-30, 1d

    section Mantenimiento
    CI Node.js 24 + Android compat (1h)      :done, mnt0, 2026-04-28, 1d
    CI + compat. deps + i18n fixes (2h)      :done, mnt,  2026-05-04, 1d
    CI format fix + UI tab cleanup (0.5h)    :done, mnt2, 2026-05-11, 1d
    Borrado pacientes + evaluaciones (1h)    :done, mnt3, 2026-05-11, 1d
    Fix interpretation keys legacy BD (1h)   :done, mnt4, 2026-05-11, 1d
    Grafico evolucion - hora y eje (1h)      :done, mnt5, 2026-05-11, 1d
    Revision UI/UX global pantallas (5h)     :done, mnt6, 2026-05-11, 1d

    section Fase 5 - Design System y UX
    Design system + paleta + Inter (30m)     :done, f5a,  2026-05-05, 1d
    Widgets animados + pantallas (30m)       :done, f5b,  2026-05-05, 1d

    section Fase 6 - Saneamiento tecnico
    6.1 Seguridad y release (2h)             :done, f6a,  2026-05-08, 1d
    6.2 Optimizacion backend (1h)            :done, f6b,  2026-05-08, 1d
    6.3 Refactor i18n + arquitectura (0.5h)  :done, f6c,  2026-05-08, 1d
    6.4 Rendimiento web + tests + a11y (0.5h) :done, f6d,  2026-05-08, 1d

    section Fase 7 - Features de producto
    7.1 Indicador sin conexion (0.5h)        :done, f7a,  2026-05-08, 1d
    7.2 Web/tablet responsive (1h)           :done, f7b,  2026-05-08, 1d
    7.3 Modo tutorial por item (1h)          :done, f7c,  2026-05-08, 1d

    section Fase 8 - Calidad
    8.1 Auditoria post-Fase 7 (1h)           :done, f8a,  2026-05-08, 1d
    8.2 Auth hardening + nav fix (2h)        :done, f8b,  2026-05-09, 1d

    section Fase 9 - Beta
    9.1 Password reset flow (2h)             :done, f9a,  2026-05-09, 1d
    9.2 Despliegue web Netlify (1h)          :done, f9b,  2026-05-09, 1d
    9.3 APK Android firmado (0.5h)           :done, f9c,  2026-05-09, 1d
```

> Tiempos derivados de los timestamps de los commits de git.
> Total acumulado: **~68h** de trabajo activo (Fases 0–9 + Mantenimiento).

---

## Stack

| Capa | Tecnología |
|---|---|
| Frontend | Flutter 3.41.9 · Material 3 · Inter (google_fonts) |
| Estado | Riverpod (`AsyncNotifier` / `Notifier`) |
| Navegación | go_router · `StatefulShellRoute` |
| Backend | Supabase (Auth + PostgreSQL + RLS + Edge Functions) |
| Offline | Drift (SQLite) — Android e iOS |
| i18n | intl + ARB files — ES + EN |
| Error tracking | Sentry (condicional) |
| CI/CD | GitHub Actions + Netlify |

## Arquitectura

**Feature-first con Clean Architecture.** Flujo estricto:

```
UI → Provider (Riverpod) → UseCase → Repository → DataSource → Supabase
```

- Calculadoras de escalas: **funciones puras** en `domain/` — sin imports Flutter/Supabase, con tests exhaustivos de frontera
- Repositorios lanzan `Failure` (nunca excepciones crudas); datasources lanzan `AppException`
- Navegación persistente: `StatefulShellRoute.indexedStack` con 4 branches
- Offline-first: caché local Drift + sincronización con Supabase al recuperar conexión

## Comandos

```powershell
# Dependencias
flutter pub get

# Tests (191 en total)
flutter test

# Análisis estático
flutter analyze

# Ejecutar en web (dev)
flutter run --dart-define-from-file=env/dev.json -d chrome

# Formatear
dart format lib test
```

> Requiere `env/dev.json` (usa `env/dev.example.json` como plantilla). La app arranca sin credenciales — Supabase y Sentry se inicializan condicionalmente.

## Documentación

- [`docs/ROADMAP.md`](docs/ROADMAP.md) — fases, entregables y decisiones de diseño
- [`docs/METODOLOGIA_Y_PLANIFICACION.md`](docs/METODOLOGIA_Y_PLANIFICACION.md) — metodología, planificación estimada vs real, análisis de desviaciones (~68h)
- [Issues y milestones](https://github.com/grisllo/NeuroScaleApp/issues) — trazabilidad completa de tareas
