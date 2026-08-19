import 'package:numlexa_numbers/numlexa_numbers.dart';
import 'package:test/test.dart';

/// Fichas validas de ejemplo, para no repetir literales por todo el fichero.
TileSet _tableroValido() =>
    TileSet(<Tile>[Tile(100), Tile(75), Tile(3), Tile(3), Tile(7), Tile(1)]);

void main() {
  group('Tile', () {
    test('acepta las cuatro fichas grandes', () {
      for (final valor in <int>[25, 50, 75, 100]) {
        expect(Tile(valor).value, valor);
        expect(Tile(valor).isLarge, isTrue);
      }
    });

    test('acepta las diez fichas pequenas', () {
      for (var valor = 1; valor <= 10; valor++) {
        expect(Tile(valor).value, valor);
        expect(Tile(valor).isLarge, isFalse);
      }
    });

    test('rechaza valores que no estan en ninguna bolsa', () {
      for (final valor in <int>[0, -1, 11, 24, 26, 99, 101, 1000]) {
        expect(Tile.tryFrom(valor), isNull, reason: 'valor $valor');
        expect(() => Tile(valor), throwsArgumentError, reason: 'valor $valor');
      }
    });

    test('es un valor: dos fichas iguales son iguales', () {
      expect(Tile(25), Tile(25));
      expect(Tile(25).hashCode, Tile(25).hashCode);
      expect(Tile(25), isNot(Tile(50)));
    });
  });

  group('TileSet', () {
    test('acepta un tablero valido de seis fichas', () {
      final tablero = _tableroValido();
      expect(tablero.tiles.length, 6);
      expect(tablero.largeCount, 2);
    });

    test('exige exactamente seis fichas', () {
      final cinco = <Tile>[Tile(1), Tile(2), Tile(3), Tile(4), Tile(5)];
      expect(TileSet.tryFrom(cinco), isNull);
      expect(TileSet.tryFrom(<Tile>[...cinco, Tile(6), Tile(7)]), isNull);
      expect(() => TileSet(cinco), throwsArgumentError);
    });

    test('rechaza una ficha grande repetida: solo hay una de cada', () {
      final repetida = <Tile>[
        Tile(100),
        Tile(100),
        Tile(1),
        Tile(2),
        Tile(3),
        Tile(4),
      ];
      expect(TileSet.tryFrom(repetida), isNull);
    });

    test('acepta una ficha pequena repetida dos veces, pero no tres', () {
      final dos = <Tile>[Tile(3), Tile(3), Tile(1), Tile(2), Tile(4), Tile(5)];
      expect(TileSet.tryFrom(dos), isNotNull);
      final tres = <Tile>[Tile(3), Tile(3), Tile(3), Tile(2), Tile(4), Tile(5)];
      expect(TileSet.tryFrom(tres), isNull);
    });

    test('admite de cero a cuatro fichas grandes', () {
      expect(
        TileSet.tryFrom(<Tile>[
          Tile(1),
          Tile(2),
          Tile(3),
          Tile(4),
          Tile(5),
          Tile(6),
        ])?.largeCount,
        0,
      );
      expect(
        TileSet.tryFrom(<Tile>[
          Tile(25),
          Tile(50),
          Tile(75),
          Tile(100),
          Tile(5),
          Tile(6),
        ])?.largeCount,
        4,
      );
    });

    test('la lista de fichas no se puede modificar desde fuera', () {
      final tablero = _tableroValido();
      expect(() => tablero.tiles.add(Tile(9)), throwsUnsupportedError);
    });

    test('normaliza el orden de las fichas, de mayor a menor', () {
      expect(
        _tableroValido().tiles.map((Tile t) => t.value).toList(),
        <int>[100, 75, 7, 3, 3, 1],
        reason:
            'los indices de Expression apuntan a este orden: si no fuera '
            'canonico, la misma expresion significaria cosas distintas',
      );
    });

    test('es un valor y no depende del orden en que se construya', () {
      final a = TileSet(<Tile>[
        Tile(100),
        Tile(75),
        Tile(3),
        Tile(3),
        Tile(7),
        Tile(1),
      ]);
      final b = TileSet(<Tile>[
        Tile(1),
        Tile(3),
        Tile(3),
        Tile(7),
        Tile(75),
        Tile(100),
      ]);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });

  group('Target', () {
    test('acepta los extremos del rango', () {
      expect(Target(101).value, 101);
      expect(Target(999).value, 999);
    });

    test('rechaza fuera de [101, 999]', () {
      for (final valor in <int>[-1, 0, 1, 100, 1000, 12345]) {
        expect(Target.tryFrom(valor), isNull, reason: 'valor $valor');
        expect(
          () => Target(valor),
          throwsArgumentError,
          reason: 'valor $valor',
        );
      }
    });

    test('es un valor', () {
      expect(Target(500), Target(500));
      expect(Target(500).hashCode, Target(500).hashCode);
      expect(Target(500), isNot(Target(501)));
    });
  });

  group('Expression', () {
    test('una hoja referencia una posicion valida del tablero', () {
      for (var i = 0; i < 6; i++) {
        expect(TileLeaf(i).index, i);
      }
    });

    test('rechaza una hoja fuera del tablero', () {
      for (final i in <int>[-1, 6, 7, 100]) {
        expect(TileLeaf.tryFrom(i), isNull, reason: 'indice $i');
        expect(() => TileLeaf(i), throwsArgumentError, reason: 'indice $i');
      }
    });

    test('un nodo compone dos subexpresiones con una operacion', () {
      final e = OpNode(Operation.add, TileLeaf(0), TileLeaf(1));
      expect(e.operation, Operation.add);
      expect(e.left, TileLeaf(0));
      expect(e.right, TileLeaf(1));
    });

    test('cuenta las operaciones del arbol', () {
      expect(TileLeaf(0).opCount, 0);
      expect(OpNode(Operation.add, TileLeaf(0), TileLeaf(1)).opCount, 1);
      expect(
        OpNode(
          Operation.multiply,
          OpNode(Operation.add, TileLeaf(0), TileLeaf(1)),
          TileLeaf(2),
        ).opCount,
        2,
      );
    });

    test('reune los indices de ficha que usa', () {
      expect(TileLeaf(4).usedTiles, <int>{4});
      expect(
        OpNode(
          Operation.subtract,
          OpNode(Operation.add, TileLeaf(0), TileLeaf(1)),
          TileLeaf(5),
        ).usedTiles,
        <int>{0, 1, 5},
      );
    });

    test('rechaza usar la misma ficha dos veces en el mismo arbol', () {
      expect(
        OpNode.tryFrom(Operation.add, TileLeaf(2), TileLeaf(2)),
        isNull,
        reason: 'CLAUDE.md §5: cada ficha se usa como maximo una vez',
      );
      expect(
        OpNode.tryFrom(
          Operation.add,
          OpNode(Operation.multiply, TileLeaf(0), TileLeaf(1)),
          TileLeaf(1),
        ),
        isNull,
      );
      expect(
        () => OpNode(Operation.add, TileLeaf(3), TileLeaf(3)),
        throwsArgumentError,
      );
    });

    test('es un valor: dos arboles identicos son iguales', () {
      final a = OpNode(Operation.divide, TileLeaf(0), TileLeaf(1));
      final b = OpNode(Operation.divide, TileLeaf(0), TileLeaf(1));
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(OpNode(Operation.add, TileLeaf(0), TileLeaf(1))));
    });

    test('las cuatro operaciones tienen simbolo', () {
      expect(Operation.add.symbol, '+');
      expect(Operation.subtract.symbol, '-');
      expect(Operation.multiply.symbol, '*');
      expect(Operation.divide.symbol, '/');
    });
  });

  group('Solution', () {
    final expresion = OpNode(
      Operation.multiply,
      OpNode(Operation.add, TileLeaf(0), TileLeaf(1)),
      TileLeaf(2),
    );

    test('guarda la expresion y su valor', () {
      final s = Solution(expression: expresion, value: 700);
      expect(s.value, 700);
      expect(s.expression, expresion);
      expect(s.opCount, 2);
      expect(s.usedTiles, <int>{0, 1, 2});
    });

    test('rechaza un valor que no sea estrictamente positivo', () {
      for (final v in <int>[0, -1, -700]) {
        expect(
          () => Solution(expression: expresion, value: v),
          throwsArgumentError,
          reason: 'valor $v',
        );
      }
    });

    test('sabe si agota las seis fichas', () {
      expect(Solution(expression: expresion, value: 700).usesAllTiles, isFalse);
    });

    test('es un valor', () {
      expect(
        Solution(expression: expresion, value: 700),
        Solution(expression: expresion, value: 700),
      );
      expect(
        Solution(expression: expresion, value: 700).hashCode,
        Solution(expression: expresion, value: 700).hashCode,
      );
    });
  });

  group('PuzzleMeta', () {
    test('describe la dificultad de un puzle alcanzable', () {
      final m = PuzzleMeta(
        solutionCount: 12,
        minOps: 3,
        requiresDivision: false,
        requiresAllTiles: true,
      );
      expect(m.solutionCount, 12);
      expect(m.minOps, 3);
      expect(m.requiresDivision, isFalse);
      expect(m.requiresAllTiles, isTrue);
    });

    test('exige al menos una solucion: todo puzle servido tiene exacta', () {
      expect(
        () => PuzzleMeta(
          solutionCount: 0,
          minOps: 1,
          requiresDivision: false,
          requiresAllTiles: false,
        ),
        throwsArgumentError,
        reason: 'CLAUDE.md §5: solucion exacta garantizada, sin excepciones',
      );
    });

    test('exige entre 1 y 5 operaciones: seis fichas dan cinco como mucho', () {
      for (final ops in <int>[0, -1, 6, 7]) {
        expect(
          () => PuzzleMeta(
            solutionCount: 1,
            minOps: ops,
            requiresDivision: false,
            requiresAllTiles: false,
          ),
          throwsArgumentError,
          reason: 'minOps $ops',
        );
      }
    });

    test('es un valor', () {
      final a = PuzzleMeta(
        solutionCount: 3,
        minOps: 2,
        requiresDivision: true,
        requiresAllTiles: false,
      );
      final b = PuzzleMeta(
        solutionCount: 3,
        minOps: 2,
        requiresDivision: true,
        requiresAllTiles: false,
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });

  group('representacion legible', () {
    // No es cobertura por cobertura: estos `toString` son lo que se lee en el
    // mensaje de cada `ArgumentError` y en cada fallo de test del evaluador
    // (F1.02). Si cambian de forma, conviene que sea a proposito.
    test('los valores simples se identifican', () {
      expect(Tile(75).toString(), 'Tile(75)');
      expect(Target(512).toString(), 'Target(512)');
      expect(TileLeaf(2).toString(), 'TileLeaf(2)');
    });

    test('el tablero se muestra en orden canonico', () {
      expect(_tableroValido().toString(), 'TileSet(100, 75, 7, 3, 3, 1)');
    });

    test('la expresion se muestra en notacion infija con parentesis', () {
      final e = OpNode(
        Operation.multiply,
        OpNode(Operation.add, TileLeaf(0), TileLeaf(1)),
        TileLeaf(2),
      );
      expect(e.toString(), '((TileLeaf(0) + TileLeaf(1)) * TileLeaf(2))');
      expect(
        Solution(expression: e, value: 700).toString(),
        'Solution(((TileLeaf(0) + TileLeaf(1)) * TileLeaf(2)) = 700)',
      );
    });

    test('las metricas se leen de un vistazo', () {
      final m = PuzzleMeta(
        solutionCount: 3,
        minOps: 2,
        requiresDivision: true,
        requiresAllTiles: false,
      );
      expect(
        m.toString(),
        'PuzzleMeta(soluciones: 3, minOps: 2, division: true, todas: false)',
      );
    });
  });
}
