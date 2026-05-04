import '../../shared/domain/entities/scale_definition.dart';
import '../../shared/domain/entities/scale_item.dart';
import '../../shared/domain/entities/scale_result.dart';
import 'barthel_calculator.dart';

class BarthelDefinition extends ScaleDefinition {
  const BarthelDefinition();

  @override
  String get key => 'barthel';

  @override
  String get displayName => 'Barthel Index';

  @override
  int get version => 1;

  @override
  List<ScaleItem> get items => const [
        ScaleItem(
          key: barthelKeyFeeding,
          labelKey: 'barthelItemFeeding',
          min: 0,
          max: 10,
          options: [
            (0, 'barthelFeedingOpt0'),
            (5, 'barthelFeedingOpt5'),
            (10, 'barthelFeedingOpt10'),
          ],
        ),
        ScaleItem(
          key: barthelKeyBathing,
          labelKey: 'barthelItemBathing',
          min: 0,
          max: 5,
          options: [
            (0, 'barthelBathingOpt0'),
            (5, 'barthelBathingOpt5'),
          ],
        ),
        ScaleItem(
          key: barthelKeyGrooming,
          labelKey: 'barthelItemGrooming',
          min: 0,
          max: 5,
          options: [
            (0, 'barthelGroomingOpt0'),
            (5, 'barthelGroomingOpt5'),
          ],
        ),
        ScaleItem(
          key: barthelKeyDressing,
          labelKey: 'barthelItemDressing',
          min: 0,
          max: 10,
          options: [
            (0, 'barthelDressingOpt0'),
            (5, 'barthelDressingOpt5'),
            (10, 'barthelDressingOpt10'),
          ],
        ),
        ScaleItem(
          key: barthelKeyBowels,
          labelKey: 'barthelItemBowels',
          min: 0,
          max: 10,
          options: [
            (0, 'barthelBowelsOpt0'),
            (5, 'barthelBowelsOpt5'),
            (10, 'barthelBowelsOpt10'),
          ],
        ),
        ScaleItem(
          key: barthelKeyBladder,
          labelKey: 'barthelItemBladder',
          min: 0,
          max: 10,
          options: [
            (0, 'barthelBladderOpt0'),
            (5, 'barthelBladderOpt5'),
            (10, 'barthelBladderOpt10'),
          ],
        ),
        ScaleItem(
          key: barthelKeyToiletUse,
          labelKey: 'barthelItemToiletUse',
          min: 0,
          max: 10,
          options: [
            (0, 'barthelToiletUseOpt0'),
            (5, 'barthelToiletUseOpt5'),
            (10, 'barthelToiletUseOpt10'),
          ],
        ),
        ScaleItem(
          key: barthelKeyTransfer,
          labelKey: 'barthelItemTransfer',
          min: 0,
          max: 15,
          options: [
            (0, 'barthelTransferOpt0'),
            (5, 'barthelTransferOpt5'),
            (10, 'barthelTransferOpt10'),
            (15, 'barthelTransferOpt15'),
          ],
        ),
        ScaleItem(
          key: barthelKeyMobility,
          labelKey: 'barthelItemMobility',
          min: 0,
          max: 15,
          options: [
            (0, 'barthelMobilityOpt0'),
            (5, 'barthelMobilityOpt5'),
            (10, 'barthelMobilityOpt10'),
            (15, 'barthelMobilityOpt15'),
          ],
        ),
        ScaleItem(
          key: barthelKeyStairs,
          labelKey: 'barthelItemStairs',
          min: 0,
          max: 10,
          options: [
            (0, 'barthelStairsOpt0'),
            (5, 'barthelStairsOpt5'),
            (10, 'barthelStairsOpt10'),
          ],
        ),
      ];

  @override
  ScaleResult calculate(Map<String, int> answers) => calculateBarthel(answers);
}
