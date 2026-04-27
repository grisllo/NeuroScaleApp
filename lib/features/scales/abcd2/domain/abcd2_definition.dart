import '../../shared/domain/entities/scale_definition.dart';
import '../../shared/domain/entities/scale_item.dart';
import '../../shared/domain/entities/scale_result.dart';
import 'abcd2_calculator.dart';

class Abcd2Definition extends ScaleDefinition {
  const Abcd2Definition();

  @override
  String get key => 'abcd2';

  @override
  String get displayName => 'ABCD2';

  @override
  int get version => 1;

  @override
  List<ScaleItem> get items => const [
        ScaleItem(
          key: abcd2KeyAge,
          label: 'Edad',
          min: 0,
          max: 1,
          options: [
            (0, 'Menor de 60 años'),
            (1, '60 años o más'),
          ],
        ),
        ScaleItem(
          key: abcd2KeyBp,
          label: 'Tensión arterial',
          min: 0,
          max: 1,
          options: [
            (0, 'TAS < 140 mmHg y TAD < 90 mmHg'),
            (1, 'TAS ≥ 140 mmHg o TAD ≥ 90 mmHg'),
          ],
        ),
        ScaleItem(
          key: abcd2KeyClinical,
          label: 'Características clínicas del AIT',
          min: 0,
          max: 2,
          options: [
            (0, 'Otros síntomas'),
            (1, 'Disartria sin debilidad unilateral'),
            (2, 'Debilidad unilateral (hemiparesia)'),
          ],
        ),
        ScaleItem(
          key: abcd2KeyDuration,
          label: 'Duración de los síntomas',
          min: 0,
          max: 2,
          options: [
            (0, 'Menos de 10 minutos'),
            (1, 'Entre 10 y 59 minutos'),
            (2, '60 minutos o más'),
          ],
        ),
        ScaleItem(
          key: abcd2KeyDiabetes,
          label: 'Diabetes mellitus',
          min: 0,
          max: 1,
          options: [
            (0, 'No'),
            (1, 'Sí'),
          ],
        ),
      ];

  @override
  ScaleResult calculate(Map<String, int> answers) => calculateAbcd2(answers);
}
