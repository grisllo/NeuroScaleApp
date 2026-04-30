import 'algorithm_definition.dart';
import 'algorithm_node.dart';

class AlgorithmState {
  const AlgorithmState({
    required this.definition,
    required this.path,
    required this.selectedOptionIds,
  });

  final AlgorithmDefinition definition;

  /// Node IDs visited so far (first = startNodeId).
  final List<String> path;

  /// Option IDs chosen at each step.
  final List<String> selectedOptionIds;

  AlgorithmNode get currentNode => definition.nodes[path.last]!;

  bool get isComplete => currentNode is ResultNode;

  /// Number of questions answered.
  int get stepCount => selectedOptionIds.length;

  /// Total questions along the chosen path (known only after completion).
  bool get canGoBack => path.length > 1;
}
