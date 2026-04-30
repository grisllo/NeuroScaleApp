import '../entities/algorithm_definition.dart';
import '../entities/algorithm_node.dart';
import '../entities/algorithm_option.dart';
import '../entities/algorithm_urgency.dart';

const htaIctusAlgorithm = AlgorithmDefinition(
  id: 'htaIctus',
  titleKey: 'algoHtaIctusTitle',
  descriptionKey: 'algoHtaIctusDescription',
  startNodeId: 'q_type',
  nodes: {
    'q_type': QuestionNode(
      id: 'q_type',
      questionKey: 'algoHtaIctusQType',
      options: [
        AlgorithmOption(
          id: 'ischemic',
          labelKey: 'algoHtaIctusQTypeIschemic',
          nextNodeId: 'q_reperfusion',
        ),
        AlgorithmOption(
          id: 'hemorrhagic',
          labelKey: 'algoHtaIctusQTypeHemorrhagic',
          nextNodeId: 'q_ich_sbp',
        ),
        AlgorithmOption(
          id: 'sah',
          labelKey: 'algoHtaIctusQTypeSah',
          nextNodeId: 'q_sah_vasospasm',
        ),
        AlgorithmOption(
          id: 'unknown',
          labelKey: 'algoHtaIctusQTypeUnknown',
          nextNodeId: 'r_unknown_type',
        ),
      ],
    ),
    'q_reperfusion': QuestionNode(
      id: 'q_reperfusion',
      questionKey: 'algoHtaIctusQReperfusion',
      options: [
        AlgorithmOption(
          id: 'yes',
          labelKey: 'algoHtaIctusQReperfusionYes',
          nextNodeId: 'r_reperfusion_target',
        ),
        AlgorithmOption(
          id: 'no',
          labelKey: 'algoHtaIctusQReperfusionNo',
          nextNodeId: 'q_ischemic_bp',
        ),
      ],
    ),
    'q_ischemic_bp': QuestionNode(
      id: 'q_ischemic_bp',
      questionKey: 'algoHtaIctusQIschemicBp',
      options: [
        AlgorithmOption(
          id: 'yes',
          labelKey: 'algoHtaIctusQIschemicBpYes',
          nextNodeId: 'r_ischemic_treat',
        ),
        AlgorithmOption(
          id: 'no',
          labelKey: 'algoHtaIctusQIschemicBpNo',
          nextNodeId: 'r_ischemic_observe',
        ),
      ],
    ),
    'q_ich_sbp': QuestionNode(
      id: 'q_ich_sbp',
      questionKey: 'algoHtaIctusQIchSbp',
      options: [
        AlgorithmOption(
          id: 'yes',
          labelKey: 'algoHtaIctusQIchSbpYes',
          nextNodeId: 'r_ich_treat',
        ),
        AlgorithmOption(
          id: 'no',
          labelKey: 'algoHtaIctusQIchSbpNo',
          nextNodeId: 'r_ich_observe',
        ),
      ],
    ),
    'q_sah_vasospasm': QuestionNode(
      id: 'q_sah_vasospasm',
      questionKey: 'algoHtaIctusQSahVasospasm',
      options: [
        AlgorithmOption(
          id: 'yes',
          labelKey: 'algoHtaIctusQSahVasospasmYes',
          nextNodeId: 'r_sah_vasospasm',
        ),
        AlgorithmOption(
          id: 'no',
          labelKey: 'algoHtaIctusQSahVasospasmNo',
          nextNodeId: 'r_sah_no_vasospasm',
        ),
      ],
    ),
    'r_unknown_type': ResultNode(
      id: 'r_unknown_type',
      titleKey: 'algoHtaIctusRUnknownTypeTitle',
      urgency: AlgorithmUrgency.high,
      recommendationKeys: [
        'algoHtaIctusRUnknownTypeRec1',
        'algoHtaIctusRUnknownTypeRec2',
        'algoHtaIctusRUnknownTypeRec3',
      ],
    ),
    'r_reperfusion_target': ResultNode(
      id: 'r_reperfusion_target',
      titleKey: 'algoHtaIctusRReperfusionTargetTitle',
      urgency: AlgorithmUrgency.critical,
      recommendationKeys: [
        'algoHtaIctusRReperfusionTargetRec1',
        'algoHtaIctusRReperfusionTargetRec2',
        'algoHtaIctusRReperfusionTargetRec3',
      ],
    ),
    'r_ischemic_treat': ResultNode(
      id: 'r_ischemic_treat',
      titleKey: 'algoHtaIctusRIschemicTreatTitle',
      urgency: AlgorithmUrgency.high,
      recommendationKeys: [
        'algoHtaIctusRIschemicTreatRec1',
        'algoHtaIctusRIschemicTreatRec2',
        'algoHtaIctusRIschemicTreatRec3',
      ],
    ),
    'r_ischemic_observe': ResultNode(
      id: 'r_ischemic_observe',
      titleKey: 'algoHtaIctusRIschemicObserveTitle',
      urgency: AlgorithmUrgency.info,
      recommendationKeys: [
        'algoHtaIctusRIschemicObserveRec1',
        'algoHtaIctusRIschemicObserveRec2',
        'algoHtaIctusRIschemicObserveRec3',
      ],
    ),
    'r_ich_treat': ResultNode(
      id: 'r_ich_treat',
      titleKey: 'algoHtaIctusRIchTreatTitle',
      urgency: AlgorithmUrgency.high,
      recommendationKeys: [
        'algoHtaIctusRIchTreatRec1',
        'algoHtaIctusRIchTreatRec2',
        'algoHtaIctusRIchTreatRec3',
      ],
    ),
    'r_ich_observe': ResultNode(
      id: 'r_ich_observe',
      titleKey: 'algoHtaIctusRIchObserveTitle',
      urgency: AlgorithmUrgency.info,
      recommendationKeys: [
        'algoHtaIctusRIchObserveRec1',
        'algoHtaIctusRIchObserveRec2',
        'algoHtaIctusRIchObserveRec3',
      ],
    ),
    'r_sah_vasospasm': ResultNode(
      id: 'r_sah_vasospasm',
      titleKey: 'algoHtaIctusRSahVasospasmTitle',
      urgency: AlgorithmUrgency.high,
      recommendationKeys: [
        'algoHtaIctusRSahVasospasmRec1',
        'algoHtaIctusRSahVasospasmRec2',
        'algoHtaIctusRSahVasospasmRec3',
      ],
    ),
    'r_sah_no_vasospasm': ResultNode(
      id: 'r_sah_no_vasospasm',
      titleKey: 'algoHtaIctusRSahNoVasospasmTitle',
      urgency: AlgorithmUrgency.moderate,
      recommendationKeys: [
        'algoHtaIctusRSahNoVasospasmRec1',
        'algoHtaIctusRSahNoVasospasmRec2',
        'algoHtaIctusRSahNoVasospasmRec3',
      ],
    ),
  },
);
