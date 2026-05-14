# Justificación del proyecto

## Motivación

Las escalas neurológicas estandarizadas son instrumentos clínicamente mandatados en España: la **Estrategia en Ictus del Sistema Nacional de Salud (actualización 2024)** del Ministerio de Sanidad establece la NIHSS como herramienta obligatoria en la valoración del ictus agudo y define los criterios de reperfusión en función de su puntuación. La Guía de Práctica Clínica sobre el Manejo del Ictus en Atención Primaria (OSTEBA/GuíaSalud, 2025) recomienda la escala de Glasgow para la valoración inicial del nivel de conciencia en urgencias. El protocolo **Código Ictus**, vigente en todas las comunidades autónomas, depende directamente de la puntuación NIHSS medida en urgencias para tomar decisiones de tratamiento con una ventana terapéutica inferior a 4,5 horas.

A pesar de esta relevancia clínica, su aplicación en la práctica asistencial adolece de dos problemas concretos: la fragmentación (el profesional consulta las escalas en fuentes distintas, muchas veces en papel o en aplicaciones de cálculo genéricas sin contexto neurológico) y la ausencia de trazabilidad por paciente (no existe herramienta que registre las evaluaciones sucesivas de un mismo caso clínico para monitorizar su evolución).

NeuroScale App nació para resolver precisamente esos dos problemas: centralizar las escalas neurológicas más utilizadas en una única aplicación multiplataforma, y registrar el historial de evaluaciones vinculado a cada caso clínico anonimizado.

## Estado de la cuestión: aplicaciones existentes

El mercado ofrece varias aplicaciones de referencia para cálculo clínico. El siguiente análisis se centra en su cobertura de escalas neurológicas y en las funcionalidades relevantes para el entorno asistencial español.

| Aplicación | Plataformas | Escalas neurológicas | Historial por paciente | Offline | Precio |
|---|---|---|---|---|---|
| **MDCalc** | iOS, Android, Web | GCS, NIHSS, mRS, Barthel, ABCD2 y más de 270 calculadoras | No | Parcial | Gratuita |
| **Calculate by QxMD** | iOS, Android | Más de 400 calculadoras incluyendo GCS, NIHSS, ABCD2 | No | Sí | Gratuita |
| **Medscape** | iOS, Android, Web | Calculadoras neurológicas (motor QxMD) | No | Parcial | Gratuita (registro) |
| **MedCalc** (medcalc.ch) | iOS, Android | GCS, NIHSS y más de 30 calculadoras | No | Sí | Gratuita |
| **Neuro Toolkit** | iOS únicamente | GCS, ABCD2, UPDRS, EDSS (sin actualizaciones desde 2019) | No | Sí | De pago |
| **NeuroScale App** | Android, iOS, Web | GCS, NIHSS, mRS, Barthel, ABCD2 + 3 algoritmos clínicos | **Sí** | **Sí** | — |

Fuentes: App Store, Google Play, PMC NIH (App review: MDCalc, 2019; Mobile medical applications in neurology, 2018), web oficial de cada aplicación.

## Limitaciones de las soluciones existentes

Del análisis anterior se extraen cinco limitaciones estructurales comunes a todas las aplicaciones del mercado:

1. **Calculadoras de uso único sin memoria.** Ninguna app permite almacenar evaluaciones sucesivas vinculadas a un caso clínico. La monitorización de la evolución de un ictus o un traumatismo craneoencefálico requiere combinar manualmente los resultados de diferentes sesiones, lo que introduce riesgo de error y dificulta el seguimiento.

2. **Ausencia de gestión de pacientes anonimizada.** Las apps generalistas no contemplan el riesgo de introducción accidental de datos identificativos en campos de texto libre. NeuroScale App incorpora un detector activo de PII (DNI, NIE, email, teléfono, fecha de nacimiento) que bloquea el guardado si detecta información sensible.

3. **Algoritmos clínicos no integrados.** Herramientas como la activación del Código Ictus o el manejo de la hipertensión en el ictus agudo requieren combinar varias escalas con criterios decisionales. Ninguna app del mercado encadena ese flujo en un árbol de decisión guiado; el profesional debe construirlo mentalmente.

4. **Cobertura lingüística limitada.** La mayoría son monolingüe (inglés), lo que supone una barrera de adopción en el entorno asistencial español. NeuroScale App es completamente bilingüe (español e inglés) desde la primera versión.

5. **Ausencia de versión web optimizada.** Neuro Toolkit funciona únicamente en iOS. Las demás son aplicaciones móvil-first sin interfaz web adaptada al uso en estación de trabajo de urgencias o consulta. NeuroScale App compila para web con navegación adaptativa (NavigationBar en móvil, NavigationRail en tablet y escritorio).

## Público objetivo

La aplicación está dirigida a dos perfiles principales:

- **Profesionales de la salud en activo**: médicos de urgencias, neurólogos, médicos de atención primaria y enfermería de urgencias que aplican estas escalas de forma rutinaria y necesitan registrar la evolución de sus pacientes de forma ágil y segura.
- **Estudiantes de Medicina y Ciencias de la Salud**: alumnos que deben conocer y practicar la aplicación de estas escalas durante su formación clínica, para quienes el modo tutorial (explicación clínica por ítem) resulta especialmente útil.

## Conclusión de la justificación

NeuroScale App no compite con las grandes plataformas de referencia médica generalistas (MDCalc, Medscape) en amplitud de catálogo, sino que propone un valor diferencial concreto: **la trazabilidad clínica anonimizada por paciente** para las escalas neurológicas más utilizadas en España, combinada con los algoritmos de decisión que guían las actuaciones de urgencia más críticas. Este enfoque cubre un vacío real que ninguna de las soluciones existentes atiende actualmente.

## Referencias de este apartado

- Ministerio de Sanidad. (2024). *Estrategia en Ictus del Sistema Nacional de Salud. Actualización 2024*. Recuperado de https://www.sanidad.gob.es/areas/calidadAsistencial/estrategias/ictus/docs/Estrategia_en_Ictus_del_SNS._Actualizacion_2024_accesible.pdf
- OSTEBA / GuíaSalud. (2025). *Guía de Práctica Clínica sobre el Manejo del Ictus en Atención Primaria*. Recuperado de https://portal.guiasalud.es/wp-content/uploads/2025/02/gpc_635_manejo_ictus_ap_osteba_compl.pdf
- Sociedad Española de Neurología. (s.f.). *Guías y Protocolos*. Recuperado de https://www.sen.es/profesionales/guias-y-protocolos/110-guias-y-protocolos
- Elsevier Radiología. (2022). *Actualización del Código Ictus en urgencias*. Recuperado de https://www.elsevier.es/es-revista-radiologia-119-articulo-actualizacion-del-codigo-ictus-urgencias-S0033833822002508
- Storrow, A. B., et al. (2019). MDCalc Medical Calculator App Review. *JAMIA Open*, 2(3). Recuperado de https://pmc.ncbi.nlm.nih.gov/articles/PMC6737202/
- Sacks, D., et al. (2018). Mobile medical applications in neurology. *Journal of the Neurological Sciences*, 390. Recuperado de https://pmc.ncbi.nlm.nih.gov/articles/PMC5765940/
