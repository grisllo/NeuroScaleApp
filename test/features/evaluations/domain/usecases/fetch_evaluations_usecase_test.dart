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

// Matcher helper: matches any fetchAll call for a given userId
void _stubFetchAll(
  _MockEvaluationRepository repo,
  String userId,
  Future<List<Evaluation>> Function() answer,
) {
  when(
    () => repo.fetchAll(
      userId,
      scales: any(named: 'scales'),
      dateFrom: any(named: 'dateFrom'),
      dateTo: any(named: 'dateTo'),
      searchQuery: any(named: 'searchQuery'),
      page: any(named: 'page'),
      pageSize: any(named: 'pageSize'),
    ),
  ).thenAnswer((_) => answer());
}

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
    _stubFetchAll(mockRepo, 'user-1', () async => evaluations);

    final result = await useCase('user-1');

    expect(result, evaluations);
  });

  test('devuelve lista vacía si el repositorio no tiene datos', () async {
    _stubFetchAll(mockRepo, 'user-1', () async => []);

    final result = await useCase('user-1');

    expect(result, isEmpty);
  });

  test('la lista llega ordenada por createdAt desc (orden delegado al repo)',
      () async {
    final newer = _eval('e1', DateTime(2026, 4, 27));
    final older = _eval('e2', DateTime(2026, 4, 26));
    _stubFetchAll(mockRepo, 'user-1', () async => [newer, older]);

    final result = await useCase('user-1');

    expect(result.first.id, 'e1');
    expect(result.last.id, 'e2');
  });

  test('propaga la excepción si el repositorio falla', () {
    when(
      () => mockRepo.fetchAll(
        any(),
        scales: any(named: 'scales'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        searchQuery: any(named: 'searchQuery'),
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
      ),
    ).thenThrow(Exception('network error'));

    expect(() => useCase('user-1'), throwsException);
  });

  test('pasa filtro de escalas al repositorio', () async {
    _stubFetchAll(mockRepo, 'user-1', () async => []);

    await useCase('user-1', scales: {'gcs', 'barthel'});

    verify(
      () => mockRepo.fetchAll(
        'user-1',
        scales: {'gcs', 'barthel'},
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        searchQuery: any(named: 'searchQuery'),
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
      ),
    ).called(1);
  });

  test('pasa búsqueda textual al repositorio', () async {
    _stubFetchAll(mockRepo, 'user-1', () async => []);

    await useCase('user-1', searchQuery: 'varón');

    verify(
      () => mockRepo.fetchAll(
        'user-1',
        scales: any(named: 'scales'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        searchQuery: 'varón',
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
      ),
    ).called(1);
  });

  test('pasa número de página al repositorio', () async {
    _stubFetchAll(mockRepo, 'user-1', () async => []);

    await useCase('user-1', page: 2);

    verify(
      () => mockRepo.fetchAll(
        'user-1',
        scales: any(named: 'scales'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        searchQuery: any(named: 'searchQuery'),
        page: 2,
        pageSize: any(named: 'pageSize'),
      ),
    ).called(1);
  });
}
