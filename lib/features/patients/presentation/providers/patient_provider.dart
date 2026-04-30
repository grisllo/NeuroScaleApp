import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/patients_local_datasource.dart';
import '../../data/datasources/supabase_patient_datasource.dart';
import '../../data/repositories/patient_repository_impl.dart';
import '../../domain/repositories/patient_repository.dart';

final _patientDatasourceProvider = Provider<SupabasePatientDatasource>(
  (ref) => SupabasePatientDatasource(ref.watch(supabaseClientProvider)),
);

final _patientsLocalDatasourceProvider = Provider<PatientsLocalDatasource>(
  (ref) => PatientsLocalDatasource(ref.watch(appDatabaseProvider)),
);

final patientRepositoryProvider = Provider<PatientRepository>(
  (ref) => PatientRepositoryImpl(
    remote: ref.watch(_patientDatasourceProvider),
    local: ref.watch(_patientsLocalDatasourceProvider),
  ),
);
