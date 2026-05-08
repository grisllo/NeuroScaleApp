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
      labelKey: 'abcd2AgeLabel',
      helpKey: 'abcd2AgeHelp',
      min: 0,
      max: 1,
      options: [(0, 'abcd2AgeOpt0'), (1, 'abcd2AgeOpt1')],
    ),
    ScaleItem(
      key: abcd2KeyBp,
      labelKey: 'abcd2BpLabel',
      helpKey: 'abcd2BpHelp',
      min: 0,
      max: 1,
      options: [(0, 'abcd2BpOpt0'), (1, 'abcd2BpOpt1')],
    ),
    ScaleItem(
      key: abcd2KeyClinical,
      labelKey: 'abcd2ClinicalLabel',
      helpKey: 'abcd2ClinicalHelp',
      min: 0,
      max: 2,
      options: [
        (0, 'abcd2ClinicalOpt0'),
        (1, 'abcd2ClinicalOpt1'),
        (2, 'abcd2ClinicalOpt2'),
      ],
    ),
    ScaleItem(
      key: abcd2KeyDuration,
      labelKey: 'abcd2DurationLabel',
      helpKey: 'abcd2DurationHelp',
      min: 0,
      max: 2,
      options: [
        (0, 'abcd2DurationOpt0'),
        (1, 'abcd2DurationOpt1'),
        (2, 'abcd2DurationOpt2'),
      ],
    ),
    ScaleItem(
      key: abcd2KeyDiabetes,
      labelKey: 'abcd2DiabetesLabel',
      helpKey: 'abcd2DiabetesHelp',
      min: 0,
      max: 1,
      options: [(0, 'abcd2DiabetesOpt0'), (1, 'abcd2DiabetesOpt1')],
    ),
  ];

  @override
  ScaleResult calculate(Map<String, int> answers) => calculateAbcd2(answers);
}
