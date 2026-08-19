// Tipos del motor de cifras.
//
// Objetivo de diseno (F1.01): que **no se pueda representar un estado
// imposible**. Una ficha de valor 42 no existe; un tablero de cinco fichas no
// existe; un objetivo de 1000 no existe; una expresion que use dos veces la
// misma ficha no existe.
//
// La unica excepcion es deliberada y esta explicada en `Expression`.

import 'dart:collection';

/// Valores de la bolsa grande: hay **una** de cada (`CLAUDE.md §5`).
const Set<int> largeTileValues = <int>{25, 50, 75, 100};

/// Valores de la bolsa pequena: hay **dos** de cada.
const Set<int> smallTileValues = <int>{1, 2, 3, 4, 5, 6, 7, 8, 9, 10};

/// Numero de fichas de una ronda de cifras.
const int tilesPerPuzzle = 6;

/// Maximo de operaciones de una solucion: seis fichas dan cinco combinaciones.
const int maxOperations = tilesPerPuzzle - 1;

/// Valor minimo del objetivo, incluido.
const int minTargetValue = 101;

/// Valor maximo del objetivo, incluido.
const int maxTargetValue = 999;

/// Una ficha. Solo puede existir con un valor de alguna de las dos bolsas.
final class Tile {
  const Tile._(this.value);

  /// Crea una ficha, o lanza si el valor no pertenece a ninguna bolsa.
  factory Tile(int value) {
    final ficha = Tile.tryFrom(value);
    if (ficha == null) {
      throw ArgumentError.value(
        value,
        'value',
        'no es una ficha valida: se esperaba 1-10 o una de $largeTileValues',
      );
    }
    return ficha;
  }

  /// Crea una ficha, o `null` si el valor no es valido.
  static Tile? tryFrom(int value) {
    if (largeTileValues.contains(value) || smallTileValues.contains(value)) {
      return Tile._(value);
    }
    return null;
  }

  final int value;

  bool get isLarge => largeTileValues.contains(value);

  @override
  bool operator ==(Object other) => other is Tile && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Tile($value)';
}

/// Las seis fichas de una ronda, con las multiplicidades de las bolsas.
///
/// El orden se **normaliza de mayor a menor** al construir. No es cosmetica:
/// los indices de [TileLeaf] apuntan a esta lista, asi que sin un orden
/// canonico la misma expresion significaria cosas distintas segun como se
/// hubiera construido el tablero.
final class TileSet {
  TileSet._(this._tiles);

  /// Crea un tablero, o lanza explicando que invariante se ha roto.
  factory TileSet(List<Tile> tiles) {
    final motivo = _validationError(tiles);
    if (motivo != null) {
      throw ArgumentError.value(tiles, 'tiles', motivo);
    }
    return TileSet._(_canonical(tiles));
  }

  /// Crea un tablero, o `null` si las fichas no forman uno valido.
  static TileSet? tryFrom(List<Tile> tiles) {
    if (_validationError(tiles) != null) {
      return null;
    }
    return TileSet._(_canonical(tiles));
  }

  static List<Tile> _canonical(List<Tile> tiles) {
    return List<Tile>.of(tiles)
      ..sort((Tile a, Tile b) => b.value.compareTo(a.value));
  }

  /// Devuelve el motivo por el que las fichas no son un tablero, o `null`.
  static String? _validationError(List<Tile> tiles) {
    if (tiles.length != tilesPerPuzzle) {
      return 'un tablero tiene exactamente $tilesPerPuzzle fichas, '
          'y se han recibido ${tiles.length}';
    }
    final apariciones = <int, int>{};
    for (final ficha in tiles) {
      apariciones[ficha.value] = (apariciones[ficha.value] ?? 0) + 1;
    }
    for (final entrada in apariciones.entries) {
      final maximo = largeTileValues.contains(entrada.key) ? 1 : 2;
      if (entrada.value > maximo) {
        return 'la ficha ${entrada.key} aparece ${entrada.value} veces y en '
            'la bolsa solo hay $maximo';
      }
    }
    return null;
  }

  final List<Tile> _tiles;

