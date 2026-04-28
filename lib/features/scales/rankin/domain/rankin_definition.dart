import '../../shared/domain/entities/scale_definition.dart';
import '../../shared/domain/entities/scale_item.dart';
import '../../shared/domain/entities/scale_result.dart';
import 'rankin_calculator.dart';

class RankinDefinition extends ScaleDefinition {
  const RankinDefinition();

  @override
  String get key => 'rankin';

  @override
  String get displayName => 'mRS (Modified Rankin Scale)';

  @override
  int get version => 1;

  @override
  List<ScaleItem> get items => const [
        ScaleItem(
          key: rankinKeyScore,
          label: 'Grado de discapacidad',
          min: 0,
          max: 6,
          options: [
            (0, 'Sin síntomas'),
            (
              1,
              'Sin discapacidad significativa — realiza todas las actividades habituales'
            ),
            (
              2,
              'Discapacidad leve — incapaz de realizar algunas actividades previas, pero independiente'
            ),
            (
              3,
              'Discapacidad moderada — requiere ayuda, pero camina sin asistencia'
            ),
            (
              4,
              'Discapacidad moderadamente grave — incapaz de caminar y de atender necesidades sin ayuda'
            ),
            (
              5,
              'Discapacidad grave — postrado en cama, incontinente, requiere cuidados de enfermería constantes'
            ),
            (6, 'Fallecido'),
          ],
        ),
      ];

  @override
  ScaleResult calculate(Map<String, int> answers) => calculateRankin(answers);
}
