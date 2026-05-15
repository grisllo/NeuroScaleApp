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

## Cómo leer este apartado

Cada requisito se describe en cuatro niveles de detalle. El nivel **R** (Requisito) presenta la necesidad del usuario en lenguaje natural. El nivel **F** (Función) describe qué hace la aplicación para cubrirla. El nivel **T** (Tarea) entra en el detalle técnico de cómo se implementó. Y el nivel **P** (Prueba) indica cómo se verifica que la implementación cumple lo que promete. Un lector no técnico puede quedarse en los niveles R y F y obtener una visión completa del alcance; un lector técnico puede descender a T y P para validar cada componente.

---

## R01 — Autenticación y gestión de cuenta

Cualquier persona que quiera utilizar NeuroScale App debe identificarse primero. La autenticación es la puerta de entrada a todo lo demás: sin sesión activa, la aplicación no muestra ninguna evaluación ni permite crear pacientes. Este requisito agrupa todo lo relacionado con la gestión de la cuenta del usuario, desde el registro inicial hasta el borrado definitivo de la misma. El objetivo es que cualquier usuario pueda crearse una cuenta, recuperar el acceso si olvida la contraseña, modificarla cuando lo desee y, llegado el caso, eliminar su cuenta junto con todos los datos asociados sin dejar rastros.

### R01F01 — Registro de nueva cuenta

Un usuario nuevo abre la aplicación y encuentra un formulario sencillo: introduce su correo electrónico, elige una contraseña y la confirma. La aplicación comprueba que el correo tiene un formato válido y que la contraseña cumple un mínimo de longitud, y a continuación envía un enlace de verificación al correo indicado. Hasta que el usuario hace clic en ese enlace y confirma su dirección, la cuenta permanece inactiva. Este paso evita que alguien pueda registrarse con un correo que no le pertenece.

**R01F01T01** — Implementar `SignUpUseCase` que invoca `supabase.auth.signUp()` y convierte la respuesta en una entidad `AppUser` o lanza `AuthFailure` ante credenciales inválidas.

> **R01F01T01P01** — Prueba unitaria: correo válido + contraseña mínima → retorna `AppUser` no nulo; correo vacío → lanza `AuthFailure`. Implementada en `test/features/auth/domain/usecases/sign_up_usecase_test.dart` (2 tests). Commit de referencia: `6d677db`.

### R01F02 — Inicio de sesión

Una vez confirmada la cuenta, el usuario inicia sesión introduciendo su correo y contraseña. Si las credenciales son correctas, la aplicación abre la pantalla principal con las escalas; si la sesión no está activa, cualquier intento de acceder a otras zonas redirige automáticamente al login. Este comportamiento, llamado *guard* de autenticación, garantiza que el flujo de la aplicación respeta siempre el estado de la sesión.

**R01F02T01** — Implementar `SignInUseCase` con `supabase.auth.signInWithPassword()`, gestión de errores localizados y redireccionamiento mediante `authStateProvider`.

> **R01F02T01P01** — Prueba unitaria: credenciales correctas → sesión activa; contraseña incorrecta → `AuthFailure` con mensaje localizable. Implementada en `test/features/auth/domain/usecases/sign_in_usecase_test.dart` (3 tests). Commit: `586b6df`.

### R01F03 — Recuperación de contraseña

Si el usuario olvida su contraseña, no debería perder el acceso a sus pacientes y evaluaciones. La aplicación le permite solicitar un enlace de recuperación: introduce su correo, recibe un mensaje con un enlace seguro y, al pulsarlo desde su dispositivo, llega a una pantalla donde puede definir una contraseña nueva. La aplicación detecta automáticamente este flujo gracias al sistema de eventos de autenticación de Supabase.

**R01F03T01** — Implementar `passwordRecoveryProvider` (Riverpod) que escucha `onAuthStateChange` y activa la ruta de restablecimiento; formulario de nueva contraseña con confirmación y `AnimatedCheck` de confirmación.

> **R01F03T01P01** — Prueba manual en dispositivo físico y Chrome: solicitar enlace → recibir email → activar enlace → introducir nueva contraseña → confirmar. Commit: `c97bfe5`.

### R01F04 — Cambio de contraseña autenticado

Aunque no haya olvidado su contraseña, el usuario puede querer cambiarla por motivos de seguridad o de costumbre. Desde la pantalla de perfil tiene un formulario que se lo permite, pero con una garantía importante: antes de aceptar el cambio, la aplicación le pide que introduzca también la contraseña actual. De este modo, si alguien obtiene acceso físico al dispositivo con una sesión abierta, no podrá apropiarse de la cuenta cambiando la contraseña sin conocerla previamente.

