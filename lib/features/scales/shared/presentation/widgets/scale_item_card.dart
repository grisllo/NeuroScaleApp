import 'package:flutter/material.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/extensions/scale_key_resolver.dart';
import '../../../../../core/theme/app_radii.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/scale_item_help_button.dart';
import '../../domain/entities/scale_item.dart';

/// Card for a single scale item with radio options.
/// Used by GCS, Barthel and ABCD2 — scales with simple integer options.
/// NIHSS has its own card due to untestable-value logic.
class ScaleItemCard extends StatelessWidget {
  const ScaleItemCard({
    super.key,
    required this.item,
    required this.selectedValue,
    required this.onChanged,
  });

  final ScaleItem item;
  final int? selectedValue;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.resolveKey(item.labelKey),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (item.helpKey != null)
                  ScaleItemHelpButton(
                    labelKey: item.labelKey,
                    helpKey: item.helpKey!,
                  ),
                if (selectedValue != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Chip(
                    label: Text('$selectedValue'),
                    backgroundColor: scheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            RadioGroup<int>(
              groupValue: selectedValue,
              onChanged: (int? v) {
                if (v != null) onChanged(v);
              },
              child: Column(
                children: item.options
                    .map(
                      (opt) => RadioListTile<int>(
                        value: opt.$1,
                        title: Text(
                          '${opt.$1} — ${context.l10n.resolveKey(opt.$2)}',
                        ),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        selected: selectedValue == opt.$1,
                        selectedTileColor: scheme.primaryContainer.withValues(
                          alpha: 0.35,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
