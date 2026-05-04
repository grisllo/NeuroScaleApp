import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/providers/locale_provider.dart';
import '../../../../features/auth/presentation/providers/auth_controller.dart';
import '../../../../features/auth/presentation/providers/session_provider.dart';
import '../../../../l10n/generated/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider).asData?.value;
    final selectedLocale = ref.watch(localeProvider).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Email ────────────────────────────────────────────────────
          Card(
            child: ListTile(
              leading: const Icon(Icons.email_outlined),
              title: Text(l10n.profileEmailLabel),
              subtitle: Text(
                session?.email ?? '—',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Language selector ─────────────────────────────────────────
          Text(
            l10n.profileLanguageLabel,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SegmentedButton<String>(
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
            ),
          ),
          const SizedBox(height: 32),

          // ── Sign out ──────────────────────────────────────────────────
          FilledButton.tonalIcon(
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout_rounded),
            label: Text(l10n.signOutButton),
          ),
        ],
      ),
    );
  }
}
