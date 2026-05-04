import '../../shared/domain/entities/scale_definition.dart';
import '../../shared/domain/entities/scale_item.dart';
import '../../shared/domain/entities/scale_result.dart';
import 'rankin_calculator.dart';

class RankinDefinition extends ScaleDefinition {
  const RankinDefinition();

  @override
  String get key => 'rankin';

  @override
  String get displayName => 'mRS (Modified Rankin Scale)';

  @override
  int get version => 1;

  @override
  List<ScaleItem> get items => const [
        ScaleItem(
          key: rankinKeyScore,
          labelKey: 'rankinScoreLabel',
          min: 0,
          max: 6,
          options: [
            (0, 'rankinLevel0'),
            (1, 'rankinLevel1'),
            (2, 'rankinLevel2'),
            (3, 'rankinLevel3'),
            (4, 'rankinLevel4'),
            (5, 'rankinLevel5'),
            (6, 'rankinLevel6'),
          ],
        ),
      ];

  @override
  ScaleResult calculate(Map<String, int> answers) => calculateRankin(answers);
}
