import 'dart:io';

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
    } on SocketException {
      throw const ConnectionException('Sin conexión a internet.');
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
      if (response.session == null) {
        throw const EmailConfirmationPendingException();
      }
      return AppUserModel.fromSupabaseUser(user);
    } on EmailConfirmationPendingException {
      rethrow;
    } on AuthException catch (e) {
      if (e.statusCode == '429') throw const RateLimitException();
      throw UnauthorizedException(e.message);
    } on SocketException {
      throw const ConnectionException('Sin conexión a internet.');
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
    } on SocketException {
      // Ignorar errores de red en signOut — la sesión local se borra igualmente.
    }
  }

  Stream<AppUserModel?> watchSession() =>
      _client.auth.onAuthStateChange.map((event) {
        final user = event.session?.user;
        return user != null ? AppUserModel.fromSupabaseUser(user) : null;
      });

  Future<void> requestPasswordReset({
    required String email,
    String? redirectTo,
  }) async {
    try {
      await _client.auth.resetPasswordForEmail(email, redirectTo: redirectTo);
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } on SocketException {
      throw const ConnectionException('Sin conexión a internet.');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> updatePassword({required String password}) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: password));
    } on AuthException catch (e) {
      throw UnauthorizedException(e.message);
    } on SocketException {
      throw const ConnectionException('Sin conexión a internet.');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> deleteAccount() async {
    try {
      final response = await _client.functions.invoke('delete-account');
      if (response.status != 200) {
        throw ServerException(
          'Error al borrar la cuenta (${response.status}).',
        );
      }
    } on SocketException {
      throw const ConnectionException('Sin conexión a internet.');
    } catch (e) {
      if (e is ServerException || e is ConnectionException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
