import 'package:flutter_test/flutter_test.dart';
import 'package:neuroscale_app/features/algorithms/domain/algorithms/stroke_code_algorithm.dart';
import 'package:neuroscale_app/features/algorithms/domain/entities/algorithm_node.dart';
import 'package:neuroscale_app/features/algorithms/domain/entities/algorithm_urgency.dart';
import 'package:neuroscale_app/features/algorithms/domain/usecases/evaluate_algorithm.dart';

ResultNode _traverse(List<String> optionIds) {
  var state = startAlgorithm(strokeCodeAlgorithm);
  for (final id in optionIds) {
    state = stepAlgorithm(state, id);
  }
  expect(state.isComplete, isTrue, reason: 'Path did not reach a result node');
  return state.currentNode as ResultNode;
}

void main() {
  group('strokeCodeAlgorithm — definition integrity', () {
    test('all nodes referenced in options exist', () {
      for (final node in strokeCodeAlgorithm.nodes.values) {
        if (node is QuestionNode) {
          for (final opt in node.options) {
            expect(
              strokeCodeAlgorithm.nodes.containsKey(opt.nextNodeId),
              isTrue,
              reason: 'nextNodeId "${opt.nextNodeId}" missing from node "${node.id}"',
            );
          }
        }
      }
    });

    test('startNodeId exists in nodes', () {
      expect(
        strokeCodeAlgorithm.nodes.containsKey(strokeCodeAlgorithm.startNodeId),
        isTrue,
      );
    });
  });

  group('strokeCodeAlgorithm — paths', () {
    // Out-of-window path
    test('out of window → r_out_of_window (moderate)', () {
      final r = _traverse(['no']);
      expect(r.id, 'r_out_of_window');
      expect(r.urgency, AlgorithmUrgency.moderate);
    });

    // CT not done
    test('in window + no CT → r_ct_first (high)', () {
      final r = _traverse(['yes', 'no']);
      expect(r.id, 'r_ct_first');
      expect(r.urgency, AlgorithmUrgency.high);
    });

    // Minor deficit
    test('in window + CT ok + minor deficit → r_minor_deficit (low)', () {
      final r = _traverse(['yes', 'yes', 'no']);
      expect(r.id, 'r_minor_deficit');
      expect(r.urgency, AlgorithmUrgency.low);
    });

    // Absolute contraindication
    test('absolute contraindication → r_absolute_ci (moderate)', () {
      final r = _traverse(['yes', 'yes', 'yes', 'yes']);
      expect(r.id, 'r_absolute_ci');
      expect(r.urgency, AlgorithmUrgency.moderate);
    });

    // BP not controlled
    test('BP not controlled → r_treat_bp (high)', () {
      final r = _traverse(['yes', 'yes', 'yes', 'no', 'no']);
      expect(r.id, 'r_treat_bp');
      expect(r.urgency, AlgorithmUrgency.high);
    });

    // Candidate < 3h
    test('BP ok + < 3h → r_candidate_3h (critical)', () {
      final r = _traverse(['yes', 'yes', 'yes', 'no', 'yes', 'yes']);
      expect(r.id, 'r_candidate_3h');
      expect(r.urgency, AlgorithmUrgency.critical);
    });

    // Candidate 3-4.5h with relative CI
    test('3-4.5h + relative CI → r_relative_ci (moderate)', () {
      final r = _traverse(['yes', 'yes', 'yes', 'no', 'yes', 'no', 'yes']);
      expect(r.id, 'r_relative_ci');
      expect(r.urgency, AlgorithmUrgency.moderate);
    });

    // Candidate 3-4.5h without relative CI
    test('3-4.5h + no relative CI → r_candidate_4h (critical)', () {
      final r = _traverse(['yes', 'yes', 'yes', 'no', 'yes', 'no', 'no']);
      expect(r.id, 'r_candidate_4h');
      expect(r.urgency, AlgorithmUrgency.critical);
    });
  });

  group('strokeCodeAlgorithm — result content', () {
    test('r_candidate_3h has 3 recommendations', () {
      final r = _traverse(['yes', 'yes', 'yes', 'no', 'yes', 'yes']);
      expect(r.recommendationKeys.length, 3);
    });

    test('r_candidate_4h has 3 recommendations', () {
      final r = _traverse(['yes', 'yes', 'yes', 'no', 'yes', 'no', 'no']);
      expect(r.recommendationKeys.length, 3);
    });
  });
}
