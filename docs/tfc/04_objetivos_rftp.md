# Objetivos y Requisitos Funcionales, Técnicos y de Prueba (RFTP)

## Objetivos del proyecto

El objetivo principal de NeuroScale App es ofrecer a profesionales de la salud y a estudiantes de medicina una herramienta multiplataforma que reúna las escalas neurológicas más usadas en la práctica clínica española, permita registrar evaluaciones de forma anonimizada y aporte algoritmos clínicos de apoyo a la decisión.

Los objetivos específicos son:

1. Implementar las cinco escalas neurológicas más frecuentes en neurología de urgencias (GCS, NIHSS, mRS, Barthel y ABCD²) con cálculo correcto, interpretación de gravedad y modo tutorial ítem a ítem.
2. Desarrollar tres algoritmos clínicos guiados (Código Ictus, HTA en ictus agudo y HSA Hunt-Hess/Fisher) que orienten al profesional en situaciones de alta urgencia.
3. Guardar las evaluaciones de forma anonimizada, vinculadas a un paciente identificado por un alias libre, con un gráfico de evolución en el tiempo.
4. Mantener la aplicación operativa sin conexión a Internet mediante una caché local, con sincronización automática al volver la red.
5. Publicar la aplicación en web (GitHub Pages) y distribuirla en Android (APK firmado), con soporte completo de idiomas español e inglés.
6. Garantizar la corrección clínica mediante un conjunto de pruebas que cubra los umbrales diagnósticos de cada escala y cada algoritmo.

---

## Cómo leer este apartado

Cada requisito se describe en cuatro niveles. **R** plantea la necesidad en lenguaje natural, **F** describe qué hace la aplicación para cubrirla, **T** explica qué se construye y **P** indica qué se comprueba para verificar que funciona.

Las cinco escalas neurológicas funcionan internamente del mismo modo, igual que los tres algoritmos clínicos, así que se describen una sola vez como caso representativo y se enumeran en sus tablas correspondientes.

---

## R01 — Autenticación y gestión de cuenta

Cualquier usuario debe identificarse antes de usar la aplicación. Sin sesión activa, no se puede acceder a evaluaciones ni a pacientes. Este requisito agrupa registro, login, recuperación, cambio de contraseña y borrado definitivo de la cuenta.

### R01F01 — Registro de nueva cuenta

El usuario nuevo introduce su correo y una contraseña, y recibe un enlace de confirmación. La cuenta queda inactiva hasta que lo pulsa, lo que evita registros con correos ajenos.

**R01F01T01** — Construir el flujo de registro que valida el correo, lo envía al servicio de autenticación y devuelve un usuario verificado o un error explicativo si la información no es válida.

> **R01F01T01P01** — Se comprueba que un correo válido con una contraseña suficiente registra al usuario correctamente y que un correo vacío genera el error esperado.

### R01F02 — Inicio de sesión

El usuario introduce correo y contraseña y, si son correctos, accede a la aplicación. Un mecanismo de protección redirige siempre al login cuando no hay sesión activa.

**R01F02T01** — Implementar el inicio de sesión contra el servicio de autenticación con mensajes de error traducibles, y un guardián de navegación que vigile en todo momento si la sesión sigue abierta.

> **R01F02T01P01** — Se verifica que unas credenciales correctas abren la sesión y que una contraseña incorrecta produce un mensaje de error claro.

### R01F03 — Recuperación de contraseña

Si el usuario olvida la contraseña, solicita un enlace de recuperación, lo abre desde su correo y define una contraseña nueva. La aplicación detecta el flujo automáticamente.

**R01F03T01** — Detectar el evento de recuperación que envía el servicio de autenticación y dirigir al usuario a la pantalla de nueva contraseña con confirmación visual al terminar.

> **R01F03T01P01** — Se comprueba el ciclo completo: solicitar el enlace, recibirlo por correo, pulsarlo, introducir la nueva contraseña y confirmar el acceso.

