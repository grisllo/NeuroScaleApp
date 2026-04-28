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
          label: 'Alimentación',
          min: 0,
          max: 10,
          options: [
            (0, 'Incapaz'),
            (5, 'Necesita ayuda para cortar, extender mantequilla, etc.'),
            (10, 'Independiente — puede comer solo'),
          ],
        ),
        ScaleItem(
          key: barthelKeyBathing,
          label: 'Baño / Ducha',
          min: 0,
          max: 5,
          options: [
            (0, 'Dependiente'),
            (5, 'Independiente — puede bañarse solo'),
          ],
        ),
        ScaleItem(
          key: barthelKeyGrooming,
          label: 'Aseo personal',
          min: 0,
          max: 5,
          options: [
            (0, 'Necesita ayuda'),
            (5, 'Independiente — cara, manos, dientes, peinado, afeitado'),
          ],
        ),
        ScaleItem(
          key: barthelKeyDressing,
          label: 'Vestido',
          min: 0,
          max: 10,
          options: [
            (0, 'Dependiente'),
            (5, 'Necesita ayuda, pero puede hacer la mitad sin ayuda'),
            (10, 'Independiente — incluye botones, cremalleras, cordones'),
          ],
        ),
        ScaleItem(
          key: barthelKeyBowels,
          label: 'Deposiciones (control intestinal)',
          min: 0,
          max: 10,
          options: [
            (0, 'Incontinente o necesita enema'),
            (5, 'Accidente ocasional — menos de una vez por semana'),
            (10, 'Continente'),
          ],
        ),
        ScaleItem(
          key: barthelKeyBladder,
          label: 'Micción (control vesical)',
          min: 0,
          max: 10,
          options: [
            (0, 'Incontinente o sondado y sin control'),
            (5, 'Accidente ocasional — menos de una vez cada 24 h'),
            (10, 'Continente — más de 7 días sin escapes'),
          ],
        ),
        ScaleItem(
          key: barthelKeyToiletUse,
          label: 'Uso del WC',
          min: 0,
          max: 10,
          options: [
            (0, 'Dependiente'),
            (5, 'Necesita alguna ayuda pero puede hacer algo solo'),
            (
              10,
              'Independiente — ir al WC, bajarse ropa, limpiarse y vestirse'
            ),
          ],
        ),
        ScaleItem(
          key: barthelKeyTransfer,
          label: 'Traslado sillón–cama',
          min: 0,
          max: 15,
          options: [
            (0, 'Incapaz — no tiene equilibrio al sentarse'),
            (5, 'Gran ayuda — una o dos personas, puede sentarse'),
            (10, 'Pequeña ayuda — física o supervisión'),
            (15, 'Independiente'),
          ],
        ),
        ScaleItem(
          key: barthelKeyMobility,
          label: 'Deambulación',
          min: 0,
          max: 15,
          options: [
            (0, 'Inmóvil'),
            (5, 'Independiente en silla de ruedas, incluye esquinas'),
            (10, 'Camina con ayuda de una persona — física o supervisión'),
            (15, 'Independiente — puede usar ayudas técnicas'),
          ],
        ),
        ScaleItem(
          key: barthelKeyStairs,
          label: 'Subir y bajar escaleras',
          min: 0,
          max: 10,
          options: [
            (0, 'Incapaz'),
            (5, 'Necesita ayuda — física o supervisión'),
            (10, 'Independiente — puede usar pasamanos o bastón'),
          ],
        ),
      ];

  @override
  ScaleResult calculate(Map<String, int> answers) => calculateBarthel(answers);
}
