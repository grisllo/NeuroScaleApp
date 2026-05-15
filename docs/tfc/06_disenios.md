# Diseños

Los diagramas de esta sección se pueden visualizar directamente en GitHub abriendo este fichero, que renderiza Mermaid de forma nativa. Las capturas externas (Supabase, GitHub Actions, interfaces de la app) se insertarán manualmente en el documento final.

---

## Arquitectura de la solución

Muestra cómo el cliente Flutter se organiza en capas (presentación, dominio, datos) y cómo estas se conectan con los servicios externos de Supabase y con el hosting de GitHub.

```mermaid
flowchart TB
    subgraph cliente["Cliente — Aplicación Flutter"]
        direction TB
        UI["Capa de presentación (pantallas, widgets)"]
        State["Gestión de estado (Riverpod)"]
        UseCase["Casos de uso (domain)"]
        Calc["Calculadoras puras (escalas y algoritmos)"]
        Repo["Repositorios (data)"]
        LocalDB["Caché local (Drift / SQLite)"]
    end
    subgraph backend["Backend — Supabase"]
        direction TB
        Auth["Auth Service (JWT)"]
        Postgres["PostgreSQL + Row Level Security"]
        EdgeFn["Edge Function: delete-account"]
    end
    subgraph hosting["Hosting y CI/CD — GitHub"]
        direction TB
        Repo2["Repositorio (rama main)"]
        Actions["GitHub Actions (CI + Deploy)"]
        Pages["GitHub Pages (versión web pública)"]
    end
    UI --> State
    State --> UseCase
    UseCase --> Calc
    UseCase --> Repo
    Repo --> LocalDB
    Repo -.->|HTTPS / PostgREST| Auth
    Repo -.->|HTTPS / PostgREST| Postgres
    Repo -.->|HTTPS| EdgeFn
    Repo2 -->|push| Actions
    Actions -->|deploy| Pages
```

---

## Diagrama de despliegue y comunicación

Muestra dónde se ejecuta cada componente del sistema y qué protocolos usa para comunicarse.

```mermaid
flowchart LR
    User(("Usuario"))
    subgraph dispositivo["Dispositivo del usuario"]
        WebApp["App web (Chrome, Firefox, Safari)"]
        AndroidApp["App Android (APK firmado)"]
    end
    subgraph github["GitHub"]
        Pages["GitHub Pages (HTTPS)"]
        CI["GitHub Actions"]
        RepoGit["Repositorio main"]
    end
    subgraph supabase["Supabase EU-West-2"]
        AuthSvc["Auth (JWT)"]
        DB["PostgreSQL + RLS"]
        EdgeFnSvc["Edge Function: delete-account"]
    end
    User --> WebApp
    User --> AndroidApp
    WebApp -->|HTTPS| Pages
    Pages -->|carga estática| WebApp
    WebApp -->|HTTPS / PostgREST| AuthSvc
    AndroidApp -->|HTTPS / PostgREST| AuthSvc
    WebApp -->|HTTPS / PostgREST| DB
    AndroidApp -->|HTTPS / PostgREST| DB
    WebApp -->|HTTPS + JWT| EdgeFnSvc
    AndroidApp -->|HTTPS + JWT| EdgeFnSvc
    RepoGit -->|push a main| CI
    CI -->|build + deploy| Pages
```

---

## Diagrama de clases del dominio

Muestra las entidades del dominio (escalas, algoritmos, evaluaciones, pacientes) y sus relaciones. No incluye las capas de datos ni de presentación, que dependen del dominio y no al revés.

