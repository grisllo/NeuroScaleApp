import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/env/env.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/request_password_reset_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/update_password_usecase.dart';
import 'session_provider.dart';

class PasswordResetController extends AsyncNotifier<void> {
  @override
  // Synchronous build: avoids AsyncLoading→AsyncData on init that would
  // trigger the "sent" listener in ForgotPasswordScreen prematurely.
  FutureOr<void> build() {}

  Future<void> requestReset({required String email}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = _requireRepo();
      final redirectTo = Env.redirectUrl.isEmpty
          ? null
          : '${Env.redirectUrl}/reset-password';
      await RequestPasswordResetUseCase(
        repo,
      ).call(email: email, redirectTo: redirectTo);
    });
  }

  Future<void> updatePassword({required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = _requireRepo();
      await UpdatePasswordUseCase(repo).call(password: password);
    });
  }

  /// Verifies [currentPassword] by re-authenticating, then sets [newPassword].
  Future<void> verifyAndUpdatePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = _requireRepo();
      await SignInUseCase(repo).call(email: email, password: currentPassword);
      await UpdatePasswordUseCase(repo).call(password: newPassword);
    });
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

final passwordResetControllerProvider =
    AsyncNotifierProvider<PasswordResetController, void>(
      PasswordResetController.new,
    );
