# Contributing — NeuroScale App

## Configuración del entorno

```powershell
git clone https://github.com/grisllo/NeuroScaleApp.git
cd NeuroScaleApp
flutter pub get
cp env/dev.example.json env/dev.json   # editar con credenciales Supabase de dev
flutter run --dart-define-from-file=env/dev.json
```

---

## Flujo de trabajo

1. **Crea un branch** desde `main`: `git checkout -b feat/mi-feature`
2. **Implementa** siguiendo la arquitectura feature-first (ver `CLAUDE.md`).
3. **Tests**: toda calculadora de escala requiere tests de frontera. Ver `test/features/scales/`.
4. **Checks antes de commit**:
   ```powershell
   dart format lib test
   flutter analyze          # debe ser 0 issues
   flutter test             # debe ser 100% verde
   ```
5. **Commit** con Conventional Commits.
6. **PR** a `main` — CI corre los 3 checks automáticamente.

---

## Convenciones

### Commits

| Prefijo | Cuándo |
|---|---|
| `feat:` | Nueva funcionalidad |
| `fix:` | Corrección de bug |
| `refactor:` | Refactorización sin cambio de comportamiento |
| `test:` | Tests nuevos o modificados |
| `docs:` | Documentación |
| `chore:` | Configuración, dependencias, CI |

### Código

- Nombres de archivo: `snake_case.dart`
- Clases: `PascalCase`
- Constantes de entorno: `SCREAMING_SNAKE_CASE` solo para constantes reales
- Imports dentro de `lib/`: **relativos** (regla de linter)
- Trailing commas obligatorias (regla de linter)
- Sin comentarios obvios — solo cuando el WHY no es evidente

### i18n

Toda cadena visible al usuario va en `lib/l10n/app_es.arb` **y** `lib/l10n/app_en.arb`.
Nunca hardcodear strings en widgets.

### No PII

Ni en el código, ni en tests, ni en comentarios. Usar alias ficticios ("P001", "Caso A").

---

## Añadir una nueva escala neurológica

Usar el skill `/create-scale` desde Claude Code. Genera el scaffold completo:
- Calculadora pura en `domain/`
- Tests de frontera en `test/features/scales/<escala>/`
- Screen en `presentation/`
- Claves ARB en ES+EN

---

## Añadir un algoritmo clínico

1. Definir el árbol en `lib/features/algorithms/domain/data/` siguiendo el patrón de `stroke_code_algorithm.dart`.
2. Registrar en `kAlgorithms` en `lib/features/algorithms/domain/data/algorithm_registry.dart`.
3. Añadir claves ARB para preguntas, opciones y resultados.
4. Tests del árbol de decisión siguiendo `test/features/algorithms/`.

---

## Accesibilidad (checklist para features nuevos)

- [ ] Todos los `IconButton` tienen `tooltip:`
- [ ] Imágenes significativas tienen `Semantics(label: ..., excludeSemantics: true)`
- [ ] Íconos decorativos van dentro de `ExcludeSemantics`
- [ ] Colores no son la única forma de comunicar información (`color-not-only`)
- [ ] Contraste ≥ 4.5:1 para texto normal (verificar en dark mode también)
- [ ] Touch targets mínimo 44×44pt
- [ ] Campos de contraseña tienen toggle show/hide con `tooltip:` (`showPasswordTooltip` / `hidePasswordTooltip`)
- [ ] Strings nuevas tienen claves ARB en `app_es.arb` **y** `app_en.arb`
