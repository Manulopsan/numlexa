// Solver: encuentra la expresion que alcanza un objetivo, o la que mas se
// acerca.
//
// Observacion que simplifica todo el problema: **el numero de operaciones no
// depende del valor, sino de cuantas fichas se usan**. Una expresion que gasta
// exactamente `k` fichas tiene siempre `k - 1` operaciones. Asi que «la
// solucion con menos operaciones» es simplemente «la que usa menos fichas», y
// basta recorrer las mascaras por numero de bits ascendente y quedarse con la
// primera que alcance el objetivo.
//
// El DP de F1.04 solo guarda valores. Aqui se guarda ademas **como** se
// obtuvo cada valor: un paso con la operacion y las dos mitades. No se
// construyen arboles durante el calculo —seria carisimo y casi todos se
// tirarian—, sino que se reconstruye uno solo al final, el de la respuesta.

import 'types.dart';

/// Como se obtuvo un valor: dos mitades y la operacion que las une.
///
/// Una hoja se representa con [operation] a `null`.
class _Paso {
  const _Paso.hoja()
    : operation = null,
      leftMask = 0,
      left = 0,
      rightMask = 0,
      right = 0;

  const _Paso(
    this.operation,
    this.leftMask,
    this.left,
    this.rightMask,
    this.right,
  );

  final Operation? operation;
  final int leftMask;
  final int left;
  final int rightMask;
  final int right;
}

/// Tabla de reconstruccion: por mascara, como se llega a cada valor.
List<Map<int, _Paso>> _buildTable(TileSet tiles) {
  final fichas = tiles.tiles;
  final n = fichas.length;
  final total = 1 << n;
  final tabla = List<Map<int, _Paso>>.generate(
    total,
    (_) => <int, _Paso>{},
    growable: false,
  );

  for (var i = 0; i < n; i++) {
    tabla[1 << i][fichas[i].value] = const _Paso.hoja();
  }

  for (var mascara = 1; mascara < total; mascara++) {
    if (mascara & (mascara - 1) == 0) {
      continue;
    }
    final destino = tabla[mascara];
    final bitMasBajo = mascara & -mascara;

    for (var a = (mascara - 1) & mascara; a > 0; a = (a - 1) & mascara) {
      if (a & bitMasBajo == 0) {
        continue;
      }
      final b = mascara ^ a;
      for (final x in tabla[a].keys) {
        for (final y in tabla[b].keys) {
          destino[x + y] ??= _Paso(Operation.add, a, x, b, y);
          destino[x * y] ??= _Paso(Operation.multiply, a, x, b, y);
          if (x > y) {
            destino[x - y] ??= _Paso(Operation.subtract, a, x, b, y);
          } else if (y > x) {
            destino[y - x] ??= _Paso(Operation.subtract, b, y, a, x);
          }
          if (x % y == 0) {
            destino[x ~/ y] ??= _Paso(Operation.divide, a, x, b, y);
          }
          if (y % x == 0) {
            destino[y ~/ x] ??= _Paso(Operation.divide, b, y, a, x);
          }
        }
      }
    }
  }

  return tabla;
}

/// Reconstruye el arbol que produce [valor] con las fichas de [mascara].
Expression _reconstruir(List<Map<int, _Paso>> tabla, int mascara, int valor) {
  final paso = tabla[mascara][valor]!;
  final op = paso.operation;
  if (op == null) {
    // Hoja: la mascara tiene un solo bit, y su posicion es el indice.
    var indice = 0;
    var m = mascara;
    while (m > 1) {
      m >>= 1;
      indice++;
    }
    return TileLeaf(indice);
  }
  return OpNode(
    op,
    _reconstruir(tabla, paso.leftMask, paso.left),
    _reconstruir(tabla, paso.rightMask, paso.right),
  );
}

int _popcount(int m) {
  var c = 0;
  var x = m;
  while (x != 0) {
    x &= x - 1;
    c++;
  }
  return c;
}

/// Resuelve [target] con [tiles].
///
/// Devuelve la solucion **exacta con menos operaciones** si existe. Si no, la
/// **mejor aproximacion**: la de menor distancia al objetivo y, a igualdad de
/// distancia, la de menos operaciones.
///
/// Siempre devuelve algo: con seis fichas siempre hay al menos seis valores
/// alcanzables, asi que la peor respuesta posible es una ficha suelta.
Solution solve(TileSet tiles, Target target) {
  final tabla = _buildTable(tiles);
  final objetivo = target.value;

  var mejorMascara = 0;
  var mejorValor = 0;
  var mejorDistancia = -1;
  var mejorOps = 0;

  for (var mascara = 1; mascara < tabla.length; mascara++) {
    final ops = _popcount(mascara) - 1;
    for (final valor in tabla[mascara].keys) {
      final distancia = (valor - objetivo).abs();
      // Menor distancia gana; a igualdad, menos operaciones.
      final mejora =
          mejorDistancia < 0 ||
          distancia < mejorDistancia ||
          (distancia == mejorDistancia && ops < mejorOps);
      if (mejora) {
        mejorDistancia = distancia;
        mejorOps = ops;
        mejorMascara = mascara;
        mejorValor = valor;
        // Aqui habia un atajo para «exacta con cero operaciones». Se quito
        // porque es inalcanzable: un objetivo esta en [101, 999] y ninguna
        // ficha pasa de 100, asi que una hoja suelta nunca acierta. Lo delato
        // el umbral de cobertura, que lo senalo como las unicas dos lineas sin
        // ejecutar de todo el paquete.
      }
    }
  }

  return Solution(
    expression: _reconstruir(tabla, mejorMascara, mejorValor),
    value: mejorValor,
  );
}
