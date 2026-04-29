import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neuroscale_app/core/errors/failures.dart';
import 'package:neuroscale_app/features/patients/domain/entities/patient.dart';
import 'package:neuroscale_app/features/patients/domain/repositories/patient_repository.dart';
import 'package:neuroscale_app/features/patients/domain/usecases/create_patient_usecase.dart';

class _MockPatientRepository extends Mock implements PatientRepository {}

void main() {
  late _MockPatientRepository mockRepo;
  late CreatePatientUseCase useCase;

  setUp(() {
    mockRepo = _MockPatientRepository();
    useCase = CreatePatientUseCase(mockRepo);
    registerFallbackValue(
      Patient(
        id: '',
        userId: '',
        alias: 'fallback',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    );
  });

  Patient buildCreated({String alias = 'P-001', String notes = ''}) => Patient(
        id: 'patient-uuid',
        userId: 'user-1',
        alias: alias,
        notes: notes,
        createdAt: DateTime(2026, 4, 29),
        updatedAt: DateTime(2026, 4, 29),
      );

  test('crea paciente con alias y notas trimmed', () async {
    when(() => mockRepo.create(any())).thenAnswer((_) async => buildCreated());

    final result = await useCase(
      userId: 'user-1',
      alias: '  P-001  ',
      notes: '  ictus isquémico  ',
    );

    expect(result.id, 'patient-uuid');
    final captured =
        verify(() => mockRepo.create(captureAny())).captured.single as Patient;
    expect(captured.alias, 'P-001');
    expect(captured.notes, 'ictus isquémico');
    expect(captured.userId, 'user-1');
  });

  test('lanza ValidationFailure si alias está vacío', () {
    expect(
      () => useCase(userId: 'user-1', alias: ''),
      throwsA(isA<ValidationFailure>()),
    );
    verifyNever(() => mockRepo.create(any()));
  });

  test('lanza ValidationFailure si alias solo tiene espacios', () {
    expect(
      () => useCase(userId: 'user-1', alias: '   '),
      throwsA(isA<ValidationFailure>()),
    );
    verifyNever(() => mockRepo.create(any()));
  });

  test('notas opcionales por defecto vacías', () async {
    when(() => mockRepo.create(any())).thenAnswer((_) async => buildCreated());

    await useCase(userId: 'user-1', alias: 'P-001');

    final captured =
        verify(() => mockRepo.create(captureAny())).captured.single as Patient;
    expect(captured.notes, '');
  });
}
