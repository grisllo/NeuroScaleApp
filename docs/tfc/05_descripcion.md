# Descripción del sistema

## Arquitectura general

NeuroScale App está construida sobre una arquitectura de dos dimensiones ortogonales: **feature-first** en el eje horizontal (organización de carpetas) y **Clean Architecture** en el eje vertical (capas de responsabilidad dentro de cada feature).

La decisión de no usar una estructura plana `data/`–`domain/`–`presentation/` a nivel de raíz responde a la escala del proyecto: con cinco escalas, tres algoritmos, gestión de pacientes, evaluaciones, autenticación y perfil, la cohesión por feature escala mejor que la cohesión por capa. Cada módulo puede crecer, testearse y borrarse de forma independiente sin afectar al resto.

### Capas de responsabilidad

Cada feature implementa tres capas con reglas de dependencia estrictas:

| Capa | Contenido | Regla de dependencia |
|---|---|---|
| **Domain** | Entidades, calculadoras puras, interfaces de repositorio, casos de uso | Sin imports de Flutter ni Supabase. Solo Dart puro. |
| **Data** | Implementaciones de repositorios, datasources, modelos ORM, mappers | Puede importar Supabase, Drift y paquetes de datos. |
| **Presentation** | Screens, widgets, providers Riverpod, notifiers | Solo importa el dominio. Nunca llama a datasources directamente. |

El flujo de datos sigue la dirección `UI → Provider → UseCase → Repository → DataSource → Supabase / Drift`. Los repositorios lanzan subtipos de `Failure` (nunca excepciones desnudas); los datasources lanzan subtipos de `AppException` que los repositorios convierten en `Failure` en sus bloques `catch`.

### Estructura de módulos

```
lib/
├── core/                    infraestructura compartida
│   ├── database/            AppDatabase (Drift), DAOs
│   ├── routing/             go_router, AppShell, guards de auth
│   ├── theme/               tokens de diseño, paleta clínica, tipografía Inter
│   ├── errors/              jerarquía Failure / AppException
│   ├── widgets/             widgets reutilizables (ResponsiveContainer, SeverityBadge…)
│   └── utils/               PiiDetector, extensiones
│
├── features/
│   ├── auth/                autenticación y gestión de cuenta
│   ├── scales/
│   │   ├── shared/          entidades base (ScaleItem, ScaleResult, Severity, ScaleDefinition)
│   │   ├── gcs/             Glasgow Coma Scale
│   │   ├── nihss/           NIHSS
│   │   ├── rankin/          Modified Rankin Scale
│   │   ├── barthel/         Índice de Barthel
│   │   └── abcd2/           ABCD²
│   ├── evaluations/         persistencia y consulta de evaluaciones
│   ├── patients/            CRUD de pacientes anonimizados + gráfico de evolución
│   ├── algorithms/          algoritmos clínicos de decisión (Código Ictus, HTA, HSA)
│   ├── home/                pantalla de escalas (entry point tras login)
│   └── profile/             perfil, tema e idioma
│
└── l10n/                    app_es.arb + app_en.arb (519 entradas cada uno)
```

---

## Modelo de dominio

### Escalas neurológicas

La abstracción central de las escalas es la clase `ScaleDefinition`, que actúa como contrato compartido entre las cinco escalas:

| Campo / Método | Tipo | Descripción |
|---|---|---|
| `key` | `String` | Identificador único de la escala (`'gcs'`, `'nihss'`…) |
| `displayName` | `String` | Nombre para mostrar en la interfaz |
| `version` | `int` | Versión del protocolo de la escala |
| `items` | `List<ScaleItem>` | Ítems que componen la escala |
| `calculate(answers)` | `ScaleResult` | Función pura de cálculo |

Cada ítem de escala se representa mediante `ScaleItem`:

| Campo | Tipo | Descripción |
|---|---|---|
| `key` | `String` | Identificador único del ítem |
| `labelKey` | `String` | Clave ARB del enunciado |
| `min` / `max` | `int` | Rango válido de puntuación |
| `options` | `List<(int, String)>` | Pares (valor, clave ARB de opción) |
| `untestableValue` | `int?` | Valor especial `UN` (solo NIHSS: 9) |
| `helpKey` | `String?` | Clave ARB del texto tutorial |