  /// Las fichas en orden canonico. La lista no es modificable.
  List<Tile> get tiles => UnmodifiableListView<Tile>(_tiles);

  /// Cuantas fichas grandes hay. Palanca principal de dificultad (`D-03`).
  int get largeCount => _tiles.where((Tile t) => t.isLarge).length;

  @override
  bool operator ==(Object other) {
    if (other is! TileSet) {
      return false;
    }
    for (var i = 0; i < _tiles.length; i++) {
      if (_tiles[i] != other._tiles[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(_tiles);

  @override
  String toString() => 'TileSet(${_tiles.map((Tile t) => t.value).join(', ')})';
}

/// El objetivo de la ronda. Siempre en `[101, 999]`.
final class Target {
  const Target._(this.value);

  /// Crea un objetivo, o lanza si esta fuera de rango.
  factory Target(int value) {
    final objetivo = Target.tryFrom(value);
    if (objetivo == null) {
      throw ArgumentError.value(
        value,
        'value',
        'el objetivo debe estar en [$minTargetValue, $maxTargetValue]',
      );
    }
    return objetivo;
  }

  /// Crea un objetivo, o `null` si esta fuera de rango.
  static Target? tryFrom(int value) {
    if (value < minTargetValue || value > maxTargetValue) {
      return null;
    }
    return Target._(value);
  }

  final int value;

  @override
  bool operator ==(Object other) => other is Target && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Target($value)';
}

/// Las cuatro operaciones permitidas. No hay mas (`CLAUDE.md §5`).
enum Operation {
  add('+'),
  subtract('-'),
  multiply('*'),
  divide('/');

  const Operation(this.symbol);

  final String symbol;
}

/// Arbol de una expresion sobre las fichas de un tablero.
///
/// **Excepcion deliberada al «sin estados imposibles»:** este arbol puede ser
/// sintacticamente valido y semanticamente invalido, como `3 - 5` o `100 / 3`.
/// Es a proposito. El servidor recibe expresiones de los clientes y tiene que
/// poder **representarlas para rechazarlas** (`CLAUDE.md §6`, regimen B); si
/// fueran irrepresentables, la validacion se colaria dentro del parseo, donde
/// es mucho mas dificil de probar. De eso se encarga `evaluate()` en F1.02.
///
/// Lo que si es irrepresentable es usar dos veces la misma ficha: eso no es
/// una jugada mala, es una jugada que no existe.
sealed class Expression {
  const Expression();

  /// Indices de ficha que consume el arbol.
  Set<int> get usedTiles;

  /// Numero de operaciones del arbol.
  int get opCount;
}

/// Hoja: una ficha del tablero, por posicion.
final class TileLeaf extends Expression {
  const TileLeaf._(this.index);

  /// Crea una hoja, o lanza si el indice cae fuera del tablero.
  factory TileLeaf(int index) {
    final hoja = TileLeaf.tryFrom(index);
    if (hoja == null) {
      throw ArgumentError.value(
        index,
        'index',
        'una hoja apunta a una posicion en [0, ${tilesPerPuzzle - 1}]',
      );
    }
    return hoja;
  }

  /// Crea una hoja, o `null` si el indice cae fuera del tablero.
  static TileLeaf? tryFrom(int index) {
    if (index < 0 || index >= tilesPerPuzzle) {
      return null;
    }
    return TileLeaf._(index);
  }

  final int index;

  @override
  Set<int> get usedTiles => <int>{index};

  @override
  int get opCount => 0;

  @override
  bool operator ==(Object other) => other is TileLeaf && other.index == index;

  @override
  int get hashCode => index.hashCode;

  @override
  String toString() => 'TileLeaf($index)';
}

/// Nodo: dos subexpresiones combinadas por una operacion.
final class OpNode extends Expression {
  OpNode._(this.operation, this.left, this.right, this.usedTiles);

  /// Crea un nodo, o lanza si ambas ramas comparten alguna ficha.
  factory OpNode(Operation operation, Expression left, Expression right) {
    final nodo = OpNode.tryFrom(operation, left, right);
    if (nodo == null) {
      throw ArgumentError(
        'las dos ramas comparten fichas '
        '(${left.usedTiles.intersection(right.usedTiles)}): cada ficha se usa '
        'como maximo una vez',
      );
    }
    return nodo;
  }

  /// Crea un nodo, o `null` si ambas ramas comparten alguna ficha.
  static OpNode? tryFrom(
    Operation operation,
    Expression left,
    Expression right,
  ) {
    if (left.usedTiles.intersection(right.usedTiles).isNotEmpty) {
      return null;
    }
    return OpNode._(operation, left, right, <int>{
      ...left.usedTiles,
      ...right.usedTiles,
    });
  }

  final Operation operation;
  final Expression left;
  final Expression right;

  @override
  final Set<int> usedTiles;

  @override
  int get opCount => 1 + left.opCount + right.opCount;

  @override
  bool operator ==(Object other) =>
      other is OpNode &&
      other.operation == operation &&
      other.left == left &&
      other.right == right;

  @override
  int get hashCode => Object.hash(operation, left, right);

  @override
  String toString() => '($left ${operation.symbol} $right)';
}

/// Una expresion junto con el valor que produce.
///
/// A diferencia de [Expression], una [Solution] **no puede llevar un valor
/// invalido**: si existe, su valor es un entero estrictamente positivo. Quien
/// la construye es el evaluador (F1.02), que es el unico que puede afirmarlo.
final class Solution {
  /// Crea una solucion, o lanza si el valor no es estrictamente positivo.
  factory Solution({required Expression expression, required int value}) {
    if (value <= 0) {
      throw ArgumentError.value(
        value,
        'value',
        'el valor de una solucion es un entero estrictamente positivo',
      );
    }
    return Solution._(expression, value);
  }

  const Solution._(this.expression, this.value);

  final Expression expression;
  final int value;

  int get opCount => expression.opCount;

  Set<int> get usedTiles => expression.usedTiles;

  /// Si agota las seis fichas del tablero.
  bool get usesAllTiles => usedTiles.length == tilesPerPuzzle;

  @override
  bool operator ==(Object other) =>
      other is Solution &&
      other.expression == expression &&
      other.value == value;

  @override
  int get hashCode => Object.hash(expression, value);

  @override
  String toString() => 'Solution($expression = $value)';
}

/// Metricas de dificultad de un puzle (`F1.07`).
final class PuzzleMeta {
  /// Crea las metricas, o lanza si describen un puzle que no puede existir.
  factory PuzzleMeta({
    required int solutionCount,
    required int minOps,
    required bool requiresDivision,
    required bool requiresAllTiles,
  }) {
    if (solutionCount < 1) {
      throw ArgumentError.value(
        solutionCount,
        'solutionCount',
        'todo puzle servido tiene solucion exacta garantizada, sin excepciones '
            '(CLAUDE.md §5)',
      );
    }
    if (minOps < 1 || minOps > maxOperations) {
      throw ArgumentError.value(
        minOps,
        'minOps',
        'con $tilesPerPuzzle fichas hay entre 1 y $maxOperations operaciones',
      );
    }
    return PuzzleMeta._(
      solutionCount,
      minOps,
      requiresDivision,
      requiresAllTiles,
    );
  }

  const PuzzleMeta._(
    this.solutionCount,
    this.minOps,
    this.requiresDivision,
    this.requiresAllTiles,
  );

  /// Cuantas soluciones exactas distintas tiene.
  final int solutionCount;

  /// Operaciones de la solucion mas corta.
  final int minOps;

  /// Si toda solucion exacta pasa por una division.
  final bool requiresDivision;

  /// Si toda solucion exacta agota las seis fichas.
  final bool requiresAllTiles;

  @override
  bool operator ==(Object other) =>
      other is PuzzleMeta &&
      other.solutionCount == solutionCount &&
      other.minOps == minOps &&
      other.requiresDivision == requiresDivision &&
      other.requiresAllTiles == requiresAllTiles;

  @override
  int get hashCode =>
      Object.hash(solutionCount, minOps, requiresDivision, requiresAllTiles);

  @override
  String toString() =>
      'PuzzleMeta(soluciones: $solutionCount, minOps: $minOps, '
      'division: $requiresDivision, todas: $requiresAllTiles)';
}
