---
name: fl-chart-patterns
description: Patterns and conventions for fl_chart in NeuroScale App. Use before implementing any chart screen (2A.3 evolution tab, future dashboard). Covers LineChart setup, score normalization, tooltips, multi-series, empty states, and color conventions.
---

# fl_chart patterns for NeuroScale App

## Package version

`fl_chart: ">=0.68.0 <0.69.0"` — pinned to 0.68.x for Flutter 3.24.x compatibility.
`fl_chart >=0.69.0` uses `Color.a` / `withValues` which require Flutter 3.27+.

### SideTitleWidget API (0.68.x)
Uses `axisSide: meta.axisSide` — NOT `meta: meta` (that's 0.69+).

## When to use

Before implementing any chart UI in this project. The patterns below apply to:
- **2A.3**: Evolution tab in HistoryScreen (LineChart per scale, temporal axis)
- Any future dashboard or progress chart

---

## 1. Score normalization

All scales have different max scores (GCS: 15, mRS: 6, Barthel: 100, ABCD2: 7, NIHSS: 42).
To display multiple scales on the same Y axis, normalize to 0–100%:

```dart
double normalize(int score, int maxScore) => score / maxScore * 100;
```

The Y axis always goes 0–100. Tooltip shows the raw score, not the normalized value.

---

## 2. Scale metadata

Define a constants file or a helper to map `scaleType` → max score and color:

```dart
const _kScaleMaxScores = {'gcs': 15, 'rankin': 6, 'barthel': 100, 'abcd2': 7, 'nihss': 42};
const _kScaleColors = {
  'gcs':     Color(0xFF1565C0), // blue
  'rankin':  Color(0xFF2E7D32), // green
  'barthel': Color(0xFFE65100), // orange
  'abcd2':   Color(0xFF6A1B9A), // purple
  'nihss':   Color(0xFFC62828), // red
};
```

---

## 3. LineChart minimum setup

```dart
LineChart(
  LineChartData(
    minY: 0,
    maxY: 100,
    lineBarsData: [_barForScale(scale, evaluations)],
    titlesData: FlTitlesData(
      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: _dateLabel, reservedSize: 32)),
      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    ),
    lineTouchData: LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipItems: _tooltipItems,
      ),
    ),
    gridData: FlGridData(show: true, drawVerticalLine: false),
    borderData: FlBorderData(show: false),
  ),
)
```

---

## 4. Building a LineChartBarData

```dart
LineChartBarData _barForScale(String scale, List<Evaluation> evaluations) {
  final maxScore = _kScaleMaxScores[scale] ?? 1;
  final color = _kScaleColors[scale] ?? Colors.grey;
  final spots = evaluations.asMap().entries.map((entry) {
    // X = index (oldest → newest), Y = normalized score
    return FlSpot(entry.key.toDouble(), normalize(entry.value.totalScore, maxScore));
  }).toList();

  return LineChartBarData(
    spots: spots,
    isCurved: true,
    curveSmoothness: 0.3,
    color: color,
    barWidth: 2.5,
    dotData: FlDotData(show: spots.length < 15), // hide dots when dense
    belowBarData: BarAreaData(
      show: true,
      color: color.withOpacity(0.08),
    ),
  );
}
```

---

## 5. Tooltip content

Show raw score + interpretation (not the normalized %). Access the original `Evaluation` via the spot index:

```dart
List<LineTooltipItem?> _tooltipItems(List<LineBarSpot> spots) {
  return spots.map((spot) {
    final eval = _evaluations[spot.spotIndex];
    return LineTooltipItem(
      '${eval.totalScore}/${_kScaleMaxScores[eval.scaleType]}\n${eval.interpretation}',
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    );
  }).toList();
}
```

---

## 6. X-axis date labels

Sort evaluations oldest → newest before building spots. Use the index as X and map back:

```dart
Widget _dateLabel(double value, TitleMeta meta) {
  final i = value.toInt();
  if (i < 0 || i >= _evaluations.length) return const SizedBox();
  final dt = _evaluations[i].createdAt;
  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: Text('${dt.day}/${dt.month}', style: const TextStyle(fontSize: 10)),
  );
}
```

Only show a label every N entries to avoid crowding: return `SizedBox()` when `i % spacing != 0`.

---

## 7. Empty state

Show a friendly message if a scale has fewer than 2 evaluations (can't draw a line):

```dart
if (evaluations.length < 2) {
  return Center(
    child: Text(
      'Se necesitan al menos 2 evaluaciones de ${scale.toUpperCase()} para mostrar la evolución.',
      textAlign: TextAlign.center,
    ),
  );
}
```

---

## 8. Multi-scale layout

Render one chart per scale type that has ≥ 2 evaluations. Wrap each in a `Card` with a title. Use a `ListView` so the user can scroll between charts.

Do **not** mix all scales in a single chart — the normalization makes values comparable visually, but clinically they are unrelated and mixing misleads the reader.

---

## 9. Performance

- Sort and normalize data **outside** `build()` — in the notifier or via a `Provider`.
- Use `const` constructors wherever possible for axis titles and grid config.
- If the list exceeds 50 evaluations per scale, consider sampling (show every Nth point) to keep rendering smooth.

---

## 10. What NOT to do

- Do **not** use `BarChart` for temporal data — `LineChart` is always correct here.
- Do **not** hardcode colors inline — use `_kScaleColors` so all charts are consistent.
- Do **not** show raw normalized values in tooltips — always show `score/maxScore`.
- Do **not** call `setState` or `ref.invalidate` from inside a chart callback — only from user gestures.