**R01F04T01** — Implementar lógica de re-autenticación en `ProfileNotifier`: `signIn()` de verificación → si ok, `updatePassword()`; lanzar `AuthFailure` si la contraseña actual es incorrecta.

> **R01F04T01P01** — Prueba manual: contraseña actual errónea → mensaje de error visible; contraseña correcta → cambio confirmado. Commit: `949361f`.

### R01F05 — Borrado de cuenta y datos

El RGPD reconoce al usuario el derecho a eliminar sus datos personales del servicio. NeuroScale App lo implementa de forma íntegra: desde el perfil, el usuario puede solicitar el borrado de su cuenta, y la aplicación elimina en cascada todas sus evaluaciones, pacientes y la propia cuenta de autenticación. La operación es irreversible y por eso se solicita confirmación explícita mediante un diálogo de advertencia antes de ejecutarla.

**R01F05T01** — Implementar Edge Function `delete-account` (Deno/TypeScript) con `verify_jwt=true`; llamarla desde `DeleteAccountUseCase`; mostrar `AlertDialog` de confirmación antes de ejecutar.

> **R01F05T01P01** — Prueba de integración manual: crear cuenta de test → guardar evaluación → borrar cuenta → intentar iniciar sesión → verificar que la cuenta ya no existe en Supabase Dashboard. Commit: `178b9e9`.

---

## R02 — Aplicación de escalas neurológicas

Las escalas son el corazón funcional de NeuroScale App. El usuario las aplica a un paciente, responde a cada uno de sus ítems, obtiene una puntuación y una interpretación clínica de gravedad, y opcionalmente guarda el resultado. Las cinco escalas implementadas son las más utilizadas en neurología de urgencias en el sistema sanitario español: la Escala de Coma de Glasgow para valorar el nivel de consciencia, la NIHSS para cuantificar la gravedad del ictus isquémico, la Escala de Rankin modificada para medir la discapacidad neurológica tras un ictus, el Índice de Barthel para evaluar la independencia en las actividades básicas de la vida diaria, y la escala ABCD² para estimar el riesgo de ictus tras un accidente isquémico transitorio. Cada una incluye un modo tutorial pensado para estudiantes y profesionales que necesiten refrescar el significado clínico de cada ítem.

### R02F01 — Glasgow Coma Scale (GCS)

La GCS es la escala más conocida para medir el nivel de consciencia de un paciente, especialmente útil en traumatismos craneoencefálicos y emergencias neurológicas. Pregunta tres cosas: con qué facilidad abre los ojos el paciente, qué calidad tiene su respuesta verbal y cómo responde con el movimiento. La puntuación va de 3 a 15, y la aplicación clasifica el resultado en tres tramos: grave (3–8), moderado (9–12) o leve (13–15). Cuanto más baja la puntuación, más profunda la alteración de la consciencia.

**R02F01T01** — Implementar `GcsCalculator.calculate(o, v, m)` como función pura que retorna `ScaleResult` con puntuación e interpretación de severidad.

> **R02F01T01P01** — Prueba unitaria que cubre los límites de cada subescala, la puntuación mínima (3), la máxima (15) y todos los umbrales de clasificación. Implementada en `test/features/scales/gcs/gcs_calculator_test.dart` (17 tests). Commit: `6d677db`.

### R02F02 — NIHSS (National Institutes of Health Stroke Scale)

La NIHSS es la herramienta de referencia para cuantificar la gravedad de un ictus isquémico en su fase aguda. Está compuesta por 11 ítems que recorren el examen neurológico completo: nivel de consciencia, orientación, mirada, campo visual, parálisis facial, fuerza en cada extremidad, ataxia, sensibilidad, lenguaje, disartria y atención. La puntuación total va de 0 (sin déficit) a 42 (déficit muy grave). Algunos ítems pueden marcarse como no valorables (por ejemplo, si el paciente está intubado y no se le puede evaluar la palabra); la escala asigna a esos casos el valor convencional 9. La aplicación incluye además un aviso clínico automático cuando la puntuación del primer ítem indica coma.

**R02F02T01** — Implementar `NihssCalculator.calculate(items)` que maneja valores `UN` como `9` según el protocolo estándar; generar aviso de coma cuando el ítem 1a = 3. Implementar UI con campo `Untestable` por ítem.

