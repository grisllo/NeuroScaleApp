# Trabajos futuros

NeuroScale App ha llegado a la versión 1.0.0 como proyecto académico funcional y desplegado, pero su recorrido natural no se agota ahí. Las líneas que se describen a continuación apuntan a cómo podría evolucionar la aplicación si se quisiera convertir en un producto clínico real, con usuarios más allá del entorno del TFC.

## Distribución en tiendas de aplicaciones

En su estado actual, la versión 1.0.0 se distribuye en Android mediante un APK firmado de descarga directa. El paso natural sería publicarla en Google Play Store y, en paralelo, preparar la versión de iOS para la App Store. La base de código ya contempla iOS como plataforma activa en el proyecto Flutter, pero compilar el `.ipa` requiere un Mac con Xcode y una cuenta de desarrollador de Apple (99 $ anuales). La publicación en Play Store, por su parte, exige un registro único de 25 $ y pasar por el proceso de revisión de política de privacidad.

## Certificación como producto sanitario (MDR 2017/745)

En su estado actual, NeuroScale App es una herramienta de **apoyo a la decisión clínica** y no un dispositivo médico certificado. Si se pretendiera su uso en entornos hospitalarios regulados o su distribución comercial como software de soporte diagnóstico, sería necesario iniciar el proceso de certificación bajo el **Reglamento (UE) 2017/745** (MDR) en la categoría de Software as a Medical Device (SaMD). Este proceso implica:

- Clasificación del software según el Anexo VIII del MDR (clase I, IIa o IIb según el riesgo).
- Establecimiento de un Sistema de Gestión de la Calidad (SGC) conforme a la norma **ISO 13485:2016**.
- Elaboración del expediente técnico con evidencia clínica y análisis de riesgo según **ISO 14971:2019**.
- Intervención de un organismo notificado (para clases IIa y superiores).

La arquitectura actual facilita este proceso: las calculadoras son funciones puras con tests exhaustivos que proporcionan evidencia de corrección clínica; los algoritmos están modelados como grafos inmutables trazables; la ausencia de PII simplifica la evaluación de privacidad.

## Integración con Historia Clínica Electrónica (HCE)

La aplicación opera actualmente de forma independiente. Una línea de evolución relevante sería la integración con los sistemas de HCE utilizados en el sistema sanitario español (Selene, Orion Clinical, SAP IS-H) mediante el estándar **HL7 FHIR R4**, que define recursos estandarizados para observaciones clínicas (`Observation`), pacientes (`Patient`) y diagnósticos. Esta integración permitiría:

- Importar datos del paciente desde el HCE, eliminando la necesidad de crear aliases manualmente.
- Exportar las evaluaciones como recursos FHIR `Observation` vinculados al episodio clínico.
- Auditabilidad completa del proceso de evaluación dentro del historial del paciente.

## Nuevas escalas y algoritmos

La arquitectura basada en `ScaleDefinition` permite añadir nuevas escalas con un coste mínimo. Escalas candidatas identificadas por su uso en neurología y neurorrehabilitación:

| Escala | Ámbito | Rango |
|---|---|---|
| **MoCA** (Montreal Cognitive Assessment) | Cribado de deterioro cognitivo | 0–30 |
| **MMSE** (Mini-Mental State Examination) | Evaluación cognitiva global | 0–30 |
| **Berg Balance Scale** | Equilibrio en rehabilitación | 0–56 |
| **Fugl-Meyer Assessment** | Recuperación motora post-ictus | 0–226 |
| **FAC** (Functional Ambulation Categories) | Capacidad de deambulación | 0–5 |
| **CPSS** (Cincinnati Prehospital Stroke Scale) | Cribado prehospitalario de ictus | 0–3 |

En cuanto a algoritmos, se podría ampliar el módulo con el **protocolo de manejo del ictus hemorrágico** (hemorragia intracerebral espontánea: indicación de cirugía, escala ICH Score) y los **criterios de ingreso en UCI neurológica** tras HSA.

## Exportación de informes clínicos

Actualmente los resultados solo son visibles en la aplicación. Una mejora de alto valor para el usuario sería la generación de **informes PDF** con el resumen de la evaluación (escala, puntuación, interpretación, fecha, alias del paciente y desglose por ítem), exportables o enviables por correo desde la pantalla de resultado. En Flutter, esto es viable mediante el paquete `pdf` + `printing`.

## Validación con usuarios reales

Una de las carencias más claras del proyecto, vista en perspectiva, es la ausencia de un estudio formal de usabilidad con profesionales sanitarios. Un trabajo futuro de evidente valor sería organizar un piloto con un grupo pequeño de médicos y estudiantes de medicina y medir, al menos, el tiempo hasta el primer uso correcto, la tasa de errores en la aplicación de la NIHSS (la más compleja del conjunto), la satisfacción percibida con el cuestionario SUS y la identificación de flujos problemáticos a partir de los registros de sesión. Los resultados de ese piloto serían la base de una iteración de UX orientada a reducir la carga cognitiva en situaciones de urgencia, que es donde la aplicación pretende ser más útil.

## Mejoras técnicas aplazadas

| Mejora | Motivación | Condición de activación |
|---|---|---|
| **Certificate pinning** para Supabase | Evitar ataques MITM en redes hospitalarias no confiables | Certificación clínica o requisito de seguridad del cliente |
| **Leaked Password Protection** | Bloquear contraseñas comprometidas en brechas conocidas | Migración a plan Supabase Pro |
| **Cobertura de tests al 60–80 %** | Actualmente 20,7 % global (dominio al 100 %; UI sin tests) | Si se introducen flujos UI complejos con regresiones frecuentes |
| **Internacionalización adicional** (PT, FR) | Ampliar el mercado potencial a Portugal y Francia | Cuando haya un caso de uso real |
| **Modo multi-institución** | Permitir equipos de profesionales con pacientes compartidos | Si se plantea un modelo de negocio B2B |
| **Notificaciones push** | Recordatorios de reevaluación periódica de pacientes crónicos | Cuando haya usuarios activos con seguimiento longitudinal |
