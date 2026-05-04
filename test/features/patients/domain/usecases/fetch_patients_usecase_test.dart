import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neuroscale_app/features/patients/domain/entities/patient.dart';
import 'package:neuroscale_app/features/patients/domain/repositories/patient_repository.dart';
import 'package:neuroscale_app/features/patients/domain/usecases/fetch_patients_usecase.dart';

class _MockPatientRepository extends Mock implements PatientRepository {}

void main() {
  late _MockPatientRepository mockRepo;
  late FetchPatientsUseCase useCase;

  setUp(() {
    mockRepo = _MockPatientRepository();
    useCase = FetchPatientsUseCase(mockRepo);
  });

  Patient buildPatient(String id) => Patient(
    id: id,
    userId: 'user-1',
    alias: 'P-$id',
    notes: '',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  test('delega al repositorio con el userId', () async {
    when(
      () => mockRepo.fetchAll(any(), searchQuery: any(named: 'searchQuery')),
    ).thenAnswer((_) async => [buildPatient('1'), buildPatient('2')]);

    final result = await useCase('user-1');

    expect(result, hasLength(2));
    verify(() => mockRepo.fetchAll('user-1', searchQuery: '')).called(1);
  });

  test('propaga searchQuery al repositorio', () async {
    when(
      () => mockRepo.fetchAll(any(), searchQuery: any(named: 'searchQuery')),
    ).thenAnswer((_) async => []);

    await useCase('user-1', searchQuery: 'P-001');

    verify(() => mockRepo.fetchAll('user-1', searchQuery: 'P-001')).called(1);
  });

  test('retorna lista vacía cuando no hay pacientes', () async {
    when(
      () => mockRepo.fetchAll(any(), searchQuery: any(named: 'searchQuery')),
    ).thenAnswer((_) async => []);

    final result = await useCase('user-1');

    expect(result, isEmpty);
  });
}
