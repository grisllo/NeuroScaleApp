import 'algorithm_node.dart';

class AlgorithmDefinition {
  const AlgorithmDefinition({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.startNodeId,
    required this.nodes,
  });

  final String id;
  final String titleKey;
  final String descriptionKey;
  final String startNodeId;
  final Map<String, AlgorithmNode> nodes;
}
