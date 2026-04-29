import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../domain/entities/patient.dart';
import '../providers/patients_controller.dart';

/// Dialog to create or edit a Patient.
/// Pass [initial] to edit; null to create.
/// Returns the created/updated Patient on save, null on cancel.
class PatientEditDialog extends ConsumerStatefulWidget {
  const PatientEditDialog({super.key, this.initial});

  final Patient? initial;

  static Future<Patient?> show(
    BuildContext context, {
    Patient? initial,
  }) =>
      showDialog<Patient>(
        context: context,
        builder: (_) => PatientEditDialog(initial: initial),
      );

  @override
  ConsumerState<PatientEditDialog> createState() => _PatientEditDialogState();
}

class _PatientEditDialogState extends ConsumerState<PatientEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _aliasController;
  late final TextEditingController _notesController;
  bool _busy = false;
  String? _errorMessage;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _aliasController = TextEditingController(text: widget.initial?.alias ?? '');
    _notesController = TextEditingController(text: widget.initial?.notes ?? '');
  }

  @override
  void dispose() {
    _aliasController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _errorMessage = null;
    });
    try {
      final notifier = ref.read(patientsControllerProvider.notifier);
      final result = _isEditing
          ? await notifier.updatePatient(
              widget.initial!.copyWith(
                alias: _aliasController.text.trim(),
                notes: _notesController.text.trim(),
              ),
            )
          : await notifier.create(
              alias: _aliasController.text.trim(),
              notes: _notesController.text.trim(),
            );
      if (!mounted) return;
      Navigator.of(context).pop(result);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(_isEditing ? l10n.patientEditTitle : l10n.patientCreateTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _aliasController,
              autofocus: !_isEditing,
              decoration: InputDecoration(
                labelText: l10n.patientAliasLabel,
                hintText: l10n.patientAliasHint,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.patientAliasRequired
                  : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l10n.patientNotesLabel,
                hintText: l10n.patientNotesHint,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.caseDescriptionWarning,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancelButton),
        ),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: _busy
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditing ? l10n.saveButton : l10n.patientCreateButton),
        ),
      ],
    );
  }
}
