---
name: create-scale
description: Scaffold a new neurological scale inside lib/features/scales/<name>/ following Clean Architecture conventions for NeuroScale App. Use when the user asks to add a new scale (e.g. "add the NIHSS scale", "scaffold a new scale called X"). Creates the calculator (pure function in domain/), placeholder screen, ARB strings, and an exhaustive boundary unit test for the calculator.
---

# Create Scale skill

## When to invoke

The user wants a new neurological scale added to NeuroScale App. Examples:
- "Add the NIHSS scale"
- "Scaffold the Rankin scale"
- "Create a new scale called Foo with items A (1-3) and B (1-5)"

## Inputs to confirm with the user

Before generating files, confirm:
1. **Scale name** in snake_case (`gcs`, `nihss`, `rankin`, `barthel`, etc.).
2. **Display name** in Spanish (e.g., "Escala de Coma de Glasgow").
3. **Items**: each with key, label, min and max integer score.
4. **Total score range** and **interpretation buckets** (ranges and severity labels).
5. Whether the calculator has any conditional rules (e.g., NIHSS: intubated patient blocks items). If yes, document each rule explicitly before coding.

## Files to generate

Inside `lib/features/scales/<name>/`:

```
domain/
├── <name>_definition.dart       Scale items + metadata (extends ScaleDefinition from scales/shared)
├── <name>_calculator.dart       Pure function: ({Map<String,int> answers}) → ScaleResult
└── (any conditional rules helpers)
presentation/
└── <name>_scale_screen.dart     Placeholder using Riverpod and the routing convention
```

Plus:
- `test/features/scales/<name>/<name>_calculator_test.dart` with **exhaustive boundary tests**: every interpretation threshold (one test below, one at, one above), invalid inputs (out-of-range scores), missing answers.
- ARB entries in `lib/l10n/app_es.arb` for the scale title, item labels, severity labels, and interpretation copy.
- A new route in `lib/core/routing/app_router.dart` (e.g. `/scales/<name>`).

## Conventions to follow

- The calculator must be a **pure function with no Flutter or Supabase imports**. It receives a `Map<String,int>` (or a typed answers record) and returns a `ScaleResult`. This makes it trivial to unit test.
- Severity buckets are encoded in the calculator, not in the UI — UI only renders what the result says.
- Validate input ranges (`assert` for invariants the caller controls, throw `ValidationFailure` for user-facing invalid input).
- All user-facing strings come from ARB — never hardcode in Dart.
- The screen widget uses the same `_PlaceholderScreen` pattern from `app_router.dart` until properly implemented; it should at minimum render the form with sliders/segmented buttons and a "Calcular" button that pushes to `/result`.

## After generation

Always run:
```powershell
flutter gen-l10n
flutter analyze
flutter test test/features/scales/<name>/
```

All boundary tests must pass before considering the skill done.

## What this skill does NOT do

- Does **not** add Supabase persistence (that lives in `features/evaluations/`). The calculator is independent of how the result is stored.
- Does **not** decide clinical correctness — the user must provide validated thresholds. Cite the source (paper, guideline) in a comment at the top of the calculator file.
- Does **not** add charts (Phase 2A `features/history/`).
