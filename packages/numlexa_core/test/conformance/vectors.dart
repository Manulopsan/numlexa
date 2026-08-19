// Cargador de los vectores dorados de `conformance/`.
//
// Vive en `test/` y no en `lib/` a proposito: leer ficheros del repositorio es
// infraestructura de verificacion, no una regla del juego, y no tiene por que
// viajar dentro del binario de la aplicacion.

import 'dart:convert';
import 'dart:io';

/// Un caso dorado: entrada y salida esperada, con un identificador legible.
class VectorCase {
  const VectorCase(this.id, this.input, this.expected);

  final String id;
  final Map<String, Object?> input;

  /// Puede ser `null`, y eso es un valor esperado valido, no una ausencia.
  final Object? expected;

  /// Lee un entero de la entrada, fallando claro si el vector esta mal formado.
  int intInput(String clave) {
    final valor = input[clave];
    if (valor is! int) {
      throw StateError(
        'El caso "$id" esperaba un entero en "$clave" y trae: $valor',
      );
    }
    return valor;
  }
}

/// Un fichero de vectores completo.
class VectorFile {
  const VectorFile(this.name, this.version, this.cases);

  final String name;
  final int version;
  final List<VectorCase> cases;
}

/// Sube por el arbol de directorios hasta encontrar `conformance/`.
///
/// Los tests se ejecutan con el directorio de trabajo en la raiz del paquete,
/// pero eso cambia segun quien los lance. Buscar hacia arriba evita rutas
/// relativas fragiles del tipo `../../conformance`.
Directory conformanceDir() {
  var dir = Directory.current.absolute;
  while (true) {
    final candidato = Directory('${dir.path}/conformance');
    if (candidato.existsSync()) {
      return candidato;
    }
    final padre = dir.parent;
    if (padre.path == dir.path) {
      throw StateError(
        'No se encontro el directorio `conformance/` subiendo desde '
        '${Directory.current.absolute.path}',
      );
    }
    dir = padre;
  }
}

/// Carga un fichero de vectores por nombre, sin extension.
VectorFile loadVectors(String nombre) {
  final fichero = File('${conformanceDir().path}/$nombre.json');
  if (!fichero.existsSync()) {
    throw StateError('No existe el fichero de vectores ${fichero.path}');
  }
  final raiz = jsonDecode(fichero.readAsStringSync()) as Map<String, Object?>;
  final casos = (raiz['cases']! as List<Object?>)
      .cast<Map<String, Object?>>()
      .map(
        (Map<String, Object?> c) => VectorCase(
          c['id']! as String,
          c['input']! as Map<String, Object?>,
          c['expected'],
        ),
      )
      .toList();

  // Un fichero sin casos pasaria en verde sin comprobar nada. Eso es el dolor
  // #2 disfrazado de test que aprueba, asi que se rechaza.
  if (casos.isEmpty) {
    throw StateError('El fichero de vectores "$nombre" no contiene casos.');
  }
  final ids = casos.map((VectorCase c) => c.id).toSet();
  if (ids.length != casos.length) {
    throw StateError('El fichero de vectores "$nombre" tiene ids repetidos.');
  }

  return VectorFile(raiz['name']! as String, raiz['version']! as int, casos);
}
