import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class WatchSessionUseCase {
  const WatchSessionUseCase(this._repository);

  final AuthRepository _repository;

  Stream<AppUser?> call() => _repository.watchSession();
}
