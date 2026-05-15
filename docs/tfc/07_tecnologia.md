# Tecnología

Esta sección describe el stack tecnológico completo de NeuroScale App, con la versión utilizada y la justificación de cada elección frente a las alternativas consideradas.

---

## Lenguaje y framework principal

### Flutter 3.41.9 + Dart 3.8

**Flutter** es el framework de interfaz de usuario de Google para compilar aplicaciones nativas para Android, iOS, web y escritorio desde una única base de código Dart. NeuroScale App compila a APK firmado para Android, paquete web estático para GitHub Pages y está preparada para iOS.

**Justificación frente a alternativas:**

| Alternativa | Razón de descarte |
|---|---|
| React Native | La capa de puente JS-nativo introduce latencia de renderizado. Flutter compila a código nativo ARM sin puente, lo que es crítico en formularios clínicos con actualización de puntuación en tiempo real. |
| Kotlin Multiplatform | Comparte lógica de negocio pero requiere UI nativa separada por plataforma; el coste de desarrollo se multiplica. |
| Ionic / Capacitor | Webview envuelto; rendimiento inferior y mayor consumo de memoria. No aceptable para una herramienta clínica. |
| Xamarin / MAUI | Ecosistema con menor adopción que Flutter en el contexto médico/académico; curva de aprendizaje mayor para el perfil del desarrollador. |

Flutter se eligió también por su sistema de widgets composables, el motor de renderizado propio (Impeller/Skia) que garantiza 60 fps independientemente del dispositivo, y el hot-reload que aceleró significativamente el ciclo de desarrollo.

---

## Backend como servicio

### Supabase 2.12.4 (supabase_flutter)

**Supabase** es una plataforma open-source de backend que ofrece autenticación, base de datos PostgreSQL, almacenamiento y funciones serverless como servicio gestionado. NeuroScale App usa Auth, PostgreSQL con RLS y Edge Functions.

**Justificación frente a alternativas:**

| Alternativa | Razón de descarte |
|---|---|
| Firebase (Firestore) | Base de datos documental NoSQL; requiere desnormalizar relaciones entre evaluaciones y pacientes. El modelo relacional de Supabase es más natural para datos clínicos con FK y agregaciones. |
| Firebase (Realtime DB) | Sin soporte SQL; las consultas con filtros y ordenación son costosas de modelar. |
| Appwrite | Menos maduro que Supabase en el momento de inicio del proyecto; menor documentación de RLS. |
| Backend propio (Node.js + PostgreSQL) | Requiere infraestructura, CI/CD y mantenimiento del servidor. El plan gratuito de Supabase cubre todos los requisitos del proyecto sin coste operativo. |
| Parse Platform | Plataforma con menor adopción activa; menor integración con Flutter. |

**Componentes de Supabase utilizados:**

| Componente | Uso en el proyecto |
|---|---|
| **Auth** | Registro, login, recuperación de contraseña, gestión de sesiones JWT |
| **PostgreSQL** | Tablas `evaluations` y `patients` con RLS y migraciones versionadas |
| **Edge Functions** | `delete-account`: borrado de usuario con `service_role` desde Deno/TypeScript |
| **Row Level Security** | Aislamiento total de datos entre usuarios sin lógica en cliente |

---

## Gestión de estado

### Riverpod 3.1.0 (flutter_riverpod)

**Riverpod** es un framework de gestión de estado y dependencias para Flutter construido sobre el concepto de proveedores inmutables y reactivos. NeuroScale App usa `AsyncNotifier` para estados asincrónos (listas de evaluaciones, operaciones de red) y `Notifier` para estados sincrónos (tema, algoritmo en curso).

**Justificación frente a alternativas:**

| Alternativa | Razón de descarte |
|---|---|
| BLoC / Cubit | Mayor boilerplate (eventos + estados + bloques) para funcionalidad equivalente. La curva de entrada es más pronunciada sin ventaja apreciable en este tamaño de proyecto. |
| Provider (original) | No compila de forma segura en tiempo de ejecución; Riverpod lo reemplaza con seguridad en tiempo de compilación. |
| GetX | Mezcla UI, estado y navegación en una sola abstracción; dificulta las pruebas unitarias y viola la separación de capas de Clean Architecture. |
| setState / InheritedWidget | Solo viable para estado local; escala mal en aplicaciones con múltiples features y dependencias cruzadas. |
| MobX | Requiere generación de código adicional y annotations; añade complejidad sin ventaja en este contexto. |

**Ventaja clave:** Riverpod permite testear los providers en aislamiento total sin depender del árbol de widgets, lo que simplifica las pruebas de los casos de uso y los notifiers.

---

## Routing

### go_router 17.2.3

**go_router** es el paquete de routing declarativo oficial del equipo de Flutter. Usa URL para identificar rutas, soporta deep linking y guards de redirección, y está integrado con `StatefulShellRoute` para la navegación con estado persistente entre pestañas.

