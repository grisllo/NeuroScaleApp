import '../../shared/domain/entities/scale_definition.dart';
import '../../shared/domain/entities/scale_item.dart';
import '../../shared/domain/entities/scale_result.dart';
import 'gcs_calculator.dart';

class GcsDefinition extends ScaleDefinition {
  const GcsDefinition();

  @override
  String get key => 'gcs';

  @override
  String get displayName => 'Glasgow Coma Scale';

  @override
  int get version => 1;

  @override
  List<ScaleItem> get items => const [
        ScaleItem(
          key: gcsKeyEye,
          label: 'Respuesta ocular',
          min: 1,
          max: 4,
          options: [
            (1, 'Sin respuesta'),
            (2, 'Al dolor'),
            (3, 'A la voz'),
            (4, 'Espontánea'),
          ],
        ),
        ScaleItem(
          key: gcsKeyVerbal,
          label: 'Respuesta verbal',
          min: 1,
          max: 5,
          options: [
            (1, 'Sin respuesta'),
            (2, 'Sonidos incomprensibles'),
            (3, 'Palabras inapropiadas'),
            (4, 'Confuso'),
            (5, 'Orientado'),
          ],
        ),
        ScaleItem(
          key: gcsKeyMotor,
          label: 'Respuesta motora',
          min: 1,
          max: 6,
          options: [
            (1, 'Sin respuesta'),
            (2, 'Extensión anormal (descerebración)'),
            (3, 'Flexión anormal (decorticación)'),
            (4, 'Retirada al dolor'),
            (5, 'Localiza el dolor'),
            (6, 'Obedece órdenes'),
          ],
        ),
      ];

  @override
  ScaleResult calculate(Map<String, int> answers) => calculateGcs(answers);
}
