import { canary } from "../../functions/_shared/canary.ts";
import { intInput, loadVectors } from "./vectors.ts";

/** Comparacion estricta sin dependencias externas. `null` es un valor valido. */
function igual(obtenido: unknown, esperado: unknown, caso: string): void {
  if (obtenido !== esperado) {
    throw new Error(
      `caso dorado "${caso}": se esperaba ${
        JSON.stringify(esperado)
      } y se obtuvo ${JSON.stringify(obtenido)}`,
    );
  }
}

const vectores = loadVectors("canary");

for (const caso of vectores.cases) {
  Deno.test(`conformidad: ${vectores.name} v${vectores.version} ${caso.id}`, () => {
    igual(
      canary(intInput(caso, "a"), intInput(caso, "b")),
      caso.expected,
      caso.id,
    );
  });
}

Deno.test("el cargador rechaza un fichero inexistente", () => {
  let lanzo = false;
  try {
    loadVectors("no-existe");
  } catch {
    lanzo = true;
  }
  if (!lanzo) {
    throw new Error(
      "loadVectors deberia haber lanzado con un fichero inexistente",
    );
  }
});
