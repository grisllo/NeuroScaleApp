import 'package:flutter_test/flutter_test.dart';
import 'package:neuroscale_app/features/algorithms/domain/entities/algorithm_definition.dart';
import 'package:neuroscale_app/features/algorithms/domain/entities/algorithm_node.dart';
import 'package:neuroscale_app/features/algorithms/domain/entities/algorithm_option.dart';
import 'package:neuroscale_app/features/algorithms/domain/entities/algorithm_urgency.dart';
import 'package:neuroscale_app/features/algorithms/domain/usecases/evaluate_algorithm.dart';

// Minimal algorithm for unit testing traversal logic.
const _questionA = QuestionNode(
  id: 'q_a',
  questionKey: 'qA',
  options: [
    AlgorithmOption(id: 'yes', labelKey: 'yes', nextNodeId: 'q_b'),
    AlgorithmOption(id: 'no', labelKey: 'no', nextNodeId: 'r_end_no'),
  ],
);

const _questionB = QuestionNode(
  id: 'q_b',
  questionKey: 'qB',
  options: [
    AlgorithmOption(id: 'opt1', labelKey: 'opt1', nextNodeId: 'r_end_yes'),
    AlgorithmOption(id: 'opt2', labelKey: 'opt2', nextNodeId: 'r_end_no'),
  ],
);

const _resultYes = ResultNode(
  id: 'r_end_yes',
  titleKey: 'resultYes',
  urgency: AlgorithmUrgency.high,
  recommendationKeys: ['rec1'],
);

const _resultNo = ResultNode(
  id: 'r_end_no',
  titleKey: 'resultNo',
  urgency: AlgorithmUrgency.info,
  recommendationKeys: ['rec2'],
);

const _testDef = AlgorithmDefinition(
  id: 'test',
  titleKey: 'testTitle',
  descriptionKey: 'testDesc',
  startNodeId: 'q_a',
  nodes: {
    'q_a': _questionA,
    'q_b': _questionB,
    'r_end_yes': _resultYes,
    'r_end_no': _resultNo,
  },
);

void main() {
  group('startAlgorithm', () {
    test('sets path to [startNodeId]', () {
      final state = startAlgorithm(_testDef);
      expect(state.path, ['q_a']);
      expect(state.selectedOptionIds, isEmpty);
    });

    test('currentNode is the start node', () {
      final state = startAlgorithm(_testDef);
      expect(state.currentNode.id, 'q_a');
    });

    test('isComplete is false at start', () {
      expect(startAlgorithm(_testDef).isComplete, isFalse);
    });

    test('canGoBack is false at start', () {
      expect(startAlgorithm(_testDef).canGoBack, isFalse);
    });
  });

  group('stepAlgorithm', () {
    test('advances to next node on valid option', () {
      final s0 = startAlgorithm(_testDef);
      final s1 = stepAlgorithm(s0, 'yes');
      expect(s1.currentNode.id, 'q_b');
      expect(s1.path, ['q_a', 'q_b']);
      expect(s1.selectedOptionIds, ['yes']);
    });

    test('reaches ResultNode after full path', () {
      final s0 = startAlgorithm(_testDef);
      final s1 = stepAlgorithm(s0, 'yes');
      final s2 = stepAlgorithm(s1, 'opt1');
      expect(s2.isComplete, isTrue);
      expect(s2.currentNode, isA<ResultNode>());
      expect((s2.currentNode as ResultNode).id, 'r_end_yes');
    });

    test('takes the "no" branch directly to result', () {
      final s0 = startAlgorithm(_testDef);
      final s1 = stepAlgorithm(s0, 'no');
      expect(s1.isComplete, isTrue);
      expect((s1.currentNode as ResultNode).id, 'r_end_no');
    });

    test('throws StateError when stepping from a ResultNode', () {
      final s0 = startAlgorithm(_testDef);
      final s1 = stepAlgorithm(s0, 'no'); // reaches result
      expect(() => stepAlgorithm(s1, 'any'), throwsStateError);
    });

    test('throws ArgumentError for unknown option id', () {
      final s0 = startAlgorithm(_testDef);
      expect(() => stepAlgorithm(s0, 'invalid'), throwsArgumentError);
    });

    test('stepCount increases by one per step', () {
      final s0 = startAlgorithm(_testDef);
      expect(s0.stepCount, 0);
      final s1 = stepAlgorithm(s0, 'yes');
      expect(s1.stepCount, 1);
      final s2 = stepAlgorithm(s1, 'opt1');
      expect(s2.stepCount, 2);
    });
  });

  group('backAlgorithm', () {
    test('returns to previous node', () {
      final s0 = startAlgorithm(_testDef);
      final s1 = stepAlgorithm(s0, 'yes');
      final s2 = backAlgorithm(s1);
      expect(s2.currentNode.id, 'q_a');
      expect(s2.path, ['q_a']);
      expect(s2.selectedOptionIds, isEmpty);
    });

    test('no-op when already at start', () {
      final s0 = startAlgorithm(_testDef);
      final s1 = backAlgorithm(s0);
      expect(s1.path, s0.path);
    });

    test('can go back from a ResultNode', () {
      final s0 = startAlgorithm(_testDef);
      final s1 = stepAlgorithm(s0, 'no');
      expect(s1.isComplete, isTrue);
      final s2 = backAlgorithm(s1);
      expect(s2.isComplete, isFalse);
      expect(s2.currentNode.id, 'q_a');
    });

    test('canGoBack is true after one step', () {
      final s1 = stepAlgorithm(startAlgorithm(_testDef), 'yes');
      expect(s1.canGoBack, isTrue);
    });
  });

  group('restartAlgorithm', () {
    test('resets to initial state', () {
      final s0 = startAlgorithm(_testDef);
      final s2 = stepAlgorithm(stepAlgorithm(s0, 'yes'), 'opt1');
      final reset = restartAlgorithm(s2);
      expect(reset.path, ['q_a']);
      expect(reset.selectedOptionIds, isEmpty);
      expect(reset.isComplete, isFalse);
    });
  });
}
