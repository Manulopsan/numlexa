// Enumeracion de los multiconjuntos validos de seis fichas.
//
// Esta es la entrada del DP de alcanzabilidad (F1.04): para cada uno de estos
// multiconjuntos se calculara de golpe que objetivos entre 101 y 999 son
// alcanzables, y de ahi sale la garantia de que todo puzle servido tiene
// solucion exacta (`CLAUDE.md §5`).
//
// La cuenta total esta calculada a mano en la bitacora de F1.03 y fijada en
// los tests: **13.243**. Si la implementacion cambia y la cuenta no cuadra,
// el test se cae, que es justo lo que se quiere.

import 'types.dart';

/// Valores de la bolsa grande, en orden descendente y estable.
const List<int> _largeOrdered = <int>[100, 75, 50, 25];

/// Valores de la bolsa pequena, en orden descendente y estable.
const List<int> _smallOrdered = <int>[10, 9, 8, 7, 6, 5, 4, 3, 2, 1];

/// Cuantas veces puede repetirse una ficha pequena.
const int _smallMultiplicity = 2;

/// Enumera todos los multiconjuntos validos de seis fichas.
///
/// El recorrido es **determinista**: mismo orden en cada ejecucion, lo que
/// permite que el generador offline de F1.08 reanude por indice y que los
/// artefactos sean reproducibles.
Iterable<TileSet> enumerateTileSets() sync* {
  for (var grandes = 0; grandes <= _largeOrdered.length; grandes++) {
    for (final elegidas in _combinaciones(_largeOrdered, grandes)) {
      for (final pequenas in _multiconjuntosPequenos(
        tilesPerPuzzle - grandes,
      )) {
        yield TileSet(<Tile>[
          for (final v in elegidas) Tile(v),
          for (final v in pequenas) Tile(v),
        ]);
      }
    }
  }
}

/// Cuenta los multiconjuntos por numero de fichas grandes, sin enumerarlos.
///
/// Es la comprobacion cruzada de [enumerateTileSets]: llega al mismo resultado
/// por combinatoria en vez de por recorrido, asi que un error en cualquiera de
/// los dos caminos se delata.
Map<int, int> countTileSetsByLargeCount() {
  final resultado = <int, int>{};
  for (var grandes = 0; grandes <= _largeOrdered.length; grandes++) {
    resultado[grandes] =
        _combinatorio(_largeOrdered.length, grandes) *
        countSmallMultisets(tilesPerPuzzle - grandes);
  }
  return resultado;
}

/// Multiconjuntos de tamano [m] sobre las diez fichas pequenas, con cada valor
/// repetido como mucho dos veces.
///
/// Es el coeficiente de `x^m` en `(1 + x + x^2)^10`, calculado como
/// `sum_j C(10, j) * C(10 - j, m - 2j)`, donde `j` es cuantos valores se usan
/// dos veces. Devuelve 0 fuera de la fila.
int countSmallMultisets(int m) {
  if (m < 0 || m > _smallOrdered.length * _smallMultiplicity) {
    return 0;
  }
  final tipos = _smallOrdered.length;
  var total = 0;
  for (var j = 0; j * 2 <= m; j++) {
    final unaVez = m - 2 * j;
    if (j > tipos || unaVez > tipos - j) {
      continue;
    }
    total += _combinatorio(tipos, j) * _combinatorio(tipos - j, unaVez);
  }
  return total;
}

/// Combinaciones de [k] elementos de [valores], en orden estable.
Iterable<List<int>> _combinaciones(List<int> valores, int k) sync* {
  if (k == 0) {
    yield const <int>[];
    return;
  }
  if (k > valores.length) {
    return;
  }
  for (var i = 0; i <= valores.length - k; i++) {
    for (final resto in _combinaciones(valores.sublist(i + 1), k - 1)) {
      yield <int>[valores[i], ...resto];
    }
  }
}

/// Multiconjuntos de [m] fichas pequenas, cada valor como mucho dos veces.
Iterable<List<int>> _multiconjuntosPequenos(int m) sync* {
  yield* _pequenosDesde(0, m, const <int>[]);
}

Iterable<List<int>> _pequenosDesde(
  int desde,
  int restantes,
  List<int> acumulado,
) sync* {
  if (restantes == 0) {
    yield acumulado;
    return;
  }
  if (desde >= _smallOrdered.length) {
    return;
  }
  // Poda: aunque se cogieran dos de cada valor restante, no llegaria.
  if ((_smallOrdered.length - desde) * _smallMultiplicity < restantes) {
    return;
  }
  final valor = _smallOrdered[desde];
  final maximo = restantes < _smallMultiplicity
      ? restantes
      : _smallMultiplicity;
  for (var veces = 0; veces <= maximo; veces++) {
    yield* _pequenosDesde(desde + 1, restantes - veces, <int>[
      ...acumulado,
      for (var i = 0; i < veces; i++) valor,
    ]);
  }
}

/// Numero combinatorio C(n, k), exacto y sin desbordar en estos tamanos.
int _combinatorio(int n, int k) {
  if (k < 0 || k > n) {
    return 0;
  }
  final kk = k > n - k ? n - k : k;
  var resultado = 1;
  for (var i = 0; i < kk; i++) {
    resultado = resultado * (n - i) ~/ (i + 1);
  }
  return resultado;
}
