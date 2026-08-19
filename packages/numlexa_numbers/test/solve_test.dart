import 'package:numlexa_numbers/numlexa_numbers.dart';
import 'package:test/test.dart';

TileSet _t(List<int> v) => TileSet(v.map(Tile.new).toList());

/// Los 20 casos conocidos del criterio de aceptacion.
final List<(String, TileSet, int)> casos = <(String, TileSet, int)>[
  ('clasico 952', _t(<int>[25, 50, 75, 100, 3, 6]), 952),
  ('tope 999 con las cuatro grandes', _t(<int>[25, 50, 75, 100, 3, 6]), 999),
  ('suelo 101 con las cuatro grandes', _t(<int>[25, 50, 75, 100, 3, 6]), 101),
  ('sin grandes, objetivo alto', _t(<int>[10, 9, 8, 7, 6, 5]), 987),
  ('sin grandes, objetivo bajo', _t(<int>[10, 9, 8, 7, 6, 5]), 103),
  ('una grande', _t(<int>[100, 9, 7, 6, 3, 1]), 921),
  ('una grande, division necesaria', _t(<int>[75, 8, 7, 5, 3, 2]), 811),
  ('dos grandes', _t(<int>[100, 75, 8, 6, 4, 2]), 743),
  ('dos grandes, objetivo primo', _t(<int>[50, 25, 9, 8, 3, 1]), 997),
  ('tres grandes', _t(<int>[100, 75, 50, 9, 4, 2]), 638),
  ('tres grandes, objetivo redondo', _t(<int>[100, 50, 25, 7, 5, 2]), 500),
  ('cuatro grandes con dos unos', _t(<int>[100, 75, 50, 25, 1, 1]), 449),
  ('cuatro grandes con dos dieces', _t(<int>[100, 75, 50, 25, 10, 10]), 876),
  ('pares repetidos', _t(<int>[9, 9, 8, 8, 7, 7]), 654),
  ('pares bajos', _t(<int>[4, 4, 3, 3, 2, 2]), 288),
  ('mezcla con unos', _t(<int>[100, 10, 6, 4, 1, 1]), 337),
  ('objetivo alcanzable con pocas fichas', _t(<int>[100, 9, 8, 7, 6, 5]), 900),
  ('objetivo de dos fichas', _t(<int>[100, 75, 50, 25, 6, 3]), 175),
  ('numeros medianos', _t(<int>[75, 10, 9, 8, 7, 6]), 412),
  ('el mas hostil medido', _t(<int>[25, 50, 75, 100, 3, 6]), 887),
];

int _popcount(int m) {
  var c = 0;
  var x = m;
  while (x != 0) {
    c += x & 1;
    x >>= 1;
  }
  return c;
}

/// Minimo de operaciones con el que se puede alcanzar [objetivo], o `null`.
int? _minOpsReales(TileSet tablero, int objetivo) {
  final tabla = reachableBySubset(tablero);
  int? mejor;
  for (var mascara = 1; mascara < tabla.length; mascara++) {
    if (!tabla[mascara].contains(objetivo)) {
      continue;
    }
    final ops = _popcount(mascara) - 1;
    if (mejor == null || ops < mejor) {
      mejor = ops;
    }
  }
  return mejor;
}

void main() {
  group('criterio de aceptacion: 20 casos en menos de 200 ms', () {
    test('hay exactamente 20 casos', () {
      expect(casos.length, 20);
    });

    for (final caso in casos) {
      final (nombre, tablero, objetivo) = caso;
      test('$nombre -> $objetivo', () {
        final reloj = Stopwatch()..start();
        final s = solve(tablero, Target(objetivo));
        reloj.stop();

        expect(
          reloj.elapsedMilliseconds,
          lessThan(200),
          reason: 'tardo ${reloj.elapsedMilliseconds} ms',
        );

        // La expresion devuelta tiene que valer lo que dice que vale, y eso
        // lo dictamina el evaluador de F1.02, no el solver.
        expect(
          evaluate(s.expression, tablero),
          s.value,
          reason: 'el solver miente sobre su propio resultado',
        );

        final minOps = _minOpsReales(tablero, objetivo);
        if (minOps != null) {
          expect(s.value, objetivo, reason: 'era alcanzable y no lo encontro');
          expect(
            s.opCount,
            minOps,
            reason: 'no es la solucion con menos operaciones',
          );
        } else {
          // No alcanzable: debe ser la mejor aproximacion posible.
          final alcanzables = reachable(tablero);
          final mejorDistancia = alcanzables
              .map((int v) => (v - objetivo).abs())
              .reduce((int a, int b) => a < b ? a : b);
          expect((s.value - objetivo).abs(), mejorDistancia);
        }
      });
    }
  });

  group('exactitud y minimalidad', () {
    test('el 952 se resuelve exacto', () {
      final s = solve(_t(<int>[25, 50, 75, 100, 3, 6]), Target(952));
      expect(s.value, 952);
    });

    test('un objetivo que es una sola ficha no gasta ninguna operacion', () {
      // 175 = 100 + 75, una sola operacion. Nada mas corto es posible.
      final s = solve(_t(<int>[100, 75, 50, 25, 6, 3]), Target(175));
      expect(s.value, 175);
      expect(s.opCount, 1);
      expect(s.usedTiles.length, 2);
    });

    test('prefiere la solucion corta aunque exista una larga', () {
      final tablero = _t(<int>[100, 75, 50, 25, 10, 5]);
      final s = solve(tablero, Target(125));
      expect(s.value, 125);
      expect(s.opCount, 1, reason: '100 + 25 basta');
    });
  });

  group('mejor aproximacion', () {
    test('un tablero yermo devuelve su valor mas cercano, no un fallo', () {
      // {1,1,2,2,3,3} alcanza como mucho 36. Ver F1.04.
      final tablero = _t(<int>[1, 1, 2, 2, 3, 3]);
      final s = solve(tablero, Target(500));
      expect(s.value, lessThan(minTargetValue));
      expect(evaluate(s.expression, tablero), s.value);
      final alcanzables = reachable(tablero);
      final mejor = alcanzables
          .map((int v) => (v - 500).abs())
          .reduce((int a, int b) => a < b ? a : b);
      expect((s.value - 500).abs(), mejor);
    });

    test('con empate en distancia elige la de menos operaciones', () {
      // Tablero yermo: 36 es el maximo y se alcanza de varias formas.
      final tablero = _t(<int>[1, 1, 2, 2, 3, 3]);
      final s = solve(tablero, Target(999));
      final tabla = reachableBySubset(tablero);
      var minOps = 99;
      for (var m = 1; m < tabla.length; m++) {
        if (tabla[m].contains(s.value)) {
          final ops = _popcount(m) - 1;
          if (ops < minOps) minOps = ops;
        }
      }
      expect(s.opCount, minOps);
    });
  });

  group('coherencia con el resto del motor', () {
    test('si el bitmap dice alcanzable, el solver lo encuentra exacto', () {
      final tablero = _t(<int>[100, 75, 50, 25, 6, 3]);
      final bitmap = TargetBitmap.fromTileSet(tablero);
      var comprobados = 0;
      for (var objetivo = 101; objetivo <= 999; objetivo += 37) {
        final s = solve(tablero, Target(objetivo));
        if (bitmap.contains(objetivo)) {
          expect(s.value, objetivo, reason: 'objetivo $objetivo');
        }
        expect(evaluate(s.expression, tablero), s.value);
        comprobados++;
      }
      expect(comprobados, greaterThan(20));
    });
  });
}
