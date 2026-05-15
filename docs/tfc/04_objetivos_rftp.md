# Objetivos y Requisitos Funcionales, Técnicos y de Prueba (RFTP)

## Objetivos del proyecto

El objetivo principal de NeuroScale App es ofrecer a profesionales de la salud y a estudiantes de medicina una herramienta multiplataforma que reúna las escalas neurológicas más usadas en la práctica clínica española, permita registrar evaluaciones de forma anonimizada y aporte algoritmos clínicos de apoyo a la decisión.

Los objetivos específicos son:

1. Implementar las cinco escalas neurológicas más frecuentes en neurología de urgencias (GCS, NIHSS, mRS, Barthel y ABCD²) con cálculo correcto, interpretación de gravedad y modo tutorial ítem a ítem.
2. Desarrollar tres algoritmos clínicos guiados (Código Ictus, HTA en ictus agudo y HSA Hunt-Hess/Fisher) que orienten al profesional en situaciones de alta urgencia.
3. Guardar las evaluaciones de forma anonimizada, vinculadas a un paciente identificado por un alias libre, con un gráfico de evolución en el tiempo.
4. Mantener la aplicación operativa sin conexión a Internet mediante una caché local, con sincronización automática al volver la red.
5. Publicar la aplicación en web (GitHub Pages) y distribuirla en Android (APK firmado), con soporte completo de idiomas español e inglés.
6. Garantizar la corrección clínica mediante un conjunto de pruebas automatizadas que cubra los umbrales diagnósticos de cada escala y cada algoritmo.

---

## Cómo leer este apartado

Cada requisito se describe en cuatro niveles. El nivel **R** (Requisito) plantea la necesidad en lenguaje natural. El nivel **F** (Función) describe qué hace la aplicación para cubrirla. El nivel **T** (Tarea) entra en el detalle técnico de la implementación. Y el nivel **P** (Prueba) indica cómo se verifica.

Un lector no técnico puede quedarse en R y F y obtener una visión completa. Las cinco escalas neurológicas funcionan internamente del mismo modo, igual que los tres algoritmos clínicos, así que se describen una sola vez como caso de uso representativo. Las cinco escalas y los tres algoritmos concretos se enumeran en sus tablas correspondientes.

---

## R01 — Autenticación y gestión de cuenta

Cualquier usuario debe identificarse antes de usar la aplicación. Sin sesión activa, no se puede acceder a evaluaciones ni a pacientes. Este requisito agrupa todo lo relacionado con la gestión de la cuenta: registro, login, recuperación, cambio de contraseña y borrado definitivo.

### R01F01 — Registro de nueva cuenta

El usuario nuevo introduce su correo y una contraseña, y recibe un enlace de confirmación por correo. La cuenta queda inactiva hasta que pulsa ese enlace, lo que evita registros con correos ajenos.

**R01F01T01** — Implementar `SignUpUseCase` que invoca `supabase.auth.signUp()` y devuelve un `AppUser` o lanza `AuthFailure`.

> **R01F01T01P01** — `test/features/auth/domain/usecases/sign_up_usecase_test.dart` (2 tests). Commit: `6d677db`.

### R01F02 — Inicio de sesión

El usuario introduce correo y contraseña y, si son correctos, accede a la aplicación. Un *guard* de navegación redirige siempre al login cuando no hay sesión activa.

**R01F02T01** — Implementar `SignInUseCase` con `supabase.auth.signInWithPassword()` y redirección vía `authStateProvider`.

> **R01F02T01P01** — `test/features/auth/domain/usecases/sign_in_usecase_test.dart` (3 tests). Commit: `586b6df`.

### R01F03 — Recuperación de contraseña

Si el usuario olvida la contraseña, solicita un enlace de recuperación, lo abre desde su correo y define una contraseña nueva. La aplicación detecta el flujo automáticamente.

**R01F03T01** — `passwordRecoveryProvider` (Riverpod) escucha `onAuthStateChange` y activa la ruta de restablecimiento.

> **R01F03T01P01** — Prueba manual en dispositivo físico y Chrome. Commit: `c97bfe5`.

### R01F04 — Cambio de contraseña autenticado

Desde el perfil, el usuario puede cambiar su contraseña, pero la aplicación le pide primero la contraseña actual. Así, si alguien obtiene acceso físico al dispositivo con la sesión abierta, no puede apropiarse de la cuenta.

**R01F04T01** — Re-autenticación en `ProfileNotifier`: `signIn()` de verificación previa, después `updatePassword()`.

> **R01F04T01P01** — Prueba manual. Commit: `949361f`.

### R01F05 — Borrado de cuenta y datos

El RGPD reconoce el derecho del usuario a eliminar sus datos. La aplicación borra en cascada evaluaciones, pacientes y la propia cuenta, previa confirmación explícita.

