// Bitmap de alcanzabilidad: que objetivos de [101, 999] alcanza un tablero.
//
// Es la forma embarcable del DP (`D-02`). El producto cartesiano de
// multiconjuntos por objetivos son millones de filas y no cabe en un movil,
// pero **un bit por objetivo si**: 899 bits, 113 bytes por multiconjunto. Con
// 13.243 multiconjuntos son unos 1,4 MB para responder al instante a «¿este
// objetivo tiene solucion con estas fichas?».
//
// El bit `i` corresponde al objetivo `101 + i`.

import 'dart:typed_data';

import 'dp.dart';
import 'types.dart';

/// Cuantos objetivos legales hay: de 101 a 999, ambos incluidos.
const int targetCount = maxTargetValue - minTargetValue + 1;

/// Bytes que ocupa un bitmap. 899 bits redondeados hacia arriba.
const int bitmapByteLength = (targetCount + 7) ~/ 8;

/// Los objetivos alcanzables de un multiconjunto, como bits.
final class TargetBitmap {
  TargetBitmap._(this._bytes);

  /// Un bitmap sin ningun objetivo marcado.
  factory TargetBitmap.empty() => TargetBitmap._(Uint8List(bitmapByteLength));

  /// Marca los objetivos de [targets]. Lo que cae fuera de `[101, 999]` se
  /// **ignora**: son valores alcanzables que no son objetivos legales, no un
  /// error de quien llama.
  factory TargetBitmap.fromTargets(Iterable<int> targets) {
    final bytes = Uint8List(bitmapByteLength);
    for (final objetivo in targets) {
      if (objetivo < minTargetValue || objetivo > maxTargetValue) {
        continue;
      }
      final bit = objetivo - minTargetValue;
      bytes[bit >> 3] |= 1 << (bit & 7);
    }
    return TargetBitmap._(bytes);
  }

  /// Calcula el bitmap de un tablero ejecutando el DP de F1.04.
  factory TargetBitmap.fromTileSet(TileSet tiles) =>
      TargetBitmap.fromTargets(reachableTargets(tiles));

  /// Reconstruye un bitmap desde su forma serializada.
  factory TargetBitmap.fromBytes(Uint8List bytes) {
    if (bytes.length != bitmapByteLength) {
      throw ArgumentError.value(
        bytes.length,
        'bytes.length',
        'un bitmap ocupa exactamente $bitmapByteLength bytes',
      );
    }
    return TargetBitmap._(Uint8List.fromList(bytes));
  }

  final Uint8List _bytes;

  /// Si [target] es alcanzable. Fuera de rango siempre es `false`.
  bool contains(int target) {
    if (target < minTargetValue || target > maxTargetValue) {
      return false;
    }
    final bit = target - minTargetValue;
    return _bytes[bit >> 3] & (1 << (bit & 7)) != 0;
  }

  /// Cuantos objetivos alcanza. Es la medida de «riqueza» de un multiconjunto
  /// y la entrada de las bandas de dificultad de F1.10.
  int get popcount {
    var total = 0;
    for (final b in _bytes) {
      var x = b;
      while (x != 0) {
        x &= x - 1;
        total++;
      }
    }
    return total;
  }

  /// Los objetivos marcados, en orden ascendente.
  Iterable<int> targets() sync* {
    for (var t = minTargetValue; t <= maxTargetValue; t++) {
      if (contains(t)) {
        yield t;
      }
    }
  }

  /// Copia de los bytes. Es una copia a proposito: el bitmap es inmutable y
  /// nadie de fuera puede alterarlo por descuido.
  Uint8List toBytes() => Uint8List.fromList(_bytes);

  @override
  bool operator ==(Object other) {
    if (other is! TargetBitmap) {
      return false;
    }
    for (var i = 0; i < bitmapByteLength; i++) {
      if (_bytes[i] != other._bytes[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(_bytes);

  @override
  String toString() => 'TargetBitmap($popcount/$targetCount)';
}
