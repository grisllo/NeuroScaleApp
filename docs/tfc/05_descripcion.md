# Descripción del sistema

## Arquitectura general

NeuroScale App está organizada siguiendo dos criterios complementarios que actúan en planos distintos. En el plano del código, el proyecto se estructura por **funcionalidades** (lo que se conoce como *feature-first*): cada feature —autenticación, pacientes, escalas, algoritmos, perfil— vive en su propia carpeta con todo lo que necesita. En el plano interno de cada feature, las responsabilidades se reparten en tres capas siguiendo los principios de Clean Architecture: el dominio, los datos y la presentación.

La elección de organizar por feature y no por capa (es decir, evitar tener un único `data/`, `domain/` y `presentation/` en la raíz del proyecto) responde a un problema práctico. Cuando el código crece hasta tener varias funcionalidades distintas, agrupar por capa obliga a saltar de un lado a otro cada vez que se toca un módulo concreto. Agrupar por feature, en cambio, mantiene cerca todo lo relacionado con un mismo dominio y permite añadirlo, modificarlo o eliminarlo sin afectar al resto.

### Las tres capas

Dentro de cada feature, las tres capas tienen reglas estrictas sobre qué puede depender de qué:

| Capa | Qué vive aquí | Reglas |
|---|---|---|
| **Domain** | Entidades, calculadoras puras, interfaces de repositorio, casos de uso | No conoce Flutter ni Supabase. Solo Dart puro. |
| **Data** | Implementaciones de repositorios, fuentes de datos, modelos ORM y mapeadores | Puede usar Supabase, Drift y todo lo relacionado con persistencia. |
| **Presentation** | Pantallas, widgets, proveedores Riverpod, notifiers | Habla con el dominio. Nunca llama directamente a fuentes de datos. |

El flujo de datos respeta siempre la misma dirección: la interfaz pide algo al proveedor, el proveedor invoca un caso de uso, el caso de uso pasa por el repositorio, y el repositorio decide si la información viene del servidor remoto o de la caché local. En sentido inverso, cuando algo falla, los repositorios devuelven una jerarquía de errores tipados (`Failure`) que la interfaz puede traducir a mensajes localizados sin perder información sobre la causa.

### Estructura de carpetas

```
lib/
├── core/                    infraestructura compartida
│   ├── database/            base de datos local (Drift) y DAOs
│   ├── routing/             configuración de navegación, guardián de auth
│   ├── theme/               paleta clínica, tipografía, animaciones base
│   ├── errors/              jerarquía de errores tipados
│   ├── widgets/             widgets reutilizables
│   └── utils/               detector de PII, extensiones, helpers
│
├── features/
│   ├── auth/                autenticación y gestión de cuenta
│   ├── scales/
│   │   ├── shared/          entidades base comunes a todas las escalas
│   │   ├── gcs/             Glasgow Coma Scale
│   │   ├── nihss/           NIHSS
│   │   ├── rankin/          Modified Rankin Scale
│   │   ├── barthel/         Índice de Barthel
│   │   └── abcd2/           ABCD²
│   ├── evaluations/         persistencia y consulta de evaluaciones
│   ├── patients/            pacientes anonimizados + gráfico de evolución
│   ├── algorithms/          algoritmos clínicos de decisión
│   ├── home/                pantalla de escalas (entrada tras el login)
│   └── profile/             perfil, tema e idioma
│
└── l10n/                    textos en español e inglés (519 entradas)
```

---

## Modelo de dominio

El modelo de dominio es la parte de la aplicación que representa el conocimiento clínico de las escalas y los algoritmos, sin mezclarlo con detalles técnicos de la interfaz ni de la persistencia. Aquí viven las entidades que el resto de la aplicación consume.

### Escalas neurológicas

Todas las escalas comparten un mismo contrato abstracto que reúne los datos comunes: un identificador único, un nombre para mostrar, una versión, la lista de ítems que la componen y la función de cálculo que produce el resultado.

| Campo / método | Tipo | Descripción |
|---|---|---|
| `key` | texto | Identificador único de la escala (`'gcs'`, `'nihss'`…) |
| `displayName` | texto | Nombre legible en la interfaz |
| `version` | entero | Versión del protocolo |
| `items` | lista | Ítems clínicos que componen la escala |
| `calculate(answers)` | función | Devuelve la puntuación y la interpretación |