> **R02F02T01P01** — Prueba unitaria que cubre todos los umbrales de clasificación, combinaciones con ítems `UN` y el aviso de coma. Implementada en `test/features/scales/nihss/nihss_calculator_test.dart` (27 tests). Commits: `70d2a59`, `f94c775`.

### R02F03 — Modified Rankin Scale (mRS)

A diferencia de las escalas anteriores, la mRS no se calcula sumando ítems: el clínico observa al paciente y selecciona directamente un grado del 0 al 6 que describe su nivel de discapacidad neurológica. El grado 0 significa que no tiene síntomas, los grados intermedios cubren distintos niveles de dependencia (sin discapacidad significativa, leve, moderada, moderadamente grave, grave) y el grado 6 corresponde al fallecimiento del paciente. Es la escala estándar para describir el desenlace funcional de un ictus a los tres o seis meses de evolución.

**R02F03T01** — Implementar `RankinCalculator.calculate(grade)` con mapeo de grado a `Severity`; pantalla de selección única con descripción clínica por grado.

> **R02F03T01P01** — Prueba unitaria que verifica cada uno de los 7 grados posibles y los casos límite. Implementada en `test/features/scales/rankin/rankin_calculator_test.dart` (12 tests). Commit: `2e10959`.

### R02F04 — Índice de Barthel

El Índice de Barthel mide hasta qué punto un paciente puede realizar las actividades básicas de la vida diaria de forma autónoma. Recorre diez aspectos del día a día: comer, asearse, ducharse, vestirse, controlar los esfínteres, usar el inodoro, trasladarse de la cama a la silla, caminar y subir escaleras. Cada ítem suma un número distinto de puntos según el grado de autonomía, y el total va de 0 (dependencia total) a 100 (independencia completa). La aplicación implementa los pesos exactos de la versión española validada por Baztán y colaboradores, que es la que se utiliza de forma estándar en el sistema sanitario español.

**R02F04T01** — Implementar `BarthelCalculator.calculate(items)` con los valores exactos de cada ítem según la versión validada en español (Baztán 1993); validar que ningún ítem supere su máximo permitido.

> **R02F04T01P01** — Prueba unitaria que cubre todos los umbrales de clasificación, valores límite de cada ítem y puntuaciones con combinaciones de cero. Implementada en `test/features/scales/barthel/barthel_calculator_test.dart` (16 tests). Commit: `7ced22c`.

### R02F05 — ABCD² (estratificación de riesgo post-AIT)

Cuando un paciente sufre un accidente isquémico transitorio (un episodio breve con síntomas de ictus que remiten en menos de 24 horas), una pregunta clínica clave es: ¿cuál es la probabilidad de que sufra un ictus completo en los próximos días? La escala ABCD² responde a esta pregunta mediante cinco factores de riesgo: edad del paciente, presión arterial en el momento del episodio, tipo de síntomas clínicos, duración del episodio y presencia de diabetes. La suma de los cinco factores va de 0 a 7 y permite clasificar al paciente en riesgo bajo (0–3), moderado (4–5) o alto (6–7), lo que orienta sobre la urgencia con que debe ser estudiado.

**R02F05T01** — Implementar `Abcd2Calculator.calculate(items)` con los pesos exactos por ítem (edad, presión arterial, clínica, duración, diabetes); pantalla de 5 preguntas con opciones múltiples.

> **R02F05T01P01** — Prueba unitaria que verifica todos los umbrales de riesgo, puntuaciones extremas y combinaciones de ítems representativas. Implementada en `test/features/scales/abcd2/abcd2_calculator_test.dart` (15 tests). Commit: `902594c`.

### R02F06 — Modo tutorial por ítem

Cada escala se aplica respondiendo a varios ítems clínicos cuyo significado no siempre es evidente para alguien que está aprendiendo o que la usa de forma poco frecuente. Por eso, junto a cada pregunta de las escalas GCS, NIHSS, Barthel y ABCD² aparece un pequeño botón con un signo de interrogación: al pulsarlo se abre una ficha emergente con la descripción clínica del ítem y la referencia bibliográfica de la fuente original. El modo tutorial no condiciona el flujo de la evaluación: el usuario que ya conoce la escala simplemente lo ignora.

**R02F06T01** — Implementar `ScaleItemHelpButton` con `helpKey` asociada a cada ítem; 31 claves ARB en ES+EN con textos clínicos revisados; `BottomSheet` con título, descripción y referencia.

