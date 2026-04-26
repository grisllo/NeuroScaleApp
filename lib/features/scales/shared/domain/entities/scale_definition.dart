import 'scale_item.dart';
import 'scale_result.dart';

abstract class ScaleDefinition {
  const ScaleDefinition();

  String get key;
  String get displayName;
  int get version;
  List<ScaleItem> get items;

  /// Pure calculation — no Flutter or Supabase imports allowed here.
  /// Throws [ValidationFailure] if any answer is out of range or missing.
  ScaleResult calculate(Map<String, int> answers);
}
