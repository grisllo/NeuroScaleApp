# Abstract

## Resumen

**NeuroScale App** es una aplicación multiplataforma para Android, iOS y web dirigida a profesionales de la salud y estudiantes de medicina. Permite aplicar, calcular e interpretar cinco escalas neurológicas estandarizadas —GCS, NIHSS, mRS, Barthel Index y ABCD2— y recorrer tres algoritmos clínicos de decisión (Código Ictus, HTA en ictus agudo y clasificación HSA Hunt-Hess/Fisher), con indicación de urgencia en cada resultado.

La aplicación gestiona pacientes de forma completamente anonimizada: cada evaluación se vincula a un alias clínico libre, sin datos identificativos, y se registra tanto en una base de datos remota (Supabase PostgreSQL con Row Level Security) como en un almacén local SQLite (Drift) para permitir el uso sin conexión. El historial de cada paciente se visualiza mediante gráficos de evolución temporal por escala.

Desde el punto de vista técnico, el proyecto se desarrolló con Flutter 3.41.9 y Dart, siguiendo una arquitectura feature-first con Clean Architecture en cada feature y Riverpod como solución de gestión de estado. El dominio clínico —calculadoras de escalas y árboles de decisión de algoritmos— se implementó como funciones puras con cobertura de tests exhaustiva sobre todos los umbrales clínicos. El proyecto alcanzó la versión 1.0.0 con 204 tests automatizados en CI, despliegue web en GitHub Pages y distribución Android mediante APK firmado.

**Palabras clave:** Flutter, escalas neurológicas, aplicación clínica, Supabase, Clean Architecture, TDD, multiplataforma.

---

## Abstract

**NeuroScale App** is a cross-platform application for Android, iOS and web targeting healthcare professionals and medical students. It provides a complete workflow for applying, calculating and interpreting five standardised neurological scales —GCS, NIHSS, mRS, Barthel Index and ABCD2— and three step-by-step clinical decision algorithms (Stroke Code, Acute Stroke Hypertension and SAH Hunt-Hess/Fisher classification), each yielding an urgency level alongside the clinical recommendation.

The application manages patients in a fully anonymised manner: each evaluation is linked to a free-text clinical alias, with no personally identifiable information, and is persisted both on a remote database (Supabase PostgreSQL with Row Level Security) and in a local SQLite store (Drift) for offline support. Patient history is visualised through temporal evolution charts per scale.

From a technical standpoint, the project was built with Flutter 3.41.9 and Dart, following a feature-first architecture with Clean Architecture layers inside each feature and Riverpod for state management. The clinical domain —scale calculators and algorithm decision trees— was implemented as pure functions with exhaustive boundary tests covering every clinical threshold. The project reached version 1.0.0 with 204 automated tests running in CI, production web deployment on GitHub Pages, and Android distribution via a signed APK.

**Keywords:** Flutter, neurological scales, clinical application, Supabase, Clean Architecture, TDD, cross-platform.
