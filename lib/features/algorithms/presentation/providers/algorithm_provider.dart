import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/algorithm_definition.dart';
import '../../domain/entities/algorithm_state.dart';
import '../../domain/usecases/evaluate_algorithm.dart';

class AlgorithmNotifier extends Notifier<AlgorithmState?> {
  @override
  AlgorithmState? build() => null;

  void start(AlgorithmDefinition definition) =>
      state = startAlgorithm(definition);

  void step(String optionId) {
    if (state == null) return;
    state = stepAlgorithm(state!, optionId);
  }

  void back() {
    if (state == null) return;
    state = backAlgorithm(state!);
  }

  void restart() {
    if (state == null) return;
    state = restartAlgorithm(state!);
  }
}

final algorithmProvider = NotifierProvider<AlgorithmNotifier, AlgorithmState?>(
  AlgorithmNotifier.new,
);
