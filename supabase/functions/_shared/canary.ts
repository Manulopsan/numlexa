// Implementacion TypeScript del canario. Ver `conformance/README.md`.
//
// No es una regla del juego. Su unico cometido es demostrar que el circuito de
// conformidad funciona: mismo JSON, dos lenguajes, y una divergencia rompe el
// build. Su gemela en Dart esta en
// `packages/numlexa_core/test/conformance/canary.dart` y las dos DEBEN cambiar
// a la vez.
//
// Vive en `_shared/` y no en un directorio propio porque los directorios que
// empiezan por `_` no son Edge Functions: `deploy.yml` los excluye a proposito.

/** Devuelve `a * 10 + b`, o `null` si alguno de los dos es negativo. */
export function canary(a: number, b: number): number | null {
  if (a < 0 || b < 0) {
    return null;
  }
  return a * 10 + b;
}
