# CLAUDE.md

Guidance for [Claude Code](https://claude.ai/code) when working in this repository.

---

## Project

**NeuroScale App** — Flutter cross-platform application (Android, iOS, web) for applying, calculating, recording and interpreting neurological scales (GCS, NIHSS, mRS, Barthel, ABCD2) and clinical decision algorithms. Targeted at medical professionals and students. Backend: Supabase (Auth + PostgreSQL + Row Level Security + Edge Functions).

Status: **v1.0.0** released on 2026-05-13. 204 tests green, `flutter analyze` at 0 issues, ~87 h of active development. Web production: <https://grisllo.github.io/NeuroScaleApp/>.

⚠️ **Medical context**: this is a clinical decision-support tool. Calculation correctness is non-negotiable. Domain logic must be implemented as pure functions with exhaustive unit tests covering every boundary score. The disclaimer in the UI does not exempt the codebase from clinical accuracy.

---

## Commands

Flutter is installed at `C:\Users\grisllo\dev\flutter\bin\` on this Windows machine. Use **PowerShell** to run Flutter commands — `bash` on this host does not have Flutter on its `PATH`. Bash from this environment is usable for `git` and POSIX-style scripts.

| Task | Command |
| --- | --- |
| Install dependencies | `flutter pub get` |
| Generate localisations | `flutter gen-l10n` (also runs on `flutter pub get` when `generate: true`) |
| Static analysis | `flutter analyze` |
| Run all tests | `flutter test` |
| Run tests with coverage | `flutter test --coverage` |
| Run a single test file | `flutter test test/path/to/file_test.dart` |
| Filter tests by name | `flutter test --plain-name "GCS boundary"` |
| Run in web (dev) | `flutter run --dart-define-from-file=env/dev.json -d chrome` |
| Format | `dart format lib test` |
| Build APK (dev) | `flutter build apk --dart-define-from-file=env/dev.json` |
| Build web (dev) | `flutter build web --dart-define-from-file=env/dev.json` |
| Build web (prod) | `flutter build web --dart-define-from-file=env/prod.json --base-href /NeuroScaleApp/` |

`env/dev.json` is gitignored. Use `env/dev.example.json` as a template — it lists `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_REDIRECT_URL`, `SENTRY_DSN`, `FLAVOR`. The app initialises Supabase and Sentry **conditionally** — running without those keys works (UI placeholders only), so the project boots from a clean clone without setup.

---

## Architecture

**Feature-first with Clean Architecture layers inside each feature.** This layout was chosen over a root-level `data/`/`domain/`/`presentation/` split because the project accumulates many features (auth, evaluations, patients, five scales, algorithms), and feature-level cohesion scales better as the project grows.

```
lib/
├── core/                          shared infrastructure
│   ├── theme/   routing/   env/   errors/   constants/
│   ├── extensions/   providers/   utils/   widgets/   database/
├── features/
│   ├── auth/                      data/  domain/  presentation/
│   ├── scales/
│   │   ├── shared/                base entities (ScaleItem, ScaleResult, Severity)
│   │   ├── gcs/   nihss/   rankin/   barthel/   abcd2/
│   ├── evaluations/               persistence of completed scale evaluations (local + remote)
│   ├── patients/                  patient management (CRUD + temporal evolution chart)
│   └── algorithms/                clinical decision trees (Stroke Code, HTA, SAH)
└── l10n/                          app_es.arb + app_en.arb; generated/ excluded from analyzer
```

**Layer rules** (enforced by code review):

- UI never reaches the data layer or Supabase directly. Flow: `UI → Provider → UseCase → Repository → DataSource → Supabase / Drift`.
- Clinical scale calculations live in `domain/` as **pure functions** — no Flutter or Supabase imports, trivially testable.
- Repositories **throw `Failure`** subtypes (never raw exceptions). Datasources throw `AppException` subtypes; repositories convert them to `Failure` in catch blocks. Controllers use `AsyncValue.guard()` to catch. No `Either<L,R>` — deliberately avoided to keep the code simple (see `docs/ROADMAP.md` → _Decisiones arquitectónicas clave_).
- `presentation/` uses Riverpod (`AsyncNotifier` / `Notifier`) — no business logic in widgets.

**Routing** uses `go_router` via `appRouterProvider` (Riverpod). The auth guard redirects unauthenticated users to `/login`; `passwordRecoveryProvider` takes precedence and routes to `/reset-password` when a recovery flow is active.

**i18n** uses `intl` + `flutter_localizations`. All user-facing strings go in `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb` (≈ 519 keys per language). Generated code lives in `lib/l10n/generated/` and is excluded from analyzer.

**Local persistence**: Drift (SQLite) with two tables (`Evaluations`, `Patients`) configured in `lib/core/database/app_database.dart`. The strategy is cache-aside: remote-first, with the local cache acting as fallback when offline.

---

## Conventions

- Dart files: `snake_case`. Classes: `PascalCase`. Constants: `SCREAMING_SNAKE_CASE` only for true constants; otherwise `camelCase`.
- Imports inside `lib/` use **relative paths** (enforced by linter rule `prefer_relative_imports`).
- Strings: prefer single quotes (lint rule).
- Trailing commas required (lint rule) — they keep diffs cleaner and help the formatter.
- Commits: Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`). Subject in present tense, lowercase, with a short scope when useful (`feat(security): ...`).
- `case_description` on evaluations is free text but **must not contain PII**. The UI warns and blocks the save when PII is detected (`pii_detector.dart`).
- Bundle id / `--org`: `com.neuroscale`.