Cada ítem de escala es una pregunta clínica con sus opciones de respuesta, un rango válido de puntuación y, opcionalmente, un texto de ayuda y un valor especial para casos no valorables (este último solo aplica a la NIHSS):

| Campo | Tipo | Descripción |
|---|---|---|
| `key` | texto | Identificador del ítem |
| `labelKey` | texto | Clave del enunciado para el sistema de traducciones |
| `min` / `max` | enteros | Rango válido de puntuación |
| `options` | lista de pares | Cada opción es un valor numérico y su clave traducible |
| `untestableValue` | entero opcional | Valor reservado para casos no valorables (NIHSS = 9) |
| `helpKey` | texto opcional | Clave del texto del modo tutorial |

El resultado de aplicar una escala se representa como un objeto cerrado que incluye la puntuación, el máximo posible, la severidad clasificada, la interpretación traducible y el desglose por ítem:

| Campo | Tipo | Descripción |
|---|---|---|
| `totalScore` | entero | Puntuación obtenida |
| `maxScore` | entero | Puntuación máxima posible |
| `severity` | enum | Clasificación de gravedad (sin déficit, leve, moderada, grave) |
| `interpretation` | texto | Clave traducible de la interpretación |
| `itemScores` | mapa | Puntuación obtenida en cada ítem |

### Algoritmos clínicos

Los algoritmos clínicos se modelan como árboles de decisión inmutables. El árbol es un conjunto de nodos enlazados, donde solo existen dos tipos: nodos de pregunta y nodos de resultado.

Un **nodo de pregunta** plantea una decisión y ofrece varias opciones; cada opción apunta al nodo siguiente:

| Campo | Tipo | Descripción |
|---|---|---|
| `id` | texto | Identificador del nodo |
| `questionKey` | texto | Clave traducible de la pregunta |
| `hintKey` | texto opcional | Texto de ayuda |
| `options` | lista | Opciones disponibles, cada una con su nodo destino |

Un **nodo de resultado** es una hoja del árbol: no tiene continuación, sino que entrega un resultado clínico con su nivel de urgencia:

| Campo | Tipo | Descripción |
|---|---|---|
| `id` | texto | Identificador del nodo |
| `titleKey` | texto | Clave traducible del título del resultado |
| `urgency` | enum | Nivel de urgencia (informativa, baja, moderada, alta, crítica) |
| `recommendationKeys` | lista | Recomendaciones clínicas asociadas |

Durante el recorrido del árbol, la aplicación mantiene un estado de ejecución que recuerda los nodos visitados y permite avanzar, retroceder o reiniciar:

| Campo / propiedad | Tipo | Descripción |
|---|---|---|
| `definition` | algoritmo | Definición inmutable del algoritmo |
| `path` | lista | Historial de nodos visitados |
| `selectedOptionIds` | lista | Opciones elegidas en cada paso |
| `currentNode` | nodo | Nodo actual (calculado a partir del historial) |
| `isComplete` | booleano | Indica si se ha llegado a un nodo de resultado |
| `canGoBack` | booleano | Indica si hay nodos anteriores en el historial |

### Evaluaciones y pacientes

Una **evaluación** representa una escala completada y guardada: contiene la puntuación, la interpretación, el desglose por ítem, las marcas de tiempo y, opcionalmente, una referencia al paciente al que pertenece.

| Campo | Tipo | Descripción |
|---|---|---|
| `id` | UUID | Identificador único |
| `userId` | UUID | Usuario propietario |
| `scaleType` | texto | Tipo de escala (`gcs`, `nihss`, etc.) |
| `scaleVersion` | entero | Versión del protocolo usado |
| `caseDescription` | texto | Descripción libre anonimizada (validada contra PII) |
| `totalScore` | entero | Puntuación obtenida |
| `interpretation` | texto | Interpretación clínica |
| `detailedScores` | mapa | Desglose por ítem |
| `patientId` | UUID opcional | Paciente al que se asocia |
| `createdAt` / `updatedAt` | fecha y hora | Marcas temporales |