> **R02F06T01P01** — Prueba manual en las cuatro escalas: activar el botón ? en cada ítem y verificar que el `BottomSheet` muestra el texto correcto. Commits: `bb65acb`, `6babf9a`, `5a6c667`.

---

## R03 — Algoritmos clínicos de decisión

Las escalas son una herramienta de medida; los algoritmos clínicos son una herramienta de decisión. Cuando un profesional se enfrenta a un paciente con sospecha de ictus, no solo necesita medir su NIHSS: necesita decidir si activa el Código Ictus, si administra tratamiento fibrinolítico, qué hacer con su presión arterial o qué grado de hemorragia subaracnoidea presenta. NeuroScale App implementa tres de los árboles de decisión más relevantes en neurología de urgencias. Cada uno guía al usuario paso a paso, le pregunta los datos que necesita y entrega un resultado final que combina una indicación clínica con un nivel de urgencia (informativa, baja, moderada, alta o crítica).

### R03F01 — Código Ictus (fibrinólisis intravenosa)

El Código Ictus es el protocolo de actuación urgente ante una sospecha de ictus isquémico agudo. Su objetivo es decidir si el paciente cumple los criterios para recibir tratamiento con tPA (alteplasa), un fibrinolítico que solo puede administrarse dentro de una ventana terapéutica de 3 a 4,5 horas desde el inicio de los síntomas. El algoritmo guía al usuario por una serie de preguntas sobre tiempo, gravedad neurológica, contraindicaciones y comorbilidades, y entrega como resultado una recomendación clara sobre si el paciente es candidato a fibrinólisis o no.

**R03F01T01** — Implementar `StrokeCodeAlgorithm` como árbol de nodos inmutables (`AlgorithmNode`) con función pura `evaluate(nodeId, answer)`; pantalla `AlgorithmScreen` con animación de barrido entre nodos.

> **R03F01T01P01** — Prueba unitaria que recorre todos los caminos posibles del árbol y verifica que cada hoja produce el nivel de urgencia correcto. Implementada en `test/features/algorithms/stroke_code_algorithm_test.dart` (12 tests). Commit: `884ff0c`.

### R03F02 — HTA en ictus agudo

La presión arterial en la fase aguda de un ictus se maneja de forma muy distinta según el tipo de ictus que sufra el paciente. En un ictus isquémico sin reperfusión se tolera una presión más alta para preservar la circulación cerebral; en un ictus isquémico con reperfusión, en cambio, la presión debe controlarse estrictamente para evitar la transformación hemorrágica. En una hemorragia intracerebral los objetivos son más estrictos aún, y en una hemorragia subaracnoidea entran en juego otros factores como el vasoespasmo. El algoritmo recorre estas ramas pidiendo al usuario el tipo de ictus y los valores de presión, y entrega los objetivos terapéuticos y las indicaciones farmacológicas adecuadas en cada caso.

**R03F02T01** — Implementar `HtaIctusAlgorithm` con nodos paramétricos que admiten valor numérico de PA; lógica de comparación de umbrales dentro de la función pura de evaluación.

> **R03F02T01P01** — Prueba unitaria que cubre las cuatro ramas de tipo de ictus y los umbrales de PA definidos por las guías ESO 2021. Implementada en `test/features/algorithms/hta_ictus_algorithm_test.dart` (11 tests). Commit: `884ff0c`.

### R03F03 — HSA Hunt-Hess / Fisher

Ante una hemorragia subaracnoidea (la rotura de un aneurisma cerebral, una emergencia neurológica de primer orden), el clínico necesita clasificar al paciente con dos criterios independientes para decidir el manejo: una clasificación clínica basada en el estado neurológico del paciente (la escala Hunt-Hess, con cinco grados de I a V) y una clasificación radiológica basada en la imagen de TC craneal (la escala Fisher modificada, con cuatro grados de 1 a 4). El algoritmo presenta ambas escalas de forma secuencial, recoge las dos respuestas y combina las dos clasificaciones en el resultado final, orientando sobre la prioridad de la intervención neuroquirúrgica.

**R03F03T01** — Implementar `SahAlgorithm` con dos subramas independientes (clínica y radiológica) que se presentan secuencialmente; mostrar ambas clasificaciones en el resultado final.

> **R03F03T01P01** — Prueba unitaria que verifica los cinco grados Hunt-Hess y los cuatro grados Fisher. Suite de integración de algoritmos en `test/features/algorithms/sah_algorithm_test.dart` (9 tests) y `evaluate_algorithm_test.dart` (15 tests). Commit: `01846f7`.

