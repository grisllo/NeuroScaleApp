import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/evaluation.dart';
import '../../domain/usecases/save_evaluation_usecase.dart';
import 'evaluation_provider.dart';

class SaveEvaluationController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> save(Evaluation evaluation) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => SaveEvaluationUseCase(
        ref.read(evaluationRepositoryProvider),
      ).call(evaluation),
    );
  }
}

final saveEvaluationControllerProvider =
    AsyncNotifierProvider<SaveEvaluationController, void>(
      SaveEvaluationController.new,
    );
