# Referencias

Las referencias se presentan en orden alfabético por apellido del primer autor dentro de cada bloque temático, siguiendo el formato APA 7.ª edición. Las URLs se verificaron el 15 de mayo de 2026.

Cada bloque empieza con un párrafo breve que explica cómo se aplicaron esas fuentes en el proyecto: qué decisión concreta de la implementación (umbrales de severidad, criterios clínicos, pesos por ítem, etc.) se sustenta en cada referencia. La intención es que el lector pueda trazar, desde una línea de código, hasta la fuente médica que la justifica.

---

## Escalas neurológicas

Las cinco escalas implementadas en la aplicación se construyeron a partir de sus publicaciones originales para el cálculo de la puntuación y de fuentes secundarias para la clasificación de gravedad por tramos. Para el Índice de Barthel se utilizó la versión validada en español por Baztán, que es la que se aplica de forma estándar en el sistema sanitario español. Para el NIHSS se siguió el procedimiento publicado por el NINDS para garantizar la reproducibilidad de la puntuación, incluido el tratamiento del valor `UN` (no valorable) como 9. La distinción entre la escala de Rankin original y su versión modificada (mRS, la que se aplica actualmente) se reflejó en el dominio incluyendo el grado 6 (fallecido).

Baztán, J. J., Pérez del Molino, J., Alarcón, T., San Cristóbal, E., Izquierdo, G., & Manzarbeitia, I. (1993). Índice de Barthel: instrumento válido para la valoración funcional de pacientes con enfermedad cerebrovascular. *Revista Española de Geriatría y Gerontología, 28*(1), 32–40.

Brott, T., Adams, H. P., Olinger, C. P., Marler, J. R., Barsan, W. G., Biller, J., Spilker, J., Holleran, R., Eberle, R., Hertzberg, V., Rorick, M., Moomaw, C. J., & Walker, M. (1989). Measurements of acute cerebral infarction: A clinical examination scale. *Stroke, 20*(7), 864–870. https://doi.org/10.1161/01.STR.20.7.864

Cid-Ruzafa, J., & Damián-Moreno, J. (1997). Valoración de la discapacidad física: el índice de Barthel. *Revista Española de Salud Pública, 71*(2), 127–137. https://doi.org/10.1590/S1135-57271997000200004

Johnston, S. C., Rothwell, P. M., Nguyen-Huynh, M. N., Giles, M. F., Elkins, J. S., Bernstein, A. L., & Sidney, S. (2007). Validation and refinement of scores to predict very early stroke risk after transient ischaemic attack. *The Lancet, 369*(9558), 283–292. https://doi.org/10.1016/S0140-6736(07)60150-0

Lyden, P. (2017). Using the National Institutes of Health Stroke Scale: A cautionary tale. *Stroke, 48*(2), 513–519. https://doi.org/10.1161/STROKEAHA.116.015434

Lyden, P., Brott, T., Tilley, B., Welch, K. M. A., Mascha, E. J., Levine, S., Haley, E. C., Grotta, J., Marler, J., & the NINDS tPA Stroke Study Group. (1994). Improved reliability of the NIH Stroke Scale using video training. *Stroke, 25*(11), 2220–2226. https://doi.org/10.1161/01.STR.25.11.2220

Mahoney, F. I., & Barthel, D. W. (1965). Functional evaluation: The Barthel Index. *Maryland State Medical Journal, 14*, 61–65.

Rankin, J. (1957). Cerebral vascular accidents in patients over the age of 60: II. Prognosis. *Scottish Medical Journal, 2*(5), 200–215. https://doi.org/10.1177/003693305700200504

Rothwell, P. M., Giles, M. F., Flossmann, E., Lovelock, C. E., Redgrave, J. N. E., Warlow, C. P., & Mehta, Z. (2005). A simple score (ABCD) to identify individuals at high early risk of stroke after transient ischaemic attack. *The Lancet, 366*(9479), 29–36. https://doi.org/10.1016/S0140-6736(05)66702-5

Teasdale, G., & Jennett, B. (1974). Assessment of coma and impaired consciousness: A practical scale. *The Lancet, 304*(7872), 81–84. https://doi.org/10.1016/S0140-6736(74)91639-0

Teasdale, G., Maas, A., Lecky, F., Manley, G., Stocchetti, N., & Murray, G. (2014). The Glasgow Coma Scale at 40 years: Standing the test of time. *The Lancet Neurology, 13*(8), 844–854. https://doi.org/10.1016/S1474-4422(14)70120-6

