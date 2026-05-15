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

El diagrama de casos de uso se encuentra en el apartado de Diseños. Las tablas siguientes describen cada caso de uso con sus datos de entrada y salida, las tablas de base de datos implicadas, las clases del dominio involucradas y las interfaces de usuario correspondientes.

---

### CU-01 — Registrar nueva cuenta

**Descripción:** El usuario crea una nueva cuenta en la aplicación introduciendo su correo electrónico y una contraseña.

| PRECONDICIONES | POSTCONDICIONES |
|---|---|
| La aplicación muestra la pantalla de registro | La cuenta queda creada en Supabase Auth |
| El correo no está registrado previamente | El usuario recibe un correo de confirmación |

| DATOS DE ENTRADA | DATOS DE SALIDA |
|---|---|
| Correo electrónico | Mensaje de verificación pendiente |
| Contraseña | |

| TABLAS | CLASES |
|---|---|
| auth.users | AppUser |
| | SignUpUseCase |
| | AuthRepository |

| INTERFACES |
|---|
| RegisterScreen |

---

### CU-02 — Iniciar sesión

**Descripción:** El usuario accede a la aplicación con su correo electrónico y contraseña registrados.

| PRECONDICIONES | POSTCONDICIONES |
|---|---|
| El usuario tiene cuenta confirmada | Sesión activa con token JWT |
| La aplicación muestra la pantalla de login | El usuario es redirigido a la pantalla de escalas |

| DATOS DE ENTRADA | DATOS DE SALIDA |
|---|---|
| Correo electrónico | Token de sesión JWT |
| Contraseña | AppUser (id, email) |

| TABLAS | CLASES |
|---|---|
| auth.users | AppUser |
| | SignInUseCase |
| | AuthRepository |

| INTERFACES |
|---|
| LoginScreen · ScalesTabScreen |

---

### CU-03 — Aplicar una escala neurológica

**Descripción:** El usuario aplica una de las cinco escalas neurológicas (GCS, NIHSS, mRS, Barthel o ABCD²) y obtiene la puntuación con su interpretación clínica.

| PRECONDICIONES | POSTCONDICIONES |
|---|---|
| El usuario está autenticado | La pantalla de resultado muestra la puntuación |
| La aplicación muestra la pestaña de escalas | La gravedad queda clasificada por tramos y color |

| DATOS DE ENTRADA | DATOS DE SALIDA |
|---|---|
| Respuestas a los ítems de la escala | Puntuación total |
| Escala seleccionada | Clasificación de gravedad |
| | Desglose de puntuación por ítem |

| TABLAS | CLASES |
|---|---|
| — (sin persistencia en este paso) | ScaleDefinition |
| | ScaleItem |
| | ScaleResult |
| | Severity |

| INTERFACES |
|---|
| ScalesTabScreen · ScaleFormScreen · ResultScreen |

---

### CU-04 — Guardar evaluación

**Descripción:** El usuario guarda el resultado de una escala asociándolo a un paciente y una descripción libre del caso.

| PRECONDICIONES | POSTCONDICIONES |
|---|---|
| La pantalla de resultado está activa | La evaluación queda guardada en el servidor |
| | La evaluación queda guardada en la caché local |

| DATOS DE ENTRADA | DATOS DE SALIDA |
|---|---|
| Resultado de la escala | Evaluación persistida con identificador único |
| Paciente asociado (opcional) | Animación de confirmación |
| Descripción libre del caso | |

| TABLAS | CLASES |
|---|---|
| evaluations | Evaluation |
| patients | SaveEvaluationUseCase |
| | EvaluationRepository |
| | PiiDetector |

| INTERFACES |
|---|
| ResultScreen |

---

### CU-05 — Consultar historial

**Descripción:** El usuario consulta la lista de evaluaciones guardadas con opciones de ordenación.

| PRECONDICIONES | POSTCONDICIONES |
|---|---|
| El usuario tiene al menos una evaluación guardada | La lista de evaluaciones se muestra ordenada |

| DATOS DE ENTRADA | DATOS DE SALIDA |
|---|---|
| Criterio de ordenación (reciente / antigua / escala) | Lista de evaluaciones ordenada |
| | Escala, puntuación, severidad y fecha de cada evaluación |

| TABLAS | CLASES |
|---|---|
| evaluations | Evaluation |
| | FetchEvaluationsUseCase |
| | EvaluationRepository |

| INTERFACES |
|---|
| EvaluationsHistoryScreen · EvaluationTile |

---

### CU-06 — Ver evolución temporal de un paciente

**Descripción:** El usuario visualiza la evolución de las puntuaciones de un paciente a lo largo del tiempo mediante un gráfico de líneas.

| PRECONDICIONES | POSTCONDICIONES |
|---|---|
| El paciente tiene al menos dos evaluaciones | El gráfico muestra la evolución temporal |
| Las evaluaciones son de la misma escala | Los tooltips muestran puntuación y fecha por punto |

