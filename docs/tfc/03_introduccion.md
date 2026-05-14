# Introducción

## Descripción del proyecto

**NeuroScale App** es una aplicación multiplataforma (Android, iOS y web) que centraliza las herramientas de evaluación neurológica más utilizadas en el entorno clínico español. Permite a profesionales de la salud y estudiantes de medicina aplicar escalas neurológicas estandarizadas, calcular puntuaciones, interpretar resultados con su clasificación de gravedad y registrar las evaluaciones de forma anonimizada vinculadas a un caso clínico.

La aplicación está disponible en producción en [grisllo.github.io/NeuroScaleApp](https://grisllo.github.io/NeuroScaleApp/), con distribución Android mediante APK firmado para instalación directa en dispositivos físicos.

## Funcionalidades principales

### Escalas neurológicas

La aplicación implementa cinco escalas con sus calculadoras clínicas, rangos de interpretación y clasificación de gravedad:

| Escala | Rango | Uso clínico principal |
|---|---|---|
| **GCS** — Glasgow Coma Scale | 3–15 | Nivel de consciencia en TCE y emergencias |
| **NIHSS** — National Institutes of Health Stroke Scale | 0–42 | Gravedad del ictus isquémico agudo |
| **mRS** — Modified Rankin Scale | 0–6 | Discapacidad neurológica post-ictus (incluye grado 6: fallecido) |
| **Barthel Index** | 0–100 | Independencia funcional en actividades de la vida diaria |
| **ABCD²** | 0–7 | Estratificación del riesgo de ictus tras accidente isquémico transitorio |

Cada escala dispone de un **modo tutorial** que muestra, ítem a ítem, la descripción clínica y la referencia bibliográfica de cada criterio de puntuación.

### Algoritmos clínicos de decisión

Tres árboles de decisión guiados con indicación de urgencia clasificada (`crítica`, `alta`, `moderada`, `baja`, `informativa`):

- **Código Ictus** — criterios de indicación de fibrinólisis intravenosa (tPA) en ventana terapéutica 3–4,5 horas.
- **HTA en ictus agudo** — manejo de la presión arterial según tipo de ictus (isquémico con o sin reperfusión, hemorragia intracerebral, hemorragia subaracnoidea).
- **HSA Hunt-Hess / Fisher** — clasificación clínica y radiológica de la hemorragia subaracnoidea.

### Gestión de pacientes y evaluaciones

- Gestión de pacientes anonimizados mediante alias clínico libre (por ejemplo, `P-001`). Nunca se almacena el nombre real ni ningún dato identificativo.
- Evaluaciones vinculadas a paciente con campo de descripción del caso, protegido por un detector activo de PII que bloquea el guardado ante la detección de DNI, NIE, email, teléfono o fecha de nacimiento.
- Gráficos de evolución temporal por escala para cada paciente, permitiendo monitorizar la progresión clínica a lo largo del tiempo.
- Borrado granular de pacientes y evaluaciones individuales, con propagación en cascada en base de datos.

### Cuenta y preferencias

- Registro, inicio de sesión, recuperación y cambio de contraseña mediante Supabase Auth.
- Borrado de cuenta con eliminación completa de todos los datos asociados (Edge Function con privilegios de administrador).
- Tema claro, oscuro o automático (sigue la preferencia del sistema).
- Idioma español o inglés, con persistencia entre sesiones.

### Calidad técnica

- **204 tests automatizados**: calculadoras de dominio cubren todos los umbrales clínicos; tests de presentación para componentes críticos.
- **Modo offline**: caché local SQLite (Drift) para Android e iOS — la aplicación funciona sin conexión y sincroniza al recuperarla.
- **Diseño responsive**: NavigationBar en móvil, NavigationRail en tablet y escritorio.
- **Internacionalización completa**: 519 entradas ARB en español e inglés.

## Problemas que resuelve

El proyecto da respuesta a tres necesidades concretas detectadas en el uso clínico real:

1. **Fragmentación de herramientas**: el profesional consulta cada escala en una app o documento diferente, sin contexto clínico ni continuidad. NeuroScale App unifica las cinco escalas más usadas en neurología de urgencias en una interfaz única.

2. **Ausencia de trazabilidad clínica**: ninguna app del mercado registra el historial de evaluaciones de un mismo caso. NeuroScale App almacena cada evaluación vinculada al paciente y la representa gráficamente para monitorizar la evolución.

3. **Brecha entre escalas y decisiones**: las escalas son una entrada de un proceso decisional que el clínico debe construir mentalmente. Los algoritmos clínicos de la aplicación encadenan ese proceso en un árbol de decisión guiado, reduciendo el riesgo de omisión en situaciones de alta presión.

## Alcance y limitaciones

**Dentro del alcance**:
- Cálculo e interpretación de las cinco escalas en todas las plataformas.
- Persistencia de evaluaciones con sincronización remota y caché local.
- Algoritmos clínicos de decisión como herramienta de apoyo.
- Gestión de pacientes anonimizados con visualización de evolución.

**Fuera del alcance**:
- Diagnóstico médico: la aplicación es una herramienta de apoyo a la decisión clínica, no un sistema de diagnóstico. Cada pantalla de resultado incluye un aviso explícito de que los resultados deben ser interpretados por un profesional sanitario.
- Integración con sistemas de historia clínica electrónica (HCE): la aplicación opera de forma independiente y no se conecta a sistemas hospitalarios como Selene, Orion o equivalentes.
- Certificación como producto sanitario bajo el Reglamento (UE) 2017/745 (MDR): el desarrollo actual corresponde a un proyecto académico; la certificación requeriría un proceso específico descrito en el apartado de trabajos futuros.