### R01F04 — Cambio de contraseña autenticado

Desde el perfil, el usuario puede cambiar su contraseña, pero la aplicación le pide primero la contraseña actual. Así, si alguien obtiene acceso físico al dispositivo con la sesión abierta, no puede apropiarse de la cuenta.

**R01F04T01** — Pedir la contraseña actual y verificarla antes de aceptar la nueva, devolviendo un error si la verificación falla.

> **R01F04T01P01** — Se verifica que una contraseña actual incorrecta bloquea el cambio y que la contraseña correcta lo permite.

### R01F05 — Borrado de cuenta y datos

El RGPD reconoce el derecho del usuario a eliminar sus datos. La aplicación borra en cascada evaluaciones, pacientes y la propia cuenta, previa confirmación explícita.

**R01F05T01** — Crear una función en servidor con privilegios elevados que elimine al usuario y todos sus datos asociados, y un diálogo de confirmación previo en la aplicación para evitar borrados accidentales.

> **R01F05T01P01** — Se prueba el ciclo completo: crear una cuenta de prueba, guardar una evaluación, borrar la cuenta y verificar que no queda rastro ni del usuario, ni de los pacientes, ni de las evaluaciones.

---

## R02 — Aplicación de escalas neurológicas

Las escalas son el corazón funcional de la aplicación. El usuario elige una escala, responde a sus ítems, obtiene una puntuación con interpretación de gravedad y, opcionalmente, guarda el resultado. NeuroScale App implementa cinco escalas que comparten el mismo flujo interno:

| Escala | Rango | Para qué se usa |
|---|---|---|
| **GCS** | 3–15 | Nivel de consciencia en traumatismos craneoencefálicos. |
| **NIHSS** | 0–42 | Gravedad de un ictus isquémico agudo. |
| **mRS** | 0–6 | Discapacidad tras un ictus (6 = fallecido). |
| **Barthel** | 0–100 | Independencia para actividades de la vida diaria. |
| **ABCD²** | 0–7 | Riesgo de ictus tras un episodio isquémico transitorio. |

Como las cinco escalas siguen el mismo patrón funcional, se describen mediante un único caso representativo y un caso adicional para el modo tutorial.

### R02F01 — Aplicación de una escala (caso común a las cinco)

El usuario selecciona una escala y responde a sus ítems uno a uno. La aplicación calcula la puntuación al instante, la clasifica en un tramo de gravedad con su color clínico y muestra el resultado con la interpretación y el desglose por ítem.

**R02F01T01** — Implementar para cada escala una función de cálculo aislada del resto de la aplicación, fácil de testear, que devuelva la puntuación y la interpretación a partir de los ítems respondidos. Los pesos y umbrales siguen las fuentes médicas verificadas en la bibliografía: Teasdale para GCS, Brott y Lyden para NIHSS, Van Swieten para mRS, Baztán para Barthel (versión española) y Johnston para ABCD². Acompañar el cálculo con una pantalla que muestre el progreso y resalte la opción seleccionada en cada ítem.

> **R02F01T01P01** — Para cada escala se comprueba que la puntuación mínima y la máxima producen el resultado correcto, que cada cambio de tramo de gravedad ocurre exactamente en el valor esperado y que las combinaciones extrañas (ítems vacíos, fuera de rango o, en NIHSS, marcados como no valorables) se gestionan sin errores.

### R02F02 — Modo tutorial por ítem

Junto a cada ítem aparece un pequeño botón con un signo de interrogación. Al pulsarlo, una ficha emergente muestra la descripción clínica del ítem y la referencia bibliográfica de la fuente original.

**R02F02T01** — Añadir un botón de ayuda a cada ítem que abra una ficha emergente con el texto clínico correspondiente, traducido a español e inglés, y la cita de la fuente original.

> **R02F02T01P01** — Se comprueba en cada una de las cuatro escalas con tutorial que el botón de ayuda abre la ficha clínica correcta para cada ítem, con el texto adecuado en el idioma activo.

---

