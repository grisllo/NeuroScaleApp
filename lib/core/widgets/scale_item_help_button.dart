import 'package:flutter/material.dart';

import '../extensions/l10n_extension.dart';
import '../extensions/scale_key_resolver.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

/// Botón "?" que muestra un bottom sheet con la descripción clínica
/// y referencia bibliográfica del ítem de escala.
///
/// Solo se renderiza si el [ScaleItem] tiene [helpKey] no nulo.
class ScaleItemHelpButton extends StatelessWidget {
  const ScaleItemHelpButton({
    super.key,
    required this.labelKey,
    required this.helpKey,
  });

  /// Clave ARB del label del ítem (usado como título del bottom sheet).
  final String labelKey;

  /// Clave ARB del texto de ayuda (descripción + referencia bibliográfica).
  final String helpKey;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.help_outline_rounded,
        size: 18,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      tooltip: context.l10n.tutorialButtonTooltip,
      onPressed: () => _show(context),
    );
  }

  void _show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      builder: (_) => _HelpSheet(labelKey: labelKey, helpKey: helpKey),
    );
  }
}

class _HelpSheet extends StatelessWidget {
  const _HelpSheet({required this.labelKey, required this.helpKey});

  final String labelKey;
  final String helpKey;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final text = l10n.resolveKey(helpKey);

    // Separa descripción de referencia por el separador 📚
    final parts = text.split('\n\n📚 ');
    final description = parts.first;
    final reference = parts.length > 1 ? parts[1] : null;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.resolveKey(labelKey),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
          if (reference != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📚', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      reference,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
