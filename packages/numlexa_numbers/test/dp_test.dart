import 'package:numlexa_numbers/numlexa_numbers.dart';
import 'package:test/test.dart';

/// Tablero del criterio de aceptacion.
/// Orden canonico: 0=100 1=75 2=50 3=25 4=6 5=3
final TileSet tableroCriterio = TileSet(<Tile>[
  Tile(25),
  Tile(50),
  Tile(75),
  Tile(100),
  Tile(3),
  Tile(6),
]);

/// Genera TODAS las expresiones que usan exactamente los indices dados.
///
/// Es la referencia independiente: construye arboles de verdad y los pasa por
/// `evaluate()` de F1.02, sin compartir una linea con el DP. Si ambos coinciden
/// es porque los dos aciertan, no porque compartan el mismo error.
List<Expression> _arboles(List<int> indices) {
  if (indices.length == 1) {
    return <Expression>[TileLeaf(indices.single)];
  }
  final resultado = <Expression>[];
  final n = indices.length;
  // Particiones no vacias en A y B; se recorren ambos ordenes porque `-` y `/`
  // no son conmutativas.
  for (var mascara = 1; mascara < (1 << n) - 1; mascara++) {
    final a = <int>[];
    final b = <int>[];
    for (var i = 0; i < n; i++) {
      if ((mascara & (1 << i)) != 0) {
        a.add(indices[i]);
      } else {
        b.add(indices[i]);
      }
    }
    for (final izq in _arboles(a)) {
      for (final der in _arboles(b)) {
        for (final op in Operation.values) {
          final nodo = OpNode.tryFrom(op, izq, der);
          if (nodo != null) {
            resultado.add(nodo);
          }
        }
      }
    }
  }
  return resultado;
}

/// Valores alcanzables con exactamente esos indices, por fuerza bruta.
Set<int> _fuerzaBruta(List<int> indices, TileSet tablero) {
  final valores = <int>{};
  for (final arbol in _arboles(indices)) {
    final v = evaluate(arbol, tablero);
    if (v != null) {
      valores.add(v);
    }
  }
  return valores;
}

int _popcount(int m) {
  var c = 0;
  var x = m;
  while (x != 0) {
    c += x & 1;
    x >>= 1;
  }
  return c;
}

