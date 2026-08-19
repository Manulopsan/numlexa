import 'dart:typed_data';

import 'package:numlexa_numbers/numlexa_numbers.dart';
import 'package:test/test.dart';

final TileSet tableroCriterio = TileSet(<Tile>[
  Tile(25),
  Tile(50),
  Tile(75),
  Tile(100),
  Tile(3),
  Tile(6),
]);

/// Multiconjunto que no alcanza NINGUN objetivo legal: su producto maximo es
/// 36. Descubierto midiendo en F1.04.
final TileSet tableroYermo = TileSet(<Tile>[
  Tile(1),
  Tile(1),
  Tile(2),
  Tile(2),
  Tile(3),
  Tile(3),
]);

void main() {
  group('forma del bitmap', () {
    test('hay 899 objetivos legales, de 101 a 999', () {
      expect(targetCount, 899);
      expect(maxTargetValue - minTargetValue + 1, targetCount);
    });

    test('caben en 113 bytes', () {
      expect(bitmapByteLength, 113);
      expect(TargetBitmap.empty().toBytes().length, 113);
    });

    test('un bitmap vacio no contiene nada y su popcount es cero', () {
      final b = TargetBitmap.empty();
      expect(b.popcount, 0);
      for (var t = minTargetValue; t <= maxTargetValue; t++) {
        expect(b.contains(t), isFalse);
      }
    });
  });

  group('contenido', () {
    test('marca y consulta los extremos del rango', () {
      final b = TargetBitmap.fromTargets(<int>{101, 999});
      expect(b.contains(101), isTrue);
      expect(b.contains(999), isTrue);
      expect(b.contains(500), isFalse);
      expect(b.popcount, 2);
    });

    test('ignora lo que cae fuera del rango en vez de corromper el mapa', () {
      final b = TargetBitmap.fromTargets(<int>{100, 101, 999, 1000, -5, 0});
      expect(b.popcount, 2, reason: 'solo 101 y 999 son objetivos legales');
      expect(b.contains(100), isFalse);
      expect(b.contains(1000), isFalse);
    });

    test('todos los objetivos marcados se recuperan uno a uno', () {
      final origen = <int>{101, 137, 250, 499, 500, 501, 888, 999};
      final b = TargetBitmap.fromTargets(origen);
      expect(b.popcount, origen.length);
      for (var t = minTargetValue; t <= maxTargetValue; t++) {
        expect(b.contains(t), origen.contains(t), reason: 'objetivo $t');
      }
      expect(b.targets().toSet(), origen);
    });

    test('el bitmap lleno tiene los 899 bits', () {
      final todos = <int>{
        for (var t = minTargetValue; t <= maxTargetValue; t++) t,
      };
      expect(TargetBitmap.fromTargets(todos).popcount, 899);
    });
  });

  group('criterio de aceptacion: popcount plausible y estable', () {
    test('[25,50,75,100,3,6] alcanza exactamente 831 objetivos de 899', () {
      final b = TargetBitmap.fromTileSet(tableroCriterio);
      expect(b.popcount, 831);
      expect(b.contains(952), isTrue, reason: 'el 952 de F1.04');
    });

    test('el popcount nunca puede pasarse de 899', () {
      for (final t in <TileSet>[tableroCriterio, tableroYermo]) {
        expect(TargetBitmap.fromTileSet(t).popcount, inInclusiveRange(0, 899));
      }
    });

    test('un multiconjunto yermo da popcount cero, y eso es legitimo', () {
      expect(TargetBitmap.fromTileSet(tableroYermo).popcount, 0);
    });

    test('es estable: dos calculos dan exactamente los mismos bytes', () {
      final a = TargetBitmap.fromTileSet(tableroCriterio).toBytes();
      final b = TargetBitmap.fromTileSet(tableroCriterio).toBytes();
      expect(a, orderedEquals(b));
    });

    test('coincide bit a bit con reachableTargets del DP', () {
      final delDp = reachableTargets(tableroCriterio);
      final b = TargetBitmap.fromTileSet(tableroCriterio);
      for (var t = minTargetValue; t <= maxTargetValue; t++) {
        expect(b.contains(t), delDp.contains(t), reason: 'objetivo $t');
      }
    });
  });

  group('serializacion', () {
    test('ida y vuelta por bytes conserva el contenido', () {
      final original = TargetBitmap.fromTileSet(tableroCriterio);
      final vuelta = TargetBitmap.fromBytes(original.toBytes());
      expect(vuelta, original);
      expect(vuelta.popcount, original.popcount);
      expect(vuelta.toBytes(), orderedEquals(original.toBytes()));
    });

    test('los 5 bits de relleno del ultimo byte estan siempre a cero', () {
      // 113 bytes son 904 bits y solo se usan 899. Si el relleno no fuera
      // cero, dos bitmaps con el mismo contenido tendrian bytes distintos y
      // el artefacto de F1.08 dejaria de ser reproducible.
      final todos = <int>{
        for (var t = minTargetValue; t <= maxTargetValue; t++) t,
      };
      final bytes = TargetBitmap.fromTargets(todos).toBytes();
      expect(bytes.last & 0xF8, 0, reason: 'bits 899..903 deben ser cero');
    });

    test('rechaza un buffer de tamano equivocado', () {
      expect(() => TargetBitmap.fromBytes(Uint8List(112)), throwsArgumentError);
      expect(() => TargetBitmap.fromBytes(Uint8List(114)), throwsArgumentError);
    });

    test('modificar los bytes devueltos no altera el bitmap', () {
      final b = TargetBitmap.fromTargets(<int>{500});
      b.toBytes()[0] = 0xFF;
      expect(b.popcount, 1);
    });

    test('dos bitmaps iguales lo son tambien como valor', () {
      final a = TargetBitmap.fromTargets(<int>{101, 500});
      final b = TargetBitmap.fromTargets(<int>{500, 101});
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(TargetBitmap.fromTargets(<int>{101})));
    });

    test('se lee de un vistazo', () {
      expect(
        TargetBitmap.fromTargets(<int>{101, 500}).toString(),
        'TargetBitmap(2/899)',
      );
    });
  });
}
