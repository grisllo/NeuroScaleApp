# Objetivos y Requisitos Funcionales, Técnicos y de Prueba (RFTP)

## Objetivos del proyecto

El objetivo principal de NeuroScale App es proporcionar a profesionales de la salud y estudiantes de medicina una herramienta multiplataforma que centralice las escalas neurológicas más empleadas en la práctica clínica española, permita registrar evaluaciones de forma anonimizada y ofrezca algoritmos clínicos de apoyo a la decisión.

Los objetivos específicos son:

1. Implementar las cinco escalas neurológicas de uso más frecuente en neurología de urgencias (GCS, NIHSS, mRS, Barthel, ABCD²) con calculadoras clínicamente correctas, interpretación de gravedad y modo tutorial ítem a ítem.
2. Desarrollar tres algoritmos clínicos de decisión guiados (Código Ictus, HTA en ictus agudo, HSA Hunt-Hess/Fisher) que orienten al profesional en situaciones de alta urgencia.
3. Persistir evaluaciones de forma anonimizada, vinculadas a un paciente identificado por alias libre, con representación gráfica de la evolución temporal.
4. Garantizar la disponibilidad de la aplicación sin conexión mediante caché local SQLite, con sincronización transparente al recuperar la conectividad.
5. Publicar la aplicación en la web (GitHub Pages) y distribuirla en Android mediante APK firmado, con soporte completo de idiomas español e inglés.
6. Mantener la corrección clínica mediante un conjunto de pruebas automatizadas que cubra todos los umbrales diagnósticos de cada escala y algoritmo.

---

## R01 — Autenticación y gestión de cuenta

El usuario debe poder crear una cuenta, iniciar sesión con correo electrónico y contraseña, recuperar el acceso ante una contraseña olvidada, modificar su contraseña estando autenticado y eliminar su cuenta junto con todos los datos asociados.

### R01F01 — Registro de nueva cuenta

El sistema ofrece un formulario de registro con validación de formato de correo electrónico y longitud mínima de contraseña. Supabase Auth envía un enlace de confirmación al correo indicado; hasta que el usuario confirma, la cuenta permanece inactiva.

**R01F01T01** — Implementar `SignUpUseCase` que invoca `supabase.auth.signUp()` y convierte la respuesta en una entidad `AppUser` o lanza `AuthFailure` ante credenciales inválidas.

> **R01F01T01P01** — Prueba unitaria: correo válido + contraseña mínima → retorna `AppUser` no nulo; correo vacío → lanza `AuthFailure`. Implementada en `test/features/auth/domain/usecases/sign_up_usecase_test.dart` (2 tests). Commit de referencia: `6d677db`.

### R01F02 — Inicio de sesión

El sistema autentica al usuario mediante par correo/contraseña. Un guard de `go_router` redirige automáticamente a `/login` si la sesión no está activa y a la pantalla principal en caso contrario.

**R01F02T01** — Implementar `SignInUseCase` con `supabase.auth.signInWithPassword()`, gestión de errores localizados y redireccionamiento mediante `authStateProvider`.

> **R01F02T01P01** — Prueba unitaria: credenciales correctas → sesión activa; contraseña incorrecta → `AuthFailure` con mensaje localizable. Implementada en `test/features/auth/domain/usecases/sign_in_usecase_test.dart` (3 tests). Commit: `586b6df`.

### R01F03 — Recuperación de contraseña

El sistema envía un enlace de restablecimiento al correo registrado. Al activar el enlace, la aplicación detecta el tipo de evento `passwordRecovery` en el stream de autenticación y redirige al usuario a la pantalla `/reset-password`.

**R01F03T01** — Implementar `passwordRecoveryProvider` (Riverpod) que escucha `onAuthStateChange` y activa la ruta de restablecimiento; formulario de nueva contraseña con confirmación y `AnimatedCheck` de confirmación.

> **R01F03T01P01** — Prueba manual en dispositivo físico y Chrome: solicitar enlace → recibir email → activar enlace → introducir nueva contraseña → confirmar. Commit: `c97bfe5`.

### R01F04 — Cambio de contraseña autenticado

Desde la pantalla de perfil, el usuario puede cambiar su contraseña verificando primero la contraseña actual. El sistema rechaza el cambio si la verificación falla, evitando que un tercero con acceso físico al dispositivo cambie la contraseña sin conocerla.

