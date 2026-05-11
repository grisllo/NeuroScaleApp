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

// Returns the tick interval (in hours) for a given time range.
double _axisInterval(double rangeHours) {
  if (rangeHours <= 2) return 0.5;
  if (rangeHours <= 12) return 2;
  if (rangeHours <= 48) return 6;
  if (rangeHours <= 168) return 24;
  if (rangeHours <= 720) return 168;
  return 720;
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

    final firstTime = evaluations.first.createdAt;
    final rangeHours =
        evaluations.last.createdAt.difference(firstTime).inMinutes / 60.0;

    // Use real timestamps for proportional X when evaluations span > 36 s.
    final useTime = rangeHours > 0.01;

    double xFor(int i) => useTime
        ? evaluations[i].createdAt.difference(firstTime).inMinutes / 60.0
        : i.toDouble();

    // ── Spots ────────────────────────────────────────────────────────────────
    final spots = List.generate(evaluations.length, (i) {
      final normalized = evaluations[i].totalScore / maxScore * 100;
      return FlSpot(xFor(i), normalized.clamp(0, 100));
    });

    // ── Label map: x → display string ────────────────────────────────────────
    // Format: "dd/M\nHH:mm" for the first evaluation of a new day,
    //         "HH:mm" for subsequent evaluations on the same day.
    final xToLabel = <double, String>{};
    for (var i = 0; i < evaluations.length; i++) {
      final dt = evaluations[i].createdAt;
      final isDifferentDay =
          i == 0 ||
          dt.day != evaluations[i - 1].createdAt.day ||
          dt.month != evaluations[i - 1].createdAt.month;
      xToLabel[xFor(i)] = isDifferentDay
          ? '${dt.day}/${dt.month}\n${_fmtTime(dt)}'
          : _fmtTime(dt);
    }

    // Thin to at most 6 visible labels (always keep last).
    const maxLabels = 6;
    if (xToLabel.length > maxLabels) {
      final keys = xToLabel.keys.toList();
      final step = (keys.length / maxLabels).ceil();
      for (var i = 0; i < keys.length - 1; i++) {
        if (i % step != 0) xToLabel.remove(keys[i]);
      }
    }

    // ── Axis range and tick interval ─────────────────────────────────────────
    final interval = useTime ? _axisInterval(rangeHours) : 1.0;
    // maxX rounded up to the next tick boundary so the last data point
    // always falls within tolerance of a generated tick.
    final maxX = useTime
        ? (rangeHours / interval).ceil() * interval
        : (evaluations.length - 1).toDouble();

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
                          // Find the closest labeled data point to this tick.
                          MapEntry<double, String>? nearest;
                          for (final e in xToLabel.entries) {
                            if (nearest == null ||
                                (e.key - value).abs() <
                                    (nearest.key - value).abs()) {
                              nearest = e;
                            }
                          }
                          if (nearest == null ||
                              (nearest.key - value).abs() > interval * 0.45) {
                            return const SizedBox();
                          }
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              nearest.value,
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
                        // Find the evaluation closest to this spot's x.
                        var bestIdx = 0;
                        var bestDist = double.infinity;
                        for (var i = 0; i < evaluations.length; i++) {
                          final d = (xFor(i) - spot.x).abs();
                          if (d < bestDist) {
                            bestDist = d;
                            bestIdx = i;
                          }
                        }
                        final eval = evaluations[bestIdx];
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
