import '../entities/algorithm_definition.dart';
import '../entities/algorithm_node.dart';
import '../entities/algorithm_option.dart';
import '../entities/algorithm_urgency.dart';

const strokeCodeAlgorithm = AlgorithmDefinition(
  id: 'strokeCode',
  titleKey: 'algoStrokeCodeTitle',
  descriptionKey: 'algoStrokeCodeDescription',
  startNodeId: 'q_window',
  nodes: {
    'q_window': QuestionNode(
      id: 'q_window',
      questionKey: 'algoStrokeCodeQWindow',
      hintKey: 'algoStrokeCodeQWindowHint',
      options: [
        AlgorithmOption(
          id: 'yes',
          labelKey: 'algoStrokeCodeQWindowYes',
          nextNodeId: 'q_ct',
        ),
        AlgorithmOption(
          id: 'no',
          labelKey: 'algoStrokeCodeQWindowNo',
          nextNodeId: 'r_out_of_window',
        ),
      ],
    ),
    'q_ct': QuestionNode(
      id: 'q_ct',
      questionKey: 'algoStrokeCodeQCt',
      options: [
        AlgorithmOption(
          id: 'yes',
          labelKey: 'algoStrokeCodeQCtYes',
          nextNodeId: 'q_nihss',
        ),
        AlgorithmOption(
          id: 'no',
          labelKey: 'algoStrokeCodeQCtNo',
          nextNodeId: 'r_ct_first',
        ),
      ],
    ),
    'q_nihss': QuestionNode(
      id: 'q_nihss',
      questionKey: 'algoStrokeCodeQNihss',
      options: [
        AlgorithmOption(
          id: 'yes',
          labelKey: 'algoStrokeCodeQNihssYes',
          nextNodeId: 'q_contraindications',
        ),
        AlgorithmOption(
          id: 'no',
          labelKey: 'algoStrokeCodeQNihssNo',
          nextNodeId: 'r_minor_deficit',
        ),
      ],
    ),
    'q_contraindications': QuestionNode(
      id: 'q_contraindications',
      questionKey: 'algoStrokeCodeQContraindications',
      hintKey: 'algoStrokeCodeQContraindicationsHint',
      options: [
        AlgorithmOption(
          id: 'yes',
          labelKey: 'algoStrokeCodeQContraindicationsYes',
          nextNodeId: 'r_absolute_ci',
        ),
        AlgorithmOption(
          id: 'no',
          labelKey: 'algoStrokeCodeQContraindicationsNo',
          nextNodeId: 'q_bp',
        ),
      ],
    ),
    'q_bp': QuestionNode(
      id: 'q_bp',
      questionKey: 'algoStrokeCodeQBp',
      options: [
        AlgorithmOption(
          id: 'yes',
          labelKey: 'algoStrokeCodeQBpYes',
          nextNodeId: 'q_window_3h',
        ),
        AlgorithmOption(
          id: 'no',
          labelKey: 'algoStrokeCodeQBpNo',
          nextNodeId: 'r_treat_bp',
        ),
      ],
    ),
    'q_window_3h': QuestionNode(
      id: 'q_window_3h',
      questionKey: 'algoStrokeCodeQWindow3h',
      options: [
        AlgorithmOption(
          id: 'yes',
          labelKey: 'algoStrokeCodeQWindow3hYes',
          nextNodeId: 'r_candidate_3h',
        ),
        AlgorithmOption(
          id: 'no',
          labelKey: 'algoStrokeCodeQWindow3hNo',
          nextNodeId: 'q_relative_ci',
        ),
      ],
    ),
    'q_relative_ci': QuestionNode(
      id: 'q_relative_ci',
      questionKey: 'algoStrokeCodeQRelativeCi',
      hintKey: 'algoStrokeCodeQRelativeCiHint',
      options: [
        AlgorithmOption(
          id: 'yes',
          labelKey: 'algoStrokeCodeQRelativeCiYes',
          nextNodeId: 'r_relative_ci',
        ),
        AlgorithmOption(
          id: 'no',
          labelKey: 'algoStrokeCodeQRelativeCiNo',
          nextNodeId: 'r_candidate_4h',
        ),
      ],
    ),
    'r_out_of_window': ResultNode(
      id: 'r_out_of_window',
      titleKey: 'algoStrokeCodeROutOfWindowTitle',
      urgency: AlgorithmUrgency.moderate,
      recommendationKeys: [
        'algoStrokeCodeROutOfWindowRec1',
        'algoStrokeCodeROutOfWindowRec2',
        'algoStrokeCodeROutOfWindowRec3',
      ],
    ),
    'r_ct_first': ResultNode(
      id: 'r_ct_first',
      titleKey: 'algoStrokeCodeRCtFirstTitle',
      urgency: AlgorithmUrgency.high,
      recommendationKeys: [
        'algoStrokeCodeRCtFirstRec1',
        'algoStrokeCodeRCtFirstRec2',
        'algoStrokeCodeRCtFirstRec3',
      ],
    ),
    'r_minor_deficit': ResultNode(
      id: 'r_minor_deficit',
      titleKey: 'algoStrokeCodeRMinorDeficitTitle',
      urgency: AlgorithmUrgency.low,
      recommendationKeys: [
        'algoStrokeCodeRMinorDeficitRec1',
        'algoStrokeCodeRMinorDeficitRec2',
        'algoStrokeCodeRMinorDeficitRec3',
      ],
    ),
    'r_absolute_ci': ResultNode(
      id: 'r_absolute_ci',
      titleKey: 'algoStrokeCodeRAbsoluteCiTitle',
      urgency: AlgorithmUrgency.moderate,
      recommendationKeys: [
        'algoStrokeCodeRAbsoluteCiRec1',
        'algoStrokeCodeRAbsoluteCiRec2',
        'algoStrokeCodeRAbsoluteCiRec3',
      ],
    ),
    'r_treat_bp': ResultNode(
      id: 'r_treat_bp',
      titleKey: 'algoStrokeCodeRTreatBpTitle',
      urgency: AlgorithmUrgency.high,
      recommendationKeys: [
        'algoStrokeCodeRTreatBpRec1',
        'algoStrokeCodeRTreatBpRec2',
        'algoStrokeCodeRTreatBpRec3',
      ],
    ),
    'r_candidate_3h': ResultNode(
      id: 'r_candidate_3h',
      titleKey: 'algoStrokeCodeRCandidate3hTitle',
      urgency: AlgorithmUrgency.critical,
      recommendationKeys: [
        'algoStrokeCodeRCandidate3hRec1',
        'algoStrokeCodeRCandidate3hRec2',
        'algoStrokeCodeRCandidate3hRec3',
      ],
    ),
    'r_relative_ci': ResultNode(
      id: 'r_relative_ci',
      titleKey: 'algoStrokeCodeRRelativeCiTitle',
      urgency: AlgorithmUrgency.moderate,
      recommendationKeys: [
        'algoStrokeCodeRRelativeCiRec1',
        'algoStrokeCodeRRelativeCiRec2',
        'algoStrokeCodeRRelativeCiRec3',
      ],
    ),
    'r_candidate_4h': ResultNode(
      id: 'r_candidate_4h',
      titleKey: 'algoStrokeCodeRCandidate4hTitle',
      urgency: AlgorithmUrgency.critical,
      recommendationKeys: [
        'algoStrokeCodeRCandidate4hRec1',
        'algoStrokeCodeRCandidate4hRec2',
        'algoStrokeCodeRCandidate4hRec3',
      ],
    ),
  },
);
