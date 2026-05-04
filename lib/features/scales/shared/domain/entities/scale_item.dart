class ScaleItem {
  const ScaleItem({
    required this.key,
    required this.labelKey,
    required this.min,
    required this.max,
    required this.options,
    this.untestableValue,
  });

  final String key;
  final String labelKey;
  final int min;
  final int max;

  /// Ordered list of (value, description) pairs, value ascending from min to max.
  /// If [untestableValue] is set, that value may also appear as an extra option
  /// (outside [min]..[max]) and represents an "untestable" answer that is
  /// excluded from the total score.
  final List<(int, String)> options;

  /// Optional sentinel value representing an "untestable" answer for this item
  /// (e.g. NIHSS uses 9 for amputation, joint fusion or intubation). When null,
  /// the item does not accept an untestable code.
  final int? untestableValue;
}