**R01F05T01** — Edge Function `delete-account` (Deno/TypeScript) con `verify_jwt=true`, invocada desde `DeleteAccountUseCase`.

> **R01F05T01P01** — Prueba de integración manual contra Supabase Dashboard. Commit: `178b9e9`.

---

## R02 — Aplicación de escalas neurológicas

Las escalas son el corazón funcional de la aplicación. El usuario elige una escala, responde a sus ítems, obtiene una puntuación con interpretación de gravedad y, opcionalmente, guarda el resultado. NeuroScale App implementa cinco escalas que comparten el mismo flujo interno:

| Escala | Rango | Para qué se usa |
|---|---|---|
| **GCS** (Glasgow Coma Scale) | 3–15 | Nivel de consciencia, sobre todo en traumatismos craneoencefálicos. |
| **NIHSS** | 0–42 | Gravedad de un ictus isquémico en fase aguda (11 ítems neurológicos). |
| **mRS** (Modified Rankin Scale) | 0–6 | Grado de discapacidad tras un ictus (6 = fallecido). |
| **Barthel** | 0–100 | Independencia para actividades de la vida diaria. |
| **ABCD²** | 0–7 | Riesgo de ictus tras un episodio isquémico transitorio. |

Como las cinco escalas siguen el mismo patrón funcional, se describen mediante un único caso representativo y un caso adicional para el modo tutorial.

### R02F01 — Aplicación de una escala (caso común a las cinco)

El usuario selecciona una escala desde la pantalla principal y responde a sus ítems uno a uno. La aplicación calcula la puntuación total al instante, la clasifica en un tramo de gravedad con su color clínico (verde, azul, naranja o rojo) y muestra una pantalla de resultado con la interpretación y el desglose por ítem. Cada escala usa internamente su propia función de cálculo, pero el flujo del usuario es idéntico para las cinco.

**R02F01T01** — Para cada escala, implementar una función pura `calculateXxx(items)` en `domain/` que devuelva un `ScaleResult` con puntuación e interpretación. Pantalla de presentación con `ProgressBar` y resaltado de la opción seleccionada. Los pesos y umbrales se han implementado según fuentes médicas verificadas: GCS (Teasdale & Jennett 1974; Teasdale et al. 2014), NIHSS (Brott 1989; Lyden 1994), mRS (Van Swieten 1988), Barthel (Baztán 1993 — versión española en uso) y ABCD² (Johnston 2007).

> **R02F01T01P01** — Tests unitarios exhaustivos sobre todos los umbrales y casos límite de cada escala: GCS (17), NIHSS (27), mRS (12), Barthel (16), ABCD² (15). Total: 87 tests del dominio de escalas. Commits representativos: `6d677db`, `70d2a59`, `2e10959`, `7ced22c`, `902594c`.

### R02F02 — Modo tutorial por ítem

Junto a cada ítem clínico aparece un pequeño botón con un signo de interrogación. Al pulsarlo, una ficha emergente muestra la descripción clínica del ítem y la referencia bibliográfica de la fuente original. El usuario que ya conoce la escala simplemente lo ignora.

**R02F02T01** — `ScaleItemHelpButton` con `helpKey` por ítem; 31 claves ARB en español e inglés con textos clínicos revisados; `BottomSheet` con título, descripción y referencia.

> **R02F02T01P01** — Prueba manual en las cuatro escalas con tutorial (GCS, NIHSS, Barthel, ABCD²). Commits: `bb65acb`, `6babf9a`, `5a6c667`.

---

## R03 — Algoritmos clínicos de decisión

Los algoritmos no calculan una puntuación, sino que guían al profesional por un árbol de preguntas para llegar a una decisión clínica. El resultado final combina una recomendación con un nivel de urgencia (informativa, baja, moderada, alta o crítica). NeuroScale App incluye tres algoritmos que comparten el mismo motor de ejecución:

| Algoritmo | Decisión clínica que orienta |
|---|---|
| **Código Ictus** | Si el paciente cumple criterios para tratamiento fibrinolítico con tPA en la ventana de 3–4,5 h. |
| **HTA en ictus agudo** | Cómo manejar la presión arterial según el tipo de ictus (isquémico con o sin reperfusión, intracerebral, subaracnoideo). |
| **HSA Hunt-Hess / Fisher** | Clasificación clínica y radiológica de una hemorragia subaracnoidea. |

Como los tres siguen el mismo flujo, se describen como un único caso representativo.

### R03F01 — Recorrido de un algoritmo (caso común a los tres)