---

## R04 — Gestión de pacientes anonimizados

Una de las diferencias fundamentales de NeuroScale App frente a otras aplicaciones de cálculo clínico es que permite agrupar las evaluaciones por paciente, lo que hace posible monitorizar la evolución de un caso a lo largo del tiempo. Para hacerlo cumpliendo el RGPD y evitar el almacenamiento de datos personales, los pacientes se identifican mediante un alias clínico libre (por ejemplo `P-001`, `Box-3-Lunes` o `Demo-TCE-01`) que el propio usuario elige y que no contiene información identificativa real. La aplicación se asegura activamente de que ningún dato sensible se cuele en los campos de texto libre mediante un detector de patrones de PII.

### R04F01 — Creación de paciente con alias

El usuario crea un paciente nuevo desde la pestaña de pacientes y le asigna un alias libre, sin más restricciones que el alias no esté vacío y no supere una longitud máxima razonable. Una vez creado, el paciente queda guardado tanto en la base de datos remota como en la caché local del dispositivo, de modo que está disponible incluso si se pierde la conexión a Internet en el momento de seleccionarlo.

**R04F01T01** — Implementar `CreatePatientUseCase` con doble persistencia remota/local; formulario con validación de campo obligatorio y longitud máxima.

> **R04F01T01P01** — Prueba unitaria: alias válido → `Patient` creado con UUID asignado; alias vacío → `ValidationFailure`. Implementada en `test/features/patients/domain/usecases/create_patient_usecase_test.dart` (4 tests). Commit: `c8e6845`.

### R04F02 — Listado y detalle de paciente

La pestaña de pacientes muestra una lista visualmente clara donde cada paciente aparece representado por un avatar circular con sus iniciales y un color único derivado de su alias, lo que ayuda a distinguirlos de un vistazo. Al seleccionar uno, se accede a su pantalla de detalle, que reúne el historial de evaluaciones asociadas y el gráfico de evolución temporal. El listado funciona aunque no haya conexión, sirviendo los datos desde la caché local.

**R04F02T01** — Implementar `FetchPatientsUseCase` con estrategia remote-first + fallback local; `PatientAvatar` con color derivado del alias mediante hash determinista.

> **R04F02T01P01** — Prueba unitaria del caso de uso: lista de pacientes remota → retorna lista ordenada; fallo de red → retorna caché. Tests de widget del avatar: `test/features/patients/patient_avatar_test.dart` (8 tests). Commit: `f8fe853`.

### R04F03 — Borrado con propagación en cascada

Cuando un usuario elimina un paciente, la aplicación borra también todas las evaluaciones que tenía asociadas. Mantenerlas huérfanas no tendría sentido clínico ni cumpliría con la expectativa razonable del usuario (que asume que "borrar al paciente" elimina todo lo relacionado con él). La cascada se aplica directamente en la base de datos mediante una restricción de clave foránea, de modo que la operación es atómica y no puede dejar registros inconsistentes. La operación pide confirmación previa porque es irreversible.

**R04F03T01** — Implementar `DeletePatientUseCase` que invoca `supabase.from('patients').delete()` y borra el registro local de Drift; la cascada en BD elimina evaluaciones automáticamente.

> **R04F03T01P01** — Prueba unitaria: borrar paciente existente → retorna `void`; borrar paciente inexistente → `NotFoundFailure`. Implementada en `test/features/patients/domain/usecases/delete_patient_usecase_test.dart` (2 tests). Commit: `5b5fb73`.

### R04F04 — Protección activa frente a PII en la descripción del caso

Cada evaluación tiene un campo de texto libre donde el usuario puede anotar contexto clínico relevante: "Paciente con TCE leve, GCS 14, sin pérdida de consciencia". El problema potencial es que ese campo, al ser libre, podría usarse por descuido para introducir datos identificativos del paciente (un nombre, un DNI, un teléfono). NeuroScale App detecta activamente esos patrones mediante expresiones regulares y bloquea el guardado mostrando un mensaje de aviso. La protección no es perfecta —ningún detector lo es— pero cubre los formatos identificativos más habituales en España y reduce drásticamente la probabilidad de incumplimiento involuntario del RGPD.

**R04F04T01** — Implementar `PiiDetector.containsPii(text)` como función pura con 5 patrones de expresión regular; integrar la validación en `SaveEvaluationUseCase` antes de persistir.

