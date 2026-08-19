import 'package:numlexa_numbers/numlexa_numbers.dart';
import 'package:test/test.dart';

/// Tablero de referencia. Ojo: `TileSet` normaliza de mayor a menor, asi que
/// los indices son los de la lista YA ordenada.
///
/// indice: 0=100  1=75  2=50  3=25  4=7  5=3
final TileSet tablero = TileSet(<Tile>[
  Tile(100),
  Tile(75),
  Tile(50),
  Tile(25),
  Tile(7),
  Tile(3),
]);

/// Segundo tablero, con un 5, para el caso `3 - 5`.
///
/// indice: 0=10  1=9  2=8  3=7  4=5  5=3
final TileSet tableroPequeno = TileSet(<Tile>[
  Tile(10),
  Tile(9),
  Tile(8),
  Tile(7),
  Tile(5),
  Tile(3),
]);

Expression _op(Operation o, Expression a, Expression b) => OpNode(o, a, b);

void main() {
  group('criterio de aceptacion de F1.02', () {
    test('100 / 3 es null: la division no es exacta', () {
      expect(
        evaluate(_op(Operation.divide, TileLeaf(0), TileLeaf(5)), tablero),
        isNull,
      );
    });

    test('3 - 5 es null: el resultado no es estrictamente positivo', () {
      expect(
        evaluate(
          _op(Operation.subtract, TileLeaf(5), TileLeaf(4)),
          tableroPequeno,
        ),
        isNull,
      );
    });

    test('(75 + 25) * 7 es 700', () {
      final e = _op(
        Operation.multiply,
        _op(Operation.add, TileLeaf(1), TileLeaf(3)),
        TileLeaf(4),
      );
      expect(evaluate(e, tablero), 700);
    });
  });

  group('hojas y operaciones basicas', () {
    test('una hoja vale lo que la ficha a la que apunta', () {
      expect(evaluate(TileLeaf(0), tablero), 100);
      expect(evaluate(TileLeaf(5), tablero), 3);
    });

    test('suma y multiplicacion', () {
      expect(
        evaluate(_op(Operation.add, TileLeaf(0), TileLeaf(1)), tablero),
        175,
      );
      expect(
        evaluate(_op(Operation.multiply, TileLeaf(2), TileLeaf(4)), tablero),
        350,
      );
    });

    test('resta valida', () {
      expect(
        evaluate(_op(Operation.subtract, TileLeaf(0), TileLeaf(1)), tablero),
        25,
      );
    });

    test('division exacta', () {
      expect(
        evaluate(_op(Operation.divide, TileLeaf(0), TileLeaf(3)), tablero),
        4,
      );
      expect(
        evaluate(_op(Operation.divide, TileLeaf(1), TileLeaf(3)), tablero),
        3,
      );
    });
  });

  group('cero no es un valor intermedio valido', () {
    test('a - a es cero, y cero no es estrictamente positivo', () {
      // 5 - 5 usando las dos fichas de valor 5 del mismo tablero.
      final dosCincos = TileSet(<Tile>[
        Tile(5),
        Tile(5),
        Tile(9),
        Tile(8),
        Tile(7),
        Tile(3),
      ]);
      // indices: 0=9 1=8 2=7 3=5 4=5 5=3
      expect(
        evaluate(_op(Operation.subtract, TileLeaf(3), TileLeaf(4)), dosCincos),
        isNull,
        reason: 'CLAUDE.md §5: todo intermedio entero y estrictamente positivo',
      );
    });

    test(
      'un cero no puede aparecer como denominador porque no puede existir',
      () {
        // No hay forma de construir un cero: toda subexpresion valida es > 0.
        // Se comprueba que la rama que lo produciria ya es null.
        final dosCincos = TileSet(<Tile>[
          Tile(5),
          Tile(5),
          Tile(9),
          Tile(8),
          Tile(7),
          Tile(3),
        ]);
        final ceroFallido = _op(
          Operation.divide,
          TileLeaf(0),
          _op(Operation.subtract, TileLeaf(3), TileLeaf(4)),
        );
        expect(evaluate(ceroFallido, dosCincos), isNull);
      },
    );
  });

  group('propagacion del fallo', () {
    test('si falla la rama izquierda, falla el arbol entero', () {
      final e = _op(
        Operation.add,
        _op(Operation.divide, TileLeaf(0), TileLeaf(5)),
        TileLeaf(4),
      );
      expect(evaluate(e, tablero), isNull);
    });

    test('si falla la rama derecha, falla el arbol entero', () {
      final e = _op(
        Operation.add,
        TileLeaf(4),
        _op(Operation.divide, TileLeaf(0), TileLeaf(5)),
      );
      expect(evaluate(e, tablero), isNull);
    });

    test('un fallo profundo invalida todo lo de arriba', () {
      final e = _op(
        Operation.multiply,
        _op(
          Operation.add,
          _op(Operation.subtract, TileLeaf(5), TileLeaf(4)),
          TileLeaf(1),
        ),
        TileLeaf(0),
      );
      // 3 - 7 es negativo: el arbol completo cae.
      expect(evaluate(e, tablero), isNull);
    });
  });

  group('expresiones largas', () {
    test('las seis fichas encadenadas dan un entero', () {
      // ((100 + 75) * 3) - ((50 + 25) - 7) = 525 - 68 = 457
      final e = _op(
        Operation.subtract,
        _op(
          Operation.multiply,
          _op(Operation.add, TileLeaf(0), TileLeaf(1)),
          TileLeaf(5),
        ),
        _op(
          Operation.subtract,
          _op(Operation.add, TileLeaf(2), TileLeaf(3)),
          TileLeaf(4),
        ),
      );
      expect(evaluate(e, tablero), 457);
      expect(e.usedTiles.length, 6);
    });
  });

  group('trySolution', () {
    test('devuelve una solucion cuando la expresion es valida', () {
      final e = _op(
        Operation.multiply,
        _op(Operation.add, TileLeaf(1), TileLeaf(3)),
        TileLeaf(4),
      );
      final s = trySolution(e, tablero);
      expect(s, isNotNull);
      expect(s!.value, 700);
      expect(s.opCount, 2);
      expect(s.usesAllTiles, isFalse);
    });

    test('devuelve null cuando la expresion es invalida', () {
      expect(
        trySolution(_op(Operation.divide, TileLeaf(0), TileLeaf(5)), tablero),
        isNull,
      );
    });

    test('marca que agota las seis fichas', () {
      final e = _op(
        Operation.subtract,
        _op(
          Operation.multiply,
          _op(Operation.add, TileLeaf(0), TileLeaf(1)),
          TileLeaf(5),
        ),
        _op(
          Operation.subtract,
          _op(Operation.add, TileLeaf(2), TileLeaf(3)),
          TileLeaf(4),
        ),
      );
      expect(trySolution(e, tablero)?.usesAllTiles, isTrue);
    });
  });
}