Van Swieten, J. C., Koudstaal, P. J., Visser, M. C., Schouten, H. J., & van Gijn, J. (1988). Interobserver agreement for the assessment of handicap in stroke patients. *Stroke, 19*(5), 604–607. https://doi.org/10.1161/01.STR.19.5.604

### Aplicación en el proyecto

| Referencia | Decisión de implementación que sustenta |
|---|---|
| Teasdale & Jennett (1974) | Estructura de la GCS en tres subescalas (O, V, M) y rango 3–15. |
| Teasdale et al. (2014) | Clasificación de gravedad GCS: leve (13–15), moderado (9–12), grave (3–8). |
| Brott et al. (1989) | Estructura de los 11 ítems del NIHSS y rango 0–42. |
| Lyden et al. (1994) | Procedimiento de puntuación NIHSS y valor `UN = 9` para ítems no valorables. |
| Lyden (2017) | Aviso clínico cuando el ítem 1a (nivel de consciencia) indica coma. |
| Mahoney & Barthel (1965) | Estructura original del Índice de Barthel (10 ítems de AVD). |
| Baztán et al. (1993) | **Pesos exactos por ítem** en la calculadora Barthel (versión española en uso). |
| Cid-Ruzafa & Damián-Moreno (1997) | Clasificación Barthel por tramos: dependencia total / grave / moderada / leve / total. |
| Rankin (1957) | Origen histórico de la escala (referencia académica). |
| Van Swieten et al. (1988) | Versión mRS de 0 a 6 (incluye grado 6, fallecido) implementada en el dominio. |
| Rothwell et al. (2005) | Escala ABCD original (precede al ABCD²); contexto histórico. |
| Johnston et al. (2007) | Pesos por ítem del ABCD² (edad, PA, clínica, duración, diabetes) y umbrales de riesgo. |

---

## Algoritmos clínicos

Los tres algoritmos de decisión (Código Ictus, HTA en ictus agudo y HSA Hunt-Hess/Fisher) se construyeron a partir de las guías de práctica clínica vigentes en Europa y Estados Unidos. Las publicaciones originales de Hunt-Hess y Fisher se usaron para fijar los grados y la estructura de las preguntas; las guías ESO y AHA/ASA marcaron los criterios de inclusión y exclusión y los umbrales de presión arterial que aparecen en cada rama del árbol. La evidencia primaria del tratamiento con tPA (ensayo NINDS de 1995 y ECASS III de 2008) justifica la existencia misma del Código Ictus en la ventana terapéutica de 4,5 horas.

Berge, E., Whiteley, W., Audebert, H., De Marchis, G. M., Fonseca, A. C., Padiglioni, C., & Schwabedissen, H. M. (2021). European Stroke Organisation (ESO) guidelines on intravenous thrombolysis for acute ischaemic stroke. *European Stroke Journal, 6*(1), I–LXII. https://doi.org/10.1177/2396987321989865

Fisher, C. M., Kistler, J. P., & Davis, J. M. (1980). Relation of cerebral vasospasm to subarachnoid hemorrhage visualized by computerized tomographic scanning. *Neurosurgery, 6*(1), 1–9. https://doi.org/10.1227/00006123-198001000-00001

Frontera, J. A., Claassen, J., Schmidt, J. M., Wartenberg, K. E., Temes, R., Connolly, E. S., Macdonald, R. L., & Mayer, S. A. (2006). Prediction of symptomatic vasospasm after subarachnoid hemorrhage: The modified Fisher grading scale. *Neurosurgery, 58*(1), 21–27. https://doi.org/10.1227/01.NEU.0000192712.54681.DA

Hacke, W., Kaste, M., Bluhmki, E., Brozman, M., Dávalos, A., Guidetti, D., Larrue, V., Lees, K. R., Medeghri, Z., Machnig, T., Schneider, D., von Kummer, R., Wahlgren, N., & Toni, D. (2008). Thrombolysis with alteplase 3 to 4.5 hours after acute ischemic stroke. *New England Journal of Medicine, 359*(13), 1317–1329. https://doi.org/10.1056/NEJMoa0804656

Hemphill, J. C., Greenberg, S. M., Anderson, C. S., Becker, K., Bendok, B. R., Cushman, M., Fung, G. L., Goldstein, J. N., Macdonald, R. L., Mitchell, P. H., Scott, P. A., Selim, M. H., & Woo, D. (2015). Guidelines for the management of spontaneous intracerebral hemorrhage: A guideline for healthcare professionals from the American Heart Association/American Stroke Association. *Stroke, 46*(7), 2032–2060. https://doi.org/10.1161/STR.0000000000000069

