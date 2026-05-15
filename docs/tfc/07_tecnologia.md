# Tecnología

Esta sección describe el stack tecnológico de NeuroScale App con la versión utilizada y, en cada caso, la razón por la que se eligió frente a las alternativas que llegué a considerar. No pretende ser una comparativa exhaustiva del ecosistema, sino justificar las decisiones reales del proyecto.

---

## Lenguaje y framework principal

### Flutter 3.41.9 + Dart 3.8

Flutter es el framework de Google para compilar aplicaciones nativas desde una única base de código Dart. NeuroScale App compila a APK firmado para Android, paquete web estático servido por GitHub Pages y está preparada para iOS, aunque la distribución en App Store queda fuera del alcance del proyecto.

Antes de decidirme por Flutter consideré React Native, Kotlin Multiplatform e Ionic. React Native lo descarté por la latencia que introduce el puente JavaScript-nativo: en formularios clínicos donde la puntuación se actualiza en tiempo real con cada selección del usuario, esa latencia es perceptible. Kotlin Multiplatform comparte lógica de negocio pero obliga a mantener dos UI nativas (una para iOS y otra para Android), lo que multiplica el coste de mantenimiento para un solo desarrollador. Ionic, al ser una capa sobre WebView, ofrece un rendimiento que no consideré aceptable para una herramienta clínica con uso intensivo previsto.

A favor de Flutter pesaron tres factores adicionales: el motor de renderizado propio (Impeller/Skia) que mantiene 60 fps con independencia del dispositivo, el sistema de widgets composables que casa bien con Clean Architecture, y el hot-reload, que aceleró notablemente la fase de iteración visual.

---

## Backend como servicio

### Supabase 2.12.4 (supabase_flutter)

Supabase es una plataforma open-source que ofrece autenticación, base de datos PostgreSQL, almacenamiento y funciones serverless como servicio gestionado. En este proyecto se usan tres de sus componentes:

- **Auth** para registro, login, recuperación y borrado de contraseñas, con gestión de sesiones JWT.
- **PostgreSQL con Row Level Security** para las tablas `evaluations` y `patients`, con migraciones SQL versionadas.
- **Edge Functions** para la función `delete-account`, escrita en Deno/TypeScript, que necesita ejecutarse con privilegios `service_role` que no pueden invocarse desde el cliente.

La alternativa más obvia era Firebase. La descarté por el modelo de datos: Firestore es una base documental NoSQL, y mis evaluaciones tienen relaciones claras con pacientes (FK con borrado en cascada) y consultas con filtros y ordenación. Modelarlo en NoSQL habría obligado a desnormalizar y a duplicar información en cliente. Appwrite era candidato razonable pero en el momento de iniciar el proyecto su documentación sobre RLS era más limitada. La opción de levantar mi propio backend con Node.js y PostgreSQL la valoré, pero el plan gratuito de Supabase cubría todos los requisitos sin necesidad de infraestructura, CI/CD adicional ni mantenimiento del servidor.

---

## Gestión de estado

### Riverpod 3.1.0 (flutter_riverpod)

Riverpod es un framework de gestión de estado para Flutter que se construye sobre proveedores inmutables y reactivos. En el proyecto se usa `AsyncNotifier` para los estados con operaciones asíncronas (listas de evaluaciones, llamadas a Supabase) y `Notifier` para estados síncronos (tema, idioma, estado del algoritmo en curso).

La alternativa principal era BLoC / Cubit. La descarté por el coste de boilerplate: cada feature habría requerido eventos, estados y bloque, lo que añade ceremonia sin contraprestación en este tamaño de proyecto. Provider (el paquete original que Riverpod sustituye) tiene problemas conocidos de seguridad en tiempo de ejecución que Riverpod resuelve en tiempo de compilación. GetX lo descarté porque mezcla UI, estado y navegación en una sola abstracción, lo que choca de frente con la separación de capas de Clean Architecture.

La ventaja determinante de Riverpod, más allá del modelo de proveedores, fue que permite testear cada provider en aislamiento sin necesidad de árbol de widgets. Esto encajó perfectamente con la estrategia de testing del dominio.

---

## Routing

### go_router 17.2.3

`go_router` es el paquete oficial del equipo de Flutter para routing declarativo. Usa URL como identificador de ruta, soporta deep linking y guards de redirección, y se integra con `StatefulShellRoute` para mantener el estado de cada rama de navegación al cambiar de pestaña.

Consideré usar `Navigator 2.0` directamente (la API que `go_router` envuelve), pero requiere implementar a mano el parser de rutas y el delegate, lo que para este número de rutas no se justifica. También miré `auto_route`: es potente, pero genera bastante código y su configuración me pareció más verbosa.

La razón concreta por la que elegí `go_router` fue `StatefulShellRoute`. Mantener el estado independiente de las cuatro pestañas (escalas, pacientes, algoritmos, perfil) al cambiar de una a otra es algo que cualquier usuario espera por defecto, y conseguirlo a mano con `Navigator` 2.0 habría sido una fuente segura de bugs.

---

## Persistencia local

### Drift 2.31.0

Drift (antes Moor) es una biblioteca ORM tipada para SQLite que genera el código de las queries en tiempo de compilación, asegurando que los errores de tipo se detectan antes de ejecutar. En el proyecto se usa como caché offline de las evaluaciones y los pacientes.

