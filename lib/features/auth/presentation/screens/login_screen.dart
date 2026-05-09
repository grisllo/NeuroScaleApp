import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../providers/auth_controller.dart';
import '../providers/session_provider.dart';
import '../widgets/auth_form_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: AppMotion.normal,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: AppMotion.enter,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authState = ref.watch(authControllerProvider);

    ref.listen(sessionProvider, (_, next) {
      if (next.asData?.value != null && context.mounted) {
        context.go('/');
      }
    });

    ref.listen(authControllerProvider, (_, next) {
      if (next.asData?.value != null && context.mounted) {
        context.go('/');
      }
    });

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(_fadeAnimation),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.appTitle,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.loginTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      AuthFormField(
                        label: l10n.emailLabel,
                        hint: l10n.emailHint,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return l10n.fieldRequiredError;
                          }
                          if (!EmailValidator.validate(v.trim())) {
                            return l10n.emailInvalidError;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AuthFormField(
                        label: l10n.passwordLabel,
                        hint: l10n.passwordHint,
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: _submit,
                        autofillHints: const [AutofillHints.password],
                        autocorrect: false,
                        enableSuggestions: false,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return l10n.fieldRequiredError;
                          }
                          if (v.length < 6) {
                            return l10n.passwordTooShortError;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      if (authState.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _authErrorMessage(authState.error, l10n),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: authState.isLoading ? null : _submit,
                        child: authState.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(l10n.loginButton),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.go('/forgot-password'),
                        child: Text(l10n.forgotPasswordLinkText),
                      ),
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: Text(l10n.registerLinkText),
                      ),
                    ],
                  ),
                ),
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
        .signIn(
          email: _emailController.text.trim().toLowerCase(),
          password: _passwordController.text,
        );
  }

  String _authErrorMessage(Object? error, AppLocalizations l10n) {
    if (error is AuthFailure) return error.message;
    if (error is NetworkFailure) return l10n.networkErrorMessage;
    if (error is Failure) return l10n.backendUnavailableError;
    return l10n.genericErrorMessage;
  }
}
