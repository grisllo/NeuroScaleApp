import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/presentation/providers/session_provider.dart';
import '../../../../features/evaluations/domain/entities/evaluation.dart';
import '../../../../features/evaluations/domain/usecases/delete_evaluation_usecase.dart';
import '../../../../features/evaluations/domain/usecases/fetch_evaluations_usecase.dart';
import '../../../../features/evaluations/presentation/providers/evaluation_provider.dart';

class HistoryFilter {
  const HistoryFilter({
    this.scales = const {},
    this.dateRange,
    this.searchQuery = '',
  });

  final Set<String> scales;
  final DateTimeRange? dateRange;
  final String searchQuery;

  HistoryFilter copyWith({
    Set<String>? scales,
    Object? dateRange = _sentinel,
    String? searchQuery,
  }) =>
      HistoryFilter(
        scales: scales ?? this.scales,
        dateRange:
            dateRange == _sentinel ? this.dateRange : dateRange as DateTimeRange?,
        searchQuery: searchQuery ?? this.searchQuery,
      );

  static const _sentinel = Object();
}

class HistoryController extends AsyncNotifier<List<Evaluation>> {
  static const _pageSize = 20;

  HistoryFilter _filter = const HistoryFilter();
  int _page = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  // Pagination/filter metadata kept as private state with read-only getters.
  // Promoting to AsyncValue<HistoryState> would inflate the type and require
  // widening every consumer in history_screen.dart for limited gain.
  // ignore: avoid_public_notifier_properties
  HistoryFilter get filter => _filter;
  // ignore: avoid_public_notifier_properties
  bool get hasMore => _hasMore;
  // ignore: avoid_public_notifier_properties
  bool get isLoadingMore => _isLoadingMore;

  @override
  FutureOr<List<Evaluation>> build() => _fetch(reset: true);

  Future<List<Evaluation>> _fetch({bool reset = false}) async {
    if (reset) {
      _page = 0;
      _hasMore = true;
    }
    final userId = ref.read(sessionProvider).asData?.value?.id ?? '';
    final results = await FetchEvaluationsUseCase(
      ref.read(evaluationRepositoryProvider),
    ).call(
      userId,
      scales: _filter.scales,
      dateFrom: _filter.dateRange?.start,
      dateTo: _filter.dateRange?.end,
      searchQuery: _filter.searchQuery,
      page: _page,
      pageSize: _pageSize,
    );
    if (results.length < _pageSize) _hasMore = false;
    return results;
  }

  Future<void> setFilter(HistoryFilter filter) async {
    _filter = filter;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(reset: true));
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    _isLoadingMore = true;
    final current = state.value ?? [];
    _page++;
    try {
      final more = await _fetch();
      state = AsyncData([...current, ...more]);
    } catch (e, st) {
      _page--;
      state = AsyncError(e, st);
    } finally {
      _isLoadingMore = false;
    }
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
