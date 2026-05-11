import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/scale_key_resolver.dart';
import '../../../evaluations/domain/entities/evaluation.dart';

// Max scores per scale — normalization to 0-100% for uniform Y axis.
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

String _fmtTime(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

class _ScaleChart extends StatelessWidget {
  const _ScaleChart({required this.scaleType, required this.evaluations});

  final String scaleType;
  final List<Evaluation> evaluations;

  @override
  Widget build(BuildContext context) {
    final color =
        _kScaleColors[scaleType] ?? Theme.of(context).colorScheme.primary;
    final maxScore = _kMaxScores[scaleType] ?? 1;

    // Index-based X guarantees each data point has its own tick (interval: 1)
    // and labels align exactly with dots. Time info is conveyed via label text.
    double xFor(int i) => i.toDouble();

    // ── Spots ────────────────────────────────────────────────────────────────
    final spots = List.generate(evaluations.length, (i) {
      final normalized = evaluations[i].totalScore / maxScore * 100;
      return FlSpot(xFor(i), normalized.clamp(0, 100));
    });

    // ── Visible label indices ─────────────────────────────────────────────────
    // "dd/M\nHH:mm" for first of day or last eval; "HH:mm" for same-day rest.
    // Thin to at most 6 visible labels.
    const maxLabels = 6;
    final step = (evaluations.length / maxLabels).ceil().clamp(1, 999);
    final visibleIndices = {
      for (var i = 0; i < evaluations.length; i++)
        if (i % step == 0 || i == evaluations.length - 1) i,
    };

    // ── Axis range ───────────────────────────────────────────────────────────
    const interval = 1.0;
    final maxX = (evaluations.length - 1).toDouble();

    // ── Chart ────────────────────────────────────────────────────────────────
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
                  minX: 0,
                  maxX: maxX,
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
                        reservedSize: 36,
                        interval: interval,
                        getTitlesWidget: (value, meta) {
                          final i = value.round();
                          if (!visibleIndices.contains(i)) {
                            return const SizedBox();
                          }
                          final dt = evaluations[i].createdAt;
                          final isDifferentDay =
                              i == 0 ||
                              dt.day != evaluations[i - 1].createdAt.day ||
                              dt.month != evaluations[i - 1].createdAt.month;
                          final isLast = i == evaluations.length - 1;
                          final label = (isDifferentDay || isLast)
                              ? '${dt.day}/${dt.month}\n${_fmtTime(dt)}'
                              : _fmtTime(dt);
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              label,
                              style: const TextStyle(fontSize: 9),
                              textAlign: TextAlign.center,
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
                        final i = spot.x.round().clamp(
                          0,
                          evaluations.length - 1,
                        );
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
