// Comprueba el umbral de cobertura de los paquetes de `packages/`.
//
// Lee el `coverage/lcov.info` que genera `melos run test` en cada paquete,
// calcula el porcentaje de lineas cubiertas y falla si alguno baja del umbral
// (`CLAUDE.md §7`: cobertura minima del 90% en `packages/`).
//
// No usa `print()`: `avoid_print` es error en este repositorio (F0.05).

import 'dart:io';

/// Umbral obligatorio de `CLAUDE.md §7`.
const double umbralMinimo = 90.0;

/// Cobertura de un paquete, derivada de los registros `DA:` de un lcov.
class Cobertura {
  const Cobertura(this.paquete, this.lineas, this.cubiertas);

  final String paquete;
  final int lineas;
  final int cubiertas;

  /// `null` cuando el paquete aun no tiene ninguna linea ejecutable.
  double? get porcentaje => lineas == 0 ? null : cubiertas * 100 / lineas;
}

/// Extrae lineas totales y cubiertas de un `lcov.info`.
///
/// Se cuentan los registros `DA:<linea>,<ejecuciones>` en lugar de fiarse de
/// los resumenes `LF:`/`LH:`, que no todos los generadores emiten.
Cobertura _leerLcov(String paquete, File lcov) {
  var lineas = 0;
  var cubiertas = 0;
  for (final linea in lcov.readAsLinesSync()) {
    if (!linea.startsWith('DA:')) {
      continue;
    }
    final partes = linea.substring(3).split(',');
    if (partes.length < 2) {
      continue;
    }
    final ejecuciones = int.tryParse(partes[1]);
    if (ejecuciones == null) {
      continue;
    }
    lineas++;
    if (ejecuciones > 0) {
      cubiertas++;
    }
  }
  return Cobertura(paquete, lineas, cubiertas);
}

void main(List<String> args) {
  final raiz = Directory('packages');
  if (!raiz.existsSync()) {
    stderr.writeln('No existe packages/. Ejecuta esto desde la raiz del repo.');
    exit(2);
  }

  final paquetes = raiz.listSync().whereType<Directory>().toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  final resultados = <Cobertura>[];
  final sinInforme = <String>[];

  for (final paquete in paquetes) {
    final nombre = paquete.uri.pathSegments
        .where((String s) => s.isNotEmpty)
        .last;
    final lcov = File('${paquete.path}/coverage/lcov.info');
    if (!lcov.existsSync()) {
      sinInforme.add(nombre);
      continue;
    }
    resultados.add(_leerLcov(nombre, lcov));
  }

  stdout.writeln('');
  stdout.writeln('Cobertura por paquete (umbral $umbralMinimo%)');
  stdout.writeln('-' * 58);

  var falla = false;
  for (final r in resultados) {
    final pct = r.porcentaje;
    if (pct == null) {
      stdout.writeln(
        '  ${r.paquete.padRight(20)} sin lineas ejecutables todavia',
      );
      continue;
    }
    final marca = pct >= umbralMinimo ? 'OK  ' : 'FALLA';
    stdout.writeln(
      '  ${r.paquete.padRight(20)} '
      '${pct.toStringAsFixed(1).padLeft(6)}%  '
      '(${r.cubiertas}/${r.lineas})  $marca',
    );
    if (pct < umbralMinimo) {
      falla = true;
    }
  }

  // Un paquete sin informe es un fallo, no un silencio: significa que sus
  // tests no llegaron a correr. Ver dolor #2 de `CLAUDE.md §10`.
  for (final nombre in sinInforme) {
    stdout.writeln('  ${nombre.padRight(20)} SIN INFORME DE COBERTURA  FALLA');
    falla = true;
  }

  stdout.writeln('-' * 58);
  if (falla) {
    stderr.writeln('Cobertura por debajo del umbral o informe ausente.');
    exit(1);
  }
  stdout.writeln('Cobertura correcta.');
}
