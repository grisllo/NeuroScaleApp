import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../features/evaluations/domain/entities/evaluation.dart';
import '../../../../features/scales/shared/domain/entities/severity.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../providers/history_controller.dart';
import 'evaluation_detail_screen.dart';
import 'evolution_tab.dart';

// All supported scale types (chips filter)
const _kScales = ['gcs', 'rankin', 'barthel', 'abcd2'];

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(historyControllerProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final current = ref.read(historyControllerProvider.notifier).filter;
      ref
          .read(historyControllerProvider.notifier)
          .setFilter(current.copyWith(searchQuery: value.trim()));
    });
  }

  void _toggleScale(String scale) {
    final notifier = ref.read(historyControllerProvider.notifier);
    final current = notifier.filter;
    final scales = Set<String>.from(current.scales);
    if (scales.contains(scale)) {
      scales.remove(scale);
    } else {
      scales.add(scale);
    }
    notifier.setFilter(current.copyWith(scales: scales));
  }

  Future<void> _pickDateRange() async {
    final notifier = ref.read(historyControllerProvider.notifier);
    final current = notifier.filter;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: current.dateRange,
      locale: const Locale('es'),
    );
    if (!mounted) return;
    notifier.setFilter(current.copyWith(dateRange: picked));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final historyAsync = ref.watch(historyControllerProvider);
    final notifier = ref.read(historyControllerProvider.notifier);
    final filter = notifier.filter;
    final hasActiveDateFilter = filter.dateRange != null;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.historyTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () =>
                context.canPop() ? context.pop() : context.goNamed('home'),
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.listTab),
              Tab(text: l10n.evolutionTab),
            ],
          ),
        ),
        body: historyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(e.toString()),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(historyControllerProvider),
                  child: Text(l10n.retryButton),
                ),
              ],
            ),
          ),
          data: (evaluations) => TabBarView(
            children: [
              // ── Tab 0: Lista ────────────────────────────────────────
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: l10n.searchHint,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,
                        isDense: true,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      children: [
                        ..._kScales.map(
                          (scale) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: FilterChip(
                              label: Text(scale.toUpperCase()),
                              selected: filter.scales.contains(scale),
                              onSelected: (_) => _toggleScale(scale),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            avatar: const Icon(Icons.date_range, size: 16),
                            label: Text(
                              hasActiveDateFilter
                                  ? '${_fmt(filter.dateRange!.start)} – ${_fmt(filter.dateRange!.end)}'
                                  : l10n.filterByDate,
                            ),
                            selected: hasActiveDateFilter,
                            onSelected: (_) => _pickDateRange(),
                            onDeleted: hasActiveDateFilter
                                ? () => notifier.setFilter(
                                      filter.copyWith(dateRange: null),
                                    )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: evaluations.isEmpty
                        ? _EmptyState(l10n: l10n)
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount:
                                evaluations.length + (notifier.hasMore ? 1 : 0),
                            itemBuilder: (_, i) {
                              if (i == evaluations.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              return _EvaluationCard(
                                evaluation: evaluations[i],
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => EvaluationDetailScreen(
                                      evaluation: evaluations[i],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
              // ── Tab 1: Evolución ────────────────────────────────────
              EvolutionTab(evaluations: evaluations),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.historyEmpty,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => context.goNamed('home'),
            child: Text(l10n.historyEmptyAction),
          ),
        ],
      ),
    );
  }
}

// ── Evaluation card ───────────────────────────────────────────────────────────

class _EvaluationCard extends StatelessWidget {
  const _EvaluationCard({
    required this.evaluation,
    required this.onTap,
  });

  final Evaluation evaluation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severity = _severityFromInterpretation(evaluation.interpretation);
    final severityColor = _severityColor(context, severity);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        title: Row(
          children: [
            Chip(
              label: Text(
                evaluation.scaleType.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: theme.colorScheme.primary,
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                evaluation.caseDescription,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text(
                _relativeDate(evaluation.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: severityColor, width: 1),
                ),
                child: Text(
                  evaluation.interpretation,
                  style: TextStyle(
                    fontSize: 11,
                    color: severityColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  String _relativeDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Severity _severityFromInterpretation(String interpretation) {
    final lower = interpretation.toLowerCase();
    if (lower.contains('grave') ||
        lower.contains('total') ||
        lower.contains('fallecido') ||
        lower.contains('alto')) {
      return Severity.severe;
    }
    if (lower.contains('moderado') || lower.contains('moderada')) {
      return Severity.moderate;
    }
    if (lower.contains('leve') || lower.contains('bajo')) return Severity.mild;
    return Severity.none;
  }

  Color _severityColor(BuildContext context, Severity severity) =>
      switch (severity) {
        Severity.mild => Colors.green.shade600,
        Severity.moderate => Colors.orange.shade700,
        Severity.severe => Colors.red.shade700,
        Severity.none => Theme.of(context).colorScheme.secondary,
      };
}
