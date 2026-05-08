/// Detector de datos identificativos (PII) en texto libre.
///
/// Diseñado para `case_description` en evaluaciones: el usuario escribe
/// descripción anonimizada del caso y queremos bloquear el guardado si se
/// cuela un DNI/NIE/email/teléfono/fecha de nacimiento.
///
/// Función pura — sin dependencias de Flutter ni Supabase. Se valida en
/// cliente; el server-side aplica un CHECK de longitud (≤500 chars) como
/// defensa secundaria. Mantener regex de PII en plpgsql sería más frágil.
enum PiiKind { dni, nie, email, phone, date }

class PiiMatch {
  const PiiMatch({required this.kind, required this.snippet});
  final PiiKind kind;
  final String snippet;
}

class PiiDetector {
  // DNI español: 8 dígitos + letra de control (excluye I, Ñ, O, U).
  // NIE: prefijo X/Y/Z + 7 dígitos + letra de control.
  // Email: forma simplificada RFC.
  // Teléfono ES: 9 dígitos empezando por 6/7 (móvil) o 8/9 (fijo).
  // Fecha: dd/mm/yyyy con año explícito 19xx o 20xx (descarta "1-1-80"
  //        ambiguos y "hace 3 días"). Separadores: / - .
  static final Map<PiiKind, RegExp> _patterns = {
    // \s? acepta DNI/NIE con espacio o guion opcional antes de la letra
    // (p.ej. "12345678 A" o "X1234567-A" al pegar formatos comunes).
    PiiKind.dni: RegExp(
      r'\b\d{8}[\s\-]?[A-HJ-NP-TV-Z]\b',
      caseSensitive: false,
    ),
    PiiKind.nie: RegExp(
      r'\b[XYZ]\d{7}[\s\-]?[A-HJ-NP-TV-Z]\b',
      caseSensitive: false,
    ),
    PiiKind.email: RegExp(r'\b[\w.+-]+@[\w-]+\.[\w.-]+\b'),
    PiiKind.phone: RegExp(r'\b[6-9]\d{8}\b'),
    PiiKind.date: RegExp(r'\b\d{1,2}[/\-.]\d{1,2}[/\-.](?:19|20)\d{2}\b'),
  };

  static List<PiiMatch> detect(String input) {
    final results = <PiiMatch>[];
    for (final entry in _patterns.entries) {
      for (final m in entry.value.allMatches(input)) {
        results.add(PiiMatch(kind: entry.key, snippet: m.group(0)!));
      }
    }
    return results;
  }

  static bool hasAny(String input) {
    for (final regex in _patterns.values) {
      if (regex.hasMatch(input)) return true;
    }
    return false;
  }
}
