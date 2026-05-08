import 'package:flutter/material.dart';

import '../extensions/l10n_extension.dart';
import '../theme/app_spacing.dart';

/// Banner discreto que aparece en la parte superior del shell
/// cuando el dispositivo no tiene conexión a red.
/// Se muestra/oculta con AnimatedSize desde AppShell.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        color: scheme.errorContainer,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 16,
              color: scheme.onErrorContainer,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              context.l10n.offlineBannerMessage,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: scheme.onErrorContainer),
            ),
          ],
        ),
      ),
    );
  }
}
