class ScaleItem {
  const ScaleItem({
    required this.key,
    required this.label,
    required this.min,
    required this.max,
    required this.options,
  });

  final String key;
  final String label;
  final int min;
  final int max;

  /// Ordered list of (value, description) pairs, value ascending from min to max.
  final List<(int, String)> options;
}
