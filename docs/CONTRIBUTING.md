# Guía de contribución — NeuroScale App

Convenciones, flujo de trabajo y plantillas para añadir features clínicas o técnicas a NeuroScale App.

---

## Tabla de contenidos

- [1. Configuración del entorno](#1-configuración-del-entorno)
- [2. Flujo de trabajo](#2-flujo-de-trabajo)
- [3. Convenciones](#3-convenciones)
- [4. Internacionalización (i18n)](#4-internacionalización-i18n)
- [5. Sin PII](#5-sin-pii)
- [6. Añadir una nueva escala neurológica](#6-añadir-una-nueva-escala-neurológica)
- [7. Añadir un algoritmo clínico](#7-añadir-un-algoritmo-clínico)
- [8. Tests](#8-tests)
- [9. Debugging](#9-debugging)
- [10. Accesibilidad](#10-accesibilidad)

---

## 1. Configuración del entorno

```powershell
git clone https://github.com/grisllo/NeuroScaleApp.git
cd NeuroScaleApp
flutter pub get
Copy-Item env/dev.example.json env/dev.json
# Editar env/dev.json con tus credenciales de Supabase de desarrollo.
flutter run --dart-define-from-file=env/dev.json
```

Si `env/dev.json` no existe o no contiene credenciales, la aplicación arranca igualmente — Supabase y Sentry se inicializan condicionalmente.

---

## 2. Flujo de trabajo

1. Crea una rama desde `main`:
   ```powershell
   git checkout -b feat/mi-feature
   ```
2. Implementa siguiendo la arquitectura feature-first (ver [`CLAUDE.md`](../CLAUDE.md)).
3. Toda calculadora de escala requiere **tests de frontera exhaustivos** (ver `test/features/scales/`).
4. Antes de hacer commit, ejecuta los tres checks que correrá la CI:
   ```powershell
   dart format lib test
   flutter analyze          # debe terminar con 0 issues
   flutter test             # debe terminar 100 % verde
   ```
5. Commit con Conventional Commits (ver §3).
6. Pull request a `main` — la CI ejecuta los tres checks automáticamente.

---

## 3. Convenciones

### Commits — Conventional Commits

| Prefijo | Uso |
|---|---|
| `feat:` | Nueva funcionalidad. |
| `fix:` | Corrección de bug. |
| `refactor:` | Refactorización sin cambio de comportamiento. |
| `test:` | Tests nuevos o modificados. |
| `docs:` | Documentación. |
| `chore:` | Configuración, dependencias, CI. |

Ejemplos del repositorio:

- `feat(security): Fase 14.A — críticos producción: RLS, seguridad y validación`
- `fix(theme): corregir jerarquía visual inputs en dark mode`
- `docs(roadmap): pulido — TOC navegable, deuda técnica estructurada`

### Código

- Archivos: `snake_case.dart`.
- Clases: `PascalCase`.
- Constantes verdaderas: `SCREAMING_SNAKE_CASE`. Resto, `camelCase`.
- Imports internos a `lib/` en formato **relativo** (regla `prefer_relative_imports`).
- Comillas simples (regla del linter).
- Trailing commas obligatorias (mejora diffs y formato).
- Sin comentarios obvios — solo cuando el "por qué" no sea evidente.

---

## 4. Internacionalización (i18n)

Toda cadena visible al usuario va en `lib/l10n/app_es.arb` **y** `lib/l10n/app_en.arb`. Nunca se hardcodea en widgets.

Tras añadir claves:

```powershell
flutter gen-l10n
```

> El generador se ejecuta automáticamente con `flutter pub get` cuando `generate: true` está activo en `pubspec.yaml`.

Tras generar, las claves quedan disponibles vía `AppLocalizations.of(context).miClave` (o la extensión `context.l10n.miClave` definida en `lib/core/extensions/l10n_extension.dart`).

---

## 5. Sin PII

Nunca se incluye información identificativa de personas reales en código, tests, fixtures, comentarios ni documentación. Para identificar pacientes en pruebas y mocks, utilizar alias ficticios (`P001`, `Caso A`, `Sujeto 1`).

El detector de PII del proyecto está documentado en [`SECURITY.md`](SECURITY.md) §3.

---

## 6. Añadir una nueva escala neurológica

Utiliza el skill `/create-scale` desde Claude Code. Genera el scaffold completo en un solo paso:

- Calculadora pura en `lib/features/scales/<nombre>/domain/<nombre>_calculator.dart`.
- Tests de frontera en `test/features/scales/<nombre>/<nombre>_calculator_test.dart`, cubriendo todos los umbrales clínicos.
- Pantalla placeholder en `lib/features/scales/<nombre>/presentation/`.
- Claves ARB (ES + EN) para título, ítems, opciones e interpretaciones.

Sigue el patrón de escalas existentes (`gcs`, `nihss`, `rankin`, `barthel`, `abcd2`). La función calculadora debe:

- Recibir `Map<String, int>` con los valores de cada ítem.
- Devolver `ScaleResult` (entidad compartida en `lib/features/scales/shared/domain/entities/`).
- Lanzar `ValidationException` ante ítems faltantes o valores fuera de rango.
- No importar Flutter ni Supabase (función pura).

---

## 7. Añadir un algoritmo clínico

Los algoritmos clínicos son árboles de decisión con dos tipos de nodos: `QuestionNode` (preguntas con opciones) y `ResultNode` (resultados con urgencia clasificada). El patrón está implementado en `lib/features/algorithms/domain/`.

### Pasos

1. **Definir el árbol** en `lib/features/algorithms/domain/algorithms/mi_algoritmo.dart`:

   ```dart
   import '../entities/algorithm_definition.dart';
   import '../entities/algorithm_node.dart';
   import '../entities/algorithm_option.dart';
   import '../entities/algorithm_urgency.dart';

   const miAlgoritmoAlgorithm = AlgorithmDefinition(
     id: 'miAlgoritmo',
     titleKey: 'algoMiAlgoritmoTitle',
     descriptionKey: 'algoMiAlgoritmoDescription',
     startNodeId: 'q_inicio',
     nodes: {
       'q_inicio': QuestionNode(
         id: 'q_inicio',
         questionKey: 'algoMiAlgoritmoQInicio',
         options: [
           AlgorithmOption(
             id: 'sí',
             labelKey: 'algoMiAlgoritmoQInicioSi',
             nextNodeId: 'r_critico',
           ),
           AlgorithmOption(
             id: 'no',
             labelKey: 'algoMiAlgoritmoQInicioNo',
             nextNodeId: 'r_leve',
           ),
         ],
       ),
       'r_critico': ResultNode(
         id: 'r_critico',
         titleKey: 'algoMiAlgoritmoRCriticoTitle',
         bodyKey: 'algoMiAlgoritmoRCriticoBody',
         urgency: AlgorithmUrgency.critical,
       ),
       'r_leve': ResultNode(
         id: 'r_leve',
         titleKey: 'algoMiAlgoritmoRLeveTitle',
         bodyKey: 'algoMiAlgoritmoRLeveBody',
         urgency: AlgorithmUrgency.low,
       ),
     },
   );
   ```

2. **Registrarlo** en `lib/features/algorithms/domain/algorithms/algorithms_registry.dart`:

   ```dart
   const List<AlgorithmDefinition> kAlgorithms = [
     strokeCodeAlgorithm,
     htaIctusAlgorithm,
     sahAlgorithm,
     miAlgoritmoAlgorithm,   // ← añadir
   ];
   ```

3. **Añadir las claves ARB** en `lib/l10n/app_es.arb` y `lib/l10n/app_en.arb` para título, descripción, preguntas, opciones y resultados.

4. **Tests del árbol** en `test/features/algorithms/mi_algoritmo_test.dart`, cubriendo cada ramificación hasta los nodos resultado.

### Niveles de urgencia

| Valor | Significado clínico | Color |
|---|---|---|
| `AlgorithmUrgency.critical` | Acción inmediata requerida (minutos). | Rojo |
| `AlgorithmUrgency.high` | Acción urgente (horas). | Naranja |
| `AlgorithmUrgency.moderate` | Vigilancia, segunda evaluación. | Amarillo |
| `AlgorithmUrgency.low` | Sin urgencia, seguimiento ambulatorio. | Verde |
| `AlgorithmUrgency.info` | Informativo, sin acción requerida. | Azul |

---

## 8. Tests

### Ejecutar todos los tests

```powershell
flutter test
```

### Tests con cobertura (genera `coverage/lcov.info`)

```powershell
flutter test --coverage
```

### Filtrar por nombre

```powershell
# Por substring del nombre del test (insensible a mayúsculas)
flutter test --plain-name "GCS boundary"

# Por archivo concreto
flutter test test/features/scales/gcs/gcs_calculator_test.dart

# Combinar fichero + filtro
flutter test test/features/scales/gcs/gcs_calculator_test.dart --plain-name "score 15"
```

### Convenciones

- Los tests de dominio (calculadoras, algoritmos) usan únicamente `flutter_test` — sin mocks.
- Los tests de capa data utilizan `mocktail` para simular `DataSource` con `Fake` o `Mock` según convenga.
- Cada calculadora cubre **todos los umbrales clínicos** y los **casos inválidos** (mapas vacíos, claves faltantes, valores fuera de rango). Un cálculo incorrecto en producción puede tener consecuencias clínicas, por lo que la cobertura del dominio debe ser exhaustiva.

---

## 9. Debugging

### Logging temporal

Para inspección puntual, utilizar `debugPrint` (de `package:flutter/foundation.dart`). No usar `print` directamente — la regla `avoid_print` lo bloquea.

### DevTools

```powershell
flutter run --dart-define-from-file=env/dev.json -d chrome
# Una vez ejecutando, abrir DevTools desde la URL que muestra la consola.
```

DevTools permite inspeccionar el árbol de widgets, perfilar rendimiento, ver tráfico de red y depurar el estado de Riverpod.

### Drift (base de datos local)

Cuando se modifica el esquema (`lib/core/database/app_database.dart`), regenerar el código generado:

```powershell
dart run build_runner build --delete-conflicting-outputs
```

Para inspeccionar el contenido de la base de datos local en runtime:

- Android: usar **Device File Explorer** en Android Studio → `data/data/com.neuroscale/databases/neuroscale_db`.
- Web: la base de datos se almacena en `IndexedDB` y se puede inspeccionar desde las DevTools del navegador (Application → IndexedDB).

### Logs de Supabase

Para depurar problemas de RLS o políticas, las herramientas más útiles son:

- **Supabase Studio → Logs Explorer** (filtros por tipo de operación, status, usuario).
- **Supabase Studio → Database → Postgres → `pg_stat_statements`** para queries lentos.

---

## 10. Accesibilidad

Aplicar antes de hacer commit en pantallas nuevas (réplica exacta de la checklist en `CLAUDE.md`):

- [ ] Todos los `IconButton` tienen `tooltip:`.
- [ ] Imágenes y avatares significativos llevan `Semantics(label: ..., excludeSemantics: true)`.
- [ ] Iconos decorativos van envueltos en `ExcludeSemantics`.
- [ ] La información no se transmite únicamente con color (regla `color-not-only`).
- [ ] Contraste mínimo 4,5:1 en texto normal (verificar también en dark mode).
- [ ] Touch targets de al menos 44×44 pt (`SizedBox`, padding o `InkResponse` con `radius:` mínimo).
- [ ] Campos de contraseña con toggle show/hide y `tooltip:` (`showPasswordTooltip` / `hidePasswordTooltip`).
- [ ] Cadenas nuevas con claves ARB en `app_es.arb` **y** `app_en.arb`.

---

## Documentos relacionados

- [`../CLAUDE.md`](../CLAUDE.md) — instrucciones para el agente Claude Code.
- [`SECURITY.md`](SECURITY.md) — modelo de seguridad y PII.
- [`ROADMAP.md`](ROADMAP.md) — fases y decisiones de diseño.
- [`../supabase/README.md`](../supabase/README.md) — migraciones SQL.
