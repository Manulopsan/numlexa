// Evaluacion de expresiones de cifras.
//
// Las reglas son de producto y no se negocian (`CLAUDE.md §5`):
//   - Solo `+ - * /`.
//   - **Todo resultado intermedio debe ser entero y estrictamente positivo.**
//     No solo el final: cada paso.
//   - La division solo vale si es exacta.
//   - Cada ficha se usa como maximo una vez. Eso ya es irrepresentable en el
//     tipo `Expression` (F1.01), asi que aqui no hace falta comprobarlo.
//
// `null` significa «esta expresion no es una jugada valida». No es un error ni
// una excepcion: es una respuesta legitima, porque el servidor recibe jugadas
// de clientes y muchas seran invalidas. Ver `CLAUDE.md §6`, regimen B.
//
// OJO: esta funcion tendra una gemela en TypeScript (`F1.14`). Cualquier cambio
// aqui empieza por regenerar los vectores de conformidad, nunca por tocar solo
// uno de los dos lados (`D-08`).

import 'types.dart';

/// Evalua [expression] sobre [tiles].
///
/// Devuelve el valor entero de la expresion, o `null` si en algun paso se
/// incumple alguna de las reglas: division inexacta, o un intermedio que no
/// sea un entero estrictamente positivo.
int? evaluate(Expression expression, TileSet tiles) {
  switch (expression) {
    case TileLeaf(:final index):
      // Toda ficha vale entre 1 y 100, asi que una hoja siempre es valida.
      return tiles.tiles[index].value;

    case OpNode(:final operation, :final left, :final right):
      final izquierda = evaluate(left, tiles);
      if (izquierda == null) {
        return null;
      }
      final derecha = evaluate(right, tiles);
      if (derecha == null) {
        return null;
      }
      return _apply(operation, izquierda, derecha);
  }
}

/// Aplica una operacion a dos intermedios ya validos, o devuelve `null`.
int? _apply(Operation operation, int a, int b) {
  switch (operation) {
    case Operation.add:
      // Dos positivos suman un positivo: no hace falta comprobar nada.
      return a + b;

    case Operation.subtract:
      // Cero NO vale: la regla dice estrictamente positivo.
      return a > b ? a - b : null;

    case Operation.multiply:
      return a * b;

    case Operation.divide:
      // `b` nunca puede ser cero, porque todo intermedio valido es > 0. Aun
      // asi se comprueba: la alternativa es que un cambio futuro convierta
      // esto en una division por cero silenciosa.
      if (b == 0 || a % b != 0) {
        return null;
      }
      return a ~/ b;
  }
}

/// Evalua [expression] y devuelve una [Solution] si es valida.
///
/// Es la unica forma de construir una [Solution] a partir de una expresion:
/// el tipo garantiza que su valor es un entero estrictamente positivo, y solo
/// el evaluador puede afirmarlo.
Solution? trySolution(Expression expression, TileSet tiles) {
  final valor = evaluate(expression, tiles);
  if (valor == null) {
    return null;
  }
  return Solution(expression: expression, value: valor);
}