**R01F04T01** — Implementar lógica de re-autenticación en `ProfileNotifier`: `signIn()` de verificación → si ok, `updatePassword()`; lanzar `AuthFailure` si la contraseña actual es incorrecta.

> **R01F04T01P01** — Prueba manual: contraseña actual errónea → mensaje de error visible; contraseña correcta → cambio confirmado. Commit: `949361f`.

### R01F05 — Borrado de cuenta y datos

El usuario puede eliminar su cuenta desde el perfil. La operación invoca una Edge Function de Supabase con privilegios de administrador (`service_role`) que borra en cascada evaluaciones, pacientes y el propio usuario de `auth.users`. La operación es irreversible y requiere confirmación explícita mediante diálogo.

**R01F05T01** — Implementar Edge Function `delete-account` (Deno/TypeScript) con `verify_jwt=true`; llamarla desde `DeleteAccountUseCase`; mostrar `AlertDialog` de confirmación antes de ejecutar.

> **R01F05T01P01** — Prueba de integración manual: crear cuenta de test → guardar evaluación → borrar cuenta → intentar iniciar sesión → verificar que la cuenta ya no existe en Supabase Dashboard. Commit: `178b9e9`.

---

## R02 — Aplicación de escalas neurológicas

El sistema debe implementar las cinco escalas neurológicas más utilizadas en neurología de urgencias con calculadoras clínicamente correctas, clasificación de gravedad por tramos y modo tutorial que explique el significado clínico de cada ítem.

### R02F01 — Glasgow Coma Scale (GCS)

Evaluación del nivel de consciencia mediante tres subescalas: apertura ocular (O, 1–4), respuesta verbal (V, 1–5) y respuesta motora (M, 1–6). Puntuación total 3–15. Clasificación: grave (3–8), moderado (9–12), leve (13–15).

**R02F01T01** — Implementar `GcsCalculator.calculate(o, v, m)` como función pura que retorna `ScaleResult` con puntuación e interpretación de severidad.

> **R02F01T01P01** — Prueba unitaria que cubre los límites de cada subescala, la puntuación mínima (3), la máxima (15) y todos los umbrales de clasificación. Implementada en `test/features/scales/gcs/gcs_calculator_test.dart` (17 tests). Commit: `6d677db`.

### R02F02 — NIHSS (National Institutes of Health Stroke Scale)

Valoración de la gravedad del ictus isquémico mediante 11 ítems neurológicos. Puntuación 0–42. Soporte para ítem marcado como no valorable (`UN`). Aviso clínico automático cuando la puntuación indica coma (nivel de consciencia 0). Clasificación: sin déficit (0), mínimo (1–4), leve (5–15), moderado (16–20), moderado-grave (21–25), grave (26–42).

**R02F02T01** — Implementar `NihssCalculator.calculate(items)` que maneja valores `UN` como `9` según el protocolo estándar; generar aviso de coma cuando el ítem 1a = 3. Implementar UI con campo `Untestable` por ítem.

> **R02F02T01P01** — Prueba unitaria que cubre todos los umbrales de clasificación, combinaciones con ítems `UN` y el aviso de coma. Implementada en `test/features/scales/nihss/nihss_calculator_test.dart` (27 tests). Commits: `70d2a59`, `f94c775`.

### R02F03 — Modified Rankin Scale (mRS)

Escala de discapacidad neurológica post-ictus de selección única. Rango 0–6, incluyendo grado 6 (fallecido). Clasificación: sin síntomas (0), sin discapacidad significativa (1), discapacidad leve (2), moderada (3), moderadamente grave (4), grave (5), fallecido (6).

**R02F03T01** — Implementar `RankinCalculator.calculate(grade)` con mapeo de grado a `Severity`; pantalla de selección única con descripción clínica por grado.

> **R02F03T01P01** — Prueba unitaria que verifica cada uno de los 7 grados posibles y los casos límite. Implementada en `test/features/scales/rankin/rankin_calculator_test.dart` (12 tests). Commit: `2e10959`.

### R02F04 — Índice de Barthel

Valoración de la independencia funcional en actividades de la vida diaria (AVD) mediante 10 ítems. Puntuación 0–100. Clasificación: dependencia total (0–20), grave (21–60), moderada (61–90), leve (91–99), independencia total (100).

