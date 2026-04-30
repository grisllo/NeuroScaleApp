import 'algorithm_option.dart';
import 'algorithm_urgency.dart';

sealed class AlgorithmNode {
  const AlgorithmNode({required this.id});
  final String id;
}

final class QuestionNode extends AlgorithmNode {
  const QuestionNode({
    required super.id,
    required this.questionKey,
    this.hintKey,
    required this.options,
  });

  final String questionKey;
  final String? hintKey;
  final List<AlgorithmOption> options;
}

final class ResultNode extends AlgorithmNode {
  const ResultNode({
    required super.id,
    required this.titleKey,
    required this.urgency,
    required this.recommendationKeys,
  });

  final String titleKey;
  final AlgorithmUrgency urgency;
  final List<String> recommendationKeys;
}
