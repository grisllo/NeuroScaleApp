import 'package:flutter_test/flutter_test.dart' hide Evaluation;
import 'package:mocktail/mocktail.dart';
import 'package:neuroscale_app/core/errors/failures.dart';
import 'package:neuroscale_app/features/evaluations/domain/entities/evaluation.dart';
import 'package:neuroscale_app/features/evaluations/domain/repositories/evaluation_repository.dart';
import 'package:neuroscale_app/features/evaluations/domain/usecases/save_evaluation_usecase.dart';

class _MockEvaluationRepository extends Mock implements EvaluationRepository {}

void main() {
  late _MockEvaluationRepository mockRepo;
  late SaveEvaluationUseCase useCase;

  setUp(() {
    mockRepo = _MockEvaluationRepository();
    useCase = SaveEvaluationUseCase(mockRepo);
    registerFallbackValue(
      Evaluation(
        id: '',
        userId: '',
        scaleType: 'gcs',
        scaleVersion: 1,
        caseDescription: 'fallback',
        totalScore: 0,
        interpretation: '',
        detailedScores: const {},
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    );
  });

  Evaluation validEvaluation({String description = 'Varón, 65 años, TCE'}) =>
      Evaluation(
        id: 'eval-1',
        userId: 'user-1',
        scaleType: 'gcs',
        scaleVersion: 1,
        caseDescription: description,
        totalScore: 15,
        interpretation: 'Leve',
        detailedScores: const {'eye': 4, 'verbal': 5, 'motor': 6},
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

  test('llama al repositorio con evaluación válida', () async {
    when(() => mockRepo.save(any())).thenAnswer((_) async {});

    await useCase(validEvaluation());

    verify(() => mockRepo.save(any())).called(1);
  });

  test('lanza ValidationFailure si caseDescription está vacío', () {
    expect(
      () => useCase(validEvaluation(description: '')),
      throwsA(isA<ValidationFailure>()),
    );
    verifyNever(() => mockRepo.save(any()));
  });

  test('lanza ValidationFailure si caseDescription solo tiene espacios', () {
    expect(
      () => useCase(validEvaluation(description: '   ')),
      throwsA(isA<ValidationFailure>()),
    );
    verifyNever(() => mockRepo.save(any()));
  });

  test('no lanza si la descripción tiene al menos un carácter no blanco',
      () async {
    when(() => mockRepo.save(any())).thenAnswer((_) async {});

    await expectLater(
      useCase(validEvaluation(description: 'x')),
      completes,
    );
  });
}