## R03 — Algoritmos clínicos de decisión

Los algoritmos no calculan una puntuación: guían al profesional por un árbol de preguntas para llegar a una decisión clínica. El resultado final combina una recomendación con un nivel de urgencia (informativa, baja, moderada, alta o crítica).

| Algoritmo | Decisión clínica que orienta |
|---|---|
| **Código Ictus** | Si el paciente cumple criterios para fibrinólisis con tPA en la ventana de 3–4,5 h. |
| **HTA en ictus agudo** | Cómo manejar la presión arterial según el tipo de ictus. |
| **HSA Hunt-Hess / Fisher** | Clasificación clínica y radiológica de una hemorragia subaracnoidea. |

Como los tres siguen el mismo flujo, se describen como un único caso representativo.

### R03F01 — Recorrido de un algoritmo (caso común a los tres)

El usuario selecciona un algoritmo y la aplicación le presenta la primera pregunta con sus opciones. A cada respuesta el árbol avanza al siguiente nodo, y al llegar al final muestra el resultado clínico, las recomendaciones y el nivel de urgencia. El usuario puede volver atrás o reiniciar en cualquier momento.

**R03F01T01** — Modelar cada algoritmo como un árbol de decisiones inmutable formado por nodos de pregunta y nodos de resultado. Implementar un motor común que avance, retroceda y reinicie el recorrido sin alterar el estado, y una pantalla que muestre cada paso con una animación de transición. Los criterios clínicos provienen de fuentes verificadas (NINDS, Hacke, Berge para Código Ictus; Powers, Hemphill, Steiner para HTA; Hunt-Hess y Frontera para HSA).

> **R03F01T01P01** — Para cada algoritmo se recorren todos los caminos posibles del árbol y se verifica que cada final produce el nivel de urgencia y la recomendación correctos. Además se comprueba que avanzar, retroceder y reiniciar funcionan en cualquier estado intermedio.

---

## R04 — Gestión de pacientes anonimizados

NeuroScale App permite agrupar evaluaciones por paciente para poder hacer seguimiento longitudinal. Para cumplir el RGPD, los pacientes se identifican mediante un alias libre (`P-001`, `Box-3-Lunes`, `Demo-TCE-01`) que nunca contiene datos identificativos reales.

### R04F01 — Crear paciente con alias

El usuario introduce un alias libre y la aplicación lo guarda en remoto y en local. La única validación es que no esté vacío y no supere la longitud máxima.

**R04F01T01** — Crear el formulario de alta con validación de campo obligatorio y persistir el paciente tanto en el servidor como en la caché local del dispositivo.

> **R04F01T01P01** — Se prueba que un alias válido crea correctamente un paciente con su identificador único, y que un alias vacío produce un error de validación.

### R04F02 — Listar y consultar pacientes

La pestaña de pacientes muestra una lista con avatar de iniciales y color único derivado del alias. Al seleccionar uno, se accede a su detalle con historial y gráfico de evolución. Funciona también sin conexión.

**R04F02T01** — Cargar la lista de pacientes pidiendo primero al servidor y, si la conexión falla, devolverla desde la caché local. Generar un avatar con iniciales y un color determinista a partir del alias.

> **R04F02T01P01** — Se comprueba que la lista se carga ordenada desde el servidor, que se sirve correctamente desde la caché local cuando no hay red, y que el avatar produce siempre el mismo color para el mismo alias.

### R04F03 — Borrar paciente con cascada

Al eliminar un paciente se borran también sus evaluaciones automáticamente. La cascada se aplica en la base de datos, lo que garantiza que no quedan registros huérfanos. La operación pide confirmación previa por ser irreversible.

**R04F03T01** — Configurar la restricción de borrado en cascada en la base de datos y añadir un diálogo de confirmación en la aplicación antes de invocar la operación.

> **R04F03T01P01** — Se verifica que borrar un paciente existente no produce error y que intentar borrar uno que no existe genera el error esperado.