El resultado de cualquier cálculo es un `ScaleResult`:

| Campo | Tipo | Descripción |
|---|---|---|
| `totalScore` | `int` | Puntuación obtenida |
| `maxScore` | `int` | Puntuación máxima posible |
| `severity` | `Severity` | Clasificación de gravedad (`none`, `mild`, `moderate`, `severe`) |
| `interpretation` | `String` | Clave ARB de la interpretación clínica |
| `itemScores` | `Map<String, int>` | Desglose por ítem |

### Algoritmos clínicos

Los algoritmos se modelan como grafos dirigidos acíclicos de nodos inmutables. Existen dos tipos de nodo (patrón `sealed class`):

**`QuestionNode`** — nodo de pregunta:

| Campo | Tipo | Descripción |
|---|---|---|
| `id` | `String` | Identificador del nodo |
| `questionKey` | `String` | Clave ARB de la pregunta |
| `hintKey` | `String?` | Texto de ayuda opcional |
| `options` | `List<AlgorithmOption>` | Opciones disponibles, cada una con `nextNodeId` |

**`ResultNode`** — nodo hoja con resultado clínico:

| Campo | Tipo | Descripción |
|---|---|---|
| `id` | `String` | Identificador del nodo |
| `titleKey` | `String` | Clave ARB del título del resultado |
| `urgency` | `AlgorithmUrgency` | Nivel de urgencia: `info`, `low`, `moderate`, `high`, `critical` |
| `recommendationKeys` | `List<String>` | Lista de claves ARB con recomendaciones |

El estado de ejecución de un algoritmo se encapsula en `AlgorithmState`:

| Campo / Propiedad | Tipo | Descripción |
|---|---|---|
| `definition` | `AlgorithmDefinition` | Definición inmutable del algoritmo |
| `path` | `List<String>` | Historial de IDs de nodos visitados |
| `selectedOptionIds` | `List<String>` | Opciones elegidas en cada paso |
| `currentNode` | `AlgorithmNode` | Nodo actual (calculado) |
| `isComplete` | `bool` | `true` si el nodo actual es un `ResultNode` |
| `canGoBack` | `bool` | `true` si hay nodos anteriores en el historial |

### Evaluaciones

La entidad `Evaluation` representa una evaluación clínica completada y persistida:

| Campo | Tipo | Descripción |
|---|---|---|
| `id` | `String` (UUID) | Identificador único |
| `userId` | `String` (UUID) | Usuario propietario |
| `scaleType` | `String` | Tipo de escala (`'gcs'`, `'nihss'`…) |
| `scaleVersion` | `int` | Versión del protocolo usado |
| `caseDescription` | `String` | Texto libre anonimizado (validado contra PII) |
| `totalScore` | `int` | Puntuación obtenida |
| `interpretation` | `String` | Interpretación clínica |
| `detailedScores` | `Map<String, dynamic>` | Desglose por ítem (serializado como JSONB) |
| `createdAt` / `updatedAt` | `DateTime` | Marcas temporales |
| `patientId` | `String?` (UUID) | Paciente asociado (nullable) |

### Pacientes

La entidad `Patient` modela un paciente anonimizado:

| Campo | Tipo | Descripción |
|---|---|---|
| `id` | `String` (UUID) | Identificador único |
| `userId` | `String` (UUID) | Usuario propietario |
| `alias` | `String` | Identificador libre sin PII (1–255 caracteres) |
| `notes` | `String` | Notas clínicas libres (sin PII) |
| `createdAt` / `updatedAt` | `DateTime` | Marcas temporales |

### Usuarios

La entidad de dominio `AppUser` es intencionalmente mínima, ya que los datos de autenticación son gestionados íntegramente por Supabase Auth:

| Campo | Tipo | Descripción |
|---|---|---|
| `id` | `String` (UUID) | UUID del usuario en `auth.users` |
| `email` | `String` | Correo electrónico verificado |

---

## Modelo de datos persistido

### Base de datos remota (Supabase / PostgreSQL)

La base de datos remota consta de dos tablas de aplicación, más las tablas de autenticación gestionadas internamente por Supabase (`auth.users`, `auth.sessions`…).

