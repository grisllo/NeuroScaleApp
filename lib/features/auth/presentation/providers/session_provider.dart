import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/supabase_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/watch_session_usecase.dart';

final _authDatasourceProvider = Provider<SupabaseAuthDatasource>(
  (ref) => SupabaseAuthDatasource(ref.watch(supabaseClientProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(_authDatasourceProvider)),
);

final sessionProvider = StreamProvider<AppUser?>((ref) {
  try {
    return WatchSessionUseCase(ref.watch(authRepositoryProvider)).call();
  } catch (_) {
    return Stream.value(null);
  }
});

final passwordRecoveryProvider = StreamProvider<bool>((ref) {
  try {
    final client = ref.watch(supabaseClientProvider);
    return client.auth.onAuthStateChange.map(
      (state) => state.event == AuthChangeEvent.passwordRecovery,
    );
  } catch (_) {
    return Stream.value(false);
  }
});
