import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/scale_key_resolver.dart';
import '../../../evaluations/domain/entities/evaluation.dart';

// Max scores per scale — normalization to 0-100% for uniform Y axis.
// Skill: fl-chart-patterns §1 Score normalization.
const _kMaxScores = {
  'gcs': 15,
  'rankin': 6,
  'barthel': 100,
  'abcd2': 7,
  'nihss': 42,
};

const _kScaleColors = {
  'gcs': Color(0xFF1565C0),
  'rankin': Color(0xFF2E7D32),
  'barthel': Color(0xFFE65100),
  'abcd2': Color(0xFF6A1B9A),
  'nihss': Color(0xFFC62828),
};

/// Shows one LineChart per scale type that has ≥2 evaluations for this patient.
/// Adapts EvolutionTab (history feature) to per-patient scope.
class PatientEvolutionChart extends StatelessWidget {
  const PatientEvolutionChart({super.key, required this.evaluations});

  final List<Evaluation> evaluations;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final grouped = <String, List<Evaluation>>{};
    for (final e in evaluations) {
      grouped.putIfAbsent(e.scaleType, () => []).add(e);
    }
    final chartable = grouped.entries.where((e) => e.value.length >= 2).map((
      e,
    ) {
      final sorted = List<Evaluation>.from(e.value)
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return MapEntry(e.key, sorted);
    }).toList();

    if (chartable.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            l10n.evolutionEmpty,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: chartable.length,
      itemBuilder: (_, i) => _ScaleChart(
        scaleType: chartable[i].key,
        evaluations: chartable[i].value,
      ),
    );
  }
}

class _ScaleChart extends StatelessWidget {
  const _ScaleChart({required this.scaleType, required this.evaluations});

  final String scaleType;
  final List<Evaluation> evaluations;

  @override
  Widget build(BuildContext context) {
    final color =
        _kScaleColors[scaleType] ?? Theme.of(context).colorScheme.primary;
    final maxScore = _kMaxScores[scaleType] ?? 1;

    final spots = evaluations.asMap().entries.map((entry) {
      final normalized = entry.value.totalScore / maxScore * 100;
      return FlSpot(entry.key.toDouble(), normalized.clamp(0, 100));
    }).toList();

    // Indices where the calendar date changes (first evaluation of each day).
    final firstOfDay = <int>{};
    for (var i = 0; i < evaluations.length; i++) {
      if (i == 0) {
        firstOfDay.add(i);
      } else {
        final curr = evaluations[i].createdAt;
        final prev = evaluations[i - 1].createdAt;
        if (curr.day != prev.day ||
            curr.month != prev.month ||
            curr.year != prev.year) {
          firstOfDay.add(i);
        }
      }
    }
    // Thin further if there are more than 5 distinct dates.
    final step = (firstOfDay.length / 5).ceil().clamp(1, 999);
    final visibleLabels = firstOfDay
        .toList()
        .asMap()
        .entries
        .where((e) => e.key % step == 0)
        .map((e) => e.value)
        .toSet();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  scaleType.toUpperCase(),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  context.l10n.evolutionEvaluationCount(evaluations.length),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: color,
                      barWidth: 2.5,
                      dotData: FlDotData(show: spots.length < 15),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withValues(alpha: 0.08),
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (!visibleLabels.contains(i)) {
                            return const SizedBox();
                          }
                          final dt = evaluations[i].createdAt;
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              '${dt.day}/${dt.month}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) {
                          if (value % 25 != 0) return const SizedBox();
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              '${value.toInt()}%',
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) => spots.map((spot) {
                        final i = spot.spotIndex;
                        if (i < 0 || i >= evaluations.length) return null;
                        final eval = evaluations[i];
                        return LineTooltipItem(
                          '${eval.totalScore}/$maxScore\n${context.l10n.resolveKey(eval.interpretation)}',
                          const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