Hunt, W. E., & Hess, R. M. (1968). Surgical risk as related to time of intervention in the repair of intracranial aneurysms. *Journal of Neurosurgery, 28*(1), 14–20. https://doi.org/10.3171/jns.1968.28.1.0014

The National Institute of Neurological Disorders and Stroke rt-PA Stroke Study Group. (1995). Tissue plasminogen activator for acute ischemic stroke. *New England Journal of Medicine, 333*(24), 1581–1587. https://doi.org/10.1056/NEJM199512143332401

Powers, W. J., Rabinstein, A. A., Ackerson, T., Adeoye, O. M., Bambakidis, N. C., Becker, K., Biller, J., Brown, M., Demaerschalk, B. M., Hoh, B., Jauch, E. C., Kidwell, C. S., Leslie-Mazwi, T. M., Ovbiagele, B., Scott, P. A., Sheth, K. N., Southerland, A. M., Summers, D. V., & Tirschwell, D. L. (2019). Guidelines for the early management of patients with acute ischemic stroke. *Stroke, 50*(12), e344–e418. https://doi.org/10.1161/STR.0000000000000211

Rha, J. H., & Saver, J. L. (2007). The impact of recanalization on ischemic stroke outcome: A meta-analysis. *Stroke, 38*(3), 967–973. https://doi.org/10.1161/01.STR.0000258112.14918.24

Steiner, T., Juvela, S., Unterberg, A., Jung, C., Forsting, M., & Rinkel, G. (2013). European Stroke Organization guidelines for the management of intracranial aneurysms and subarachnoid haemorrhage. *Cerebrovascular Diseases, 35*(2), 93–112. https://doi.org/10.1159/000346087

### Aplicación en el proyecto

| Referencia | Decisión de implementación que sustenta |
|---|---|
| NINDS (1995) | Evidencia clínica primaria de la fibrinólisis con tPA; justifica la existencia del algoritmo Código Ictus. |
| Hacke et al. (2008, ECASS III) | Extensión de la ventana terapéutica del tPA hasta 4,5 horas, que es la condición de entrada en el algoritmo. |
| Berge et al. (2021, ESO) | Criterios de inclusión y exclusión del tPA codificados en los nodos del Código Ictus. |
| Powers et al. (2019, AHA/ASA) | Umbrales de presión arterial en la rama de ictus isquémico del algoritmo HTA. |
| Hemphill et al. (2015, AHA/ASA) | Umbrales de presión arterial en la rama de hemorragia intracerebral del algoritmo HTA. |
| Steiner et al. (2013, ESO) | Manejo de la PA en la rama de hemorragia subaracnoidea del algoritmo HTA y criterios de intervención en HSA. |
| Hunt & Hess (1968) | Cinco grados clínicos (I–V) de la escala Hunt-Hess en el algoritmo HSA. |
| Fisher et al. (1980) | Origen de la clasificación radiológica por TC en HSA. |
| Frontera et al. (2006) | Cuatro grados de la **escala de Fisher modificada** (la versión implementada en el algoritmo HSA). |
| Rha & Saver (2007) | Evidencia complementaria sobre el impacto de la recanalización; contexto del Código Ictus. |

---

## Tecnología: frameworks y librerías

Las referencias siguientes corresponden a la documentación oficial y los repositorios públicos de las tecnologías que conforman el stack del proyecto. Se citan para que el lector pueda contrastar versiones, APIs y guías de uso.

Anthropic. (2024). *Claude Code: Agentic coding in your terminal*. https://claude.ai/code

Flutter Team (Google). (2024). *Flutter documentation*. https://docs.flutter.dev

Flutter Team (Google). (2024). *go_router package documentation*. https://pub.dev/packages/go_router

Flutter Team (Google). (2024). *flutter_riverpod package*. https://pub.dev/packages/flutter_riverpod

Google. (2024). *OSV-Scanner: Vulnerability scanner for open source*. https://github.com/google/osv-scanner

Google Fonts. (2024). *Inter typeface*. https://fonts.google.com/specimen/Inter

Hönig, S. (2024). *Drift: Reactive, typesafe persistence library for Dart & Flutter*. https://drift.simonbinder.eu

Narayan, R. (2024). *fl_chart: A highly customizable Flutter chart library*. https://pub.dev/packages/fl_chart

Riverpod. (2024). *Riverpod documentation*. https://riverpod.dev

Supabase Inc. (2024). *Supabase documentation*. https://supabase.com/docs

---

## Arquitectura y calidad del software

