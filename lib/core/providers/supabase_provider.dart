import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../env/env.dart';
import '../errors/exceptions.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  if (!Env.hasSupabase) {
    throw const ConfigurationException('Backend no configurado.');
  }
  return Supabase.instance.client;
});
