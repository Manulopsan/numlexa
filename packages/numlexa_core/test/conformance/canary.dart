// Implementacion Dart del canario. Ver `conformance/README.md`.
//
// No es una regla del juego. Su unico cometido es demostrar que el circuito de
// conformidad funciona: mismo JSON, dos lenguajes, y una divergencia rompe el
// build. Su gemela en TypeScript esta en `supabase/functions/_shared/canary.ts`
// y las dos DEBEN cambiar a la vez.

/// Devuelve `a * 10 + b`, o `null` si alguno de los dos es negativo.
int? canary(int a, int b) {
  if (a < 0 || b < 0) {
    return null;
  }
  return a * 10 + b;
}
