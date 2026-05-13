import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/failure_l10n.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/password_reset_controller.dart';
import '../widgets/auth_card.dart';
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
    final isTablet = MediaQuery.sizeOf(context).width >= 600;

    ref.listen(passwordResetControllerProvider, (prev, next) {
      if (prev?.isLoading == true && next.hasValue && !next.hasError) {
        if (context.mounted) context.go('/');
      }
    });

    final formContent = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.resetPasswordTitle,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.resetPasswordInstruction,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          AuthFormField(
            label: l10n.newPasswordLabel,
            controller: _passwordController,
            obscureText: _obscure,
            autofillHints: const [AutofillHints.newPassword],
            autocorrect: false,
            enableSuggestions: false,
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
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
          const SizedBox(height: AppSpacing.lg),
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
          const SizedBox(height: AppSpacing.sm),
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                failureMessage(state.error, l10n),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: AppSpacing.xl),
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
    );

    if (isTablet) {
      return AuthCard(showLogo: false, child: formContent);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.resetPasswordTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: formContent,
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
}
