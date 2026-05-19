sealed class Failure {
  const Failure(this.message);
  final String message;

  @override
  String toString() => '$runtimeType($message)';
}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}

final class ConfigFailure extends Failure {
  const ConfigFailure(super.message);
}

final class EmailConfirmationPendingFailure extends Failure {
  const EmailConfirmationPendingFailure()
    : super('Revisa tu email para confirmar la cuenta.');
}

final class RateLimitFailure extends Failure {
  const RateLimitFailure() : super('Demasiados intentos. Espera un momento.');
}
