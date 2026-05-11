import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../auth/presentation/providers/password_reset_controller.dart';
import '../../../auth/presentation/providers/session_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionProvider).asData?.value;
    final selectedLocale = ref.watch(localeProvider).languageCode;
    final isTablet = MediaQuery.sizeOf(context).width >= Breakpoints.tablet;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 800 : double.infinity,
          ),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── CUENTA ──────────────────────────────────────────────────
              _SectionHeader(label: l10n.profileAccountSection),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: Text(l10n.profileEmailLabel),
                      subtitle: Text(
                        session?.email ?? '—',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.lock_outline),
                      title: Text(l10n.changePasswordButton),
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () => showDialog<void>(
                        context: context,
                        builder: (_) => const _ChangePasswordDialog(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── PREFERENCIAS ─────────────────────────────────────────────
              _SectionHeader(label: l10n.profilePreferencesSection),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.profileLanguageLabel,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      SegmentedButton<String>(
                        segments: [
                          ButtonSegment(
                            value: 'es',
                            label: Text(l10n.profileLanguageEs),
                          ),
                          ButtonSegment(
                            value: 'en',
                            label: Text(l10n.profileLanguageEn),
                          ),
                        ],
                        selected: {selectedLocale},
                        onSelectionChanged: (Set<String> selection) async {
                          final code = selection.first;
                          ref.read(localeProvider.notifier).set(Locale(code));
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString(localePrefsKey, code);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── SESIÓN ───────────────────────────────────────────────────
              _SectionHeader(label: l10n.profileSessionSection),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.logout_rounded),
                  title: Text(l10n.signOutButton),
                  onTap: () =>
                      ref.read(authControllerProvider.notifier).signOut(),
                ),
              ),
              const SizedBox(height: 24),

              // ── ZONA PELIGROSA ────────────────────────────────────────────
              _SectionHeader(
                label: l10n.profileDangerZoneSection,
                color: scheme.error,
              ),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: scheme.error.withValues(alpha: 0.4)),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.delete_forever_outlined,
                    color: scheme.error,
                  ),
                  title: Text(
                    l10n.deleteAccountButton,
                    style: TextStyle(color: scheme.error),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: scheme.error,
                  ),
                  onTap: () => _confirmDeleteAccount(context, ref),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAccountConfirmTitle),
        content: Text(l10n.deleteAccountConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.deleteButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(authControllerProvider.notifier).deleteAccount();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
      return;
    }

    if (!context.mounted) return;
    context.go('/login');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.deleteAccountSuccess)));
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog();

  @override
  ConsumerState<_ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final email = ref.read(sessionProvider).asData?.value?.email ?? '';
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(passwordResetControllerProvider.notifier)
          .verifyAndUpdatePassword(
            email: email,
            currentPassword: _currentController.text,
            newPassword: _newController.text.trim(),
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.changePasswordSuccess)),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.changePasswordTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_error != null) ...[
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: _currentController,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: l10n.currentPasswordLabel,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? l10n.fieldRequiredError : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _newController,
              obscureText: _obscure,
              decoration: InputDecoration(labelText: l10n.newPasswordLabel),
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
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmController,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: l10n.confirmNewPasswordLabel,
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.fieldRequiredError;
                if (v != _newController.text) {
                  return l10n.passwordMismatchError;
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancelButton),
        ),
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.saveButton),
        ),
      ],
    );
  }
}