**Tabla `evaluations`**

| Columna | Tipo PostgreSQL | Restricciones | Descripción |
|---|---|---|---|
| `id` | `uuid` | PK, `gen_random_uuid()` | Identificador único |
| `user_id` | `uuid` | FK → `auth.users(id)` ON DELETE CASCADE | Propietario |
| `scale_type` | `scale_type` (enum) | NOT NULL | `gcs`, `nihss`, `rankin`, `barthel`, `abcd2` |
| `scale_version` | `smallint` | NOT NULL, default 1 | Versión del protocolo |
| `case_description` | `text` | NOT NULL, default `''`, máx. 500 chars | Descripción anonimizada |
| `total_score` | `integer` | NOT NULL | Puntuación total |
| `interpretation` | `text` | NOT NULL | Clave ARB de interpretación |
| `detailed_scores` | `jsonb` | NOT NULL, default `{}` | Desglose por ítem |
| `patient_id` | `uuid` | FK → `patients(id)` ON DELETE CASCADE, nullable | Paciente asociado |
| `created_at` | `timestamptz` | NOT NULL, default `now()` | Fecha de creación |
| `updated_at` | `timestamptz` | NOT NULL, trigger `set_updated_at` | Última modificación |

Índices: `(user_id, created_at DESC)`, `(patient_id)`.

**Tabla `patients`**

| Columna | Tipo PostgreSQL | Restricciones | Descripción |
|---|---|---|---|
| `id` | `uuid` | PK, `gen_random_uuid()` | Identificador único |
| `user_id` | `uuid` | FK → `auth.users(id)` ON DELETE CASCADE | Propietario |
| `alias` | `text` | NOT NULL, length > 0, length ≤ 255 | Alias clínico |
| `notes` | `text` | NOT NULL, default `''` | Notas libres |
| `created_at` | `timestamptz` | NOT NULL, default `now()` | Fecha de creación |
| `updated_at` | `timestamptz` | NOT NULL, trigger `set_updated_at_patients` | Última modificación |

Índice: `(user_id, created_at DESC)`.

**Row Level Security (RLS)**

Ambas tablas tienen RLS habilitado con cuatro políticas simétricas (`select_own`, `insert_own`, `update_own`, `delete_own`) que restringen cada operación a filas donde `auth.uid() = user_id`. La función de autenticación se materializa mediante `(select auth.uid())` en las políticas para evitar la evaluación repetida por fila (migración 0009).

### Base de datos local (Drift / SQLite)

La caché local replica el subconjunto de datos necesario para el modo offline con el mismo esquema lógico, adaptado a los tipos disponibles en SQLite:

| Tabla Drift | Equivalente remoto | Diferencia |
|---|---|---|
| `Evaluations` | `evaluations` | `detailed_scores` almacenado como `TEXT` (JSON serializado) |
| `Patients` | `patients` | `notes` es nullable en SQLite |

Los DAOs (`EvaluationsDao`, `PatientsDao`) exponen operaciones de `upsert` por lote e individuales, y consultas filtradas por `userId`. La estrategia de sincronización es **cache-aside**: escritura dual remoto + local; lectura remoto-first con fallback a local ante fallo de red.

### Edge Functions

La función `delete-account` (Deno/TypeScript, `verify_jwt=true`) ejecuta el borrado en cascada del usuario con privilegios `service_role`, operación que no puede realizarse desde el cliente por limitaciones de RLS. Acepta la petición del usuario autenticado (token en cabecera `Authorization`) y elimina en orden: evaluaciones → pacientes → usuario en `auth.users`.

---

## Flujo de navegación

El routing está gestionado por `go_router` con una `StatefulShellRoute` que mantiene el estado de cada rama de navegación entre cambios de pestaña.

### Rutas de autenticación (sin shell)

| Ruta | Pantalla | Descripción |
|---|---|---|
| `/disclaimer` | `DisclaimerScreen` | Aviso médico-legal en primer inicio |
| `/login` | `LoginScreen` | Inicio de sesión |
| `/register` | `RegisterScreen` | Registro de cuenta |
| `/forgot-password` | `ForgotPasswordScreen` | Solicitud de enlace de recuperación |
| `/reset-password` | `ResetPasswordScreen` | Formulario de nueva contraseña (desde enlace) |