void main() {
  group('criterio de aceptacion de F1.04', () {
    test('[25,50,75,100,3,6] alcanza 952', () {
      expect(reachable(tableroCriterio), contains(952));
    });

    test('el 952 se puede exhibir: el evaluador confirma al DP', () {
      // ((75 * 3) * (100 + 6) - 50) / 25 = (23850 - 50) / 25 = 952
      final e = OpNode(
        Operation.divide,
        OpNode(
          Operation.subtract,
          OpNode(
            Operation.multiply,
            OpNode(Operation.multiply, TileLeaf(1), TileLeaf(5)),
            OpNode(Operation.add, TileLeaf(0), TileLeaf(4)),
          ),
          TileLeaf(2),
        ),
        TileLeaf(3),
      );
      expect(evaluate(e, tableroCriterio), 952);
    });

    test('CORRECCION: 1000000 SI es alcanzable, y aqui esta la expresion', () {
      // El criterio original de DESARROLLO.md decia que no lo era. Es falso, y
      // se demostro con una busqueda exhaustiva independiente del DP:
      //   (6 / 3) * ((25 + 75) * (50 * 100)) = 2 * (100 * 5000) = 1.000.000
      final e = OpNode(
        Operation.multiply,
        OpNode(Operation.divide, TileLeaf(4), TileLeaf(5)),
        OpNode(
          Operation.multiply,
          OpNode(Operation.add, TileLeaf(3), TileLeaf(1)),
          OpNode(Operation.multiply, TileLeaf(2), TileLeaf(0)),
        ),
      );
      expect(evaluate(e, tableroCriterio), 1000000);
      expect(reachable(tableroCriterio), contains(1000000));
    });

    test('lo que de verdad NO alcanza: 999999 ni 1000001', () {
      // Ambos comprobados con una busqueda exhaustiva por un algoritmo
      // distinto al DP (recursivo por pares, no por mascaras). Sirven para lo
      // que pretendia el criterio original: que el DP no invente valores.
      expect(reachable(tableroCriterio), isNot(contains(999999)));
      expect(reachable(tableroCriterio), isNot(contains(1000001)));
    });
  });

  group('estructura del DP', () {
    test('cada subconjunto de una sola ficha vale esa ficha', () {
      final tabla = reachableBySubset(tableroCriterio);
      for (var i = 0; i < 6; i++) {
        expect(tabla[1 << i], <int>{tableroCriterio.tiles[i].value});
      }
    });

    test('el subconjunto vacio no alcanza nada', () {
      expect(reachableBySubset(tableroCriterio)[0], isEmpty);
    });

    test('todo valor alcanzable es un entero estrictamente positivo', () {
      for (final v in reachable(tableroCriterio)) {
        expect(v, greaterThan(0));
      }
    });

    test('dos fichas grandes: el resultado se puede contar a mano', () {
      // 100 y 75: suma 175, resta 25, producto 7500. La division no es exacta.
      final tabla = reachableBySubset(tableroCriterio);
      final mascara = (1 << 0) | (1 << 1);
      expect(tabla[mascara], <int>{175, 25, 7500});
    });

    test('dos fichas con division exacta la incluyen', () {
      // 75 y 25: 100, 50, 1875 y 3.
      final tabla = reachableBySubset(tableroCriterio);
      final mascara = (1 << 1) | (1 << 3);
      expect(tabla[mascara], <int>{100, 50, 1875, 3});
    });

    test('nunca aparece un cero ni un negativo, ni con fichas iguales', () {
      // Dos treses: 3+3=6, 3*3=9, 3/3=1. La resta daria 0 y no debe estar.
      final dosTreses = TileSet(<Tile>[
        Tile(3),
        Tile(3),
        Tile(10),
        Tile(9),
        Tile(8),
        Tile(7),
      ]);
      // Orden canonico: 0=10 1=9 2=8 3=7 4=3 5=3
      final tabla = reachableBySubset(dosTreses);
      expect(tabla[(1 << 4) | (1 << 5)], <int>{6, 9, 1});
    });
  });

  group('contraste contra la fuerza bruta con el evaluador de F1.02', () {
    test('coinciden en todos los subconjuntos de hasta cuatro fichas', () {
      final tabla = reachableBySubset(tableroCriterio);
      var comprobados = 0;
      for (var mascara = 1; mascara < 64; mascara++) {
        if (_popcount(mascara) > 4) {
          continue;
        }
        final indices = <int>[
          for (var i = 0; i < 6; i++)
            if ((mascara & (1 << i)) != 0) i,
        ];
        expect(
          tabla[mascara],
          _fuerzaBruta(indices, tableroCriterio),
          reason: 'divergen en la mascara $mascara (indices $indices)',
        );
        comprobados++;
      }
      expect(comprobados, 56, reason: '6 + 15 + 20 + 15 subconjuntos');
    });
  });

  group('reachableTargets', () {
    test('solo devuelve objetivos legales', () {
      for (final v in reachableTargets(tableroCriterio)) {
        expect(v, inInclusiveRange(minTargetValue, maxTargetValue));
      }
    });

    test('es exactamente el corte de reachable con [101, 999]', () {
      final esperado = reachable(
        tableroCriterio,
      ).where((int v) => v >= minTargetValue && v <= maxTargetValue).toSet();
      expect(reachableTargets(tableroCriterio), esperado);
    });

    test('952 esta entre los objetivos alcanzables', () {
      expect(reachableTargets(tableroCriterio), contains(952));
    });
  });
}
