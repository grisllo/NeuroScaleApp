import 'severity.dart';

class ScaleResult {
  const ScaleResult({
    required this.totalScore,
    required this.maxScore,
    required this.severity,
    required this.interpretation,
    required this.itemScores,
  });

  final int totalScore;
  final int maxScore;
  final Severity severity;
  final String interpretation;

  /// Raw item scores keyed by ScaleItem.key.
  final Map<String, int> itemScores;
}