> **R04F04T01P01** — Prueba unitaria que verifica detección positiva y negativa para cada tipo de PII (DNI, NIE, email, teléfono con prefijo +34 y sin él, fecha en formatos DD/MM/YYYY y DD-MM-YYYY). Implementada en `test/core/utils/pii_detector_test.dart` (21 tests). Commit: `301157f`.

---

## R05 — Historial y evolución temporal

Aplicar una escala y obtener un resultado es solo la mitad del valor clínico que ofrece NeuroScale App. La otra mitad es poder consultar más tarde lo que se aplicó, compararlo con evaluaciones anteriores y observar la evolución del paciente a lo largo del tiempo. Este requisito agrupa todo lo relacionado con la persistencia, listado, visualización y borrado de evaluaciones, incluyendo el gráfico de evolución temporal que permite ver de un vistazo si un paciente mejora o empeora.

### R05F01 — Guardado de evaluaciones

Al terminar de aplicar una escala, el usuario llega a la pantalla de resultado, donde puede ver la puntuación, la interpretación clínica y el desglose por ítem. Desde ahí puede guardar la evaluación pulsando un botón fijo en la parte inferior. Antes de hacerlo, la aplicación le ofrece asociar el resultado a un paciente existente y añadir una descripción opcional del caso. Si la descripción contiene PII, el guardado queda bloqueado hasta que el usuario corrija el texto. Una vez guardada, una pequeña animación de confirmación le indica que todo ha ido bien.

**R05F01T01** — Implementar `SaveEvaluationUseCase` con validación de PII, doble persistencia y generación de UUID local; `ResultScreen` con botón Guardar sticky y feedback visual mediante `AnimatedCheck`.

> **R05F01T01P01** — Prueba unitaria: evaluación válida → retorna `Evaluation` con ID; descripción con DNI → `PiiDetectedFailure`. Implementada en `test/features/evaluations/domain/usecases/save_evaluation_usecase_test.dart` (4 tests). Commit: `6d677db`.

### R05F02 — Listado de evaluaciones con filtros

Una vez guardadas las evaluaciones, el usuario quiere revisarlas. La pantalla de historial las muestra como una lista ordenada por fecha, mostrando para cada una la escala aplicada, la puntuación con su color de severidad, la fecha y la información del paciente al que corresponde. El usuario puede cambiar el orden a su gusto: por más reciente, más antigua o agrupado por escala. Cada tarjeta usa una franja de color para identificar visualmente la escala de un solo vistazo, lo que ayuda a localizar rápidamente lo que se busca.

**R05F02T01** — Implementar `FetchEvaluationsUseCase` con parámetro `orderBy`; `EvaluationTile` con `SeverityBadge` y franja de color por escala.

> **R05F02T01P01** — Prueba unitaria: lista remota → lista ordenada por fecha descendente por defecto; fallo de red → lista local. Implementada en `test/features/evaluations/domain/usecases/fetch_evaluations_usecase_test.dart` (7 tests). Commit: `d8d4fe7`.

### R05F03 — Gráfico de evolución temporal

Cuando un paciente tiene varias evaluaciones de la misma escala separadas en el tiempo, la pregunta clínica natural es: ¿va mejor, igual o peor que la última vez? El gráfico de evolución temporal responde a esta pregunta visualmente. En la pantalla de detalle del paciente, el usuario selecciona qué escala quiere visualizar y aparece una gráfica de líneas donde el eje horizontal es el tiempo (proporcional a la separación real entre evaluaciones) y el eje vertical es la puntuación. Al pulsar cualquier punto del gráfico, una pequeña etiqueta emergente muestra la puntuación exacta, la fecha y la hora de esa evaluación concreta.

**R05F03T01** — Implementar `PatientDetailScreen` con selector de escala; normalizar puntuaciones al rango [0–1] para representar múltiples escalas en el mismo eje Y; eje X proporcional calculado desde epoch.

> **R05F03T01P01** — Prueba manual con el paciente `Demo-TCE-01`: 6 evaluaciones GCS (puntuaciones 8→15) + 3 evaluaciones Barthel (35→95); verificar que la curva refleja la progresión clínica esperada. Commit: `cef0664`.

### R05F04 — Borrado individual de evaluaciones

