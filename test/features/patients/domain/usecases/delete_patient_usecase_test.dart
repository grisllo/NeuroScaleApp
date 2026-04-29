import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neuroscale_app/features/patients/domain/repositories/patient_repository.dart';
import 'package:neuroscale_app/features/patients/domain/usecases/delete_patient_usecase.dart';

class _MockPatientRepository extends Mock implements PatientRepository {}

void main() {
  late _MockPatientRepository mockRepo;
  late DeletePatientUseCase useCase;

  setUp(() {
    mockRepo = _MockPatientRepository();
    useCase = DeletePatientUseCase(mockRepo);
  });

  test('delega al repositorio con el id correcto', () async {
    when(() => mockRepo.delete(any())).thenAnswer((_) async {});

    await useCase('patient-uuid');

    verify(() => mockRepo.delete('patient-uuid')).called(1);
  });

  test('propaga errores del repositorio', () async {
    when(() => mockRepo.delete(any())).thenThrow(Exception('network error'));

    expect(() => useCase('patient-uuid'), throwsA(isA<Exception>()));
  });
}
