import '../../l10n/generated/app_localizations.dart';
import '../errors/failures.dart';

/// Maps any error/Failure to a user-facing localized string.
/// Never exposes internal technical details or raw exception messages.
String failureMessage(Object? error, AppLocalizations l10n) {
  if (error is NetworkFailure) return l10n.networkErrorMessage;
  if (error is AuthFailure) return l10n.authInvalidCredentialsError;
  if (error is RateLimitFailure) return l10n.rateLimitErrorMessage;
  if (error is EmailConfirmationPendingFailure) {
    return l10n.emailConfirmationPendingMessage;
  }
  if (error is ConfigFailure) return l10n.backendUnavailableError;
  if (error is Failure) return l10n.genericErrorMessage;
  return l10n.genericErrorMessage;
}
