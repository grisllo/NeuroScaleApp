import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neuroscale_app/core/errors/failures.dart';
import 'package:neuroscale_app/features/auth/domain/entities/app_user.dart';
import 'package:neuroscale_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:neuroscale_app/features/auth/domain/usecases/sign_up_usecase.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository mockRepo;
  late SignUpUseCase useCase;

  const testUser = AppUser(id: 'user-new', email: 'nuevo@example.com');
  const email = 'nuevo@example.com';
  const password = 'password123';

  setUp(() {
    mockRepo = _MockAuthRepository();
    useCase = SignUpUseCase(mockRepo);
  });

  test('devuelve AppUser tras registrar correctamente', () async {
    when(
      () => mockRepo.signUp(email: email, password: password),
    ).thenAnswer((_) async => testUser);

    final result = await useCase(email: email, password: password);

    expect(result, testUser);
    verify(() => mockRepo.signUp(email: email, password: password)).called(1);
  });

  test('propaga AuthFailure (ej. email ya registrado)', () {
    when(
      () => mockRepo.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(const AuthFailure('Email ya registrado'));

    expect(
      () => useCase(email: email, password: password),
      throwsA(isA<AuthFailure>()),
    );
  });
}