### R04F04 — Detector de PII en descripciones libres

El campo libre de descripción del caso podría usarse por descuido para introducir datos identificativos. La aplicación detecta DNI, NIE, correo, teléfono y fechas de nacimiento y bloquea el guardado si encuentra alguno.

**R04F04T01** — Construir un detector que examine el texto contra los patrones de datos personales más habituales en España y bloquee el guardado cuando detecte alguno, mostrando un mensaje de error claro.

> **R04F04T01P01** — Para cada tipo de dato sensible se prueba tanto un caso positivo (texto que sí contiene el patrón y debe ser detectado) como uno negativo (texto similar pero sin el patrón). Se cubren DNI, NIE, correo, teléfono con y sin prefijo internacional, y fecha de nacimiento en formatos `DD/MM/YYYY` y `DD-MM-YYYY`.

---

## R05 — Historial y evolución temporal

Aplicar una escala y obtener un resultado es solo la mitad del valor. La otra mitad es poder consultar después lo que se aplicó y ver cómo evoluciona un paciente en el tiempo.

### R05F01 — Guardar evaluación

Al terminar una escala, el usuario puede guardar el resultado asociándolo a un paciente y añadiendo una descripción opcional. Una animación confirma que se guardó correctamente.

**R05F01T01** — Persistir la evaluación en remoto y en la caché local de forma simultánea, previa validación de PII en la descripción, y mostrar una animación de confirmación al usuario.

> **R05F01T01P01** — Se comprueba que una evaluación válida se guarda y devuelve un identificador, y que una evaluación cuya descripción contiene un DNI queda bloqueada con el error correspondiente.

### R05F02 — Listar evaluaciones con orden y filtros

El historial muestra las evaluaciones ordenadas por fecha. Cada tarjeta lleva una franja de color que identifica la escala y un *chip* de puntuación con el color de severidad.

**R05F02T01** — Cargar la lista de evaluaciones del usuario con orden configurable (por defecto la más reciente arriba) y representar cada una en una tarjeta con la franja de color de su escala y el chip de severidad.

> **R05F02T01P01** — Se verifica que la lista llega ordenada por fecha descendente por defecto, y que cuando el servidor falla se devuelve correctamente la versión local sin perder el orden.

### R05F03 — Gráfico de evolución temporal

En el detalle del paciente, el usuario elige una escala y la aplicación dibuja una línea con la puntuación en el tiempo. Al pulsar un punto, una etiqueta emergente muestra la puntuación, la fecha y la hora exactas.

**R05F03T01** — Dibujar una gráfica de líneas con el eje horizontal proporcional al tiempo real entre evaluaciones y el vertical normalizado a la escala seleccionada, con etiquetas emergentes al pulsar cada punto.

> **R05F03T01P01** — Se comprueba con el paciente de demostración `Demo-TCE-01`, que tiene seis evaluaciones GCS (de 8 a 15) y tres Barthel (de 35 a 95), que la curva refleja la progresión clínica esperada y que las etiquetas muestran los valores correctos.

### R05F04 — Borrar evaluación individual

Desde el historial, el usuario desliza una evaluación para borrarla. La aplicación pide confirmación y propaga el borrado a remoto y a caché local.

**R05F04T01** — Permitir el borrado por gesto deslizante con diálogo de confirmación previo, y propagar la operación tanto al servidor como a la caché local.

> **R05F04T01P01** — Se prueba que borrar una evaluación existente completa la operación sin error y que un identificador inexistente produce el error esperado.

---

## R06 — Persistencia local y modo offline

En un hospital o una zona rural no siempre hay conexión. La aplicación guarda una copia local de los datos para seguir funcionando sin red y sincroniza al recuperar la conexión.

### R06F01 — Caché local

Cada operación de escritura se guarda en remoto y en local de forma simultánea. Las lecturas intentan primero remoto y caen a local si falla la conexión.