Un **paciente** es una entidad mínima por diseño: solo un alias clínico libre y unas notas, sin nombre real, sin DNI ni ningún otro dato identificativo.

| Campo | Tipo | Descripción |
|---|---|---|
| `id` | UUID | Identificador único |
| `userId` | UUID | Usuario propietario |
| `alias` | texto | Alias clínico (1–255 caracteres) |
| `notes` | texto | Notas clínicas libres, sin PII |
| `createdAt` / `updatedAt` | fecha y hora | Marcas temporales |

### Usuarios

La entidad de dominio de usuario es intencionalmente mínima, porque todo lo relacionado con autenticación lo gestiona Supabase Auth: contraseñas, sesiones, tokens, confirmación por correo, etc. Lo único que la aplicación necesita conocer de un usuario es su identificador y su correo verificado.

| Campo | Tipo | Descripción |
|---|---|---|
| `id` | UUID | Identificador en `auth.users` |
| `email` | texto | Correo electrónico verificado |

---

## Modelo de datos persistido

NeuroScale App guarda los datos en dos sitios al mismo tiempo: en el servidor remoto (Supabase / PostgreSQL) y en una caché local del dispositivo (SQLite gestionado por Drift). Cualquier operación de escritura se replica en los dos almacenes; las lecturas intentan primero el servidor y, si la red falla, recurren a la caché sin que el usuario lo perciba.

### Base de datos remota: Supabase / PostgreSQL

El esquema remoto está formado por dos tablas de aplicación —`evaluations` y `patients`— más las tablas internas de autenticación que Supabase gestiona por su cuenta. Las dos tablas siguen las convenciones habituales de PostgreSQL: identificadores UUID, marcas de tiempo con zona horaria, claves foráneas hacia `auth.users` y restricciones de integridad explícitas.

**Tabla `evaluations`:**

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | `uuid` | PK, generación automática | Identificador único |
| `user_id` | `uuid` | FK → `auth.users(id)`, borrado en cascada | Propietario |
| `scale_type` | enum `scale_type` | No nulo | Una de las cinco escalas |
| `scale_version` | `smallint` | No nulo, valor por defecto 1 | Versión del protocolo |
| `case_description` | `text` | No nulo, máximo 500 caracteres | Descripción anonimizada |
| `total_score` | `integer` | No nulo | Puntuación obtenida |
| `interpretation` | `text` | No nulo | Interpretación clínica |
| `detailed_scores` | `jsonb` | No nulo | Desglose por ítem |
| `patient_id` | `uuid` | FK → `patients(id)`, borrado en cascada, anulable | Paciente asociado |
| `created_at` | `timestamptz` | No nulo, automático | Fecha de creación |
| `updated_at` | `timestamptz` | No nulo, actualizado por trigger | Última modificación |

Sobre esta tabla se mantienen dos índices: uno por usuario y fecha (`user_id`, `created_at`) para consultar el historial de forma rápida, y otro por paciente (`patient_id`) para filtrar las evaluaciones de un caso concreto.

**Tabla `patients`:**

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | `uuid` | PK, generación automática | Identificador único |
| `user_id` | `uuid` | FK → `auth.users(id)`, borrado en cascada | Propietario |
| `alias` | `text` | No nulo, longitud entre 1 y 255 | Alias clínico |
| `notes` | `text` | No nulo, valor por defecto vacío | Notas libres |
| `created_at` | `timestamptz` | No nulo, automático | Fecha de creación |
| `updated_at` | `timestamptz` | No nulo, actualizado por trigger | Última modificación |

### Seguridad: Row Level Security

Ambas tablas tienen activada la seguridad a nivel de fila (RLS), una característica de PostgreSQL que filtra automáticamente las filas que cada usuario puede ver y modificar. Las políticas son simétricas: cada operación (lectura, inserción, actualización, borrado) solo se permite sobre filas donde el `user_id` coincide con el identificador del usuario autenticado. Esta protección actúa a nivel de base de datos, lo que significa que sigue siendo efectiva incluso si la aplicación cliente tuviera errores o si alguien intentase saltarse las comprobaciones del lado cliente.

