import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../providers/password_reset_controller.dart';
import '../widgets/auth_form_field.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(passwordResetControllerProvider);

    ref.listen(passwordResetControllerProvider, (prev, next) {
      if (prev?.isLoading == true && next.hasValue && !next.hasError) {
        if (context.mounted) context.go('/');
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.resetPasswordTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.resetPasswordTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.resetPasswordInstruction,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  AuthFormField(
                    label: l10n.newPasswordLabel,
                    controller: _passwordController,
                    obscureText: _obscure,
                    autofillHints: const [AutofillHints.newPassword],
                    autocorrect: false,
                    enableSuggestions: false,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return l10n.fieldRequiredError;
                      if (v.length < 8 ||
                          !RegExp(r'[a-zA-Z]').hasMatch(v) ||
                          !RegExp(r'[0-9]').hasMatch(v)) {
                        return l10n.passwordTooWeakError;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AuthFormField(
                    label: l10n.confirmPasswordLabel,
                    controller: _confirmController,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: _submit,
                    autofillHints: const [AutofillHints.newPassword],
                    autocorrect: false,
                    enableSuggestions: false,
                    validator: (v) {
                      if (v == null || v.isEmpty) return l10n.fieldRequiredError;
                      if (v != _passwordController.text) {
                        return l10n.passwordMismatchError;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _errorMessage(state.error, l10n),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: state.isLoading ? null : _submit,
                    child: state.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.savePasswordButton),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(passwordResetControllerProvider.notifier)
        .updatePassword(password: _passwordController.text);
  }

  String _errorMessage(Object? error, AppLocalizations l10n) {
    if (error is AuthFailure) return error.message;
    if (error is NetworkFailure) return l10n.networkErrorMessage;
    if (error is Failure) return l10n.backendUnavailableError;
    return l10n.genericErrorMessage;
  }
}