A veces el usuario guarda una evaluación por error, o quiere eliminar registros antiguos que ya no le interesan. La aplicación permite borrar evaluaciones de forma individual desde el historial: basta con deslizar el dedo sobre una tarjeta y la aplicación pide confirmación antes de eliminarla. El borrado se propaga simultáneamente a la base de datos remota y a la caché local, de modo que la coherencia se mantiene incluso si la conexión se pierde antes de completar la operación.

**R05F04T01** — Implementar `DeleteEvaluationUseCase` con borrado remoto + local; `Dismissible` con dirección de inicio a fin y diálogo de confirmación.

> **R05F04T01P01** — Prueba unitaria: borrar evaluación existente → `void`; ID inexistente → `NotFoundFailure`. Implementada en `test/features/evaluations/domain/usecases/delete_evaluation_usecase_test.dart` (3 tests). Commit: `4c1706a`.

---

## R06 — Persistencia local y modo offline

En un entorno hospitalario o en una zona rural, no siempre hay conexión a Internet disponible. Sería problemático que NeuroScale App dejara de funcionar en esas situaciones, justo cuando más se necesita. Por eso la aplicación incluye un modo offline completo en Android e iOS: guarda una copia local de los datos del usuario en una base de datos SQLite gestionada por Drift y los sirve desde ahí cuando no hay conexión. Cuando la conexión vuelve, las nuevas operaciones se sincronizan automáticamente con el servidor.

### R06F01 — Base de datos local con Drift/SQLite

Cada evaluación y cada paciente que el usuario crea se guarda al mismo tiempo en dos sitios: en el servidor de Supabase y en una pequeña base de datos local que vive en el dispositivo. La aplicación intenta siempre leer primero desde el servidor (porque puede haber cambios hechos desde otro dispositivo), pero si falla por falta de conexión, recurre al almacén local sin que el usuario perciba la diferencia. Este patrón se conoce como *cache-aside* y es el que mejor se adapta a aplicaciones móviles con conectividad irregular.

**R06F01T01** — Implementar `AppDatabase` con las tablas `EvaluationsTable` y `PatientsTable`; DAOs `EvaluationsDao` y `PatientsDao`; integración en los repositorios mediante `try remote / catch → local`.

> **R06F01T01P01** — Prueba de integración manual: desactivar conexión → abrir la app → verificar que pacientes y evaluaciones previamente cacheados se muestran; reconectar → verificar que nuevas operaciones se sincronizan. Commit: `14a2b31`.

### R06F02 — Banner de estado de conectividad

Aunque la aplicación funcione sin conexión, es útil que el usuario sepa que está trabajando en modo offline, sobre todo si lo está haciendo sin darse cuenta. Cuando el dispositivo pierde la conectividad, una pequeña franja informativa aparece en la parte superior de la pantalla con un mensaje localizado que avisa de la situación. En cuanto se recupera la conexión, la franja desaparece automáticamente, sin que el usuario tenga que hacer nada.

**R06F02T01** — Implementar `isOfflineProvider` con `connectivity_plus`; `OfflineBanner` que se inserta condicionalmente en el slot `persistentHeader` del `AppShell`.

> **R06F02T01P01** — Prueba manual en dispositivo Android: activar modo avión → banner aparece en menos de 2 segundos; desactivar modo avión → banner desaparece. Commits: `8f5f442`, `e1cc475`.

---

## R07 — Internacionalización español/inglés

NeuroScale App nació pensada para profesionales y estudiantes hispanohablantes, pero queríamos también que fuera accesible para usuarios en inglés sin tener que mantener dos versiones distintas del código. Por eso, desde la primera versión todas las cadenas de texto de la interfaz —incluidos los textos clínicos del modo tutorial, los mensajes de error y los avisos de PII— están traducidas a los dos idiomas y el usuario puede cambiar entre ellos desde la pantalla de perfil.

### R07F01 — Catálogo de cadenas ARB con flutter_localizations

Todas las cadenas de texto que aparecen en la interfaz viven en dos ficheros centralizados (uno por idioma) en lugar de estar repartidas por los componentes de la aplicación. Cada texto tiene una clave única y el sistema oficial de internacionalización de Flutter se encarga de elegir la traducción correcta según el idioma activo. El proyecto mantiene 519 textos en español y 519 en inglés, y un proceso de generación automática los convierte en clases tipadas que el código puede consumir con seguridad.

**R07F01T01** — Mantener los dos ficheros ARB en sincronía (519 entradas cada uno); configurar `AppLocalizations` en `MaterialApp`; ejecutar `flutter gen-l10n` como paso previo al análisis estático en CI.

