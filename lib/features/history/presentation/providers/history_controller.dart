import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/presentation/providers/session_provider.dart';
import '../../../../features/evaluations/domain/entities/evaluation.dart';
import '../../../../features/evaluations/domain/usecases/delete_evaluation_usecase.dart';
import '../../../../features/evaluations/domain/usecases/fetch_evaluations_usecase.dart';
import '../../../../features/evaluations/presentation/providers/evaluation_provider.dart';

class HistoryController extends AsyncNotifier<List<Evaluation>> {
  @override
  FutureOr<List<Evaluation>> build() => _fetch();

  Future<List<Evaluation>> _fetch() {
    final userId = ref.read(sessionProvider).asData?.value?.id ?? '';
    return FetchEvaluationsUseCase(
      ref.read(evaluationRepositoryProvider),
    ).call(userId);
  }

  Future<void> delete(String id) async {
    await DeleteEvaluationUseCase(
      ref.read(evaluationRepositoryProvider),
    ).call(id);
    state = AsyncData(
      state.value?.where((e) => e.id != id).toList() ?? [],
    );
  }
}

final historyControllerProvider =
    AsyncNotifierProvider<HistoryController, List<Evaluation>>(
  HistoryController.new,
);
