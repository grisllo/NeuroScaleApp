import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../features/evaluations/domain/entities/evaluation.dart';

// Max scores per scale — used for normalization and tooltip
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

class EvolutionTab extends StatelessWidget {
  const EvolutionTab({super.key, required this.evaluations});

  final List<Evaluation> evaluations;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Group by scale, sort oldest → newest, keep only scales with ≥ 2
    final grouped = <String, List<Evaluation>>{};
    for (final e in evaluations) {
      grouped.putIfAbsent(e.scaleType, () => []).add(e);
    }
    final chartable = grouped.entries
        .where((e) => e.value.length >= 2)
        .map((e) {
          final sorted = List<Evaluation>.from(e.value)
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
          return MapEntry(e.key, sorted);
        })
        .toList();

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
  const _ScaleChart({
    required this.scaleType,
    required this.evaluations,
  });

  final String scaleType;
  final List<Evaluation> evaluations;

  @override
  Widget build(BuildContext context) {
    final color = _kScaleColors[scaleType] ?? Theme.of(context).colorScheme.primary;
    final maxScore = _kMaxScores[scaleType] ?? 1;

    final spots = evaluations.asMap().entries.map((entry) {
      final normalized = entry.value.totalScore / maxScore * 100;
      return FlSpot(entry.key.toDouble(), normalized.clamp(0, 100));
    }).toList();

    // Show one label every N to avoid crowding
    final labelStep = (evaluations.length / 5).ceil().clamp(1, 999);

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
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  scaleType.toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${evaluations.length} evaluaciones',
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
                        color: color.withOpacity(0.08),
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
                          if (i < 0 ||
                              i >= evaluations.length ||
                              i % labelStep != 0) {
                            return const SizedBox();
                          }
                          final dt = evaluations[i].createdAt;
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
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
                            axisSide: meta.axisSide,
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
                          '${eval.totalScore}/$maxScore\n${eval.interpretation}',
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
