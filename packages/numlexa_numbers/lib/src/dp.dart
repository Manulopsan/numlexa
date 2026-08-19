// DP sobre subconjuntos: que valores se pueden alcanzar con un tablero.
//
// Es el corazon del proyecto. De aqui sale la garantia de `CLAUDE.md §5`: todo
// puzle servido tiene solucion exacta. **No se consigue generando y
// comprobando**, sino calculando de golpe, para un multiconjunto de seis
// fichas, TODOS los valores alcanzables. La garantia acaba siendo por
// construccion, y en ejecucion no se calcula nada.
//
// La recurrencia es la clasica sobre particiones. Para un subconjunto S de
// fichas, todo valor alcanzable con S sale de partirlo en dos mitades no
// vacias `S = A ⊎ B`, tomar un valor de cada una y combinarlos con una de las
// cuatro operaciones. Un valor «alcanzable con S» usa TODAS las fichas de S;
// como no hace falta usarlas todas, el conjunto final es la union sobre todos
// los subconjuntos.
//
// Cada particion no ordenada se visita **una sola vez**: se obliga a que `A`
// contenga el bit mas bajo de `S`. A cambio, hay que probar los dos sentidos
// de la resta y de la division, que no son conmutativas.

import 'types.dart';

/// Tabla del DP: para cada mascara de fichas, los valores que alcanza usando
/// **exactamente** esas fichas.
///
/// El indice es una mascara de bits sobre `tiles.tiles`, en orden canonico. La
/// posicion 0 (conjunto vacio) queda vacia a proposito.
///
/// Se devuelve entera, y no solo la union, porque el solver de F1.06 la
/// necesita para reconstruir la expresion que produce un valor.
List<Set<int>> reachableBySubset(TileSet tiles) {
  final fichas = tiles.tiles;
  final n = fichas.length;
  final total = 1 << n;
  final tabla = List<Set<int>>.generate(total, (_) => <int>{}, growable: false);

  for (var i = 0; i < n; i++) {
    tabla[1 << i].add(fichas[i].value);
  }

  for (var mascara = 1; mascara < total; mascara++) {
    // Los subconjuntos de una sola ficha ya estan puestos.
    if (mascara & (mascara - 1) == 0) {
      continue;
    }
    final valores = tabla[mascara];
    final bitMasBajo = mascara & -mascara;

    // Recorre los subconjuntos propios no vacios de `mascara`. Todo subconjunto
    // propio es numericamente menor, asi que al ir de menor a mayor sus valores
    // ya estan calculados.
    for (var a = (mascara - 1) & mascara; a > 0; a = (a - 1) & mascara) {
      // Canonizacion: cada particion se visita una vez.
      if (a & bitMasBajo == 0) {
        continue;
      }
      final b = mascara ^ a;
      for (final x in tabla[a]) {
        for (final y in tabla[b]) {
          valores.add(x + y);
          valores.add(x * y);
          // Solo estrictamente positivo: `x == y` no aporta nada.
          if (x > y) {
            valores.add(x - y);
          } else if (y > x) {
            valores.add(y - x);
          }
          // `x` e `y` son siempre > 0, asi que no hay division por cero.
          if (x % y == 0) {
            valores.add(x ~/ y);
          }
          if (y % x == 0) {
            valores.add(y ~/ x);
          }
        }
      }
    }
  }

  return tabla;
}

/// Todos los valores alcanzables con [tiles], usando **cualquier** subconjunto.
///
/// No hace falta gastar las seis fichas (`CLAUDE.md §5`), asi que es la union
/// de la tabla del DP.
Set<int> reachable(TileSet tiles) {
  final union = <int>{};
  for (final valores in reachableBySubset(tiles)) {
    union.addAll(valores);
  }
  return union;
}

/// Los objetivos legales alcanzables con [tiles], es decir el corte de
/// [reachable] con `[101, 999]`.
///
/// Es lo que consume el bitmap de F1.05: 899 bits por multiconjunto.
Set<int> reachableTargets(TileSet tiles) {
  final objetivos = <int>{};
  for (final valores in reachableBySubset(tiles)) {
    for (final v in valores) {
      if (v >= minTargetValue && v <= maxTargetValue) {
        objetivos.add(v);
      }
    }
  }
  return objetivos;
}