**Justificación frente a alternativas:**

| Alternativa | Razón de descarte |
|---|---|
| Navigator 2.0 puro | API de muy bajo nivel; requiere implementar manualmente el parser de rutas y el delegate. El esfuerzo no se justifica. |
| auto_route | Potente pero genera mucho código; la configuración es más verbosa que go_router para este número de rutas. |
| beamer | Menos adopción y mantenimiento activo que go_router. |

`StatefulShellRoute` fue determinante en la elección: mantiene el estado de cada rama de navegación (escalas, pacientes, algoritmos, perfil) al cambiar de pestaña, evitando reconstrucciones innecesarias de widgets y peticiones de red duplicadas.

---

## Persistencia local

### Drift 2.31.0

**Drift** (anteriormente Moor) es una biblioteca ORM tipada para SQLite en Flutter y Dart. Genera código en tiempo de compilación para las queries, garantizando seguridad de tipos en las operaciones de base de datos. NeuroScale App usa Drift para la caché offline de evaluaciones y pacientes.

**Justificación frente a alternativas:**

| Alternativa | Razón de descarte |
|---|---|
| sqflite (directo) | SQL sin tipo; las queries son cadenas de texto susceptibles a errores en tiempo de ejecución. Drift genera las queries en tiempo de compilación. |
| Hive | Base de datos de valores clave (key-value); no apta para relaciones entre evaluaciones y pacientes. |
| Isar | Alta velocidad, pero modelo de datos sin SQL; las consultas con joins y filtros compuestos son menos expresivas. |
| ObjectBox | Licencia propietaria para proyectos comerciales. |

Drift se eligió también por su soporte nativo en web mediante `drift_flutter`, lo que permite usar la misma abstracción de base de datos en Android, iOS y web sin cambiar de implementación.

---

## Gráficos

### fl_chart 1.2.0

**fl_chart** es una biblioteca de gráficos para Flutter que soporta `LineChart`, `BarChart`, `PieChart` y otros tipos con soporte completo de animaciones y tooltips interactivos.

**Uso en el proyecto:** gráfico de evolución temporal de puntuaciones por paciente (`PatientDetailScreen`), con eje X proporcional al tiempo real y tooltips al pulsar cada punto de datos.

**Justificación frente a alternativas:**

| Alternativa | Razón de descarte |
|---|---|
| charts_flutter (Google) | Archivado; sin mantenimiento activo. |
| syncfusion_flutter_charts | Licencia de pago para uso comercial. |
| graphic | Menos documentación y ejemplos para `LineChart` con eje temporal. |

---

## Internacionalización

### flutter_localizations + intl 0.20.2

**flutter_localizations** (incluido en el SDK de Flutter) y el paquete `intl` de Dart proporcionan el sistema oficial de internacionalización basado en ficheros ARB (_Application Resource Bundle_). `flutter gen-l10n` genera las clases tipadas `AppLocalizations` a partir de `app_es.arb` y `app_en.arb`.

**Ventaja:** al ser el sistema oficial, está integrado con el analizador de Flutter, que avisa en tiempo de compilación de claves ARB faltantes o con tipos incorrectos. Todos los 519 textos de la interfaz están localizados en español e inglés.

---

## Fuentes

### google_fonts 6.2.1

Proporciona la fuente **Inter** (Variable) desde Google Fonts con caché automática en disco. Inter se eligió por su excelente legibilidad en pantallas de alta densidad, su amplia gama de pesos (100–900) para establecer jerarquía visual en tablas y formularios clínicos, y su uso extendido en interfaces de software médico.

---

## Monitorización de errores

### Sentry 9.19.0 (sentry_flutter)

**Sentry** es una plataforma de monitorización de errores en tiempo real. En NeuroScale App se inicializa condicionalmente mediante la variable de entorno `SENTRY_DSN` (ausente en builds de desarrollo). Captura excepciones no controladas, trazas de pila y contexto de dispositivo. Los datos de usuario están **excluidos** del reporte mediante la opción `sendDefaultPii: false`.

**Justificación frente a alternativas:**

| Alternativa | Razón de descarte |
|---|---|
| Firebase Crashlytics | Requiere Google Play Services; no funciona en web ni en dispositivos sin GMS. |
| Datadog | Coste significativo en plan de pago. |
| Bugsnag | Plan gratuito más limitado que Sentry para proyectos académicos. |

---

## Conectividad

### connectivity_plus 6.1.1

Detecta el estado de la conexión de red (WiFi, móvil, sin conexión) en Android, iOS y web mediante streams reactivos. Se usa para activar/desactivar el `OfflineBanner` en `AppShell` y para seleccionar la fuente de datos (remota vs. caché local) en los repositorios.

---

## Validación de formularios

