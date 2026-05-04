import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neuroscale_app/core/errors/failures.dart';
import 'package:neuroscale_app/features/auth/domain/entities/app_user.dart';
import 'package:neuroscale_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:neuroscale_app/features/auth/domain/usecases/sign_in_usecase.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository mockRepo;
  late SignInUseCase useCase;

  const testUser = AppUser(id: 'user-1', email: 'test@example.com');
  const email = 'test@example.com';
  const password = 'password123';

  setUp(() {
    mockRepo = _MockAuthRepository();
    useCase = SignInUseCase(mockRepo);
  });

  test(
    'devuelve AppUser cuando el repositorio autentica correctamente',
    () async {
      when(
        () => mockRepo.signIn(email: email, password: password),
      ).thenAnswer((_) async => testUser);

      final result = await useCase(email: email, password: password);

      expect(result, testUser);
      verify(() => mockRepo.signIn(email: email, password: password)).called(1);
    },
  );

  test('propaga AuthFailure del repositorio sin modificarla', () {
    when(
      () => mockRepo.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(const AuthFailure('Credenciales incorrectas'));

    expect(
      () => useCase(email: email, password: password),
      throwsA(isA<AuthFailure>()),
    );
  });

  test('propaga UnexpectedFailure del repositorio', () {
    when(
      () => mockRepo.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(const UnexpectedFailure('Error de servidor'));

    expect(
      () => useCase(email: email, password: password),
      throwsA(isA<UnexpectedFailure>()),
    );
  });
}
