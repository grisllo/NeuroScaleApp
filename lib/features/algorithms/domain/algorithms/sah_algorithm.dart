import '../entities/algorithm_definition.dart';
import '../entities/algorithm_node.dart';
import '../entities/algorithm_option.dart';
import '../entities/algorithm_urgency.dart';

const sahAlgorithm = AlgorithmDefinition(
  id: 'sah',
  titleKey: 'algoSahTitle',
  descriptionKey: 'algoSahDescription',
  startNodeId: 'q_consciousness',
  nodes: {
    'q_consciousness': QuestionNode(
      id: 'q_consciousness',
      questionKey: 'algoSahQConsciousness',
      options: [
        AlgorithmOption(
          id: 'alert',
          labelKey: 'algoSahQConsciousnessAlert',
          nextNodeId: 'q_focal_deficit',
        ),
        AlgorithmOption(
          id: 'drowsy',
          labelKey: 'algoSahQConsciousnessDrowsy',
          nextNodeId: 'r_hh3',
        ),
        AlgorithmOption(
          id: 'stupor',
          labelKey: 'algoSahQConsciousnessStupor',
          nextNodeId: 'r_hh4_5',
        ),
      ],
    ),
    'q_focal_deficit': QuestionNode(
      id: 'q_focal_deficit',
      questionKey: 'algoSahQFocalDeficit',
      options: [
        AlgorithmOption(
          id: 'no',
          labelKey: 'algoSahQFocalDeficitNo',
          nextNodeId: 'q_ct_sah',
        ),
        AlgorithmOption(
          id: 'yes',
          labelKey: 'algoSahQFocalDeficitYes',
          nextNodeId: 'r_hh2',
        ),
      ],
    ),
    'q_ct_sah': QuestionNode(
      id: 'q_ct_sah',
      questionKey: 'algoSahQCtSah',
      options: [
        AlgorithmOption(
          id: 'fisher_1_2',
          labelKey: 'algoSahQCtSahFisher12',
          nextNodeId: 'r_hh1_fisher_1_2',
        ),
        AlgorithmOption(
          id: 'fisher_3_4',
          labelKey: 'algoSahQCtSahFisher34',
          nextNodeId: 'r_hh1_fisher_3_4',
        ),
      ],
    ),
    'r_hh1_fisher_1_2': ResultNode(
      id: 'r_hh1_fisher_1_2',
      titleKey: 'algoSahRHh1Fisher12Title',
      urgency: AlgorithmUrgency.moderate,
      recommendationKeys: [
        'algoSahRHh1Fisher12Rec1',
        'algoSahRHh1Fisher12Rec2',
        'algoSahRHh1Fisher12Rec3',
      ],
    ),
    'r_hh1_fisher_3_4': ResultNode(
      id: 'r_hh1_fisher_3_4',
      titleKey: 'algoSahRHh1Fisher34Title',
      urgency: AlgorithmUrgency.high,
      recommendationKeys: [
        'algoSahRHh1Fisher34Rec1',
        'algoSahRHh1Fisher34Rec2',
        'algoSahRHh1Fisher34Rec3',
      ],
    ),
    'r_hh2': ResultNode(
      id: 'r_hh2',
      titleKey: 'algoSahRHh2Title',
      urgency: AlgorithmUrgency.high,
      recommendationKeys: [
        'algoSahRHh2Rec1',
        'algoSahRHh2Rec2',
        'algoSahRHh2Rec3',
      ],
    ),
    'r_hh3': ResultNode(
      id: 'r_hh3',
      titleKey: 'algoSahRHh3Title',
      urgency: AlgorithmUrgency.critical,
      recommendationKeys: [
        'algoSahRHh3Rec1',
        'algoSahRHh3Rec2',
        'algoSahRHh3Rec3',
      ],
    ),
    'r_hh4_5': ResultNode(
      id: 'r_hh4_5',
      titleKey: 'algoSahRHh45Title',
      urgency: AlgorithmUrgency.critical,
      recommendationKeys: [
        'algoSahRHh45Rec1',
        'algoSahRHh45Rec2',
        'algoSahRHh45Rec3',
      ],
    ),
  },
);
