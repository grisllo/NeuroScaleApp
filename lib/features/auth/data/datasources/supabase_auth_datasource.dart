import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/app_user_model.dart';

class SupabaseAuthDatasource {
  const SupabaseAuthDatasource(this._client);

  final SupabaseClient _client;

  Future<AppUserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) throw const UnauthorizedException('Login fallido.');
      return AppUserModel.fromSupabaseUser(user);
    } on AuthException catch (e) {
      throw UnauthorizedException(e.message);
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<AppUserModel> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) throw const UnauthorizedException('Registro fallido.');
      return AppUserModel.fromSupabaseUser(user);
    } on AuthException catch (e) {
      throw UnauthorizedException(e.message);
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw UnauthorizedException(e.message);
    }
  }

  Stream<AppUserModel?> watchSession() =>
      _client.auth.onAuthStateChange.map((event) {
        final user = event.session?.user;
        return user != null ? AppUserModel.fromSupabaseUser(user) : null;
      });
}
