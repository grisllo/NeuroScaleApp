import 'package:flutter_test/flutter_test.dart' hide Evaluation;
import 'package:mocktail/mocktail.dart';
import 'package:neuroscale_app/features/evaluations/domain/repositories/evaluation_repository.dart';
import 'package:neuroscale_app/features/evaluations/domain/usecases/delete_evaluation_usecase.dart';

class _MockEvaluationRepository extends Mock implements EvaluationRepository {}

void main() {
  late _MockEvaluationRepository mockRepo;
  late DeleteEvaluationUseCase useCase;

  setUp(() {
    mockRepo = _MockEvaluationRepository();
    useCase = DeleteEvaluationUseCase(mockRepo);
  });

  test('llama al repositorio con el id correcto', () async {
    when(() => mockRepo.delete('eval-1')).thenAnswer((_) async {});

    await useCase('eval-1');

    verify(() => mockRepo.delete('eval-1')).called(1);
  });

  test('no llama al repositorio con un id distinto', () async {
    when(() => mockRepo.delete('eval-1')).thenAnswer((_) async {});

    await useCase('eval-1');

    verifyNever(() => mockRepo.delete('otro-id'));
  });

  test('propaga la excepción si el repositorio falla', () {
    when(() => mockRepo.delete(any())).thenThrow(Exception('network error'));

    expect(() => useCase('eval-1'), throwsException);
  });
}