### Base de datos local: Drift / SQLite

La caché local replica el subconjunto de datos que el usuario consulta con más frecuencia. El esquema lógico es el mismo, adaptado a los tipos disponibles en SQLite: lo que en PostgreSQL es `jsonb` se almacena como cadena de texto serializada, y los campos opcionales se marcan como anulables.

| Tabla local | Equivalente remoto | Diferencias relevantes |
|---|---|---|
| `Evaluations` | `evaluations` | `detailed_scores` se guarda como JSON en texto plano |
| `Patients` | `patients` | `notes` admite valor nulo |

### Edge Functions

La función `delete-account`, escrita en TypeScript sobre Deno, ejecuta el borrado completo de un usuario con privilegios de administrador. Esta operación no se puede hacer desde el cliente porque las políticas RLS lo impedirían (un usuario no puede borrar registros de `auth.users`). La función verifica el token JWT del usuario, comprueba que efectivamente quiere borrarse a sí mismo, y elimina en orden sus evaluaciones, sus pacientes y por último su entrada en `auth.users`.

---

## Flujo de navegación

La navegación se construye con `go_router` sobre la primitiva `StatefulShellRoute`, que tiene una propiedad clave: mantiene el estado interno de cada rama de navegación entre cambios de pestaña, evitando reconstrucciones innecesarias y peticiones de red duplicadas.

### Rutas de autenticación (fuera del shell)

| Ruta | Pantalla | Cuándo se muestra |
|---|---|---|
| `/disclaimer` | Aviso médico-legal | En la primera ejecución de la aplicación |
| `/login` | Inicio de sesión | Sin sesión activa o tras un cierre |
| `/register` | Registro | Acceso desde el enlace de login |
| `/forgot-password` | Solicitud de recuperación | Acceso desde el enlace de login |
| `/reset-password` | Nueva contraseña | Cuando el usuario pulsa el enlace recibido por correo |

### Shell principal (cuatro ramas con estado independiente)

| Rama | Raíz | Subrutas | Propósito |
|---|---|---|---|
| 0 | `/` | `/scales/gcs`, `/scales/nihss`, `/scales/rankin`, `/scales/barthel`, `/scales/abcd2`, `/result` | Aplicación de escalas |
| 1 | `/patients` | `/patients/:id` | Pacientes y detalle individual |
| 2 | `/algorithms` | `/algorithms/:id` | Algoritmos clínicos |
| 3 | `/profile` | — | Cuenta, tema e idioma |

El guardián de autenticación vigila en todo momento si la sesión está activa. Cuando deja de estarlo —por cierre voluntario o por borrado de cuenta— redirige al usuario al login. Hay una excepción que tiene prioridad sobre este comportamiento: si el flujo en curso es una recuperación de contraseña, el guardián redirige a `/reset-password` en lugar de al login, porque en ese caso el usuario sí tiene un token válido aunque limitado.

Las transiciones entre pantallas combinan un fundido suave con un desplazamiento ligero hacia arriba, lo justo para que el cambio se note pero no distraiga.

---

## Casos de uso

Los casos de uso describen los flujos principales del sistema desde la perspectiva del usuario. Las precondiciones y postcondiciones se refieren al estado observable de la aplicación, no a su estado interno. La estructura es la habitual para una memoria académica: actor, precondiciones, postcondiciones, flujo principal y flujos alternativos.

### CU-01 — Registrar nueva cuenta

| Campo | Descripción |
|---|---|
| **Actores** | Usuario no autenticado |
| **Precondiciones** | La aplicación muestra el login o la pantalla de registro |
| **Postcondiciones** | La cuenta queda creada y el usuario recibe un correo de confirmación |

**Flujo principal:**
1. El usuario navega a la pantalla de registro.
2. Introduce correo y contraseña (mínimo de seis caracteres).
3. La aplicación valida el formato en el cliente antes de enviar nada al servidor.
4. El servicio de autenticación procesa el alta y envía un correo con un enlace de confirmación.
5. La aplicación muestra un mensaje informando de que la verificación está pendiente.

