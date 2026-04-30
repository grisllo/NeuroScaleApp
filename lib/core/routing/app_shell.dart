import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';

/// Persistent shell that wraps bottom navigation.
/// Follows the StatefulNavigationShell pattern from the
/// flutter-setup-declarative-routing skill.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      // Tapping the active tab navigates back to its initial location.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: l10n.tabHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people_rounded),
            label: l10n.tabPatients,
          ),
          NavigationDestination(
            icon: const Icon(Icons.alt_route_outlined),
            selectedIcon: const Icon(Icons.alt_route_rounded),
            label: l10n.tabAlgorithms,
          ),
        ],
      ),
    );
  }
}
