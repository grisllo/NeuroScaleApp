enum Severity {
  none,
  mild,
  moderate,
  severe;

  String get label => switch (this) {
    Severity.none => 'Sin síntomas',
    Severity.mild => 'Leve',
    Severity.moderate => 'Moderado',
    Severity.severe => 'Grave',
  };

  /// ARB key for this severity level (used for i18n lookups).
  String get interpretationKey => switch (this) {
    Severity.none => 'severityNone',
    Severity.mild => 'severityMild',
    Severity.moderate => 'severityModerate',
    Severity.severe => 'severitySevere',
  };
}
