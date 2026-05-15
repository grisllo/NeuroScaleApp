# Conclusiones

## Objetivos alcanzados

NeuroScale App funciona. La versión 1.0.0, publicada el 13 de mayo de 2026, implementa las cinco escalas neurológicas previstas, los tres algoritmos clínicos de decisión, la gestión de pacientes anonimizados, el modo offline, la internacionalización completa en español e inglés y el despliegue automático en web y Android. Se sustenta sobre 204 tests automatizados, cero issues de análisis estático y un pipeline de CI que bloquea cualquier regresión antes de que llegue a producción. Todo eso en 19 días de desarrollo activo y unas 85 horas de trabajo efectivo, lo que para un proyecto de este tamaño y con este nivel de calidad técnica es un resultado del que estoy orgulloso.

Más allá de los números, el resultado es una aplicación ligera y minimalista que hace exactamente lo que promete, sin más. Eso era lo que quería.

## Lecciones técnicas

Una de las cosas más interesantes del proyecto fue enfrentarme a la cantidad de opciones que existen para resolver el mismo problema. ¿Feature-first o layer-first? ¿Riverpod, BLoC o Provider? ¿Repositorios con `Failure` directo o con `Either<L,R>`? Ninguna de esas decisiones tiene una respuesta universalmente correcta. Lo que aprendí es que lo importante no es elegir la opción "buena", sino elegir una que encaje con el proyecto concreto y mantenerla con consistencia. La arquitectura que tiene sentido para NeuroScale App habría sido un sobrediseño en un proyecto más pequeño y un problema en uno más grande.

La inversión en arquitectura limpia desde el primer commit se rentabilizó rápido: a partir de la cuarta escala, añadir una nueva costaba menos de dos horas porque el patrón estaba tan interiorizado que era casi mecánico. El TDD en las calculadoras clínicas no fue opcional: en dos ocasiones los tests capturaron errores reales antes de que llegaran a la interfaz, un umbral mal codificado en Barthel y un caso límite del NIHSS. En una herramienta de apoyo clínico eso no es un bug menor. Y descubrí que el salto entre "funciona en mi máquina" y "está listo para producción" consume casi la mitad del tiempo total —seguridad, accesibilidad, offline, animaciones, firma del APK, documentación—, todo lo que el usuario final no ve pero que define si una app es seria o no.

## El papel de la IA y valoración personal

Durante mis prácticas recientes en empresa estuve integrando agentes de IA para asistir en la programación, y esa experiencia me cambió bastante la perspectiva. Ver cómo se usaba en un contexto profesional real me convenció de que esto no es una moda pasajera: probablemente sea la forma habitual de desarrollar software a partir de ahora. Quería llevarme ese proceso a algo mío, un proyecto lo suficientemente grande como para interiorizar cómo funciona de verdad y no solo en ejercicios pequeños.

Con Claude Code aprendí que la herramienta funciona bien cuando tú sabes qué quieres construir. La generación de código repetitivo, los DAOs de Drift, las políticas RLS, los tests de frontera, los ficheros ARB, todo eso se aceleró mucho. Pero las decisiones de arquitectura las tomé yo, y la validación clínica de cada calculadora contra las fuentes médicas también. La IA produce código que parece correcto; comprobar que lo es en un contexto clínico es trabajo humano. Lo que más me llevé del proceso es una disciplina concreta: proponer el diseño, revisarlo antes de implementar, avanzar en pasos pequeños y verificar cada salida. Cuando saltaba algún paso, las correcciones posteriores costaban más que el tiempo ahorrado.

Me quedo con la sensación de que las herramientas disponibles hoy —Flutter, Supabase, GitHub Pages, IA generativa— permiten que un desarrollador en solitario construya y despliegue algo que hace unos años habría requerido un equipo. Y tengo ganas de seguir ampliando NeuroScale App: hay escalas que añadir, un piloto con profesionales sanitarios que hacer, y la certificación MDR como horizonte si algún día el proyecto sale del ámbito académico.