### Shell principal (4 ramas, NavigationBar / NavigationRail)

| Rama | Raíz | Subrutas | Descripción |
|---|---|---|---|
| 0 — Escalas | `/` (`ScalesTabScreen`) | `/scales/gcs`, `/scales/nihss`, `/scales/rankin`, `/scales/barthel`, `/scales/abcd2`, `/result` | Selección y aplicación de escalas |
| 1 — Pacientes | `/patients` (`PatientsTabScreen`) | `/patients/:id` | Lista y detalle de paciente |
| 2 — Algoritmos | `/algorithms` (`AlgorithmsTabScreen`) | `/algorithms/:id` | Lista y ejecución de algoritmos |
| 3 — Perfil | `/profile` | — | Cuenta, tema, idioma |

El guard de autenticación (`_RouterNotifier.redirect`) redirige a `/login` cuando no hay sesión activa. El `passwordRecoveryProvider` tiene prioridad sobre el guard estándar y redirige a `/reset-password` cuando se detecta un evento `passwordRecovery` en el stream de Supabase.

Las transiciones de página usan una animación combinada de fundido (`FadeTransition`) y deslizamiento hacia arriba (`SlideTransition`) con curva `easeOutCubic`.

---

## Casos de uso

Los siguientes casos de uso cubren los flujos principales del sistema. Las precondiciones y postcondiciones describen el estado observable de la aplicación, no el estado interno.

---

### CU-01 — Registrar nueva cuenta

| Campo | Descripción |
|---|---|
| **Actores** | Usuario no autenticado |
| **Precondiciones** | La aplicación está en la pantalla de login o registro |
| **Postcondiciones** | La cuenta está creada en Supabase Auth; el usuario recibe un correo de confirmación |

**Flujo principal:**
1. El usuario navega a `/register`.
2. Introduce correo electrónico y contraseña (mínimo 6 caracteres).
3. El sistema valida el formato del correo y la longitud de la contraseña en cliente.
4. `SignUpUseCase` invoca `supabase.auth.signUp()`.
5. Supabase envía un correo de confirmación al usuario.
6. La aplicación muestra un mensaje de verificación pendiente.

**Flujos alternativos:**
- 3a. Correo con formato inválido → mensaje de error localizado, sin llamada al servidor.
- 4a. Correo ya registrado → `AuthFailure` con mensaje `emailAlreadyInUse`.

---

### CU-02 — Iniciar sesión

| Campo | Descripción |
|---|---|
| **Actores** | Usuario registrado y con cuenta confirmada |
| **Precondiciones** | La aplicación muestra `/login` |
| **Postcondiciones** | Sesión activa; el usuario es redirigido a la pantalla de escalas (`/`) |

**Flujo principal:**
1. El usuario introduce correo y contraseña.
2. `SignInUseCase` invoca `supabase.auth.signInWithPassword()`.
3. Supabase valida las credenciales y devuelve un `Session`.
4. `authStateProvider` detecta el cambio de estado y el guard de routing redirige a `/`.

**Flujos alternativos:**
- 2a. Contraseña incorrecta → `AuthFailure` con mensaje `invalidCredentials`.
- 2b. Sin conexión → `NetworkFailure`; la pantalla de login muestra el `OfflineBanner`.

---

### CU-03 — Aplicar escala neurológica

| Campo | Descripción |
|---|---|
| **Actores** | Usuario autenticado |
| **Precondiciones** | El usuario está en la pestaña de escalas (`/`) |
| **Postcondiciones** | La pantalla de resultado muestra la puntuación y la interpretación clínica |

**Flujo principal:**
1. El usuario selecciona una escala de la lista (p. ej. GCS).
2. La aplicación navega a `/scales/gcs` y presenta los ítems secuencialmente.
3. El usuario selecciona una opción por cada ítem.
4. La calculadora de dominio (`calculateGcs`) computa la puntuación en tiempo real.
5. Al completar todos los ítems, el botón «Calcular» lleva a `/result`.
6. `ResultScreen` muestra la puntuación total, la clasificación de gravedad (con el color clínico correspondiente) y el desglose por ítem.

