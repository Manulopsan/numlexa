import 'package:test/test.dart';

import 'canary.dart';
import 'vectors.dart';

void main() {
  final vectores = loadVectors('canary');

  group('conformidad: ${vectores.name} v${vectores.version}', () {
    for (final caso in vectores.cases) {
      test(caso.id, () {
        final obtenido = canary(caso.intInput('a'), caso.intInput('b'));
        expect(obtenido, caso.expected, reason: 'caso dorado "${caso.id}"');
      });
    }
  });

  test('el cargador rechaza un fichero inexistente', () {
    expect(() => loadVectors('no-existe'), throwsStateError);
  });
}
