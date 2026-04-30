import '../entities/algorithm_definition.dart';
import '../entities/algorithm_node.dart';
import '../entities/algorithm_state.dart';

/// Returns the initial state for a given algorithm.
AlgorithmState startAlgorithm(AlgorithmDefinition definition) {
  assert(
    definition.nodes.containsKey(definition.startNodeId),
    'startNodeId "${definition.startNodeId}" not found in nodes',
  );
  return AlgorithmState(
    definition: definition,
    path: [definition.startNodeId],
    selectedOptionIds: [],
  );
}

/// Advances the algorithm by selecting [optionId] on the current QuestionNode.
///
/// Throws [StateError] if already at a ResultNode.
/// Throws [ArgumentError] if [optionId] is not valid for the current node.
AlgorithmState stepAlgorithm(AlgorithmState state, String optionId) {
  final current = state.currentNode;
  if (current is! QuestionNode) {
    throw StateError('Cannot step: already at a result node (${current.id})');
  }

  final option = current.options.firstWhere(
    (o) => o.id == optionId,
    orElse: () => throw ArgumentError(
      'Option "$optionId" not found in node "${current.id}"',
    ),
  );

  assert(
    state.definition.nodes.containsKey(option.nextNodeId),
    'nextNodeId "${option.nextNodeId}" not found in nodes',
  );

  return AlgorithmState(
    definition: state.definition,
    path: [...state.path, option.nextNodeId],
    selectedOptionIds: [...state.selectedOptionIds, optionId],
  );
}

/// Goes back one step. Returns the same state if already at the start.
AlgorithmState backAlgorithm(AlgorithmState state) {
  if (!state.canGoBack) return state;
  return AlgorithmState(
    definition: state.definition,
    path: state.path.sublist(0, state.path.length - 1),
    selectedOptionIds: state.selectedOptionIds.sublist(
      0,
      state.selectedOptionIds.length - 1,
    ),
  );
}

/// Resets the algorithm to the initial state.
AlgorithmState restartAlgorithm(AlgorithmState state) =>
    startAlgorithm(state.definition);
