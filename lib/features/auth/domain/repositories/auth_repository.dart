import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> signIn({required String email, required String password});
  Future<AppUser> signUp({required String email, required String password});
  Future<void> signOut();
  Stream<AppUser?> watchSession();
  Future<void> requestPasswordReset({
    required String email,
    String? redirectTo,
  });
  Future<void> updatePassword({required String password});
}
