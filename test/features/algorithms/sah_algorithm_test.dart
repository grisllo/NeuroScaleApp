import 'package:flutter_test/flutter_test.dart';
import 'package:neuroscale_app/features/algorithms/domain/algorithms/sah_algorithm.dart';
import 'package:neuroscale_app/features/algorithms/domain/entities/algorithm_node.dart';
import 'package:neuroscale_app/features/algorithms/domain/entities/algorithm_urgency.dart';
import 'package:neuroscale_app/features/algorithms/domain/usecases/evaluate_algorithm.dart';

ResultNode _traverse(List<String> optionIds) {
  var state = startAlgorithm(sahAlgorithm);
  for (final id in optionIds) {
    state = stepAlgorithm(state, id);
  }
  expect(state.isComplete, isTrue, reason: 'Path did not reach a result node');
  return state.currentNode as ResultNode;
}

void main() {
  group('sahAlgorithm — definition integrity', () {
    test('all nodes referenced in options exist', () {
      for (final node in sahAlgorithm.nodes.values) {
        if (node is QuestionNode) {
          for (final opt in node.options) {
            expect(
              sahAlgorithm.nodes.containsKey(opt.nextNodeId),
              isTrue,
              reason:
                  'nextNodeId "${opt.nextNodeId}" missing from node "${node.id}"',
            );
          }
        }
      }
    });

    test('startNodeId exists in nodes', () {
      expect(sahAlgorithm.nodes.containsKey(sahAlgorithm.startNodeId), isTrue);
    });
  });

  group('sahAlgorithm — paths', () {
    // Alert + no focal deficit + Fisher 1-2
    test('alert + no deficit + Fisher 1-2 → r_hh1_fisher_1_2 (moderate)', () {
      final r = _traverse(['alert', 'no', 'fisher_1_2']);
      expect(r.id, 'r_hh1_fisher_1_2');
      expect(r.urgency, AlgorithmUrgency.moderate);
    });

    // Alert + no focal deficit + Fisher 3-4
    test('alert + no deficit + Fisher 3-4 → r_hh1_fisher_3_4 (high)', () {
      final r = _traverse(['alert', 'no', 'fisher_3_4']);
      expect(r.id, 'r_hh1_fisher_3_4');
      expect(r.urgency, AlgorithmUrgency.high);
    });

    // Alert + focal deficit → Hunt-Hess II
    test('alert + focal deficit → r_hh2 (high)', () {
      final r = _traverse(['alert', 'yes']);
      expect(r.id, 'r_hh2');
      expect(r.urgency, AlgorithmUrgency.high);
    });

    // Drowsy → Hunt-Hess III
    test('drowsy → r_hh3 (critical)', () {
      final r = _traverse(['drowsy']);
      expect(r.id, 'r_hh3');
      expect(r.urgency, AlgorithmUrgency.critical);
    });

    // Stupor/coma → Hunt-Hess IV-V
    test('stupor/coma → r_hh4_5 (critical)', () {
      final r = _traverse(['stupor']);
      expect(r.id, 'r_hh4_5');
      expect(r.urgency, AlgorithmUrgency.critical);
    });
  });

  group('sahAlgorithm — result content', () {
    test('all results have exactly 3 recommendations', () {
      final results = sahAlgorithm.nodes.values.whereType<ResultNode>();
      for (final r in results) {
        expect(
          r.recommendationKeys.length,
          3,
          reason: '${r.id} should have 3 recs',
        );
      }
    });

    test('critical results are r_hh3 and r_hh4_5', () {
      final critical = sahAlgorithm.nodes.values
          .whereType<ResultNode>()
          .where((r) => r.urgency == AlgorithmUrgency.critical)
          .map((r) => r.id)
          .toSet();
      expect(critical, {'r_hh3', 'r_hh4_5'});
    });
  });
}
