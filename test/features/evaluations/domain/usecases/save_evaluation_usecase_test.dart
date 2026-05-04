import 'package:flutter_test/flutter_test.dart' hide Evaluation;
import 'package:mocktail/mocktail.dart';
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

  Evaluation buildEvaluation({
    String description = 'Notas de la evaluación',
    String? patientId,
  }) => Evaluation(
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
    patientId: patientId,
  );

  test('llama al repositorio con evaluación válida', () async {
    when(() => mockRepo.save(any())).thenAnswer((_) async {});

    await useCase(buildEvaluation());

    verify(() => mockRepo.save(any())).called(1);
  });

  test(
    'acepta caseDescription vacío (ahora opcional desde Fase 3.2)',
    () async {
      when(() => mockRepo.save(any())).thenAnswer((_) async {});

      await expectLater(useCase(buildEvaluation(description: '')), completes);
      verify(() => mockRepo.save(any())).called(1);
    },
  );

  test('acepta evaluación con patientId asignado', () async {
    when(() => mockRepo.save(any())).thenAnswer((_) async {});

    await useCase(buildEvaluation(patientId: 'patient-uuid'));

    verify(() => mockRepo.save(any())).called(1);
  });

  test('acepta evaluación sin patientId (legacy / sin asignar)', () async {
    when(() => mockRepo.save(any())).thenAnswer((_) async {});

    await useCase(buildEvaluation(patientId: null));

    verify(() => mockRepo.save(any())).called(1);
  });
}