### email_validator 3.0.0

Validación de formato de correo electrónico según RFC 5322 mediante expresión regular. Se usa en los formularios de registro y recuperación de contraseña para rechazar entradas malformadas antes de realizar la llamada a Supabase Auth.

---

## Preferencias de usuario

### shared_preferences 2.5.3

Almacenamiento de pares clave-valor en `NSUserDefaults` (iOS), `SharedPreferences` (Android) y `localStorage` (web). Se usa para persistir el tema seleccionado (claro/oscuro/automático) y el idioma preferido entre sesiones. Los datos almacenados son exclusivamente preferencias de interfaz, sin información clínica ni PII.

---

## Herramientas de desarrollo y calidad

### build_runner 2.4.13 + drift_dev 2.31.0

`build_runner` es el sistema de generación de código de Dart. `drift_dev` lo usa para generar los DAOs tipados y los companions de las tablas Drift a partir de las definiciones de `AppDatabase`. Se ejecuta con `flutter pub run build_runner build` antes de cada cambio de esquema.

### flutter_lints 6.0.0 + riverpod_lint 3.1.0 + custom_lint 0.8.1

Conjunto de reglas de análisis estático que se ejecuta con `flutter analyze`. Las reglas habilitadas incluyen `prefer_relative_imports`, `prefer_single_quotes` y `require_trailing_commas`, que se refuerzan como errores en `analysis_options.yaml`. `riverpod_lint` añade comprobaciones específicas de Riverpod (providers no usados, notifiers sin `build`, etc.). El análisis está integrado en el pipeline de CI: un PR con advertencias no puede fusionarse.

### mocktail 1.0.5

Biblioteca de mocking para pruebas unitarias en Dart. Se usa en los tests de los casos de uso para simular los repositorios (`MockEvaluationRepository`, `MockPatientRepository`, `MockAuthRepository`) sin dependencias de red ni base de datos. Alternativa a `mockito` que no requiere generación de código con `build_runner`.

### flutter_launcher_icons 0.14.3

Genera los iconos de la aplicación para todas las plataformas y densidades de pantalla a partir de una imagen fuente única (`assets/icon.png` de 1024 × 1024 px). Configurado en `pubspec.yaml` bajo la clave `flutter_launcher_icons`.

### osv-scanner (Google, v2.0.2)

Escáner de vulnerabilidades de dependencias de código abierto que analiza `pubspec.lock` contra la base de datos [OSV](https://osv.dev). Integrado como job separado en el pipeline de CI, tras el job principal de análisis y tests. Bloquea el merge ante la detección de vulnerabilidades con CVE conocido.

---

## Infraestructura y despliegue

### GitHub Actions

El pipeline de integración continua (`.github/workflows/ci.yaml`) ejecuta en cada push a `main` y en cada pull request:

1. **Formato** — `dart format --set-exit-if-changed .`
2. **Análisis estático** — `flutter analyze`
3. **Tests con cobertura** — `flutter test --coverage` (artefacto `lcov.info`)
4. **Escaneo de vulnerabilidades** — `osv-scanner --lockfile=pubspec.lock`

El pipeline de despliegue (`.github/workflows/deploy.yml`) construye la versión web con `flutter build web --base-href /NeuroScaleApp/` y la publica en GitHub Pages mediante `peaceiris/actions-gh-pages`. La versión de Flutter está fijada a `3.41.9 stable` en ambos workflows para garantizar reproducibilidad.

### GitHub Pages

Alojamiento estático gratuito para la versión web de producción. La URL pública es `https://grisllo.github.io/NeuroScaleApp/`. El deploy es automático en cada push a `main` que supere el pipeline de CI.

---

## Resumen del stack

| Categoría | Tecnología | Versión |
|---|---|---|
| Framework UI | Flutter | 3.41.9 |
| Lenguaje | Dart | 3.8 |
| Backend (BaaS) | Supabase | 2.12.4 |
| Base de datos remota | PostgreSQL (Supabase) | — |
| Base de datos local | Drift (SQLite) | 2.31.0 |
| Gestión de estado | Riverpod | 3.1.0 |
| Routing | go_router | 17.2.3 |
| Gráficos | fl_chart | 1.2.0 |
| i18n | flutter_localizations + intl | 0.20.2 |
| Fuentes | google_fonts (Inter) | 6.2.1 |
| Monitorización | Sentry | 9.19.0 |
| Conectividad | connectivity_plus | 6.1.1 |
| Preferencias | shared_preferences | 2.5.3 |
| Mocking (tests) | mocktail | 1.0.5 |
| Análisis estático | flutter_lints + riverpod_lint | 6.0.0 / 3.1.0 |
| Seguridad deps | osv-scanner | 2.0.2 |
| CI/CD | GitHub Actions | — |
| Hosting web | GitHub Pages | — |
