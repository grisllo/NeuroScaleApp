import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/extensions/failure_l10n.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/auth_controller.dart';
import '../providers/session_provider.dart';
import '../widgets/auth_card.dart';
import '../widgets/auth_form_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authState = ref.watch(authControllerProvider);
    final isTablet = MediaQuery.sizeOf(context).width >= 600;

    ref.listen(sessionProvider, (_, next) {
      if (next.asData?.value != null && context.mounted) context.go('/');
    });
    ref.listen(authControllerProvider, (_, next) {
      if (next.asData?.value != null && context.mounted) context.go('/');
    });

    final formFields = [
      AuthFormField(
        label: l10n.emailLabel,
        hint: l10n.emailHint,
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
        validator: (v) {
          if (v == null || v.trim().isEmpty) return l10n.fieldRequiredError;
          if (!EmailValidator.validate(v.trim())) return l10n.emailInvalidError;
          return null;
        },
      ),
      const SizedBox(height: AppSpacing.lg),
      AuthFormField(
        label: l10n.passwordLabel,
        hint: l10n.passwordHint,
        controller: _passwordController,
        obscureText: _obscurePassword,
        autofillHints: const [AutofillHints.newPassword],
        autocorrect: false,
        enableSuggestions: false,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
      const SizedBox(height: AppSpacing.lg),
      AuthFormField(
        label: l10n.confirmPasswordLabel,
        controller: _confirmController,
        obscureText: _obscurePassword,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: _submit,
        autofillHints: const [AutofillHints.newPassword],
        autocorrect: false,
        enableSuggestions: false,
        validator: (v) {
          if (v == null || v.isEmpty) return l10n.fieldRequiredError;
          if (v != _passwordController.text) return l10n.passwordMismatchError;
          return null;
        },
      ),
      const SizedBox(height: AppSpacing.sm),
      if (authState.hasError)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            failureMessage(authState.error, l10n),
            style: TextStyle(
              color: authState.error is EmailConfirmationPendingFailure
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      const SizedBox(height: AppSpacing.xl),
      FilledButton(
        onPressed: authState.isLoading ? null : _submit,
        child: authState.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(l10n.registerButton),
      ),
      const SizedBox(height: AppSpacing.sm),
      TextButton(
        onPressed: () => context.go('/login'),
        child: Text(l10n.loginLinkText),
      ),
    ];

    // ── Web / tablet: card blanca centrada sobre fondo primary ────────────
    if (isTablet) {
      return AuthCard(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.registerTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              ...formFields,
            ],
          ),
        ),
      );
    }

    // ── Móvil: layout actual ──────────────────────────────────────────────
    return Scaffold(
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
                    l10n.registerTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  ...formFields,
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
        .read(authControllerProvider.notifier)
        .signUp(
          email: _emailController.text.trim().toLowerCase(),
          password: _passwordController.text,
        );
  }
}
