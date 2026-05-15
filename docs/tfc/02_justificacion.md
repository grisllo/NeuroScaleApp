# Justificación del proyecto

## Motivación

Las escalas neurológicas estandarizadas son instrumentos de uso obligado en la práctica clínica española. La Estrategia en Ictus del Sistema Nacional de Salud, en su actualización de 2024, establece la NIHSS como herramienta obligatoria en la valoración del ictus agudo y define los criterios de reperfusión a partir de su puntuación. La Guía de Práctica Clínica sobre el Manejo del Ictus en Atención Primaria (OSTEBA/GuíaSalud, 2025) recomienda la escala de Glasgow para la valoración inicial del nivel de conciencia en urgencias. Y el protocolo Código Ictus, vigente en todas las comunidades autónomas, depende directamente de la puntuación NIHSS para tomar decisiones de tratamiento con una ventana terapéutica inferior a 4,5 horas.

A pesar de esta relevancia clínica, su aplicación cotidiana arrastra dos problemas que cualquiera que haya rotado por urgencias conoce. El primero es la fragmentación: el profesional consulta cada escala en una fuente distinta, muchas veces en papel o en calculadoras genéricas sin contexto neurológico. El segundo es la ausencia de trazabilidad por paciente: no hay ninguna herramienta extendida que registre las evaluaciones sucesivas de un mismo caso clínico para monitorizar su evolución.

NeuroScale App se diseñó precisamente para atender esos dos huecos: agrupar en una sola aplicación multiplataforma las escalas neurológicas más utilizadas y registrar el historial de evaluaciones vinculado a cada caso clínico anonimizado.

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

Repasando el análisis anterior aparecen varias limitaciones que se repiten en todas o casi todas las aplicaciones del mercado.

La primera y más visible es que se trata de calculadoras de uso único sin memoria. Ninguna de las aplicaciones revisadas permite almacenar evaluaciones sucesivas vinculadas a un caso clínico. Monitorizar la evolución de un ictus o de un traumatismo craneoencefálico obliga al profesional a combinar manualmente los resultados de cada sesión, lo que introduce riesgo de error y dificulta el seguimiento longitudinal.

Tampoco contemplan la gestión de pacientes anonimizada. Las apps generalistas ofrecen campos de texto libre sin pensar en el riesgo de introducción accidental de datos identificativos. NeuroScale App incorpora un detector activo de PII (DNI, NIE, correo, teléfono y fecha de nacimiento) que bloquea el guardado si detecta información sensible.

Otra limitación es que los algoritmos clínicos no están integrados con las escalas. Herramientas como la activación del Código Ictus o el manejo de la hipertensión en el ictus agudo requieren combinar varias escalas con criterios decisionales que el profesional debe construir mentalmente. Ninguna app del mercado encadena ese flujo en un árbol de decisión guiado.

A esto se suman dos limitaciones de alcance: la mayoría son monolingües (inglés), lo que supone una barrera de adopción en el entorno asistencial español, y casi todas son aplicaciones móvil-first sin interfaz web adaptada al uso en una estación de trabajo de urgencias o consulta. Neuro Toolkit, además, solo está disponible en iOS. NeuroScale App es bilingüe (español e inglés) desde la primera versión y compila también para web, con una navegación que se adapta al tamaño de pantalla (NavigationBar en móvil y NavigationRail en tablet o escritorio).

## Público objetivo

La aplicación está dirigida a dos perfiles principales:

- **Profesionales de la salud en activo**: médicos de urgencias, neurólogos, médicos de atención primaria y enfermería de urgencias que aplican estas escalas de forma rutinaria y necesitan registrar la evolución de sus pacientes de forma ágil y segura.
- **Estudiantes de Medicina y Ciencias de la Salud**: alumnos que deben conocer y practicar la aplicación de estas escalas durante su formación clínica, para quienes el modo tutorial (explicación clínica por ítem) resulta especialmente útil.

## Conclusión de la justificación

El proyecto no pretende competir con las grandes plataformas de referencia médica generalistas, como MDCalc o Medscape, en amplitud de catálogo. Propone un valor diferencial distinto: ofrecer trazabilidad clínica anonimizada por paciente sobre las escalas neurológicas más utilizadas en España, y combinarla con los algoritmos de decisión que guían las actuaciones de urgencia más críticas. Es un nicho concreto, pero un nicho que las soluciones actuales no cubren.

## Referencias de este apartado

- Ministerio de Sanidad. (2024). *Estrategia en Ictus del Sistema Nacional de Salud. Actualización 2024*. Recuperado de https://www.sanidad.gob.es/areas/calidadAsistencial/estrategias/ictus/docs/Estrategia_en_Ictus_del_SNS._Actualizacion_2024_accesible.pdf
- OSTEBA / GuíaSalud. (2025). *Guía de Práctica Clínica sobre el Manejo del Ictus en Atención Primaria*. Recuperado de https://portal.guiasalud.es/wp-content/uploads/2025/02/gpc_635_manejo_ictus_ap_osteba_compl.pdf
- Sociedad Española de Neurología. (s.f.). *Guías y Protocolos*. Recuperado de https://www.sen.es/profesionales/guias-y-protocolos/110-guias-y-protocolos
- Elsevier Radiología. (2022). *Actualización del Código Ictus en urgencias*. Recuperado de https://www.elsevier.es/es-revista-radiologia-119-articulo-actualizacion-del-codigo-ictus-urgencias-S0033833822002508
- Storrow, A. B., et al. (2019). MDCalc Medical Calculator App Review. *JAMIA Open*, 2(3). Recuperado de https://pmc.ncbi.nlm.nih.gov/articles/PMC6737202/
- Sacks, D., et al. (2018). Mobile medical applications in neurology. *Journal of the Neurological Sciences*, 390. Recuperado de https://pmc.ncbi.nlm.nih.gov/articles/PMC5765940/
