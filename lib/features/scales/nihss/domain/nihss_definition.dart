import '../../shared/domain/entities/scale_definition.dart';
import '../../shared/domain/entities/scale_item.dart';
import '../../shared/domain/entities/scale_result.dart';
import 'nihss_calculator.dart';

class NihssDefinition extends ScaleDefinition {
  const NihssDefinition();

  @override
  String get key => 'nihss';

  @override
  String get displayName => 'NIHSS';

  @override
  int get version => 1;

  @override
  List<ScaleItem> get items => const [
        ScaleItem(
          key: nihssKey1aLoc,
          label: '1a. Nivel de consciencia (LOC)',
          min: 0,
          max: 3,
          options: [
            (0, 'Alerta'),
            (1, 'No alerta, despertable con estímulos menores'),
            (2, 'No alerta, requiere estímulos repetidos o dolorosos'),
            (3, 'Coma; respuestas reflejas o sin respuesta'),
          ],
        ),
        ScaleItem(
          key: nihssKey1bLocQuestions,
          label: '1b. Preguntas LOC (mes y edad)',
          min: 0,
          max: 2,
          options: [
            (0, 'Ambas correctas'),
            (1, 'Una correcta'),
            (2, 'Ninguna correcta'),
          ],
        ),
        ScaleItem(
          key: nihssKey1cLocCommands,
          label: '1c. Órdenes LOC (cerrar ojos, abrir/cerrar mano)',
          min: 0,
          max: 2,
          options: [
            (0, 'Ambas órdenes correctas'),
            (1, 'Una orden correcta'),
            (2, 'Ninguna orden correcta'),
          ],
        ),
        ScaleItem(
          key: nihssKey2Gaze,
          label: '2. Mirada conjugada',
          min: 0,
          max: 2,
          options: [
            (0, 'Normal'),
            (1, 'Parálisis parcial de la mirada'),
            (2, 'Desviación forzada o paresia total no superable'),
          ],
        ),
        ScaleItem(
          key: nihssKey3Visual,
          label: '3. Campos visuales',
          min: 0,
          max: 3,
          options: [
            (0, 'Normales'),
            (1, 'Hemianopsia parcial'),
            (2, 'Hemianopsia completa'),
            (3, 'Hemianopsia bilateral / ceguera cortical'),
          ],
        ),
        ScaleItem(
          key: nihssKey4Facial,
          label: '4. Parálisis facial',
          min: 0,
          max: 3,
          options: [
            (0, 'Movimientos normales y simétricos'),
            (1, 'Parálisis menor (asimetría al sonreír)'),
            (2, 'Parálisis parcial (cara inferior)'),
            (3, 'Parálisis completa (uni o bilateral)'),
          ],
        ),
        ScaleItem(
          key: nihssKey5aMotorArmL,
          label: '5a. Motor brazo izquierdo',
          min: 0,
          max: 4,
          untestableValue: nihssUntestable,
          options: [
            (0, 'Mantiene 90°/45° durante 10 s sin caer'),
            (1, 'Cae antes de 10 s pero no choca con la cama'),
            (2, 'Algún esfuerzo contra la gravedad (cae a la cama)'),
            (3, 'Sin esfuerzo contra la gravedad'),
            (4, 'Sin movimiento'),
            (nihssUntestable, 'No evaluable (amputación o fusión articular)'),
          ],
        ),
        ScaleItem(
          key: nihssKey5bMotorArmR,
          label: '5b. Motor brazo derecho',
          min: 0,
          max: 4,
          untestableValue: nihssUntestable,
          options: [
            (0, 'Mantiene 90°/45° durante 10 s sin caer'),
            (1, 'Cae antes de 10 s pero no choca con la cama'),
            (2, 'Algún esfuerzo contra la gravedad (cae a la cama)'),
            (3, 'Sin esfuerzo contra la gravedad'),
            (4, 'Sin movimiento'),
            (nihssUntestable, 'No evaluable (amputación o fusión articular)'),
          ],
        ),
        ScaleItem(
          key: nihssKey6aMotorLegL,
          label: '6a. Motor pierna izquierda',
          min: 0,
          max: 4,
          untestableValue: nihssUntestable,
          options: [
            (0, 'Mantiene 30° durante 5 s sin caer'),
            (1, 'Cae antes de 5 s pero no choca con la cama'),
            (2, 'Algún esfuerzo contra la gravedad'),
            (3, 'Sin esfuerzo contra la gravedad'),
            (4, 'Sin movimiento'),
            (nihssUntestable, 'No evaluable (amputación o fusión articular)'),
          ],
        ),
        ScaleItem(
          key: nihssKey6bMotorLegR,
          label: '6b. Motor pierna derecha',
          min: 0,
          max: 4,
          untestableValue: nihssUntestable,
          options: [
            (0, 'Mantiene 30° durante 5 s sin caer'),
            (1, 'Cae antes de 5 s pero no choca con la cama'),
            (2, 'Algún esfuerzo contra la gravedad'),
            (3, 'Sin esfuerzo contra la gravedad'),
            (4, 'Sin movimiento'),
            (nihssUntestable, 'No evaluable (amputación o fusión articular)'),
          ],
        ),
        ScaleItem(
          key: nihssKey7Ataxia,
          label: '7. Ataxia de extremidades',
          min: 0,
          max: 2,
          untestableValue: nihssUntestable,
          options: [
            (0, 'Ausente'),
            (1, 'Presente en una extremidad'),
            (2, 'Presente en dos extremidades'),
            (nihssUntestable, 'No evaluable (amputación o fusión articular)'),
          ],
        ),
        ScaleItem(
          key: nihssKey8Sensory,
          label: '8. Sensibilidad',
          min: 0,
          max: 2,
          options: [
            (0, 'Normal'),
            (1, 'Pérdida sensitiva leve a moderada'),
            (2, 'Pérdida sensitiva grave o total'),
          ],
        ),
        ScaleItem(
          key: nihssKey9Language,
          label: '9. Mejor lenguaje',
          min: 0,
          max: 3,
          options: [
            (0, 'Sin afasia'),
            (1, 'Afasia leve a moderada'),
            (2, 'Afasia grave'),
            (3, 'Mudo, afasia global, sin habla útil ni comprensión'),
          ],
        ),
        ScaleItem(
          key: nihssKey10Dysarthria,
          label: '10. Disartria',
          min: 0,
          max: 2,
          untestableValue: nihssUntestable,
          options: [
            (0, 'Articulación normal'),
            (1, 'Disartria leve a moderada'),
            (2, 'Disartria grave (palabras casi ininteligibles)'),
            (nihssUntestable, 'No evaluable (intubado u otra barrera física)'),
          ],
        ),
        ScaleItem(
          key: nihssKey11Neglect,
          label: '11. Extinción e inatención (negligencia)',
          min: 0,
          max: 2,
          options: [
            (0, 'Normal'),
            (
              1,
              'Inatención a una modalidad (visual, táctil, auditiva o espacial)'
            ),
            (2, 'Hemi-inatención profunda a más de una modalidad'),
          ],
        ),
      ];

  @override
  ScaleResult calculate(Map<String, int> answers) => calculateNihss(answers);
}