**Flujos alternativos:**
- 4a. El usuario activa el botón ? en un ítem → se abre el `BottomSheet` tutorial con la descripción clínica y la referencia bibliográfica.
- 5a. El usuario vuelve atrás → el estado del formulario se conserva (Riverpod `Notifier`).

---

### CU-04 — Guardar evaluación

| Campo | Descripción |
|---|---|
| **Actores** | Usuario autenticado |
| **Precondiciones** | Se muestra la pantalla de resultado de una escala completada |
| **Postcondiciones** | La evaluación queda persistida en Supabase y en la caché local Drift |

**Flujo principal:**
1. El usuario pulsa «Guardar» en `ResultScreen`.
2. Aparece un formulario que permite seleccionar un paciente (opcional) e introducir una descripción libre.
3. `PiiDetector.containsPii()` valida en tiempo real la descripción; si detecta PII, el botón de guardar queda deshabilitado.
4. `SaveEvaluationUseCase` persiste la evaluación en Supabase y en Drift.
5. La pantalla muestra `AnimatedCheck` como confirmación visual.

**Flujos alternativos:**
- 3a. Descripción contiene un DNI → se muestra el mensaje `piiDetectedError`; el guardado está bloqueado hasta corregirlo.
- 4a. Fallo de red → la evaluación se persiste solo en Drift; se sincroniza al reconectar.

---

### CU-05 — Consultar historial de evaluaciones

| Campo | Descripción |
|---|---|
| **Actores** | Usuario autenticado |
| **Precondiciones** | El usuario tiene al menos una evaluación guardada |
| **Postcondiciones** | La pantalla muestra la lista de evaluaciones según el orden seleccionado |

**Flujo principal:**
1. El usuario accede a la pantalla de escalas y navega al historial.
2. `FetchEvaluationsUseCase` recupera las evaluaciones del usuario desde Supabase.
3. La lista se muestra ordenada por fecha descendente (más reciente primero) por defecto.
4. El usuario puede cambiar el orden mediante el menú: más reciente, más antigua, por escala.

**Flujos alternativos:**
- 2a. Sin conexión → se muestran las evaluaciones de la caché Drift con el `OfflineBanner` visible.
- 4a. El usuario desliza un ítem → aparece la acción de borrado con confirmación.

---

### CU-06 — Ver evolución temporal de un paciente

| Campo | Descripción |
|---|---|
| **Actores** | Usuario autenticado |
| **Precondiciones** | El paciente tiene al menos dos evaluaciones de la misma escala registradas en fechas distintas |
| **Postcondiciones** | El gráfico muestra la evolución temporal de la puntuación seleccionada |

**Flujo principal:**
1. El usuario navega a `/patients` y selecciona un paciente.
2. `PatientDetailScreen` carga las evaluaciones asociadas.
3. El selector de escala permite elegir la serie a visualizar (GCS, Barthel, etc.).
4. El `LineChart` (fl_chart) dibuja los puntos de puntuación con el eje X proporcional al tiempo real y el eje Y normalizado al rango de la escala.
5. El usuario puede pulsar un punto para ver el tooltip con puntuación exacta, fecha y hora.

**Flujos alternativos:**
- 3a. Solo hay evaluaciones de una escala → el selector se muestra preseleccionado sin posibilidad de cambio.
- 2a. Sin evaluaciones → pantalla de estado vacío con llamada a la acción.

---

### CU-07 — Ejecutar algoritmo clínico

| Campo | Descripción |
|---|---|
| **Actores** | Usuario autenticado |
| **Precondiciones** | El usuario está en la pestaña de algoritmos (`/algorithms`) |
| **Postcondiciones** | La pantalla muestra el resultado con nivel de urgencia y recomendaciones |

**Flujo principal:**
1. El usuario selecciona un algoritmo (p. ej. Código Ictus).
2. La aplicación navega a `/algorithms/strokeCode` y presenta el primer nodo.
3. El usuario responde cada pregunta seleccionando una opción.
4. `stepAlgorithm()` actualiza el `AlgorithmState` y el nodo actual cambia con animación de barrido.
5. Al alcanzar un `ResultNode`, la pantalla muestra el título del resultado, el color de urgencia (`ClinicalColors`) y las recomendaciones.
6. El botón «Reiniciar» limpia el estado y vuelve al primer nodo.