**R02F04T01** — Implementar `BarthelCalculator.calculate(items)` con los valores exactos de cada ítem según la versión validada en español (Baztán 1993); validar que ningún ítem supere su máximo permitido.

> **R02F04T01P01** — Prueba unitaria que cubre todos los umbrales de clasificación, valores límite de cada ítem y puntuaciones con combinaciones de cero. Implementada en `test/features/scales/barthel/barthel_calculator_test.dart` (16 tests). Commit: `7ced22c`.

### R02F05 — ABCD² (Stratificación de riesgo post-AIT)

Escala de cinco ítems para cuantificar el riesgo de ictus en los dos días siguientes a un accidente isquémico transitorio (AIT). Puntuación 0–7. Clasificación: riesgo bajo (0–3), moderado (4–5), alto (6–7).

**R02F05T01** — Implementar `Abcd2Calculator.calculate(items)` con los pesos exactos por ítem (edad, presión arterial, clínica, duración, diabetes); pantalla de 5 preguntas con opciones múltiples.

> **R02F05T01P01** — Prueba unitaria que verifica todos los umbrales de riesgo, puntuaciones extremas y combinaciones de ítems representativas. Implementada en `test/features/scales/abcd2/abcd2_calculator_test.dart` (15 tests). Commit: `902594c`.

### R02F06 — Modo tutorial por ítem

Cada ítem de las escalas GCS, NIHSS, Barthel y ABCD² dispone de un botón de ayuda contextual (?) que abre un `BottomSheet` con la descripción clínica del criterio y su referencia bibliográfica. El modo tutorial está diseñado para estudiantes y profesionales que deseen refrescar el significado de cada ítem durante la evaluación.

**R02F06T01** — Implementar `ScaleItemHelpButton` con `helpKey` asociada a cada ítem; 31 claves ARB en ES+EN con textos clínicos revisados; `BottomSheet` con título, descripción y referencia.

> **R02F06T01P01** — Prueba manual en las cuatro escalas: activar el botón ? en cada ítem y verificar que el `BottomSheet` muestra el texto correcto. Commits: `bb65acb`, `6babf9a`, `5a6c667`.

---

## R03 — Algoritmos clínicos de decisión

El sistema debe implementar tres árboles de decisión clínica guiados que orienten al profesional paso a paso, con indicación de nivel de urgencia clasificado en cinco categorías (`crítica`, `alta`, `moderada`, `baja`, `informativa`).

### R03F01 — Código Ictus (fibrinólisis intravenosa)

Árbol de decisión que evalúa los criterios de inclusión y exclusión para la administración de tPA (alteplasa) en ventana terapéutica de 3–4,5 horas. Cada nodo muestra una pregunta con dos opciones; el resultado final indica si el paciente cumple los criterios y qué acción clínica priorizar.

**R03F01T01** — Implementar `StrokeCodeAlgorithm` como árbol de nodos inmutables (`AlgorithmNode`) con función pura `evaluate(nodeId, answer)`; pantalla `AlgorithmScreen` con animación de barrido entre nodos.

> **R03F01T01P01** — Prueba unitaria que recorre todos los caminos posibles del árbol y verifica que cada hoja produce el nivel de urgencia correcto. Implementada en `test/features/algorithms/stroke_code_algorithm_test.dart` (12 tests). Commit: `884ff0c`.

### R03F02 — HTA en ictus agudo

Algoritmo de manejo de la presión arterial en la fase aguda del ictus, con ramificaciones según el tipo de ictus (isquémico con o sin reperfusión, hemorragia intracerebral, hemorragia subaracnoidea) y los valores de presión arterial sistólica y diastólica del paciente.

**R03F02T01** — Implementar `HtaIctusAlgorithm` con nodos paramétricos que admiten valor numérico de PA; lógica de comparación de umbrales dentro de la función pura de evaluación.

> **R03F02T01P01** — Prueba unitaria que cubre las cuatro ramas de tipo de ictus y los umbrales de PA definidos por las guías ESO 2021. Implementada en `test/features/algorithms/hta_ictus_algorithm_test.dart` (11 tests). Commit: `884ff0c`.

### R03F03 — HSA Hunt-Hess / Fisher

Algoritmo combinado para la clasificación clínica (escala Hunt-Hess, grados I–V) y radiológica (escala Fisher modificada, grados 1–4) de la hemorragia subaracnoidea. Orienta sobre la indicación de intervención neuroquirúrgica urgente.