**Flujos alternativos:**
- Si el formato del correo no es válido, se muestra un error en el cliente sin contactar con el servidor.
- Si el correo ya está registrado, el servicio devuelve un error específico y se traduce a un mensaje legible.

### CU-02 — Iniciar sesión

| Campo | Descripción |
|---|---|
| **Actores** | Usuario registrado con cuenta confirmada |
| **Precondiciones** | La aplicación muestra el login |
| **Postcondiciones** | Sesión activa, usuario redirigido a la pantalla principal |

**Flujo principal:**
1. El usuario introduce sus credenciales.
2. El servicio de autenticación las valida y devuelve una sesión.
3. El proveedor de estado detecta la sesión y el guardián de navegación redirige a la pantalla de escalas.

**Flujos alternativos:**
- Una contraseña incorrecta produce un mensaje de error traducible.
- La pérdida de conexión muestra el aviso de modo offline y bloquea el intento hasta que se restablezca la red.

### CU-03 — Aplicar una escala neurológica

| Campo | Descripción |
|---|---|
| **Actores** | Usuario autenticado |
| **Precondiciones** | El usuario se encuentra en la pestaña de escalas |
| **Postcondiciones** | Se muestra la pantalla de resultado con la puntuación y la interpretación clínica |

**Flujo principal:**
1. El usuario selecciona una escala de la lista.
2. La aplicación presenta los ítems uno a uno con su barra de progreso.
3. El usuario marca una opción por ítem.
4. La calculadora del dominio devuelve la puntuación y la interpretación al momento.
5. Al completar todos los ítems, el botón principal lleva a la pantalla de resultado, que muestra la puntuación en un círculo con el color de severidad, el desglose por ítem y un aviso clínico explícito.

**Flujos alternativos:**
- El usuario puede pulsar el botón de ayuda de cualquier ítem para abrir la ficha del modo tutorial.
- Si vuelve atrás, el estado del formulario se conserva.

### CU-04 — Guardar evaluación

| Campo | Descripción |
|---|---|
| **Actores** | Usuario autenticado |
| **Precondiciones** | El usuario está en la pantalla de resultado de una escala |
| **Postcondiciones** | La evaluación queda persistida en el servidor y en la caché local |

**Flujo principal:**
1. El usuario pulsa «Guardar» en la pantalla de resultado.
2. Aparece un formulario para seleccionar paciente y añadir una descripción libre.
3. El detector de PII valida la descripción en tiempo real; si encuentra algún patrón sensible, deshabilita el botón hasta que el texto se corrija.
4. La aplicación guarda la evaluación simultáneamente en el servidor y en la caché local.
5. Una animación de check confirma que la operación ha terminado.

**Flujos alternativos:**
- Si la descripción contiene un DNI o similar, se muestra el aviso correspondiente.
- Si falla la red, la evaluación se guarda solo en local y se sincronizará al reconectar.

### CU-05 — Consultar historial

| Campo | Descripción |
|---|---|
| **Actores** | Usuario autenticado |
| **Precondiciones** | El usuario tiene al menos una evaluación guardada |
| **Postcondiciones** | La lista de evaluaciones se muestra con el orden elegido |

**Flujo principal:**
1. El usuario accede a la lista de evaluaciones.
2. La aplicación recupera el historial desde el servidor.
3. La lista aparece ordenada por fecha descendente; el usuario puede cambiar el orden por más antigua o por escala.

**Flujos alternativos:**
- Sin conexión, la lista se sirve desde la caché con el aviso de modo offline visible.
- El usuario puede deslizar una evaluación para eliminarla con confirmación previa.

### CU-06 — Ver evolución temporal de un paciente

| Campo | Descripción |
|---|---|
| **Actores** | Usuario autenticado |
| **Precondiciones** | El paciente tiene al menos dos evaluaciones de la misma escala en fechas distintas |
| **Postcondiciones** | El gráfico muestra la evolución temporal de la escala seleccionada |

**Flujo principal:**
1. El usuario abre el detalle del paciente.
2. La aplicación carga las evaluaciones asociadas.
3. El usuario elige qué escala visualizar.
4. El gráfico dibuja los puntos de puntuación con el eje horizontal proporcional al tiempo real entre evaluaciones.
5. Al pulsar un punto, se muestra una etiqueta emergente con puntuación, fecha y hora exactas.