**Flujos alternativos:**
- 3a. El usuario pulsa «Atrás» → `backAlgorithm()` retrocede un paso en el historial.

---

### CU-08 — Gestionar paciente

| Campo | Descripción |
|---|---|
| **Actores** | Usuario autenticado |
| **Precondiciones** | El usuario está en la pestaña de pacientes |
| **Postcondiciones** | La lista de pacientes refleja la operación realizada (creación, edición o borrado) |

**Flujo principal (creación):**
1. El usuario pulsa el botón flotante «Nuevo paciente».
2. Introduce un alias clínico libre (p. ej. `P-001`).
3. `CreatePatientUseCase` persiste el paciente en Supabase y en Drift.
4. La lista se actualiza con el nuevo paciente en primer lugar.

**Flujo alternativo (borrado):**
1. El usuario desliza un paciente en la lista o accede al detalle y pulsa «Eliminar».
2. Se muestra un `AlertDialog` de confirmación.
3. `DeletePatientUseCase` borra el paciente de Supabase.
4. La restricción `ON DELETE CASCADE` elimina automáticamente todas las evaluaciones asociadas.
5. La caché Drift se actualiza.

---

### CU-09 — Configurar preferencias de usuario

| Campo | Descripción |
|---|---|
| **Actores** | Usuario autenticado |
| **Precondiciones** | El usuario está en la pantalla de perfil (`/profile`) |
| **Postcondiciones** | El tema y/o el idioma cambian inmediatamente y persisten entre sesiones |

**Flujo principal:**
1. El usuario accede a `/profile`.
2. Selecciona el tema (claro, oscuro, automático) mediante `SegmentedButton`.
3. `ThemeNotifier` actualiza el estado en Riverpod y persiste la preferencia en `SharedPreferences`.
4. `MaterialApp` reconstruye con el nuevo `ThemeMode`.
5. El usuario selecciona el idioma (español/inglés) en el selector correspondiente.
6. `LocaleProvider` actualiza el `locale` de `MaterialApp`.

---

### CU-10 — Recuperar acceso con contraseña olvidada

| Campo | Descripción |
|---|---|
| **Actores** | Usuario registrado sin sesión activa |
| **Precondiciones** | La aplicación muestra `/login` |
| **Postcondiciones** | La contraseña ha sido cambiada; el usuario tiene sesión activa |

**Flujo principal:**
1. El usuario pulsa «¿Olvidaste tu contraseña?» y navega a `/forgot-password`.
2. Introduce su correo; `AuthRepository.requestPasswordReset()` envía el enlace.
3. El usuario abre el enlace en el dispositivo donde tiene la app instalada.
4. Supabase emite un evento `passwordRecovery`; `passwordRecoveryProvider` redirige a `/reset-password`.
5. El usuario introduce y confirma la nueva contraseña.
6. `AuthRepository.updatePassword()` actualiza la contraseña; se muestra `AnimatedCheck`.
7. El guard de routing redirige a `/`.

---

### CU-11 — Eliminar cuenta y datos

| Campo | Descripción |
|---|---|
| **Actores** | Usuario autenticado |
| **Precondiciones** | El usuario está en la pantalla de perfil |
| **Postcondiciones** | La cuenta y todos los datos asociados han sido eliminados irreversiblemente |

**Flujo principal:**
1. El usuario pulsa «Eliminar cuenta» en la sección de administración de cuenta.
2. Se muestra un `AlertDialog` con advertencia de irreversibilidad y botón de confirmación en rojo.
3. `DeleteAccountUseCase` invoca la Edge Function `delete-account` con el token JWT del usuario.
4. La Edge Function borra evaluaciones, pacientes y el registro en `auth.users` con `service_role`.
5. `authStateProvider` detecta la sesión cerrada; el guard redirige a `/login`.
6. La caché Drift local se limpia en el próximo inicio de sesión.

**Flujos alternativos:**
- 3a. El token ha expirado → `AuthFailure`; se solicita re-autenticación antes de reintentar.