**R03F03T01** — Implementar `SahAlgorithm` con dos subramas independientes (clínica y radiológica) que se presentan secuencialmente; mostrar ambas clasificaciones en el resultado final.

> **R03F03T01P01** — Prueba unitaria que verifica los cinco grados Hunt-Hess y los cuatro grados Fisher. Suite de integración de algoritmos en `test/features/algorithms/sah_algorithm_test.dart` (9 tests) y `evaluate_algorithm_test.dart` (15 tests). Commit: `01846f7`.

---

## R04 — Gestión de pacientes anonimizados

El sistema debe permitir crear, listar, visualizar y eliminar pacientes identificados únicamente por un alias clínico libre (p. ej. `P-001` o `Demo-TCE-01`). Nunca se almacenará el nombre real ni ningún dato identificativo directo o indirecto.

### R04F01 — Creación de paciente con alias

El usuario introduce un alias libre sin PII. El sistema valida que el campo no esté vacío y persiste el paciente tanto en la base de datos remota (Supabase) como en la caché local (Drift).

**R04F01T01** — Implementar `CreatePatientUseCase` con doble persistencia remota/local; formulario con validación de campo obligatorio y longitud máxima.

> **R04F01T01P01** — Prueba unitaria: alias válido → `Patient` creado con UUID asignado; alias vacío → `ValidationFailure`. Implementada en `test/features/patients/domain/usecases/create_patient_usecase_test.dart` (4 tests). Commit: `c8e6845`.

### R04F02 — Listado y detalle de paciente

La pantalla de pacientes muestra la lista con avatar de iniciales y color tonal único por paciente. Al seleccionar un paciente, se accede a su pantalla de detalle con el historial de evaluaciones y el gráfico de evolución.

**R04F02T01** — Implementar `FetchPatientsUseCase` con estrategia remote-first + fallback local; `PatientAvatar` con color derivado del alias mediante hash determinista.

> **R04F02T01P01** — Prueba unitaria del caso de uso: lista de pacientes remota → retorna lista ordenada; fallo de red → retorna caché. Tests de widget del avatar: `test/features/patients/patient_avatar_test.dart` (8 tests). Commit: `f8fe853`.

### R04F03 — Borrado con propagación en cascada

Al eliminar un paciente, el sistema borra también todas las evaluaciones asociadas mediante restricción de clave foránea con `ON DELETE CASCADE` en la base de datos. El usuario confirma la operación mediante diálogo.

**R04F03T01** — Implementar `DeletePatientUseCase` que invoca `supabase.from('patients').delete()` y borra el registro local de Drift; la cascada en BD elimina evaluaciones automáticamente.

> **R04F03T01P01** — Prueba unitaria: borrar paciente existente → retorna `void`; borrar paciente inexistente → `NotFoundFailure`. Implementada en `test/features/patients/domain/usecases/delete_patient_usecase_test.dart` (2 tests). Commit: `5b5fb73`.

### R04F04 — Protección activa frente a PII en la descripción del caso

El campo de texto libre `case_description` de las evaluaciones está protegido por un detector de expresiones regulares que identifica patrones de DNI/NIE, NIF, correo electrónico, número de teléfono español y fecha de nacimiento. Si se detecta PII, el guardado queda bloqueado y se muestra un mensaje de error localizado.

**R04F04T01** — Implementar `PiiDetector.containsPii(text)` como función pura con 5 patrones de expresión regular; integrar la validación en `SaveEvaluationUseCase` antes de persistir.

> **R04F04T01P01** — Prueba unitaria que verifica detección positiva y negativa para cada tipo de PII (DNI, NIE, email, teléfono con prefijo +34 y sin él, fecha en formatos DD/MM/YYYY y DD-MM-YYYY). Implementada en `test/core/utils/pii_detector_test.dart` (21 tests). Commit: `301157f`.

---

## R05 — Historial y evolución temporal

El sistema debe almacenar cada evaluación completada con su escala, puntuación, interpretación, fecha/hora, alias del paciente y descripción del caso; y presentar el historial con opciones de ordenación y un gráfico de evolución temporal por escala.

### R05F01 — Guardado de evaluaciones

Al finalizar una escala, el usuario puede guardar el resultado asociándolo a un paciente existente y añadiendo una descripción de caso opcional (protegida por el detector de PII). La evaluación se persiste de forma síncrona en remoto y en la caché local.

