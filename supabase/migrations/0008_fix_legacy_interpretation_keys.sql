-- Migración 0008 — Normalizar interpretation keys legacy (2026-05-11)
-- Evaluaciones creadas antes de Fase 4.3 (2026-04-30) tenían el texto
-- español literal en el campo interpretation en lugar de la clave ARB.
-- Este UPDATE reemplaza los valores conocidos por sus claves canónicas.

-- ABCD2
update evaluations set interpretation = 'abcd2RiskLow'
  where scale_type = 'abcd2' and interpretation = 'Riesgo bajo (~1.0%)';

update evaluations set interpretation = 'abcd2RiskModerate'
  where scale_type = 'abcd2' and interpretation = 'Riesgo moderado (~4.1%)';

update evaluations set interpretation = 'abcd2RiskHigh'
  where scale_type = 'abcd2' and interpretation = 'Riesgo alto (~8.1%)';

-- GCS (severity keys)
update evaluations set interpretation = 'severityMild'
  where scale_type = 'gcs' and interpretation in ('Leve', 'leve');

update evaluations set interpretation = 'severityModerate'
  where scale_type = 'gcs' and interpretation in ('Moderado', 'moderado');

update evaluations set interpretation = 'severitySevere'
  where scale_type = 'gcs'
    and interpretation in ('Grave', 'grave', 'Severo', 'severo');

-- NIHSS
update evaluations set interpretation = 'nihssInterp0'
  where scale_type = 'nihss' and interpretation in ('Sin déficit', 'Sin deficit');

update evaluations set interpretation = 'nihssInterpMinor'
  where scale_type = 'nihss' and interpretation in ('Leve', 'leve', 'Menor');

update evaluations set interpretation = 'nihssInterpModerate'
  where scale_type = 'nihss' and interpretation in ('Moderado', 'moderado');

update evaluations set interpretation = 'nihssInterpModerateSevere'
  where scale_type = 'nihss'
    and interpretation in ('Moderado-Grave', 'Moderado-Severo');

update evaluations set interpretation = 'nihssInterpSevere'
  where scale_type = 'nihss' and interpretation in ('Grave', 'grave', 'Severo');

-- Barthel
update evaluations set interpretation = 'barthelInterpIndependent'
  where scale_type = 'barthel'
    and interpretation in ('Independiente', 'independiente');

update evaluations set interpretation = 'barthelInterpMild'
  where scale_type = 'barthel'
    and interpretation in ('Dependencia leve', 'Leve');

update evaluations set interpretation = 'barthelInterpModerate'
  where scale_type = 'barthel'
    and interpretation in ('Dependencia moderada', 'Moderado', 'Moderada');

update evaluations set interpretation = 'barthelInterpSevere'
  where scale_type = 'barthel'
    and interpretation in ('Dependencia severa', 'Grave', 'Severa');

update evaluations set interpretation = 'barthelInterpTotal'
  where scale_type = 'barthel'
    and interpretation in ('Dependencia total', 'Total');

-- mRS (Rankin) — los levels se almacenan como rankinInterp0..6
-- Si se guardaron como número o texto libre, normalizar:
update evaluations set interpretation = 'rankinInterp0'
  where scale_type = 'rankin' and interpretation = '0';

update evaluations set interpretation = 'rankinInterp1'
  where scale_type = 'rankin' and interpretation = '1';

update evaluations set interpretation = 'rankinInterp2'
  where scale_type = 'rankin' and interpretation = '2';

update evaluations set interpretation = 'rankinInterp3'
  where scale_type = 'rankin' and interpretation = '3';

update evaluations set interpretation = 'rankinInterp4'
  where scale_type = 'rankin' and interpretation = '4';

update evaluations set interpretation = 'rankinInterp5'
  where scale_type = 'rankin' and interpretation = '5';

update evaluations set interpretation = 'rankinInterp6'
  where scale_type = 'rankin' and interpretation = '6';