**R06F01T01** — Crear una base de datos local con las mismas tablas que la remota e integrarla en los repositorios siguiendo una estrategia de caché paralela: lectura remota con respaldo local, escritura siempre en ambos sitios.

> **R06F01T01P01** — Se comprueba que, al activar el modo avión y abrir la aplicación, los pacientes y evaluaciones cacheados anteriormente siguen apareciendo correctamente, y que al recuperar la conexión las nuevas operaciones se sincronizan con el servidor.

### R06F02 — Banner de conexión

Si se pierde la red, aparece una franja informativa en la parte superior. Desaparece sola al recuperarla.

**R06F02T01** — Vigilar el estado de la conexión de red y mostrar una franja informativa en la cabecera de la aplicación cuando se pierda, retirándola automáticamente al recuperarla.

> **R06F02T01P01** — En un dispositivo Android se comprueba que al activar el modo avión el aviso aparece en menos de dos segundos, y que al desactivarlo desaparece sin intervención del usuario.

---

## R07 — Internacionalización español/inglés

Toda la interfaz —incluidos los textos clínicos del modo tutorial— está traducida a español e inglés desde la primera versión.

### R07F01 — Catálogo de textos

Los textos viven en dos ficheros centralizados (uno por idioma) con 519 entradas cada uno, que el sistema oficial de internacionalización de Flutter convierte en clases tipadas en compilación.

**R07F01T01** — Mantener los dos ficheros de traducciones sincronizados entrada por entrada y configurar el generador de localizaciones como paso obligatorio antes del análisis estático.

> **R07F01T01P01** — En cada compilación se verifica automáticamente que el generador de localizaciones se ejecuta sin errores ni claves faltantes y que el análisis estático queda en cero avisos.

### R07F02 — Selector de idioma persistente

Desde el perfil, el usuario cambia el idioma al instante. La preferencia se recuerda entre sesiones.

**R07F02T01** — Guardar el idioma elegido en las preferencias del dispositivo y recuperarlo al iniciar la aplicación, antes de construir las pantallas.

> **R07F02T01P01** — Se prueba que tras seleccionar inglés y cerrar y volver a abrir la aplicación, el idioma elegido se mantiene sin que el usuario tenga que volver a configurarlo.

---

## R08 — Diseño responsive multiplataforma

La aplicación se adapta a móvil, tablet, escritorio y web sin cambiar de código.

### R08F01 — Navegación adaptativa

En móvil, las cuatro secciones aparecen como barra inferior; en tablet y escritorio, como panel lateral. El cambio se produce al superar 600 píxeles de ancho.

**R08F01T01** — Detectar el ancho de pantalla disponible y elegir entre barra inferior o panel lateral en consecuencia, conservando el estado de cada sección entre cambios de tamaño.

> **R08F01T01P01** — En navegador se comprueba que reducir la ventana por debajo de 600 píxeles sustituye el panel lateral por la barra inferior, y que ampliarla por encima vuelve a poner el panel lateral.

### R08F02 — Layouts en dos columnas en tablet

En pantallas grandes, el contenido se distribuye en dos columnas donde tiene sentido. El caso más visible es el detalle del paciente, con lista de evaluaciones y gráfico en paralelo.

**R08F02T01** — Aplicar un ancho máximo de 800 píxeles al contenido principal y, en las pantallas que lo permitan, distribuir lista y detalle en columnas paralelas cuando haya espacio suficiente.

> **R08F02T01P01** — En un simulador de tablet se verifica que la cuadrícula de escalas aparece en dos columnas y que la pantalla de detalle de paciente muestra la lista y el gráfico de evolución en paralelo.

### R08F03 — Despliegue web continuo

Cada cambio en la rama principal compila la versión web y la publica en GitHub Pages sin intervención manual.

**R08F03T01** — Configurar un pipeline que compile la versión web tras cada cambio aprobado y la publique automáticamente en el hosting estático.

> **R08F03T01P01** — Tras cada subida se verifica que el pipeline se completa en verde y que la URL pública del proyecto carga correctamente en los principales navegadores.
