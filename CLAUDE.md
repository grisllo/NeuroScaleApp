# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

NeuroScale App — Flutter cross-platform application (Android, iOS, web) for applying, calculating, recording and interpreting neurological scales (GCS, NIHSS, Rankin, Barthel) and clinical algorithms. Targeted at medical professionals and students. Backend: Supabase (Auth + PostgreSQL + Storage).

⚠️ **Medical context**: this is a clinical decision-support tool. Calculation correctness is non-negotiable. Domain logic must be pure functions with exhaustive unit tests covering every boundary score. The disclaimer in the UI does not exempt the codebase from clinical accuracy.

## Commands

Flutter is installed at `C:\Users\grisllo\dev\flutter\bin\` (Windows). Use PowerShell to run Flutter commands — bash on this machine does not have Flutter on its PATH.

| Task | Command |
| --- | --- |
| Install deps | `flutter pub get` |
| Generate l10n | `flutter gen-l10n` (also runs on `flutter pub get` when `generate: true`) |
| Static analysis | `flutter analyze` |
| Run all tests | `flutter test` |
| Run a single test | `flutter test test/path/to/file_test.dart` |
| Run with env (dev) | `flutter run --dart-define-from-file=env/dev.json` |
| Format | `dart format lib test` |
| Build APK (dev) | `flutter build apk --dart-define-from-file=env/dev.json` |
| Build web (dev) | `flutter build web --dart-define-from-file=env/dev.json` |

`env/dev.json` is gitignored. Use `env/dev.example.json` as a template — it lists `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SENTRY_DSN`, `FLAVOR`. The app initialises Supabase and Sentry **conditionally** — running without those keys works (UI placeholders only), so the project boots from a clean clone without setup.

## Architecture

**Feature-first with Clean Architecture layers inside each feature.** This was chosen over root-level `data/`/`domain/`/`presentation/` because the project will accumulate many features (auth, evaluations, history, four scales, algorithms) and feature-level cohesion scales better.

```
lib/
├── core/                          shared infrastructure
│   ├── theme/   routing/   env/   errors/   constants/   utils/
├── features/
│   ├── auth/                      data/  domain/  presentation/
│   ├── scales/
│   │   ├── shared/                base entities (Scale, ScaleResult, Severity)
│   │   ├── gcs/                   data/  domain/  presentation/
│   │   ├── nihss/  rankin/  barthel/ (added in later phases)
│   ├── evaluations/               persistence of completed scale evaluations
│   └── history/                   listing + charts
└── l10n/                          ARB files; generated/ excluded from analyzer
```

**Layer rules** (enforced by code review):
- UI never reaches the data layer or Supabase directly. Flow: `UI → Provider → UseCase → Repository → DataSource → Supabase`.
- Clinical scale calculations live in `domain/` as **pure functions** — easy to test, no Flutter or Supabase imports.
- Repositories return `Either<Failure, T>` style or throw `Failure` (never raw exceptions). Datasources throw `AppException` subtypes; repositories convert.
- `presentation/` uses Riverpod (`AsyncNotifier`/`Notifier`) — no business logic in widgets.

**Routing** uses `go_router` via `appRouterProvider` (Riverpod). Auth guard will redirect unauthenticated users once auth is wired in Phase 1.

**i18n** is set up from day 1 via `intl` + `flutter_localizations`. All user-facing strings go in `lib/l10n/app_es.arb` (or future `app_en.arb`). Generated code lives in `lib/l10n/generated/` and is excluded from analyzer.

## Conventions

- Dart files: `snake_case`. Classes: `PascalCase`. Constants: `SCREAMING_SNAKE_CASE` only for true constants; otherwise `camelCase`.
- Imports inside `lib/` use **relative paths** (enforced by linter rule `prefer_relative_imports`).
- Strings: prefer single quotes (lint rule).
- Trailing commas required (lint rule) — they make diffs cleaner and help formatter.
- Commits: Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`).
- `case_description` on evaluations is free text but **must not contain PII**. Warn in the UI before saving.
- Bundle id / `--org`: `com.neuroscale`.

## Roadmap and constraints

The implementation roadmap lives at `~/.claude/plans/wild-imagining-creek.md` (approved 2026-04-26). Key points:

- **MVP (Fase 1)**: auth + GCS + persistence with RLS.
- **Fase 2A**: history + Rankin + Barthel.
- **Fase 2B**: NIHSS isolated due to its 15-item conditional logic.
- **Fase 3**: clinical algorithms, offline mode, profile.
- The `patients` table from the original spec was deliberately deferred to Fase 3 — for MVP, evaluations carry a free-text `case_description` only.

## Skills

| Skill | Command | When to use |
| --- | --- | --- |
| `create-scale` | `/create-scale` | Scaffold a new neurological scale (calculator, screen, ARB strings, boundary tests) |
| `phase-close` | `/phase-close` | End-of-subfase checklist: analyze → test → update docs → close GitHub issue → commit → push |

`phase-close` asks for: subfase ID, GitHub issue number, real hours spent, and whether it closes a full phase.

## Working with Claude Code in this repo

1. **Plan first, implement after**. The user prefers `/plan` mode for non-trivial work. Wait for approval before editing.
2. **Never store PII**. Real names, DNI, identifiers — even in test fixtures.
3. **Tests are mandatory for every scale calculator**. Cover boundaries (every interpretation threshold) and invalid inputs.
4. **Run `flutter analyze` before committing.** CI will block PRs that fail analyze or test.
5. **i18n**: every new user-facing string goes through ARB. Don't hardcode in widgets.
6. **Run `/phase-close` at the end of every subfase** to keep docs, issues and the Gantt actualizados.
