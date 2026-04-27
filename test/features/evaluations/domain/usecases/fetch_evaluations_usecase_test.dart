import 'package:flutter_test/flutter_test.dart' hide Evaluation;
import 'package:mocktail/mocktail.dart';
import 'package:neuroscale_app/features/evaluations/domain/entities/evaluation.dart';
import 'package:neuroscale_app/features/evaluations/domain/repositories/evaluation_repository.dart';
import 'package:neuroscale_app/features/evaluations/domain/usecases/fetch_evaluations_usecase.dart';

class _MockEvaluationRepository extends Mock implements EvaluationRepository {}

Evaluation _eval(String id, DateTime createdAt) => Evaluation(
      id: id,
      userId: 'user-1',
      scaleType: 'gcs',
      scaleVersion: 1,
      caseDescription: 'caso test',
      totalScore: 15,
      interpretation: 'Leve',
      detailedScores: const {},
      createdAt: createdAt,
      updatedAt: createdAt,
    );

void main() {
  late _MockEvaluationRepository mockRepo;
  late FetchEvaluationsUseCase useCase;

  setUp(() {
    mockRepo = _MockEvaluationRepository();
    useCase = FetchEvaluationsUseCase(mockRepo);
  });

  test('devuelve la lista que retorna el repositorio', () async {
    final evaluations = [
      _eval('e1', DateTime(2026, 4, 27)),
      _eval('e2', DateTime(2026, 4, 26)),
    ];
    when(() => mockRepo.fetchAll('user-1'))
        .thenAnswer((_) async => evaluations);

    final result = await useCase('user-1');

    expect(result, evaluations);
    verify(() => mockRepo.fetchAll('user-1')).called(1);
  });

  test('devuelve lista vacía si el repositorio no tiene datos', () async {
    when(() => mockRepo.fetchAll('user-1')).thenAnswer((_) async => []);

    final result = await useCase('user-1');

    expect(result, isEmpty);
  });

  test('la lista llega ordenada por createdAt desc (orden delegado al repo)',
      () async {
    final newer = _eval('e1', DateTime(2026, 4, 27));
    final older = _eval('e2', DateTime(2026, 4, 26));
    when(() => mockRepo.fetchAll('user-1'))
        .thenAnswer((_) async => [newer, older]);

    final result = await useCase('user-1');

    expect(result.first.id, 'e1');
    expect(result.last.id, 'e2');
  });

  test('propaga la excepción si el repositorio falla', () {
    when(() => mockRepo.fetchAll(any())).thenThrow(Exception('network error'));

    expect(() => useCase('user-1'), throwsException);
  });
}