| DATOS DE ENTRADA | DATOS DE SALIDA |
|---|---|
| Paciente seleccionado | Gráfico de evolución temporal |
| Escala a visualizar | Puntuación, fecha y hora de cada punto |

| TABLAS | CLASES |
|---|---|
| evaluations | Patient |
| patients | Evaluation |
| | FetchEvaluationsUseCase |

| INTERFACES |
|---|
| PatientDetailScreen |

---

### CU-07 — Ejecutar un algoritmo clínico

**Descripción:** El usuario recorre un árbol de decisión clínica guiado (Código Ictus, HTA o HSA) y obtiene una recomendación con nivel de urgencia.

| PRECONDICIONES | POSTCONDICIONES |
|---|---|
| El usuario está autenticado | La pantalla muestra el resultado clínico |
| La aplicación muestra la pestaña de algoritmos | Se indica el nivel de urgencia y las recomendaciones |

| DATOS DE ENTRADA | DATOS DE SALIDA |
|---|---|
| Respuestas a las preguntas de cada nodo | Resultado clínico |
| | Nivel de urgencia (info / baja / moderada / alta / crítica) |
| | Lista de recomendaciones |

| TABLAS | CLASES |
|---|---|
| — (sin persistencia) | AlgorithmDefinition |
| | AlgorithmNode |
| | AlgorithmState |
| | AlgorithmUrgency |

| INTERFACES |
|---|
| AlgorithmsTabScreen · AlgorithmScreen |

---

### CU-08 — Gestionar un paciente

**Descripción:** El usuario crea, consulta o elimina un paciente identificado únicamente por un alias clínico anonimizado.

| PRECONDICIONES | POSTCONDICIONES |
|---|---|
| El usuario está autenticado | La lista de pacientes refleja la operación |
| La aplicación muestra la pestaña de pacientes | En borrado: las evaluaciones del paciente se eliminan en cascada |

| DATOS DE ENTRADA | DATOS DE SALIDA |
|---|---|
| Alias clínico (en creación) | Paciente creado o eliminado |
| Paciente seleccionado (en consulta o borrado) | Lista de pacientes actualizada |

| TABLAS | CLASES |
|---|---|
| patients | Patient |
| evaluations (CASCADE en borrado) | CreatePatientUseCase |
| | DeletePatientUseCase |
| | PatientRepository |

| INTERFACES |
|---|
| PatientsTabScreen · PatientDetailScreen |

---

### CU-09 — Configurar preferencias

**Descripción:** El usuario cambia el tema visual de la aplicación o el idioma de la interfaz.

| PRECONDICIONES | POSTCONDICIONES |
|---|---|
| El usuario está autenticado | El tema o el idioma cambian al instante |
| La aplicación muestra la pantalla de perfil | Las preferencias quedan guardadas entre sesiones |

| DATOS DE ENTRADA | DATOS DE SALIDA |
|---|---|
| Tema seleccionado (claro / oscuro / automático) | Interfaz actualizada |
| Idioma seleccionado (español / inglés) | Preferencia persistida en el dispositivo |

| TABLAS | CLASES |
|---|---|
| — (SharedPreferences local) | ThemeNotifier |
| | LocaleProvider |

| INTERFACES |
|---|
| ProfileScreen |

---

### CU-10 — Recuperar acceso con contraseña olvidada

**Descripción:** El usuario restablece su contraseña mediante un enlace enviado a su correo electrónico.

| PRECONDICIONES | POSTCONDICIONES |
|---|---|
| El usuario tiene cuenta confirmada | La contraseña ha sido cambiada |
| No hay sesión activa | El usuario tiene sesión activa |

| DATOS DE ENTRADA | DATOS DE SALIDA |
|---|---|
| Correo electrónico | Enlace de recuperación enviado al correo |
| Nueva contraseña (al abrir el enlace) | Confirmación visual de contraseña cambiada |

| TABLAS | CLASES |
|---|---|
| auth.users | AppUser |
| | AuthRepository |
| | RequestPasswordResetUseCase |
| | UpdatePasswordUseCase |

| INTERFACES |
|---|
| ForgotPasswordScreen · ResetPasswordScreen |

---

### CU-11 — Eliminar cuenta y datos

**Descripción:** El usuario elimina su cuenta y todos los datos asociados de forma irreversible, ejerciendo el derecho de supresión del RGPD.

| PRECONDICIONES | POSTCONDICIONES |
|---|---|
| El usuario está autenticado | La cuenta queda eliminada de Supabase Auth |
| La aplicación muestra la pantalla de perfil | Evaluaciones y pacientes eliminados en cascada |
| | La sesión se cierra automáticamente |

| DATOS DE ENTRADA | DATOS DE SALIDA |
|---|---|
| Confirmación explícita del usuario | Confirmación de borrado completo |
| | Cierre de sesión y redirección al login |

| TABLAS | CLASES |
|---|---|
| auth.users | AppUser |
| evaluations | DeleteAccountUseCase |
| patients | AuthRepository |

| INTERFACES |
|---|
| ProfileScreen |