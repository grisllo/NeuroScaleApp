# Conclusiones

## Objetivos alcanzados

NeuroScale App ha alcanzado todos los objetivos planteados al inicio del proyecto. La versión 1.0.0, publicada el 13 de mayo de 2026, es una aplicación multiplataforma funcional y desplegada que:

- Implementa las cinco escalas neurológicas más utilizadas en neurología de urgencias española (GCS, NIHSS, mRS, Barthel, ABCD2) con calculadoras clínicamente correctas validadas por **204 tests automatizados**.
- Ofrece tres algoritmos clínicos de decisión guiada (Código Ictus, HTA en ictus agudo, HSA Hunt-Hess/Fisher) que representan situaciones de alta presión en urgencias neurológicas.
- Persiste evaluaciones de forma anonimizada, las vincula a un alias de paciente y las representa gráficamente para monitorizar la evolución clínica a lo largo del tiempo.
- Funciona sin conexión en Android e iOS mediante caché SQLite (Drift), con sincronización automática al recuperar la conectividad.
- Está disponible en producción web en `https://grisllo.github.io/NeuroScaleApp/` con CI/CD automático y distribución Android mediante APK firmado.
- Está completamente localizada en español e inglés (519 entradas ARB) y tiene un diseño responsive que se adapta a móvil, tablet y escritorio.

El resultado demuestra que es posible desarrollar una herramienta clínica de calidad técnica alta —con arquitectura limpia, cobertura de tests, seguridad por diseño y despliegue en producción— en un periodo de 19 días de desarrollo activo y aproximadamente 85 horas de trabajo efectivo.

## Lecciones técnicas aprendidas

**La arquitectura clean vale su coste de entrada.** Establecer las tres capas (domain, data, presentation) desde el primer commit tuvo un coste inicial de diseño, pero la rentabilidad fue inmediata: añadir cada nueva escala siguió exactamente el mismo patrón sin tocar código existente; los tests del dominio se escribieron sin imports de Flutter ni Supabase; y los repositorios pudieron cambiarse de implementación sin que la UI lo notara.

**TDD en dominio clínico no es opcional.** Las calculadoras de GCS, NIHSS, Barthel, mRS y ABCD2 se desarrollaron con tests exhaustivos desde el primer día. En dos ocasiones durante el desarrollo se detectaron errores de umbral (un grado de severidad incorrecto en Barthel y un caso límite en NIHSS con todos los ítems marcados como `UN`) que los tests capturaron antes de llegar a la UI. Sin TDD, esos errores habrían llegado a producción en una herramienta de apoyo clínico.

**La i18n desde el primer día se paga sola.** Iniciar el proyecto con los ficheros ARB y `AppLocalizations` generó una pequeña fricción en el arranque, pero cuando llegó el momento de añadir el inglés completo (519 claves en Fase 4.3) el trabajo fue de traducción pura, sin tocar ningún widget. La experiencia habitual en proyectos que añaden i18n a posteriori es la opuesta: refactorizaciones extensas y regresiones en pantallas no actualizadas.

**El gap entre "funciona" y "listo para producción" es mayor de lo esperado.** Las fases 0 a 4 produjeron una aplicación funcional en ~45 h. Las fases 5 a 14 y los mantenimientos intermedios añadieron otras ~40 h para llegar a v1.0.0: diseño visual coherente, seguridad (RLS auditada, detector de PII, osv-scanner), modo offline, responsive completo, modo tutorial, animaciones, APK firmado, CI/CD y documentación. El 47 % del tiempo total fue polish, seguridad y calidad: invisible para el usuario final, crítico para la producción.

**La gestión del estado con Riverpod escala bien.** A lo largo del proyecto, los proveedores gestionados con Riverpod crecieron de 5 a más de 30 sin que la complejidad del estado se convirtiera en un problema. La separación entre `AsyncNotifier` (estados con operaciones de red) y `Notifier` (estados sincrónicos) resultó clara y predecible. El linter de Riverpod capturó varios proveedores sin `autoDispose` que habrían causado pérdidas de memoria en sesiones largas.

## Reflexión sobre el uso de inteligencia artificial en el desarrollo

NeuroScale App es el primer proyecto personal de este tamaño desarrollado con asistencia intensiva de IA generativa (Claude Code, Anthropic). La experiencia merece una reflexión honesta.

**Lo que aceleró.** La generación de código estructural y repetitivo (DAOs de Drift, políticas RLS de Supabase, tests de frontera para calculadoras, ficheros ARB) fue notablemente más rápida con el agente que escribiéndolo a mano. Tareas que habrían llevado dos o tres horas (como el sistema de tipos de algoritmos con `sealed classes` o la integración de go_router con `StatefulShellRoute`) se completaron en 30–60 minutos.

**Lo que no delegué.** Las decisiones arquitectónicas (feature-first vs. layer-first, `Failure` directo vs. `Either<L,R>`, la estructura de los nodos de algoritmo) fueron tomadas por el desarrollador y propuestas al agente para implementación. La revisión de que el código generado era clínicamente correcto (umbrales de severidad, valores de los ítems del Barthel según Baztán 1993, criterios de inclusión del Código Ictus) también fue responsabilidad exclusiva del desarrollador. El agente genera código que parece correcto; verificar que lo es en un contexto clínico es trabajo humano irreemplazable.

**Lo que aprendí del proceso.** El ciclo de trabajo más productivo fue: proponer el diseño en lenguaje natural → revisar el plan antes de implementar → ejecutar en pequeños pasos con tests intermedios → verificar cada output antes del siguiente paso. Cuando se saltó alguno de estos pasos (especialmente la revisión del plan), el trabajo de corrección posterior consumió más tiempo que el ahorro inicial.

**Conclusión sobre la IA.** El asistente de IA actuó como un **par programador** muy productivo en las capas de implementación, pero con una dependencia crítica de que el desarrollador tenga claridad sobre el diseño y la intención. No substituyó el pensamiento arquitectónico ni el juicio clínico; los amplificó cuando el punto de partida era sólido.

## Valoración personal

Este proyecto representó el primer desarrollo completo de una aplicación multiplataforma con backend gestionado, CI/CD, internacionalización, persistencia offline y despliegue en producción. Las competencias más significativas adquiridas fueron:

- Diseño e implementación de Clean Architecture en un proyecto real de escala media.
- Modelado de datos relacionales con PostgreSQL, RLS y migraciones versionadas.
- Gestión de estado reactivo con Riverpod en una aplicación con múltiples features interdependientes.
- Configuración de pipelines de CI/CD con GitHub Actions para un proyecto Flutter.
- Comprensión práctica de las implicaciones legales y de privacidad (RGPD, LOPDGDD) en una aplicación que maneja datos de salud, aunque sea de forma anonimizada.

El proyecto demuestra que las herramientas disponibles actualmente —Flutter, Supabase, GitHub Pages, IA generativa— permiten a un único desarrollador construir y desplegar software de calidad comparable a equipos pequeños, siempre que la disciplina arquitectónica y el criterio de calidad permanezcan en manos humanas.
