---
name: phase-close
description: End-of-subfase checklist for NeuroScale App. Runs analyze + test, updates ROADMAP, METODOLOGIA_Y_PLANIFICACION and README Gantt, closes the GitHub issue, commits and pushes. Use when a subfase is done (e.g. "cierra la subfase 2A.2", "/phase-close").
---

# Phase-close skill

## When to invoke

After finishing the implementation of a subfase and before moving to the next one. Examples:
- `/phase-close`
- "cierra la subfase 2A.2"
- "checklist de cierre"

## Inputs to confirm before running

Ask the user for the following if not provided:

1. **Subfase ID** — e.g. `2A.1`, `2A.2`, `2B`, `3`.
2. **GitHub issue number** — the issue that corresponds to this subfase (visible at github.com/grisllo/NeuroScaleApp/issues).
3. **Horas reales dedicadas** — time spent on this subfase in hours (decimal allowed, e.g. `2.5`). Used to update `METODOLOGIA_Y_PLANIFICACION.md`.
4. **¿Cierra una fase completa?** — yes/no. If yes, also update the README Gantt end date and mark the phase as completed in ROADMAP.md.

## Steps to execute in order

### Step 1 — Quality gate

Run both commands and stop if either fails:

```powershell
& "C:\Users\grisllo\dev\flutter\bin\flutter.bat" analyze
& "C:\Users\grisllo\dev\flutter\bin\flutter.bat" test
```

- `flutter analyze` must return **0 issues**. If not, fix all issues before continuing.
- `flutter test` must show **All tests passed**. If not, fix failing tests before continuing.

### Step 2 — Update ROADMAP.md

File: `docs/ROADMAP.md`

- Find the subfase entry (e.g. `### Subfase 2A.2`) and mark it as done by adding `✅` to the title and the completion date `(YYYY-MM-DD)`.
- If this closes a **full phase** (e.g. all 2A subfases done), update the phase header from `🚧 En curso` to `✅ Completada (YYYY-MM-DD)` and the "Estado actual" section to the next phase.

### Step 3 — Update METODOLOGIA_Y_PLANIFICACION.md

File: `docs/METODOLOGIA_Y_PLANIFICACION.md`

In the **Planificación real** table (section 3.2):
- Add a new row for this subfase with: task name, commit hash (use `git rev-parse --short HEAD`), date, and real hours provided by the user.

In the **Análisis de desviaciones** table (section 3.3):
- Add a row comparing estimated vs real hours and note the cause of any deviation.

Recalculate the **total row** at the bottom.

### Step 4 — Update README Gantt (only if closing a full phase)

File: `README.md`

In the Mermaid `gantt` block:
- Change the completed phase bar(s) from no tag to `:done,` prefix.
- Add the real end date to the completed phase.
- Move the `:active,` tag to the next phase.

### Step 5 — Close GitHub issue

Use `gh` CLI (full path: `C:\Program Files\GitHub CLI\gh.exe`):

```powershell
& "C:\Program Files\GitHub CLI\gh.exe" issue close <NUMBER> --reason completed
```

### Step 6 — Commit and push

Stage all modified files:
```powershell
git add -A
```

Commit using Conventional Commits. The message **must** include `Closes #<NUMBER>` so GitHub links the commit to the issue:

```
chore(phase): cierre subfase <ID> — docs y métricas

- flutter analyze 0 issues, flutter test <N> tests pasando
- ROADMAP: subfase <ID> marcada completada
- METODOLOGIA: horas reales añadidas (estimado Xh / real Yh)
- Issue #<NUMBER> cerrado

Closes #<NUMBER>

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```

Push:
```powershell
git push
```

### Step 7 — Report to user

Print a summary table:

```
✅ Subfase <ID> cerrada
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Tests          : <N> passing
Analyze        : 0 issues
Horas reales   : <Y> h  (estimado <X> h, desviación <±Z>%)
Issue cerrado  : #<NUMBER>
Commit         : <hash>
Push           : ✅ github.com/grisllo/NeuroScaleApp
```

## What this skill does NOT do

- Does **not** skip the quality gate. If analyze or test fail, it stops and reports the errors.
- Does **not** decide which hours to record — the user must provide them.
- Does **not** make code changes — only documentation, metadata and git operations.
- Does **not** create a new branch or PR — commits go directly to `main` (single-developer project).