Consideré `sqflite` (la alternativa más directa) y `Hive`. `sqflite` ejecuta SQL como cadenas de texto y los errores aparecen solo en tiempo de ejecución, lo que en un dominio donde los datos importan no me pareció aceptable. `Hive` es excelente para almacenes clave-valor, pero no encaja con un modelo relacional como el que aquí se necesita: pacientes con muchas evaluaciones, filtros por fecha y ordenación cronológica. `Isar` es rápido pero su modelo de consultas no admite joins; `ObjectBox` tiene una licencia con restricciones para uso comercial que prefería evitar.

A favor de Drift pesó también su soporte nativo en web vía `drift_flutter`. Permite usar el mismo código de persistencia en Android, iOS y web sin condicionales por plataforma.

---

## Gráficos

### fl_chart 1.2.0

`fl_chart` es una biblioteca de gráficos para Flutter con soporte para `LineChart`, `BarChart`, `PieChart` y otros tipos, con animaciones y tooltips interactivos. En NeuroScale App se usa exclusivamente para el `LineChart` de evolución temporal de las puntuaciones por paciente.

Las opciones que valoré fueron `charts_flutter` (el paquete oficial de Google) y `syncfusion_flutter_charts`. El primero está archivado y sin mantenimiento desde hace tiempo. El segundo requiere licencia de pago para uso comercial. `fl_chart` es activo, documentado y suficiente para los tipos de gráfico que el proyecto necesita.

---

## Internacionalización

### flutter_localizations + intl 0.20.2

Para la i18n se usa el sistema oficial: `flutter_localizations`, incluido en el SDK, junto con el paquete `intl`. Los textos viven en ficheros ARB (`app_es.arb` y `app_en.arb`) y `flutter gen-l10n` genera las clases tipadas que se consumen desde los widgets.

La ventaja de ceñirse al sistema oficial es que el analizador estático detecta claves ARB faltantes o con tipos incorrectos en tiempo de compilación, lo que reduce la categoría completa de errores tipo "esta pantalla quedó sin traducir". Los 519 textos de la interfaz están localizados en español e inglés y la cobertura se mantiene como invariante del proyecto.

---

## Otras dependencias relevantes

El stack se completa con varias bibliotecas pequeñas que cumplen funciones bien delimitadas:

- **google_fonts 6.2.1** sirve la tipografía **Inter** (variable) desde Google Fonts con caché en disco. Inter se eligió por su legibilidad en pantallas de alta densidad y porque tiene una gama amplia de pesos, lo que ayuda a establecer jerarquía visual en formularios clínicos cargados de información.
- **sentry_flutter 9.19.0** captura excepciones no controladas y trazas de pila. Se inicializa de forma condicional según la variable de entorno `SENTRY_DSN`, de modo que en desarrollo no se envía nada. Los datos del usuario están explícitamente excluidos del reporte (`sendDefaultPii: false`). Descarté Firebase Crashlytics porque requiere Google Play Services y no funciona en web.
- **connectivity_plus 6.1.1** expone el estado de la red como stream reactivo. Se usa para activar el `OfflineBanner` y para seleccionar fuente de datos (remota o caché local) en los repositorios.
- **email_validator 3.0.0** valida el formato de correo según RFC 5322 antes de llamar a Supabase Auth.
- **shared_preferences 2.5.3** persiste el tema y el idioma elegidos. Solo se guardan preferencias de interfaz, nunca información clínica.

---

## Herramientas de desarrollo y calidad

`build_runner` y `drift_dev` se usan para generar el código tipado de Drift; se ejecutan con `flutter pub run build_runner build` cuando cambia el esquema de la base de datos local. El análisis estático se apoya en tres paquetes encadenados: `flutter_lints` (reglas generales), `riverpod_lint` (reglas específicas de Riverpod) y `custom_lint` (motor de las dos anteriores). Las reglas más estrictas están elevadas a error en `analysis_options.yaml`, de modo que `flutter analyze` bloquea cualquier import absoluto, cadena hardcodeada o trailing comma faltante.

Para los tests se utiliza `mocktail` en lugar de `mockito`. Ambos son válidos, pero `mocktail` no requiere generación de código adicional, lo que simplifica el flujo de trabajo. Por último, `flutter_launcher_icons` genera los iconos para todas las plataformas a partir de una única imagen fuente.

En cuanto a seguridad, el pipeline de CI integra `osv-scanner` de Google, que analiza `pubspec.lock` contra la base de datos OSV y bloquea el merge si detecta dependencias con vulnerabilidades conocidas.

---

## Infraestructura y despliegue

El pipeline de integración continua está definido en `.github/workflows/ci.yaml` y se ejecuta en cada push a `main` y en cada pull request. Los pasos, en orden, son:

1. Comprobación de formato (`dart format --set-exit-if-changed`).
2. Análisis estático (`flutter analyze`).
3. Tests con cobertura (`flutter test --coverage`), con el `lcov.info` subido como artefacto.
4. Escaneo de vulnerabilidades con `osv-scanner` sobre `pubspec.lock`, como job dependiente del anterior.

El pipeline de despliegue (`deploy.yml`) construye la versión web con `flutter build web --base-href /NeuroScaleApp/` y la publica en la rama `gh-pages` mediante `peaceiris/actions-gh-pages`. La versión de Flutter está fijada a `3.41.9 stable` en ambos workflows para garantizar reproducibilidad. GitHub Pages aloja el sitio resultante sin coste.

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