> **R07F01T01P01** — `flutter gen-l10n` sin errores ni claves faltantes; `flutter analyze` en `0 issues`; `widget_test.dart` verifica que `AppLocalizations` está disponible en el árbol de widgets. Commits: `b025b43`, `3b7f16a`.

### R07F02 — Selector de idioma con persistencia

Desde la pantalla de perfil, el usuario puede cambiar el idioma de la aplicación entre español e inglés. El cambio se aplica al instante y se recuerda entre sesiones, de modo que la próxima vez que abra la aplicación seguirá apareciendo en el idioma elegido sin tener que volver a seleccionarlo.

**R07F02T01** — Implementar `LocaleProvider` (Riverpod) que lee y escribe la preferencia en `SharedPreferences`; pasar el `locale` resuelto a `MaterialApp.locale`.

> **R07F02T01P01** — Prueba manual: seleccionar inglés → reiniciar la app → verificar que el idioma persiste. Commit: `ea1a77c`.

---

## R08 — Diseño responsive multiplataforma

NeuroScale App debe funcionar igual de bien en el móvil que usa el residente para una consulta rápida, en la tablet de la sala de urgencias y en el navegador del ordenador de despacho. Para cubrir esas tres formas de uso, la interfaz se adapta automáticamente al tamaño de pantalla disponible: cambia la navegación, distribuye el contenido en una o dos columnas, y ajusta los anchos máximos para que la lectura sea cómoda en cualquier dispositivo.

### R08F01 — Navegación adaptativa

En un dispositivo móvil con pantalla estrecha, la navegación principal de la aplicación aparece como una barra inferior con los iconos de las cuatro secciones (escalas, pacientes, algoritmos y perfil). En tablet o escritorio, esa misma barra se transforma en un panel lateral vertical (NavigationRail), que aprovecha mejor el espacio horizontal disponible. El cambio se produce automáticamente cuando el ancho de la ventana supera los 600 píxeles, sin que el usuario tenga que configurar nada.

**R08F01T01** — Implementar `AppShell` con `StatefulShellRoute` de `go_router` y condición `MediaQuery.of(context).size.width >= 600` para seleccionar el tipo de navegación.

> **R08F01T01P01** — Prueba manual en Chrome: reducir ventana a < 600 px → `NavigationBar`; ampliar a > 600 px → `NavigationRail`. Test de widget en `widget_test.dart`. Commit: `d3a5f72`.

### R08F02 — Layouts adaptados a tablet

En una pantalla grande, mostrar el contenido en una sola columna estrecha desperdicia el espacio disponible y obliga al usuario a hacer más scroll del necesario. Por eso, en las pantallas de escalas, pacientes, algoritmos y perfil, la aplicación aplica un ancho máximo razonable y, cuando tiene sentido, distribuye el contenido en dos columnas. El caso más visible es la pantalla de detalle del paciente, que en tablet muestra el listado de evaluaciones a la izquierda y el gráfico de evolución a la derecha, permitiendo consultar ambos sin tener que cambiar de pestaña.

**R08F02T01** — Implementar `ResponsiveContainer` con `LayoutBuilder` y `BoxConstraints.maxWidth`; adaptar `PatientDetailScreen` a dos columnas (lista de evaluaciones + gráfico) en tablet.

> **R08F02T01P01** — Prueba manual en simulador de tablet (1024 × 1366 dp): verificar que el grid de escalas aparece en dos columnas y la pantalla de detalle de paciente muestra lista y gráfico en paralelo. Commits: `67b8645`, `8407050`.

### R08F03 — Despliegue web continuo (GitHub Pages)

Para que cualquier persona pueda probar NeuroScale App sin necesidad de instalar nada, la aplicación se publica como sitio web estático en GitHub Pages. Cada vez que se hace un push de cambios a la rama principal del repositorio, un proceso automatizado compila la versión web, la sube al hosting y la deja disponible públicamente en la URL del proyecto. Esto convierte cada commit en `main` en un despliegue inmediato, sin pasos manuales ni intervención del desarrollador.

**R08F03T01** — Configurar `deploy.yml` con acción `subosito/flutter-action` para el build y `peaceiris/actions-gh-pages` para el deploy; incluir `flutter.js` y `manifest.json` para soporte PWA.

> **R08F03T01P01** — Verificación: push a `main` → GitHub Actions completa los pasos `build` y `deploy` en verde → URL pública carga la aplicación correctamente en Chrome, Firefox y Safari. Commit: `ec8b97a`.