```mermaid
classDiagram
    class ScaleDefinition {
        <<abstract>>
        +String key
        +String displayName
        +int version
        +List~ScaleItem~ items
        +calculate(Map answers) ScaleResult
    }
    class ScaleItem {
        +String key
        +String labelKey
        +int min / max
        +List options
        +int? untestableValue
        +String? helpKey
    }
    class ScaleResult {
        +int totalScore
        +int maxScore
        +Severity severity
        +String interpretation
        +Map itemScores
    }
    class Severity {
        <<enumeration>>
        none / mild / moderate / severe
    }
    class Evaluation {
        +String id
        +String userId
        +String scaleType
        +int totalScore
        +String interpretation
        +String? patientId
        +DateTime createdAt
    }
    class Patient {
        +String id
        +String userId
        +String alias
        +String notes
    }
    class AppUser {
        +String id
        +String email
    }
    class AlgorithmDefinition {
        +String id
        +String titleKey
        +String startNodeId
        +Map~String,AlgorithmNode~ nodes
    }
    class AlgorithmNode {
        <<sealed>>
        +String id
    }
    class QuestionNode {
        +String questionKey
        +List~AlgorithmOption~ options
    }
    class ResultNode {
        +String titleKey
        +AlgorithmUrgency urgency
        +List~String~ recommendationKeys
    }
    class AlgorithmUrgency {
        <<enumeration>>
        info / low / moderate / high / critical
    }
    ScaleDefinition "1" *-- "1..*" ScaleItem : contiene
    ScaleDefinition ..> ScaleResult : produce
    ScaleResult --> Severity : clasifica
    AlgorithmNode <|-- QuestionNode
    AlgorithmNode <|-- ResultNode
    AlgorithmDefinition "1" *-- "1..*" AlgorithmNode : contiene
    ResultNode --> AlgorithmUrgency : clasifica
    Evaluation --> Patient : pertenece a
    Evaluation --> AppUser : pertenece a
    Patient --> AppUser : pertenece a
```

---

## Modelo entidad-relación

Muestra las dos tablas de aplicación (`evaluations` y `patients`), su relación con los usuarios de Supabase Auth y las tres claves foráneas con borrado en cascada.

```mermaid
erDiagram
    AUTH_USERS {
        uuid id PK
        text email
        timestamptz created_at
    }
    PATIENTS {
        uuid id PK
        uuid user_id FK
        text alias
        text notes
        timestamptz created_at
        timestamptz updated_at
    }
    EVALUATIONS {
        uuid id PK
        uuid user_id FK
        enum scale_type
        smallint scale_version
        text case_description
        integer total_score
        text interpretation
        jsonb detailed_scores
        uuid patient_id FK
        timestamptz created_at
        timestamptz updated_at
    }
    AUTH_USERS ||--o{ PATIENTS : "posee (CASCADE)"
    AUTH_USERS ||--o{ EVALUATIONS : "posee (CASCADE)"
    PATIENTS ||--o{ EVALUATIONS : "agrupa (CASCADE)"
```

> *Captura complementaria: Supabase Studio → Database → Schema Visualizer ofrece una vista visual generada automáticamente del mismo esquema.*

---

## Esquema físico de la base de datos

| Aspecto | Solución aplicada |
|---|---|
| Identificadores | UUID con generación automática |
| Marcas de tiempo | `timestamptz` actualizadas por trigger en cada UPDATE |
| Borrado en cascada | Tres FK con `ON DELETE CASCADE` |
| Índices | `(user_id, created_at DESC)` en evaluaciones; `(patient_id)` para filtrar por paciente |
| Seguridad | RLS activo en ambas tablas con cuatro políticas por tabla (select, insert, update, delete) |
| Validaciones | `alias` entre 1 y 255 caracteres; `case_description` máximo 500 caracteres |

> *Capturas: Supabase Studio → Table Editor (evaluations y patients), Authentication → Policies, Database → Indexes, Database → Migrations.*

---

## Diagrama de flujo de navegación

Muestra las pantallas de la aplicación y las transiciones entre ellas, incluyendo el comportamiento del guardián de autenticación.

