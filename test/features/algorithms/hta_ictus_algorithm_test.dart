import 'package:flutter_test/flutter_test.dart';
import 'package:neuroscale_app/features/algorithms/domain/algorithms/hta_ictus_algorithm.dart';
import 'package:neuroscale_app/features/algorithms/domain/entities/algorithm_node.dart';
import 'package:neuroscale_app/features/algorithms/domain/entities/algorithm_urgency.dart';
import 'package:neuroscale_app/features/algorithms/domain/usecases/evaluate_algorithm.dart';

ResultNode _traverse(List<String> optionIds) {
  var state = startAlgorithm(htaIctusAlgorithm);
  for (final id in optionIds) {
    state = stepAlgorithm(state, id);
  }
  expect(state.isComplete, isTrue, reason: 'Path did not reach a result node');
  return state.currentNode as ResultNode;
}

void main() {
  group('htaIctusAlgorithm — definition integrity', () {
    test('all nodes referenced in options exist', () {
      for (final node in htaIctusAlgorithm.nodes.values) {
        if (node is QuestionNode) {
          for (final opt in node.options) {
            expect(
              htaIctusAlgorithm.nodes.containsKey(opt.nextNodeId),
              isTrue,
              reason: 'nextNodeId "${opt.nextNodeId}" missing from node "${node.id}"',
            );
          }
        }
      }
    });

    test('startNodeId exists in nodes', () {
      expect(
        htaIctusAlgorithm.nodes.containsKey(htaIctusAlgorithm.startNodeId),
        isTrue,
      );
    });
  });

  group('htaIctusAlgorithm — paths', () {
    // Unknown type
    test('unknown type → r_unknown_type (high)', () {
      final r = _traverse(['unknown']);
      expect(r.id, 'r_unknown_type');
      expect(r.urgency, AlgorithmUrgency.high);
    });

    // Ischemic + reperfusion
    test('ischemic + reperfusion → r_reperfusion_target (critical)', () {
      final r = _traverse(['ischemic', 'yes']);
      expect(r.id, 'r_reperfusion_target');
      expect(r.urgency, AlgorithmUrgency.critical);
    });

    // Ischemic + no reperfusion + BP > 220/120
    test('ischemic + no reperfusion + BP > 220/120 → r_ischemic_treat (high)', () {
      final r = _traverse(['ischemic', 'no', 'yes']);
      expect(r.id, 'r_ischemic_treat');
      expect(r.urgency, AlgorithmUrgency.high);
    });

    // Ischemic + no reperfusion + BP ≤ 220/120
    test('ischemic + no reperfusion + BP ok → r_ischemic_observe (info)', () {
      final r = _traverse(['ischemic', 'no', 'no']);
      expect(r.id, 'r_ischemic_observe');
      expect(r.urgency, AlgorithmUrgency.info);
    });

    // Hemorrhagic + SBP > 150
    test('hemorrhagic + SBP > 150 → r_ich_treat (high)', () {
      final r = _traverse(['hemorrhagic', 'yes']);
      expect(r.id, 'r_ich_treat');
      expect(r.urgency, AlgorithmUrgency.high);
    });

    // Hemorrhagic + SBP ≤ 150
    test('hemorrhagic + SBP ok → r_ich_observe (info)', () {
      final r = _traverse(['hemorrhagic', 'no']);
      expect(r.id, 'r_ich_observe');
      expect(r.urgency, AlgorithmUrgency.info);
    });

    // SAH + vasospasm
    test('SAH + vasospasm → r_sah_vasospasm (high)', () {
      final r = _traverse(['sah', 'yes']);
      expect(r.id, 'r_sah_vasospasm');
      expect(r.urgency, AlgorithmUrgency.high);
    });

    // SAH + no vasospasm
    test('SAH + no vasospasm → r_sah_no_vasospasm (moderate)', () {
      final r = _traverse(['sah', 'no']);
      expect(r.id, 'r_sah_no_vasospasm');
      expect(r.urgency, AlgorithmUrgency.moderate);
    });
  });

  group('htaIctusAlgorithm — result content', () {
    test('all results have exactly 3 recommendations', () {
      final results = htaIctusAlgorithm.nodes.values.whereType<ResultNode>();
      for (final r in results) {
        expect(r.recommendationKeys.length, 3, reason: '${r.id} should have 3 recs');
      }
    });
  });
}