---

## Roadmap and constraints

The full roadmap lives in [`docs/ROADMAP.md`](docs/ROADMAP.md). The project reached **v1.0.0** on 2026-05-13. All planned phases are complete:

- **Fases 0–2B**: scaffold, auth, GCS, history, mRS, Barthel, ABCD2, NIHSS.
- **Fase 3**: UX shell + patient model.
- **Fase 4**: clinical algorithms, offline mode (Drift), EN localisation, profile screen.
- **Fases 5–9**: design system, security hardening, responsive layout, tutorial mode, beta deploy.
- **Fases 10–14**: polish, animations, UX fixes, production audit, `v1.0.0` tag.
- **Post v1.0.0 maintenance**: documentation polish, proprietary license, auth UI dark mode.

---

## Skills

The repository ships with the following Claude Code skills under `.claude/skills/`:

| Skill | Command | When to use |
| --- | --- | --- |
| `create-scale` | `/create-scale` | Scaffold a new neurological scale (pure calculator, screen placeholder, ARB keys ES+EN, boundary tests). |
| `phase-close` | `/phase-close` | End-of-subfase checklist: analyze + test + update docs (ROADMAP + Gantt) + close GitHub issue + commit + push. |
| `flutter-setup-declarative-routing` | `/flutter-setup-declarative-routing` | StatefulShellRoute + bottom nav + deep linking patterns (go_router). |
| `flutter-apply-architecture-best-practices` | `/flutter-apply-architecture-best-practices` | Validate feature structure (UI / Domain / Data layers, Repository pattern). |
| `flutter-build-responsive-layout` | `/flutter-build-responsive-layout` | LayoutBuilder + MediaQuery patterns for adaptive layouts (mobile + web). |
| `flutter-animations` | `/flutter-animations` | Implicit, explicit, hero, staggered and physics-based animations; lifecycle bugs. |
| `fl-chart-patterns` | `/fl-chart-patterns` | Project-specific conventions for `fl_chart` (score normalisation, tooltips, multi-series, empty states). |
| `ui-ux-pro-max` | `/ui-ux-pro-max` | UX/UI review and design intelligence: accessibility, touch targets, navigation, animation, forms. |
| `supabase-postgres-best-practices` | `/supabase-postgres-best-practices` | RLS, schema design, index strategy, FK conventions for Supabase. |
| `find-skills` | `/find-skills` | Discover and install agent skills. |

`phase-close` automatically computes the hours spent from git commit timestamps; it asks only for subfase ID, GitHub issue number and whether the subfase closes a full phase.

---

## Working with Claude Code in this repo

1. **Plan first, implement after**. For non-trivial work, propose a plan and wait for approval before editing.
2. **Never store PII**. No real names, DNI/NIE, identifiers, emails or phone numbers — even in test fixtures or comments.
3. **Tests are mandatory for every scale calculator**. Cover every interpretation threshold and invalid inputs.
4. **Run `flutter analyze` before committing.** CI blocks PRs that fail format, analyze, test or `osv-scanner`.
5. **`dart format` before pushing**, especially after editing files with the `Edit` tool — manual edits often miss formatting that the CI enforces.
6. **i18n**: every new user-facing string goes through ARB (both ES and EN). Don't hardcode in widgets.
7. **Invoke skills proactively**: for UI/UX, architecture, data or animation decisions, call the relevant skill before answering from general knowledge.
8. **Calculate hours from git timestamps**: never ask the user; derive elapsed time from commit ranges.
9. **Run `/phase-close` at the end of every subfase** to keep `docs/ROADMAP.md`, the GitHub issue and the Gantt in `README.md` in sync.

---

## Accessibility checklist (for new features)

Apply to every new screen or widget before committing. This checklist is mirrored in [`docs/CONTRIBUTING.md`](docs/CONTRIBUTING.md) §10.

- [ ] All `IconButton` have `tooltip:`.
- [ ] Meaningful images and avatars wrapped in `Semantics(label: ..., excludeSemantics: true)`.
- [ ] Decorative icons wrapped in `ExcludeSemantics`.
- [ ] Information is not conveyed by colour alone (`color-not-only`).
- [ ] Touch targets ≥ 44 × 44 pt (use `SizedBox` or padding when needed).
- [ ] Password fields have a show/hide toggle with `showPasswordTooltip` / `hidePasswordTooltip`.
- [ ] New user-facing strings have ARB keys in both `app_es.arb` and `app_en.arb`.

---

## Related documents

- [`docs/ROADMAP.md`](docs/ROADMAP.md) — phases, deliverables, design decisions.
- [`docs/METODOLOGIA_Y_PLANIFICACION.md`](docs/METODOLOGIA_Y_PLANIFICACION.md) — methodology, estimated vs real hours, deviations.
- [`docs/RELEASE_GUIDE.md`](docs/RELEASE_GUIDE.md) — build, secrets, deploy, rollback, pre-release checklist.
- [`docs/SECURITY.md`](docs/SECURITY.md) — RLS, PII detection, secrets, Sentry filter, auth flow.
- [`docs/CONTRIBUTING.md`](docs/CONTRIBUTING.md) — PR workflow, conventions, accessibility, debugging.
- [`supabase/README.md`](supabase/README.md) — migrations, ER model, Edge Functions.
- [`android/README.md`](android/README.md) — keystore setup and release signing.