Las decisiones arquitectónicas del proyecto (Clean Architecture en capas, feature-first, repositorios que lanzan `Failure`) se apoyan en los principios divulgados por Robert C. Martin. Las prácticas de refactor y de revisión de código se inspiran en Fowler.

Fowler, M. (2018). *Refactoring: Improving the design of existing code* (2.ª ed.). Addison-Wesley.

Martin, R. C. (2008). *Clean Code: A handbook of agile software craftsmanship*. Prentice Hall.

Martin, R. C. (2018). *Clean Architecture: A craftsman's guide to software structure and design*. Prentice Hall.

---

## Marco legal y privacidad

El tratamiento de los datos clínicos —incluso anonimizados— se diseñó conforme a la normativa europea y española vigente sobre protección de datos. La referencia al Reglamento de Productos Sanitarios (MDR) se incluye porque condiciona los pasos futuros descritos en el apartado de Trabajos futuros.

Jefatura del Estado de España. (2018). *Ley Orgánica 3/2018, de 5 de diciembre, de Protección de Datos Personales y garantía de los derechos digitales (LOPDGDD)*. Boletín Oficial del Estado, 294, 119788–119857. https://www.boe.es/eli/es/lo/2018/12/05/3

Parlamento Europeo y del Consejo de la Unión Europea. (2016). *Reglamento (UE) 2016/679 del Parlamento Europeo y del Consejo, de 27 de abril de 2016, relativo a la protección de las personas físicas en lo que respecta al tratamiento de datos personales y a la libre circulación de estos datos (RGPD)*. Diario Oficial de la Unión Europea, L 119, 1–88. https://eur-lex.europa.eu/legal-content/ES/TXT/?uri=CELEX:32016R0679

Parlamento Europeo y del Consejo de la Unión Europea. (2017). *Reglamento (UE) 2017/745 del Parlamento Europeo y del Consejo, de 5 de abril de 2017, sobre los productos sanitarios (MDR)*. Diario Oficial de la Unión Europea, L 117, 1–175. https://eur-lex.europa.eu/legal-content/ES/TXT/?uri=CELEX:32017R0745

---

## Guías clínicas y protocolos del Sistema Nacional de Salud

Las fuentes oficiales del sistema sanitario español justifican la elección de las cinco escalas implementadas y la prioridad clínica del algoritmo Código Ictus. La actualización 2024 de la Estrategia en Ictus del SNS fija la NIHSS como herramienta obligatoria en la valoración del ictus agudo.

Elsevier Radiología. (2022). *Actualización del Código Ictus en urgencias*. https://www.elsevier.es/es-revista-radiologia-119-articulo-actualizacion-del-codigo-ictus-urgencias-S0033833822002508

Ministerio de Sanidad. (2024). *Estrategia en Ictus del Sistema Nacional de Salud. Actualización 2024*. https://www.sanidad.gob.es/areas/calidadAsistencial/estrategias/ictus/docs/Estrategia_en_Ictus_del_SNS._Actualizacion_2024_accesible.pdf

OSTEBA / GuíaSalud. (2025). *Guía de Práctica Clínica sobre el Manejo del Ictus en Atención Primaria*. https://portal.guiasalud.es/wp-content/uploads/2025/02/gpc_635_manejo_ictus_ap_osteba_compl.pdf

Sociedad Española de Neurología. (s.f.). *Guías y Protocolos*. https://www.sen.es/profesionales/guias-y-protocolos/110-guias-y-protocolos

---

## Estudios sobre aplicaciones móviles médicas

Las dos referencias siguientes se citan en la sección de Justificación para situar a NeuroScale App frente al panorama actual de aplicaciones móviles de cálculo clínico.

Sacks, D., et al. (2018). Mobile medical applications in neurology. *Journal of the Neurological Sciences, 390*. https://pmc.ncbi.nlm.nih.gov/articles/PMC5765940/

Storrow, A. B., et al. (2019). MDCalc Medical Calculator App Review. *JAMIA Open, 2*(3). https://pmc.ncbi.nlm.nih.gov/articles/PMC6737202/

---

## Repositorio y recursos del proyecto

Ramos Repáraz, A. (2026). *NeuroScale App: Repositorio del proyecto* (v1.0.0). GitHub. https://github.com/grisllo/NeuroScaleApp

Ramos Repáraz, A. (2026). *NeuroScale App: Aplicación web en producción*. https://grisllo.github.io/NeuroScaleApp/

Ramos Repáraz, A. (2026). *NeuroScale App: Release v1.0.0*. GitHub Releases. https://github.com/grisllo/NeuroScaleApp/releases/tag/v1.0.0
