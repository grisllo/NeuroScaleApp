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
}
