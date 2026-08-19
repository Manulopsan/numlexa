# data/dist/ — artefactos generados, versionados por Git LFS

Todo lo que producen los generadores offline de `tools/`. Son binarios, se
regeneran desde cero y **no se editan a mano jamás**.

| Artefacto | Qué es | Lo genera |
|---|---|---|
| `numbers-bitmap.bin` | Bitmap de alcanzabilidad: 899 bits por multiconjunto de fichas | `tools/gen_numbers` (F1.08) |
| `numbers-pool.bin` | Pool curado de puzles con su `PuzzleMeta`, <2 MB | `tools/gen_numbers_pool` (F1.11) |
| `*.dawg` | DAWG por idioma para validar palabras | `tools/build_dawg` (F2.06) |
| `lfs-canary.bin` | 4 KB de ruido. **No lo usa nadie.** Ver abajo | creado a mano en F0.11 |

## Por qué LFS

Son binarios grandes que cambian enteros en cada regeneración. Sin LFS, cada
versión se guarda completa en el historial y el clon crece sin parar.

La regla de `.gitattributes` es **`data/dist/**`, deliberadamente amplia**: así
un formato nuevo entra por LFS sin que nadie tenga que acordarse de añadir su
extensión. Un binario colado como fichero normal no produce ningún error, y ese
es justo el fallo silencioso que se quiere evitar.

## `lfs-canary.bin`

Cuatro kilobytes de ruido cuyo único cometido es **demostrar que LFS funciona**.
Si en el repositorio ocupa ~130 bytes, es un puntero y todo está bien; si ocupa
4096, LFS ha dejado de aplicarse y el próximo binario de verdad entraría entero
en el historial sin que nadie viera un error.

Es el mismo criterio que el canario de `conformance/`: una salvaguarda que nunca
se ha visto funcionar no es una salvaguarda. **No se borra.**

## Aviso sobre el entorno

`git-lfs` está instalado **solo en el git de Windows**, no en el de WSL. Ver
`D-18`. Cualquier `git add` de un fichero de esta carpeta tiene que hacerse con
el git de Windows.