**Flujos alternativos:**
- Si solo hay evaluaciones de una escala, el selector aparece preseleccionado.
- Sin evaluaciones, se muestra un estado vacío con la acción de crear la primera.

### CU-07 — Ejecutar un algoritmo clínico

| Campo | Descripción |
|---|---|
| **Actores** | Usuario autenticado |
| **Precondiciones** | El usuario se encuentra en la pestaña de algoritmos |
| **Postcondiciones** | La pantalla muestra el resultado clínico con su nivel de urgencia |

**Flujo principal:**
1. El usuario selecciona un algoritmo.
2. La aplicación presenta la primera pregunta con sus opciones.
3. A cada respuesta, el árbol avanza al siguiente nodo con una animación lateral.
4. Al llegar a un nodo final, se muestra el título del resultado, las recomendaciones y el nivel de urgencia con su color asociado.

**Flujos alternativos:**
- El usuario puede volver al paso anterior o reiniciar el algoritmo en cualquier momento.

### CU-08 — Gestionar un paciente

| Campo | Descripción |
|---|---|
| **Actores** | Usuario autenticado |
| **Precondiciones** | El usuario se encuentra en la pestaña de pacientes |
| **Postcondiciones** | La lista de pacientes refleja la operación realizada |

**Flujo principal de creación:**
1. El usuario pulsa el botón de nuevo paciente.
2. Introduce un alias clínico libre.
3. La aplicación lo persiste en remoto y en local.
4. El nuevo paciente aparece en lo alto de la lista.

**Flujo alternativo de borrado:**
- El usuario desliza un paciente o accede al detalle y pulsa eliminar; la aplicación pide confirmación y, al aceptar, borra el paciente. La restricción de cascada en la base de datos elimina automáticamente sus evaluaciones asociadas.

### CU-09 — Configurar preferencias

| Campo | Descripción |
|---|---|
| **Actores** | Usuario autenticado |
| **Precondiciones** | El usuario se encuentra en la pantalla de perfil |
| **Postcondiciones** | El tema o el idioma cambian al instante y persisten entre sesiones |

**Flujo principal:**
1. El usuario abre el perfil.
2. Selecciona el tema (claro, oscuro o automático).
3. La aplicación reconstruye la interfaz con el nuevo tema y guarda la preferencia.
4. El usuario selecciona el idioma (español o inglés) y la aplicación lo aplica al instante.

### CU-10 — Recuperar acceso con contraseña olvidada

| Campo | Descripción |
|---|---|
| **Actores** | Usuario registrado sin sesión |
| **Precondiciones** | La aplicación muestra el login |
| **Postcondiciones** | La contraseña queda cambiada y el usuario tiene sesión activa |

**Flujo principal:**
1. El usuario pulsa el enlace de contraseña olvidada y navega a la pantalla correspondiente.
2. Introduce su correo y solicita el enlace de recuperación.
3. Abre el enlace en el mismo dispositivo donde tiene la aplicación instalada.
4. La aplicación detecta el evento de recuperación y redirige a la pantalla de nueva contraseña.
5. El usuario introduce y confirma la nueva contraseña.
6. La aplicación la guarda y muestra la animación de confirmación.
7. El guardián de navegación redirige a la pantalla principal.

### CU-11 — Eliminar cuenta y datos

| Campo | Descripción |
|---|---|
| **Actores** | Usuario autenticado |
| **Precondiciones** | El usuario está en la pantalla de perfil |
| **Postcondiciones** | La cuenta y todos los datos asociados han sido borrados de forma irreversible |

**Flujo principal:**
1. El usuario pulsa la opción de eliminar cuenta.
2. Aparece un diálogo de advertencia sobre la irreversibilidad de la operación.
3. Al confirmar, la aplicación invoca la función de servidor que borra al usuario.
4. La función elimina en orden las evaluaciones, los pacientes y el propio usuario.
5. El proveedor de estado detecta el cierre de sesión y el guardián redirige al login.

**Flujos alternativos:**
- Si el token ha expirado, la aplicación pide al usuario que vuelva a autenticarse antes de reintentar la operación.
