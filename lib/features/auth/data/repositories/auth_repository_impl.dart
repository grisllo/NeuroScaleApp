import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/supabase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._datasource);

  final SupabaseAuthDatasource _datasource;

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _datasource.signIn(email: email, password: password);
    } on UnauthorizedException catch (e) {
      throw AuthFailure(e.message);
    } on ConnectionException catch (e) {
      throw NetworkFailure(e.message);
    } on AppException catch (e) {
      throw UnexpectedFailure(e.message);
    }
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
  }) async {
    try {
      return await _datasource.signUp(email: email, password: password);
    } on EmailConfirmationPendingException {
      throw const EmailConfirmationPendingFailure();
    } on RateLimitException {
      throw const RateLimitFailure();
    } on UnauthorizedException catch (e) {
      throw AuthFailure(e.message);
    } on ConnectionException catch (e) {
      throw NetworkFailure(e.message);
    } on AppException catch (e) {
      throw UnexpectedFailure(e.message);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _datasource.signOut();
    } on AppException catch (e) {
      throw UnexpectedFailure(e.message);
    }
  }

  @override
  Stream<AppUser?> watchSession() => _datasource.watchSession();

  @override
  Future<void> requestPasswordReset({
    required String email,
    String? redirectTo,
  }) async {
    try {
      await _datasource.requestPasswordReset(
        email: email,
        redirectTo: redirectTo,
      );
    } on ConnectionException catch (e) {
      throw NetworkFailure(e.message);
    } on AppException catch (e) {
      throw UnexpectedFailure(e.message);
    }
  }

  @override
  Future<void> updatePassword({required String password}) async {
    try {
      await _datasource.updatePassword(password: password);
    } on UnauthorizedException catch (e) {
      throw AuthFailure(e.message);
    } on ConnectionException catch (e) {
      throw NetworkFailure(e.message);
    } on AppException catch (e) {
      throw UnexpectedFailure(e.message);
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _datasource.deleteAccount();
    } on ConnectionException catch (e) {
      throw NetworkFailure(e.message);
    } on AppException catch (e) {
      throw UnexpectedFailure(e.message);
    }
  }
}
