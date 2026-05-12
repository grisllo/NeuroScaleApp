import 'entities/severity.dart';

/// Maps stored interpretation ARB keys → Severity.
/// Single source of truth for the evaluation tile dot indicator and any
/// other UI that needs to derive Severity from a persisted interpretation key.
const Map<String, Severity> kInterpSeverity = {
  'severityNone': Severity.none,
  'severityMild': Severity.mild,
  'severityModerate': Severity.moderate,
  'severitySevere': Severity.severe,
  'nihssInterp0': Severity.none,
  'nihssInterpMinor': Severity.mild,
  'nihssInterpModerate': Severity.moderate,
  'nihssInterpModerateSevere': Severity.severe,
  'nihssInterpSevere': Severity.severe,
  'abcd2RiskLow': Severity.mild,
  'abcd2RiskModerate': Severity.moderate,
  'abcd2RiskHigh': Severity.severe,
  'barthelInterpIndependent': Severity.none,
  'barthelInterpMild': Severity.mild,
  'barthelInterpModerate': Severity.moderate,
  'barthelInterpSevere': Severity.severe,
  'barthelInterpTotal': Severity.severe,
  'rankinInterp0': Severity.none,
  'rankinInterp1': Severity.mild,
  'rankinInterp2': Severity.mild,
  'rankinInterp3': Severity.moderate,
  'rankinInterp4': Severity.moderate,
  'rankinInterp5': Severity.severe,
  'rankinInterp6': Severity.severe,
};