```mermaid
flowchart TD
    Start([Inicio de la app]) --> Disclaimer
    Disclaimer["/disclaimer — Aviso médico-legal"] -->|Primera vez aceptado| Login
    subgraph auth["Autenticación (sin shell)"]
        Login["/login"]
        Register["/register"]
        ForgotPwd["/forgot-password"]
        ResetPwd["/reset-password"]
        Login --> ForgotPwd
        Login --> Register
        ForgotPwd --> ResetPwd
    end
    Login -->|OK| Shell
    Register -->|OK| Shell
    ResetPwd -->|OK| Shell
    subgraph shell["Shell principal"]
        direction LR
        Tab0["Escalas /"]
        Tab1["Pacientes /patients"]
        Tab2["Algoritmos /algorithms"]
        Tab3["Perfil /profile"]
    end
    Tab0 --> ScaleForm["/scales/:id"]
    ScaleForm --> Result["/result"]
    Tab1 --> PatientDetail["/patients/:id"]
    Tab2 --> AlgoRun["/algorithms/:id"]
    Tab3 -->|Cerrar sesión| Login
    Tab3 -->|Borrar cuenta| Login
    Shell -->|Sin sesión| Login
```

---

## Sistema de diseño visual

### Paleta de colores clínicos

| Token | Color | Uso |
|---|---|---|
| `severity_none` | Verde | Sin déficit / independencia total |
| `severity_mild` | Azul | Déficit leve / riesgo bajo |
| `severity_moderate` | Naranja | Déficit moderado / riesgo moderado |
| `severity_severe` | Rojo | Déficit grave / urgencia crítica |
| `scale_gcs` | Índigo | Identificador visual GCS |
| `scale_nihss` | Teal | Identificador visual NIHSS |
| `scale_rankin` | Violeta | Identificador visual mRS |
| `scale_barthel` | Verde oscuro | Identificador visual Barthel |
| `scale_abcd2` | Naranja oscuro | Identificador visual ABCD² |

### Tipografía y responsive

Tipografía principal: **Inter** (Google Fonts). Diseñada para pantallas, amplia gama de pesos, jeraquía visual sin mezclar familias. Escala tipográfica de Material Design 3.

| Dispositivo | Navegación | Columnas | Ancho máximo |
|---|---|---|---|
| Móvil (< 600 dp) | Barra inferior | 1 | Sin límite |
| Tablet / escritorio (≥ 600 dp) | Panel lateral | 2 | 800 dp |

---

## Capturas de la interfaz

> *Las siguientes capturas corresponden a la versión 1.0.0 en producción.*

### Login (web)

![Pantalla de inicio de sesión en web](../screenshots/01_login_web.png)

### Cuadrícula de escalas (web / tablet)

![Cuadrícula de escalas en tablet/web](../screenshots/02_scales_grid_web.png)

### Formulario de escala — GCS (móvil)

![Formulario de la escala GCS en móvil](../screenshots/03_gcs_mobile.png)

### Resultado de escala (móvil)

![Resultado de escala en móvil](../screenshots/04_result_mobile.png)

### Gráfico de evolución de paciente (web)

![Gráfico de evolución temporal en web](../screenshots/05_patient_chart_web.png)

### Algoritmo clínico (web)

![Ejecución de algoritmo clínico en web](../screenshots/06_algorithm_web.png)

### Tema claro

![Aplicación en tema claro](../screenshots/07_light_mode.png)

### Gráfico en tema claro

![Gráfico de evolución en tema claro](../screenshots/08_graphics_light.png)

---

## Capturas de infraestructura

> *Las siguientes capturas se insertan manualmente desde Supabase Studio y GitHub.*

**Supabase Studio:**
- Schema Visualizer (`Database → Schema Visualizer`)
- Editor de tablas (`Table Editor → evaluations` y `patients`)
- Políticas RLS (`Authentication → Policies`)
- Migraciones (`Database → Migrations`)
- Edge Function (`Edge Functions → delete-account`)

**GitHub:**
- Pipeline CI en verde (`Actions → ci`)
- Pipeline deploy en verde (`Actions → deploy`)
- GitHub Pages configurado (`Settings → Pages`)
- Release v1.0.0 (`Releases → v1.0.0`)