El usuario selecciona un algoritmo y la aplicación le presenta la primera pregunta con sus opciones como tarjetas táctiles. A cada respuesta, el árbol avanza al siguiente nodo con una animación de transición lateral. Cuando llega a un nodo final, la pantalla muestra el resultado clínico, las recomendaciones y el nivel de urgencia con su color asociado. El usuario puede volver atrás en cualquier momento o reiniciar el algoritmo desde el principio.

**R03F01T01** — Modelar cada algoritmo como un grafo inmutable de `AlgorithmNode` (con dos subtipos `QuestionNode` y `ResultNode` mediante `sealed class`). Función pura `evaluate(state, optionId)` que avanza por el árbol. Pantalla `AlgorithmScreen` con animación de barrido. Los criterios clínicos se han extraído de fuentes verificadas: Código Ictus (NINDS 1995; Hacke 2008; Berge 2021), HTA (Powers 2019; Hemphill 2015; Steiner 2013), HSA (Hunt & Hess 1968; Frontera 2006).

> **R03F01T01P01** — Tests unitarios que recorren todos los caminos posibles de cada algoritmo: Código Ictus (12), HTA (11), HSA (9), motor común (15). Total: 47 tests de algoritmos. Commits: `884ff0c`, `01846f7`.

---

## R04 — Gestión de pacientes anonimizados

NeuroScale App permite agrupar evaluaciones por paciente para poder hacer seguimiento longitudinal. Para cumplir el RGPD, los pacientes se identifican mediante un alias libre (`P-001`, `Box-3-Lunes`, `Demo-TCE-01`) que el usuario elige y que nunca contiene datos identificativos reales.

### R04F01 — Crear paciente con alias

El usuario introduce un alias libre y la aplicación lo guarda en remoto y en local. La única validación es que no esté vacío y no supere la longitud máxima.

**R04F01T01** — `CreatePatientUseCase` con doble persistencia remota/local; formulario con validación.

> **R04F01T01P01** — `test/features/patients/domain/usecases/create_patient_usecase_test.dart` (4 tests). Commit: `c8e6845`.

### R04F02 — Listar y consultar pacientes

La pestaña de pacientes muestra una lista con avatar de iniciales y color único derivado del alias. Al seleccionar uno, se accede a su detalle con historial y gráfico de evolución. Funciona también sin conexión.

**R04F02T01** — `FetchPatientsUseCase` con estrategia remote-first + fallback local; `PatientAvatar` con color determinista.

> **R04F02T01P01** — `fetch_patients_usecase_test.dart` (3 tests) + `patient_avatar_test.dart` (8 tests). Commit: `f8fe853`.

### R04F03 — Borrar paciente con cascada

Al eliminar un paciente se borran también sus evaluaciones automáticamente. La cascada se aplica a nivel de base de datos, lo que garantiza que no quedan registros huérfanos. La operación pide confirmación previa por ser irreversible.

**R04F03T01** — `DeletePatientUseCase`; FK con `ON DELETE CASCADE` en la migración 0007.

> **R04F03T01P01** — `delete_patient_usecase_test.dart` (2 tests). Commit: `5b5fb73`.

### R04F04 — Detector de PII en descripciones libres

El campo libre de descripción del caso podría usarse por descuido para introducir datos identificativos. La aplicación detecta DNI, NIE, correo, teléfono y fechas de nacimiento mediante expresiones regulares y bloquea el guardado si encuentra alguno.

**R04F04T01** — `PiiDetector.containsPii(text)` con 5 patrones; integrado en `SaveEvaluationUseCase` antes de persistir.

> **R04F04T01P01** — `test/core/utils/pii_detector_test.dart` (21 tests). Commit: `301157f`.

---

## R05 — Historial y evolución temporal

Aplicar una escala y obtener un resultado es solo la mitad del valor. La otra mitad es poder consultar después lo que se aplicó y ver cómo evoluciona un paciente en el tiempo.

### R05F01 — Guardar evaluación

Al terminar una escala, el usuario puede guardar el resultado asociándolo a un paciente y añadiendo una descripción opcional. La evaluación se persiste en remoto y en la caché local. Una animación de check confirma que se guardó.

**R05F01T01** — `SaveEvaluationUseCase` con validación de PII, doble persistencia y `AnimatedCheck`.

> **R05F01T01P01** — `save_evaluation_usecase_test.dart` (4 tests). Commit: `6d677db`.

### R05F02 — Listar evaluaciones con orden y filtros

El historial muestra las evaluaciones ordenadas por fecha (la más reciente arriba por defecto). Cada tarjeta lleva una franja de color que identifica la escala y un *chip* de puntuación con el color de severidad.

**R05F02T01** — `FetchEvaluationsUseCase` con parámetro `orderBy`; `EvaluationTile` con `SeverityBadge`.

> **R05F02T01P01** — `fetch_evaluations_usecase_test.dart` (7 tests). Commit: `d8d4fe7`.

