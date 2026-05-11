import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import 'session_provider.dart';

class AuthController extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async => null;

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = _requireRepo();
      return SignInUseCase(repo).call(email: email, password: password);
    });
  }

  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = _requireRepo();
      return SignUpUseCase(repo).call(email: email, password: password);
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      final repo = _requireRepo();
      await SignOutUseCase(repo).call();
    } catch (_) {
      // Swallow signOut errors — session is cleared client-side regardless.
    }
    state = const AsyncData(null);
  }

  Future<void> deleteAccount() async {
    state = const AsyncLoading();
    try {
      final repo = _requireRepo();
      await DeleteAccountUseCase(repo).call();
    } catch (_) {
      rethrow;
    } finally {
      state = const AsyncData(null);
    }
  }

  AuthRepository _requireRepo() {
    try {
      return ref.read(authRepositoryProvider);
    } catch (_) {
      throw const ConfigFailure(
        'El servidor no está disponible. Comprueba tu conexión.',
      );
    }
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AppUser?>(
  AuthController.new,
);
