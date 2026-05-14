import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/failure_l10n.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/auth_controller.dart';
import '../providers/session_provider.dart';
import '../widgets/auth_card.dart';
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
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        textInputAction: TextInputAction.done,
        onFieldSubmitted: _submit,
        autofillHints: const [AutofillHints.password],
        autocorrect: false,
        enableSuggestions: false,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          tooltip: _obscurePassword
              ? l10n.showPasswordTooltip
              : l10n.hidePasswordTooltip,
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return l10n.fieldRequiredError;
          if (v.length < 8) return l10n.passwordTooShortError;
          return null;
        },
      ),
      const SizedBox(height: AppSpacing.sm),
      if (authState.hasError)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            failureMessage(authState.error, l10n),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
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
            : Text(l10n.loginButton),
      ),
      const SizedBox(height: AppSpacing.sm),
      TextButton(
        onPressed: () => context.go('/forgot-password'),
        child: Text(l10n.forgotPasswordLinkText),
      ),
      TextButton(
        onPressed: () => context.go('/register'),
        child: Text(l10n.registerLinkText),
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
                l10n.loginTitle,
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

    // ── Móvil: layout actual con animación de entrada ─────────────────────
    return Scaffold(
      backgroundColor: isDark
          ? AppColors.surfaceDarkContainer
          : Theme.of(context).colorScheme.surface,
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
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                          child: Image.asset(
                            'assets/logo.png',
                            width: 80,
                            height: 80,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        l10n.appTitle,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.loginTitle,
                        style: Theme.of(context).textTheme.titleMedium,
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
}
