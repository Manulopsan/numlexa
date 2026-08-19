import 'package:test/test.dart';

/// Andamio de F0.06: cada paquete necesita al menos un fichero de test para
/// que `dart test` no falle por ausencia de tests y para que el pipeline de
/// cobertura tenga algo que medir. Se sustituye por los tests reales de las
/// reglas del juego, que por `CLAUDE.md §7` se escriben ANTES que la
/// implementacion: F1.02 (cifras), F2.02 (letras) y F3.02 (nucleo).
void main() {
  test('el paquete resuelve y ejecuta sus tests', () {
    expect(1 + 1, 2);
  });
}
