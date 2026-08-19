# data/raw/ — fuentes de terceros, NO versionadas

Diccionarios y listas de frecuencia tal y como llegan del origen. **El contenido
de esta carpeta está ignorado por git a propósito**, por tres razones:

1. Pesa. El diccionario español en crudo son ~1,8 MB y son siete idiomas.
2. **La licencia está sin resolver** (`F2.03`). En Letrixa no consta atribución
   ni licencia de ninguno de los doce diccionarios. Hasta que eso se aclare, no
   se redistribuyen desde este repositorio.
3. Es material reproducible: lo que importa es el *procedimiento* de ingesta
   (`F2.04`, `F2.05`), no la copia concreta.

Lo que sí se versiona aquí es **este README y el inventario de procedencia**:
qué fichero, de dónde sale, con qué licencia y con qué fecha de descarga. Sin
eso, `F2.03` es imposible de cerrar.

## Estado

| Idioma | Fichero | Origen | Licencia | Fase |
|---|---|---|---|---|
| es | *(pendiente de mover desde la raíz)* | aportado por el usuario | **sin determinar** | F2.01 / F2.03 |

`spanish_words.json` está hoy en la raíz del repositorio, versionado desde el
commit `91f02ab`. `F2.01` debe moverlo aquí y **dejar de versionar la copia de
la raíz**.
