import 'package:numlexa_numbers/numlexa_numbers.dart';
import 'package:test/test.dart';

/// Cuentas calculadas a mano ANTES de escribir la implementacion. Ver la
/// bitacora de F1.03 en `DESARROLLO.md` para el desarrollo completo.
///
/// Bolsa pequena: multiconjuntos de tamano m sobre 10 valores con
/// multiplicidad <= 2, es decir el coeficiente de x^m en (1+x+x^2)^10.
const Map<int, int> multiconjuntosPequenosEsperados = <int, int>{
  2: 55,
  3: 210,
  4: 615,
  5: 1452,
  6: 2850,
};

/// Por numero de fichas grandes: C(4,k) * N(6-k).
const Map<int, int> porFichasGrandesEsperado = <int, int>{
  0: 2850,
  1: 5808,
  2: 3690,
  3: 840,
  4: 55,
};

const int totalEsperado = 13243;

void main() {
  group('enumerateTileSets', () {
    test('produce exactamente la cuenta calculada a mano', () {
      expect(enumerateTileSets().length, totalEsperado);
    });

    test('el reparto por numero de fichas grandes cuadra uno a uno', () {
      final cuenta = <int, int>{};
      for (final tablero in enumerateTileSets()) {
        cuenta[tablero.largeCount] = (cuenta[tablero.largeCount] ?? 0) + 1;
      }
      expect(cuenta, porFichasGrandesEsperado);
    });

    test('la suma del reparto es el total', () {
      final suma = porFichasGrandesEsperado.values.reduce(
        (int a, int b) => a + b,
      );
      expect(suma, totalEsperado);
    });

    test('no hay ni un solo multiconjunto repetido', () {
      final vistos = enumerateTileSets().toSet();
      expect(
        vistos.length,
        totalEsperado,
        reason: 'si hay menos, la enumeracion produce duplicados',
      );
    });

    test('todos tienen seis fichas y respetan las bolsas', () {
      for (final tablero in enumerateTileSets()) {
        expect(tablero.tiles.length, 6);
        final apariciones = <int, int>{};
        for (final ficha in tablero.tiles) {
          apariciones[ficha.value] = (apariciones[ficha.value] ?? 0) + 1;
        }
        for (final entrada in apariciones.entries) {
          final maximo = largeTileValues.contains(entrada.key) ? 1 : 2;
          expect(
            entrada.value,
            lessThanOrEqualTo(maximo),
            reason: 'ficha ${entrada.key} en $tablero',
          );
        }
      }
    });

    test('nunca hay mas de cuatro grandes', () {
      for (final tablero in enumerateTileSets()) {
        expect(tablero.largeCount, inInclusiveRange(0, 4));
      }
    });

    test('es determinista: dos recorridos dan la misma secuencia', () {
      final a = enumerateTileSets().toList();
      final b = enumerateTileSets().toList();
      expect(a.length, b.length);
      for (var i = 0; i < a.length; i++) {
        expect(a[i], b[i], reason: 'divergen en la posicion $i');
      }
    });

    test('contiene casos concretos reconocibles', () {
      final todos = enumerateTileSets().toSet();
      // Las cuatro grandes mas dos pequenas distintas.
      expect(
        todos.contains(
          TileSet(<Tile>[
            Tile(100),
            Tile(75),
            Tile(50),
            Tile(25),
            Tile(1),
            Tile(2),
          ]),
        ),
        isTrue,
      );
      // Sin grandes, con pares repetidos.
      expect(
        todos.contains(
          TileSet(<Tile>[Tile(1), Tile(1), Tile(2), Tile(2), Tile(3), Tile(3)]),
        ),
        isTrue,
      );
    });
  });

  group('countTileSetsByLargeCount', () {
    test('coincide con el calculo a mano sin recorrer la enumeracion', () {
      expect(countTileSetsByLargeCount(), porFichasGrandesEsperado);
    });
  });

  group('countSmallMultisets', () {
    test('reproduce los coeficientes de (1+x+x^2)^10', () {
      for (final entrada in multiconjuntosPequenosEsperados.entries) {
        expect(
          countSmallMultisets(entrada.key),
          entrada.value,
          reason: 'm = ${entrada.key}',
        );
      }
    });

    test('los extremos de la fila valen 1 y 10', () {
      expect(countSmallMultisets(0), 1);
      expect(countSmallMultisets(1), 10);
      expect(countSmallMultisets(20), 1);
    });

    test('la fila entera suma 3^10 = 59049', () {
      var suma = 0;
      for (var m = 0; m <= 20; m++) {
        suma += countSmallMultisets(m);
      }
      expect(suma, 59049);
    });

    test('fuera de la fila no hay nada', () {
      expect(countSmallMultisets(-1), 0);
      expect(countSmallMultisets(21), 0);
    });
  });
}
