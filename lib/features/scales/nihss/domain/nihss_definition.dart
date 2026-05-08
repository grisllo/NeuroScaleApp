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
      labelKey: 'nihss1aLocLabel',
      helpKey: 'nihss1aLocHelp',
      min: 0,
      max: 3,
      options: [
        (0, 'nihss1aLocOpt0'),
        (1, 'nihss1aLocOpt1'),
        (2, 'nihss1aLocOpt2'),
        (3, 'nihss1aLocOpt3'),
      ],
    ),
    ScaleItem(
      key: nihssKey1bLocQuestions,
      labelKey: 'nihss1bLocQuestionsLabel',
      helpKey: 'nihss1bLocQuestionsHelp',
      min: 0,
      max: 2,
      options: [
        (0, 'nihss1bLocQuestionsOpt0'),
        (1, 'nihss1bLocQuestionsOpt1'),
        (2, 'nihss1bLocQuestionsOpt2'),
      ],
    ),
    ScaleItem(
      key: nihssKey1cLocCommands,
      labelKey: 'nihss1cLocCommandsLabel',
      helpKey: 'nihss1cLocCommandsHelp',
      min: 0,
      max: 2,
      options: [
        (0, 'nihss1cLocCommandsOpt0'),
        (1, 'nihss1cLocCommandsOpt1'),
        (2, 'nihss1cLocCommandsOpt2'),
      ],
    ),
    ScaleItem(
      key: nihssKey2Gaze,
      labelKey: 'nihss2GazeLabel',
      helpKey: 'nihss2GazeHelp',
      min: 0,
      max: 2,
      options: [
        (0, 'nihss2GazeOpt0'),
        (1, 'nihss2GazeOpt1'),
        (2, 'nihss2GazeOpt2'),
      ],
    ),
    ScaleItem(
      key: nihssKey3Visual,
      labelKey: 'nihss3VisualLabel',
      helpKey: 'nihss3VisualHelp',
      min: 0,
      max: 3,
      options: [
        (0, 'nihss3VisualOpt0'),
        (1, 'nihss3VisualOpt1'),
        (2, 'nihss3VisualOpt2'),
        (3, 'nihss3VisualOpt3'),
      ],
    ),
    ScaleItem(
      key: nihssKey4Facial,
      labelKey: 'nihss4FacialLabel',
      helpKey: 'nihss4FacialHelp',
      min: 0,
      max: 3,
      options: [
        (0, 'nihss4FacialOpt0'),
        (1, 'nihss4FacialOpt1'),
        (2, 'nihss4FacialOpt2'),
        (3, 'nihss4FacialOpt3'),
      ],
    ),
    ScaleItem(
      key: nihssKey5aMotorArmL,
      labelKey: 'nihss5aMotorArmLLabel',
      helpKey: 'nihss5aMotorArmHelp',
      min: 0,
      max: 4,
      untestableValue: nihssUntestable,
      options: [
        (0, 'nihssMotorArmOpt0'),
        (1, 'nihssMotorArmOpt1'),
        (2, 'nihssMotorArmOpt2'),
        (3, 'nihssMotorArmOpt3'),
        (4, 'nihssMotorArmOpt4'),
        (nihssUntestable, 'nihssMotorArmOpt9'),
      ],
    ),
    ScaleItem(
      key: nihssKey5bMotorArmR,
      labelKey: 'nihss5bMotorArmRLabel',
      helpKey: 'nihss5aMotorArmHelp', // misma descripción, distinto lado
      min: 0,
      max: 4,
      untestableValue: nihssUntestable,
      options: [
        (0, 'nihssMotorArmOpt0'),
        (1, 'nihssMotorArmOpt1'),
        (2, 'nihssMotorArmOpt2'),
        (3, 'nihssMotorArmOpt3'),
        (4, 'nihssMotorArmOpt4'),
        (nihssUntestable, 'nihssMotorArmOpt9'),
      ],
    ),
    ScaleItem(
      key: nihssKey6aMotorLegL,
      labelKey: 'nihss6aMotorLegLLabel',
      helpKey: 'nihss6aMotorLegHelp',
      min: 0,
      max: 4,
      untestableValue: nihssUntestable,
      options: [
        (0, 'nihssMotorLegOpt0'),
        (1, 'nihssMotorLegOpt1'),
        (2, 'nihssMotorLegOpt2'),
        (3, 'nihssMotorLegOpt3'),
        (4, 'nihssMotorLegOpt4'),
        (nihssUntestable, 'nihssMotorLegOpt9'),
      ],
    ),
    ScaleItem(
      key: nihssKey6bMotorLegR,
      labelKey: 'nihss6bMotorLegRLabel',
      helpKey: 'nihss6aMotorLegHelp', // misma descripción, distinto lado
      min: 0,
      max: 4,
      untestableValue: nihssUntestable,
      options: [
        (0, 'nihssMotorLegOpt0'),
        (1, 'nihssMotorLegOpt1'),
        (2, 'nihssMotorLegOpt2'),
        (3, 'nihssMotorLegOpt3'),
        (4, 'nihssMotorLegOpt4'),
        (nihssUntestable, 'nihssMotorLegOpt9'),
      ],
    ),
    ScaleItem(
      key: nihssKey7Ataxia,
      labelKey: 'nihss7AtaxiaLabel',
      helpKey: 'nihss7AtaxiaHelp',
      min: 0,
      max: 2,
      untestableValue: nihssUntestable,
      options: [
        (0, 'nihss7AtaxiaOpt0'),
        (1, 'nihss7AtaxiaOpt1'),
        (2, 'nihss7AtaxiaOpt2'),
        (nihssUntestable, 'nihss7AtaxiaOpt9'),
      ],
    ),
    ScaleItem(
      key: nihssKey8Sensory,
      labelKey: 'nihss8SensoryLabel',
      helpKey: 'nihss8SensoryHelp',
      min: 0,
      max: 2,
      options: [
        (0, 'nihss8SensoryOpt0'),
        (1, 'nihss8SensoryOpt1'),
        (2, 'nihss8SensoryOpt2'),
      ],
    ),
    ScaleItem(
      key: nihssKey9Language,
      labelKey: 'nihss9LanguageLabel',
      helpKey: 'nihss9LanguageHelp',
      min: 0,
      max: 3,
      options: [
        (0, 'nihss9LanguageOpt0'),
        (1, 'nihss9LanguageOpt1'),
        (2, 'nihss9LanguageOpt2'),
        (3, 'nihss9LanguageOpt3'),
      ],
    ),
    ScaleItem(
      key: nihssKey10Dysarthria,
      labelKey: 'nihss10DysarthriaLabel',
      helpKey: 'nihss10DysarthriaHelp',
      min: 0,
      max: 2,
      untestableValue: nihssUntestable,
      options: [
        (0, 'nihss10DysarthriaOpt0'),
        (1, 'nihss10DysarthriaOpt1'),
        (2, 'nihss10DysarthriaOpt2'),
        (nihssUntestable, 'nihss10DysarthriaOpt9'),
      ],
    ),
    ScaleItem(
      key: nihssKey11Neglect,
      labelKey: 'nihss11NeglectLabel',
      helpKey: 'nihss11NeglectHelp',
      min: 0,
      max: 2,
      options: [
        (0, 'nihss11NeglectOpt0'),
        (1, 'nihss11NeglectOpt1'),
        (2, 'nihss11NeglectOpt2'),
      ],
    ),
  ];

  @override
  ScaleResult calculate(Map<String, int> answers) => calculateNihss(answers);
}
