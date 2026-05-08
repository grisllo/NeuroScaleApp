import '../../shared/domain/entities/scale_definition.dart';
import '../../shared/domain/entities/scale_item.dart';
import '../../shared/domain/entities/scale_result.dart';
import 'gcs_calculator.dart';

class GcsDefinition extends ScaleDefinition {
  const GcsDefinition();

  @override
  String get key => 'gcs';

  @override
  String get displayName => 'Glasgow Coma Scale';

  @override
  int get version => 1;

  @override
  List<ScaleItem> get items => const [
    ScaleItem(
      key: gcsKeyEye,
      labelKey: 'gcsEyeLabel',
      helpKey: 'gcsEyeHelp',
      min: 1,
      max: 4,
      options: [
        (1, 'gcsEyeOpt1'),
        (2, 'gcsEyeOpt2'),
        (3, 'gcsEyeOpt3'),
        (4, 'gcsEyeOpt4'),
      ],
    ),
    ScaleItem(
      key: gcsKeyVerbal,
      labelKey: 'gcsVerbalLabel',
      helpKey: 'gcsVerbalHelp',
      min: 1,
      max: 5,
      options: [
        (1, 'gcsVerbalOpt1'),
        (2, 'gcsVerbalOpt2'),
        (3, 'gcsVerbalOpt3'),
        (4, 'gcsVerbalOpt4'),
        (5, 'gcsVerbalOpt5'),
      ],
    ),
    ScaleItem(
      key: gcsKeyMotor,
      labelKey: 'gcsMotorLabel',
      helpKey: 'gcsMotorHelp',
      min: 1,
      max: 6,
      options: [
        (1, 'gcsMotorOpt1'),
        (2, 'gcsMotorOpt2'),
        (3, 'gcsMotorOpt3'),
        (4, 'gcsMotorOpt4'),
        (5, 'gcsMotorOpt5'),
        (6, 'gcsMotorOpt6'),
      ],
    ),
  ];

  @override
  ScaleResult calculate(Map<String, int> answers) => calculateGcs(answers);
}
