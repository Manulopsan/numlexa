// Cargador de los vectores dorados de `conformance/`, lado TypeScript.
//
// Espejo deliberado de `packages/numlexa_core/test/conformance/vectors.dart`:
// mismas comprobaciones y mismos mensajes, para que un fichero mal formado
// falle igual en los dos lados y no solo en uno.
//
// Sin dependencias externas a proposito: el CI no deberia caerse porque un
// registro de paquetes este lento.

export interface VectorCase {
  id: string;
  input: Record<string, unknown>;
  expected: unknown;
}

export interface VectorFile {
  name: string;
  version: number;
  cases: VectorCase[];
}

/** Sube por el arbol de directorios hasta encontrar `conformance/`. */
export function conformanceDir(): string {
  let dir = Deno.cwd();
  for (;;) {
    try {
      const info = Deno.statSync(`${dir}/conformance`);
      if (info.isDirectory) {
        return `${dir}/conformance`;
      }
    } catch {
      // No existe aqui; se sigue subiendo. La ausencia se reporta al llegar
      // a la raiz, no en cada nivel.
    }
    const padre = dir.replace(/[/\\][^/\\]+$/, "");
    if (padre === dir || padre === "") {
      throw new Error(
        `No se encontro el directorio \`conformance/\` subiendo desde ${Deno.cwd()}`,
      );
    }
    dir = padre;
  }
}

/** Lee un entero de la entrada de un caso, fallando claro si no lo es. */
export function intInput(caso: VectorCase, clave: string): number {
  const valor = caso.input[clave];
  if (typeof valor !== "number" || !Number.isInteger(valor)) {
    throw new Error(
      `El caso "${caso.id}" esperaba un entero en "${clave}" y trae: ${valor}`,
    );
  }
  return valor;
}

/** Carga un fichero de vectores por nombre, sin extension. */
export function loadVectors(nombre: string): VectorFile {
  const ruta = `${conformanceDir()}/${nombre}.json`;
  let crudo: string;
  try {
    crudo = Deno.readTextFileSync(ruta);
  } catch {
    throw new Error(`No existe el fichero de vectores ${ruta}`);
  }
  const raiz = JSON.parse(crudo) as VectorFile;

  // Un fichero sin casos pasaria en verde sin comprobar nada. Eso es el dolor
  // #2 disfrazado de test que aprueba, asi que se rechaza.
  if (!raiz.cases || raiz.cases.length === 0) {
    throw new Error(`El fichero de vectores "${nombre}" no contiene casos.`);
  }
  const ids = new Set(raiz.cases.map((c) => c.id));
  if (ids.size !== raiz.cases.length) {
    throw new Error(`El fichero de vectores "${nombre}" tiene ids repetidos.`);
  }
  return raiz;
}