**R05F01T01** — Implementar `SaveEvaluationUseCase` con validación de PII, doble persistencia y generación de UUID local; `ResultScreen` con botón Guardar sticky y feedback visual mediante `AnimatedCheck`.

> **R05F01T01P01** — Prueba unitaria: evaluación válida → retorna `Evaluation` con ID; descripción con DNI → `PiiDetectedFailure`. Implementada en `test/features/evaluations/domain/usecases/save_evaluation_usecase_test.dart` (4 tests). Commit: `6d677db`.

### R05F02 — Listado de evaluaciones con filtros

La pantalla de historial muestra las evaluaciones del usuario con posibilidad de ordenar por más reciente, más antigua o por escala. Cada ítem muestra la franja de color de la escala, el chip de puntuación con color de severidad y la fecha de evaluación.

**R05F02T01** — Implementar `FetchEvaluationsUseCase` con parámetro `orderBy`; `EvaluationTile` con `SeverityBadge` y franja de color por escala.

> **R05F02T01P01** — Prueba unitaria: lista remota → lista ordenada por fecha descendente por defecto; fallo de red → lista local. Implementada en `test/features/evaluations/domain/usecases/fetch_evaluations_usecase_test.dart` (7 tests). Commit: `d8d4fe7`.

### R05F03 — Gráfico de evolución temporal

La pantalla de detalle de paciente incluye un gráfico `LineChart` (fl_chart) que representa la evolución de la puntuación por escala a lo largo del tiempo. El eje X es temporal y proporcional al tiempo real; cada punto del gráfico muestra un tooltip con puntuación, fecha y hora al pulsarlo.

**R05F03T01** — Implementar `PatientDetailScreen` con selector de escala; normalizar puntuaciones al rango [0–1] para representar múltiples escalas en el mismo eje Y; eje X proporcional calculado desde epoch.

> **R05F03T01P01** — Prueba manual con el paciente `Demo-TCE-01`: 6 evaluaciones GCS (puntuaciones 8→15) + 3 evaluaciones Barthel (35→95); verificar que la curva refleja la progresión clínica esperada. Commit: `cef0664`.

### R05F04 — Borrado individual de evaluaciones

El usuario puede eliminar una evaluación del historial de forma individual mediante acción deslizante (`Dismissible`) con confirmación. El borrado propaga la eliminación a la caché local.

**R05F04T01** — Implementar `DeleteEvaluationUseCase` con borrado remoto + local; `Dismissible` con dirección de inicio a fin y diálogo de confirmación.

> **R05F04T01P01** — Prueba unitaria: borrar evaluación existente → `void`; ID inexistente → `NotFoundFailure`. Implementada en `test/features/evaluations/domain/usecases/delete_evaluation_usecase_test.dart` (3 tests). Commit: `4c1706a`.

---

## R06 — Persistencia local y modo offline

La aplicación debe funcionar sin conexión a Internet en Android e iOS, sirviendo los datos desde una caché local SQLite gestionada por Drift, e informar al usuario del estado de conectividad mediante un banner persistente.

### R06F01 — Base de datos local con Drift/SQLite

Drift actúa como capa de caché-aside para las tablas `evaluations` y `patients`. Las operaciones de escritura son duales (remoto + local); las operaciones de lectura usan el remoto como fuente primaria y el local como fallback ante fallo de red.

**R06F01T01** — Implementar `AppDatabase` con las tablas `EvaluationsTable` y `PatientsTable`; DAOs `EvaluationsDao` y `PatientsDao`; integración en los repositorios mediante `try remote / catch → local`.

> **R06F01T01P01** — Prueba de integración manual: desactivar conexión → abrir la app → verificar que pacientes y evaluaciones previamente cacheados se muestran; reconectar → verificar que nuevas operaciones se sincronizan. Commit: `14a2b31`.

### R06F02 — Banner de estado de conectividad

Cuando el dispositivo pierde la conexión, aparece un banner en la parte superior de la pantalla con el mensaje localizado `offlineBannerMessage`. El banner desaparece automáticamente al recuperar la conexión.

**R06F02T01** — Implementar `isOfflineProvider` con `connectivity_plus`; `OfflineBanner` que se inserta condicionalmente en el slot `persistentHeader` del `AppShell`.