### R05F03 — Gráfico de evolución temporal

En el detalle del paciente, el usuario elige una escala y la aplicación dibuja una línea con la puntuación en el tiempo. Al pulsar un punto, una etiqueta emergente muestra la puntuación, la fecha y la hora exactas.

**R05F03T01** — `LineChart` (fl_chart) con eje X proporcional al tiempo real y puntuaciones normalizadas [0–1].

> **R05F03T01P01** — Prueba manual con el paciente `Demo-TCE-01` (6 GCS de 8→15 + 3 Barthel de 35→95). Commit: `cef0664`.

### R05F04 — Borrar evaluación individual

Desde el historial, el usuario desliza una evaluación para borrarla. La aplicación pide confirmación y propaga el borrado a remoto y a caché local.

**R05F04T01** — `DeleteEvaluationUseCase`; `Dismissible` con diálogo de confirmación.

> **R05F04T01P01** — `delete_evaluation_usecase_test.dart` (3 tests). Commit: `4c1706a`.

---

## R06 — Persistencia local y modo offline

En un hospital o una zona rural no siempre hay conexión. La aplicación guarda una copia local de los datos para seguir funcionando sin red y sincroniza automáticamente al recuperar la conexión.

### R06F01 — Caché local con Drift

Cada operación de escritura se guarda en remoto y en local de forma simultánea. Las lecturas intentan primero remoto y caen a local si falla la conexión.

**R06F01T01** — `AppDatabase` con tablas `EvaluationsTable` y `PatientsTable`; DAOs tipados; estrategia *cache-aside* en repositorios.

> **R06F01T01P01** — Prueba de integración manual: modo avión → ver datos cachedos → reconectar → verificar sincronización. Commit: `14a2b31`.

### R06F02 — Banner de conexión

Si se pierde la red, aparece una franja informativa en la parte superior. Desaparece sola al recuperarla.

**R06F02T01** — `isOfflineProvider` con `connectivity_plus`; `OfflineBanner` en `AppShell`.

> **R06F02T01P01** — Prueba manual en Android: activar modo avión → banner aparece en <2 s; desactivar → banner desaparece. Commits: `8f5f442`, `e1cc475`.

---

## R07 — Internacionalización español/inglés

Toda la interfaz —incluidos los textos clínicos del modo tutorial— está traducida a español e inglés desde la primera versión.

### R07F01 — Catálogo de cadenas ARB

Los textos viven en dos ficheros ARB centralizados (uno por idioma) con 519 entradas cada uno. `flutter gen-l10n` los convierte en clases tipadas en compilación.

**R07F01T01** — `app_es.arb` + `app_en.arb` sincronizados; `AppLocalizations` configurado en `MaterialApp`; generación en CI.

> **R07F01T01P01** — `flutter gen-l10n` sin errores; `flutter analyze` en 0 issues. Commits: `b025b43`, `3b7f16a`.

### R07F02 — Selector de idioma persistente

Desde el perfil, el usuario cambia el idioma al instante. La preferencia se recuerda entre sesiones.

**R07F02T01** — `LocaleProvider` (Riverpod) sobre `SharedPreferences`.

> **R07F02T01P01** — Prueba manual: cambiar a inglés → reiniciar → idioma persiste. Commit: `ea1a77c`.

---

## R08 — Diseño responsive multiplataforma

La aplicación se adapta a móvil, tablet, escritorio y web sin cambiar de código.

### R08F01 — Navegación adaptativa

En móvil, las cuatro secciones aparecen como barra inferior; en tablet y escritorio, como panel lateral. El cambio se produce al superar 600 px de ancho.

**R08F01T01** — `AppShell` con `StatefulShellRoute` y condición sobre `MediaQuery.size.width`.

> **R08F01T01P01** — Prueba manual en Chrome cambiando el tamaño de ventana. Commit: `d3a5f72`.

### R08F02 — Layouts en dos columnas en tablet

En pantallas grandes, el contenido se distribuye en dos columnas donde tiene sentido (caso más visible: detalle de paciente con lista + gráfico en paralelo).

**R08F02T01** — `ResponsiveContainer` con `LayoutBuilder`; max-width 800 dp.

> **R08F02T01P01** — Prueba manual en simulador de tablet (1024×1366 dp). Commits: `67b8645`, `8407050`.

### R08F03 — Despliegue web continuo

Cada push a `main` compila la versión web y la publica en GitHub Pages sin intervención manual.

**R08F03T01** — `deploy.yml` con `subosito/flutter-action` + `peaceiris/actions-gh-pages`.

> **R08F03T01P01** — Verificación: push a `main` → CI verde → URL pública responde. Commit: `ec8b97a`.
