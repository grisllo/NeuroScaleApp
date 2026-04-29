import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/supabase_patient_datasource.dart';
import '../../data/repositories/patient_repository_impl.dart';
import '../../domain/repositories/patient_repository.dart';

final _patientDatasourceProvider = Provider<SupabasePatientDatasource>(
  (ref) => SupabasePatientDatasource(ref.watch(supabaseClientProvider)),
);

final patientRepositoryProvider = Provider<PatientRepository>(
  (ref) => PatientRepositoryImpl(ref.watch(_patientDatasourceProvider)),
);
