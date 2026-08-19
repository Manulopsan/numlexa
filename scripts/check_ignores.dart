// Comprueba que ningun `// ignore:` del repositorio esta sin justificar.
//
// `CLAUDE.md §7` lo prohibe y no existe lint que lo verifique, asi que se
// comprueba aqui y se enchufa a `melos run verify` (F0.07).
//
// Convencion: una directiva `// ignore:` o `// ignore_for_file:` esta
// justificada si la linea inmediatamente anterior es un comentario `//` con
// texto que NO es otra directiva de ignore. Es decir: hay que escribir por que.
//
//   // El plugin devuelve dynamic y no hay tipo publico al que anclarlo.
//   // ignore: avoid_dynamic_calls
//
// Limitacion asumida: se analiza texto plano, asi que una directiva escrita
// dentro de un literal de cadena contaria como tal. Es preferible ese falso
// positivo, que se ve y se corrige, a dejar pasar un ignore de verdad.
//
// No usa `print()`: `avoid_print` es error en este repositorio (F0.05).

import 'dart:io';

/// Carpetas que no se analizan: artefactos, dependencias y generados.
const Set<String> carpetasExcluidas = <String>{
  '.dart_tool',
  '.git',
  'build',
  'coverage',
  'data',
};

/// Este mismo fichero habla de ignores en sus comentarios y ejemplos.
const String ficheroExcluido = 'check_ignores.dart';

final RegExp _directiva = RegExp(r'//\s*ignore(_for_file)?\s*:');
final RegExp _comentario = RegExp(r'^\s*//');

/// Una directiva de ignore sin justificacion, con su ubicacion.
class Hallazgo {
  const Hallazgo(this.fichero, this.linea, this.texto);

  final String fichero;
  final int linea;
  final String texto;
}

/// Recorre el arbol y devuelve los ficheros Dart analizables.
List<File> _ficherosDart(Directory raiz) {
  final ficheros = <File>[];
  for (final entidad in raiz.listSync(recursive: true, followLinks: false)) {
    if (entidad is! File || !entidad.path.endsWith('.dart')) {
      continue;
    }
    final ruta = entidad.path.replaceAll(r'\', '/');
    if (ruta.endsWith(ficheroExcluido)) {
      continue;
    }
    final excluido = carpetasExcluidas.any(
      (String c) => ruta.contains('/$c/') || ruta.startsWith('$c/'),
    );
    if (!excluido) {
      ficheros.add(entidad);
    }
  }
  return ficheros;
}

/// Devuelve las directivas de ignore sin comentario de justificacion encima.
List<Hallazgo> _revisar(File fichero) {
  final hallazgos = <Hallazgo>[];
  final lineas = fichero.readAsLinesSync();
  for (var i = 0; i < lineas.length; i++) {
    if (!_directiva.hasMatch(lineas[i])) {
      continue;
    }
    // Se busca hacia atras la primera linea con contenido.
    var j = i - 1;
    while (j >= 0 && lineas[j].trim().isEmpty) {
      j--;
    }
    final justificada =
        j >= 0 &&
        _comentario.hasMatch(lineas[j]) &&
        !_directiva.hasMatch(lineas[j]) &&
        lineas[j].replaceFirst(RegExp(r'^\s*//\s*'), '').trim().isNotEmpty;
    if (!justificada) {
      hallazgos.add(
        Hallazgo(fichero.path.replaceAll(r'\', '/'), i + 1, lineas[i].trim()),
      );
    }
  }
  return hallazgos;
}

void main(List<String> args) {
  final hallazgos = <Hallazgo>[];
  for (final fichero in _ficherosDart(Directory.current)) {
    hallazgos.addAll(_revisar(fichero));
  }

  if (hallazgos.isEmpty) {
    stdout.writeln('Sin `// ignore:` injustificados.');
    return;
  }

  stderr.writeln('');
  stderr.writeln('`// ignore:` sin justificar (CLAUDE.md §7):');
  for (final h in hallazgos) {
    stderr.writeln('  ${h.fichero}:${h.linea}  ${h.texto}');
  }
  stderr.writeln('');
  stderr.writeln(
    'Escribe encima un comentario que explique por que se silencia la regla.',
  );
  exit(1);
}