> **R06F02T01P01** — Prueba manual en dispositivo Android: activar modo avión → banner aparece en menos de 2 segundos; desactivar modo avión → banner desaparece. Commits: `8f5f442`, `e1cc475`.

---

## R07 — Internacionalización español/inglés

La aplicación debe estar completamente localizada en español e inglés, con posibilidad de seleccionar el idioma desde la pantalla de perfil y persistir la preferencia entre sesiones.

### R07F01 — Catálogo de cadenas ARB con flutter_localizations

Todas las cadenas de texto de la interfaz, incluidos mensajes de error, etiquetas de escalas, textos clínicos del modo tutorial y avisos de PII, residen en los ficheros `lib/l10n/app_es.arb` y `lib/l10n/app_en.arb`. El código generado por `flutter gen-l10n` queda excluido del analizador.

**R07F01T01** — Mantener los dos ficheros ARB en sincronía (519 entradas cada uno); configurar `AppLocalizations` en `MaterialApp`; ejecutar `flutter gen-l10n` como paso previo al análisis estático en CI.

> **R07F01T01P01** — `flutter gen-l10n` sin errores ni claves faltantes; `flutter analyze` en `0 issues`; `widget_test.dart` verifica que `AppLocalizations` está disponible en el árbol de widgets. Commits: `b025b43`, `3b7f16a`.

### R07F02 — Selector de idioma con persistencia

La pantalla de perfil incluye un selector de idioma (español / inglés). La preferencia se almacena en `SharedPreferences` y se lee al iniciar la aplicación, antes de construir el árbol de widgets.

**R07F02T01** — Implementar `LocaleProvider` (Riverpod) que lee y escribe la preferencia en `SharedPreferences`; pasar el `locale` resuelto a `MaterialApp.locale`.

> **R07F02T01P01** — Prueba manual: seleccionar inglés → reiniciar la app → verificar que el idioma persiste. Commit: `ea1a77c`.

---

## R08 — Diseño responsive multiplataforma

La aplicación debe adaptar su navegación y disposición a los tres factores de forma principales: móvil (< 600 dp), tablet/escritorio (≥ 600 dp) y web (Chrome / GitHub Pages).

### R08F01 — Navegación adaptativa

En móvil se utiliza `NavigationBar` (M3) en la parte inferior; en tablet y escritorio se sustituye por `NavigationRail` lateral. El cambio se produce automáticamente al superar el breakpoint de 600 dp.

**R08F01T01** — Implementar `AppShell` con `StatefulShellRoute` de `go_router` y condición `MediaQuery.of(context).size.width >= 600` para seleccionar el tipo de navegación.

> **R08F01T01P01** — Prueba manual en Chrome: reducir ventana a < 600 px → `NavigationBar`; ampliar a > 600 px → `NavigationRail`. Test de widget en `widget_test.dart`. Commit: `d3a5f72`.

### R08F02 — Layouts adaptados a tablet

Las pantallas principales (escalas, pacientes, algoritmos, perfil) aplican `ResponsiveContainer` con ancho máximo de 800 dp y, en tablet, presentan un grid de dos columnas donde el contenido lo permite.

**R08F02T01** — Implementar `ResponsiveContainer` con `LayoutBuilder` y `BoxConstraints.maxWidth`; adaptar `PatientDetailScreen` a dos columnas (lista de evaluaciones + gráfico) en tablet.

> **R08F02T01P01** — Prueba manual en simulador de tablet (1024 × 1366 dp): verificar que el grid de escalas aparece en dos columnas y la pantalla de detalle de paciente muestra lista y gráfico en paralelo. Commits: `67b8645`, `8407050`.

### R08F03 — Despliegue web continuo (GitHub Pages)

La versión web se publica automáticamente en `https://grisllo.github.io/NeuroScaleApp/` mediante un flujo de GitHub Actions que construye con `flutter build web --base-href /NeuroScaleApp/` y despliega en la rama `gh-pages` en cada push a `main`.

**R08F03T01** — Configurar `deploy.yml` con acción `subosito/flutter-action` para el build y `peaceiris/actions-gh-pages` para el deploy; incluir `flutter.js` y `manifest.json` para soporte PWA.

> **R08F03T01P01** — Verificación: push a `main` → GitHub Actions completa los pasos `build` y `deploy` en verde → URL pública carga la aplicación correctamente en Chrome, Firefox y Safari. Commit: `ec8b97a`.
