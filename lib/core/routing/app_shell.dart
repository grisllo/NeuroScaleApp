import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';
import '../providers/connectivity_provider.dart';
import '../theme/app_motion.dart';
import '../utils/breakpoints.dart';
import '../widgets/offline_banner.dart';

/// Persistent shell that wraps bottom navigation.
/// Follows the StatefulNavigationShell pattern from the
/// flutter-setup-declarative-routing skill.
///
/// Mobile (<600px): NavigationBar en la parte inferior.
/// Tablet (≥600px): NavigationRail lateral compacto (iconos + etiquetas).
/// Desktop (≥1024px): NavigationRail lateral extendido (etiquetas en línea).
class AppShell extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isOffline = ref.watch(isOfflineProvider);
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= Breakpoints.tablet;
    final isDesktop = width >= Breakpoints.desktop;

    final content = Column(
      children: [
        AnimatedSize(
          duration: AppMotion.normal,
          curve: AppMotion.enter,
          child: isOffline ? const OfflineBanner() : const SizedBox.shrink(),
        ),
        Expanded(child: navigationShell),
      ],
    );

    final railDestinations = [
      NavigationRailDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home_rounded),
        label: Text(l10n.tabHome),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.people_outline),
        selectedIcon: const Icon(Icons.people_rounded),
        label: Text(l10n.tabPatients),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.alt_route_outlined),
        selectedIcon: const Icon(Icons.alt_route_rounded),
        label: Text(l10n.tabAlgorithms),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.person_outline_rounded),
        selectedIcon: const Icon(Icons.person_rounded),
        label: Text(l10n.tabProfile),
      ),
    ];

    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _goBranch,
              // En desktop el rail se extiende mostrando etiquetas en línea.
              extended: isDesktop,
              labelType: isDesktop
                  ? NavigationRailLabelType
                        .none // extended ya muestra etiqueta
                  : NavigationRailLabelType.all,
              destinations: railDestinations,
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: content),
          ],
        ),
      );
    }

    return Scaffold(
      body: content,
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
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: l10n.tabProfile,
          ),
        ],
      ),
    );
  }
}
