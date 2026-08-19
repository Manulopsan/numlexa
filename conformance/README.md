# conformance/ — vectores dorados Dart ↔ TypeScript

El cliente es Dart y el servidor es TypeScript, así que **las reglas del juego
existen dos veces**. Eso es tolerable, pero solo con una red de seguridad
automática. Esta carpeta es esa red. Ver `D-08` en `DESARROLLO.md`.

En Letrixa este problema ya existe: `word_points` vive en Dart y en SQL,
sincronizados por un comentario que dice «si cambia aquí, cambia allá». Eso
aguanta hasta que alguien cambia solo un lado, y entonces no falla un test:
falla una partida, meses después, y de forma injusta para alguien.

## La regla que hace que esto sirva para algo

**Cualquier cambio en las reglas empieza por regenerar los vectores, nunca por
tocar una de las dos implementaciones.** Si editas la fórmula en Dart y no en
TypeScript, el build se cae. Esa es toda la idea.

## Formato de un fichero de vectores

```json
{
  "name": "<identificador>",
  "version": 1,
  "description": "<para qué sirve>",
  "function": "<firma de la función que se prueba>",
  "contract": "<qué garantiza, incluidos los casos límite>",
  "cases": [
    { "id": "<identificador legible>", "input": { ... }, "expected": <valor|null> }
  ]
}
```

- `id` es obligatorio y **único** dentro del fichero: es lo que aparece en el
  informe cuando un caso falla, así que tiene que decir algo.
- `expected` admite `null` a propósito. `evaluate()` de `F1.02` devuelve `null`
  ante una expresión inválida, y el formato tiene que soportarlo desde el día
  uno, no cuando haga falta.
- Los ficheros son **datos**, no código: los generan los `tools/` y se leen
  igual desde los dos lados. Nadie los edita a mano para «arreglar» un test.

## Quién los ejecuta

| Lado       | Ubicación                                 | Comando                                    |
| ---------- | ----------------------------------------- | ------------------------------------------ |
| Dart       | `packages/numlexa_core/test/conformance/` | `dart test` (dentro de `melos run verify`) |
| TypeScript | `supabase/tests/conformance/`             | `deno test --allow-read`                   |

Ambos corren en el mismo job `verify` del CI, que es el check requerido para
fusionar. Una divergencia entre lados no da un aviso: rompe el build.

## `canary.json`

No son reglas del juego. Es el test de regresión **del propio mecanismo**: una
función trivial implementada en los dos lenguajes cuyo único cometido es
demostrar que el circuito completo funciona. **No se borra.** Si alguna vez el
canario deja de fallar al desincronizar los lados, es que la red de seguridad
está rota y no nos hemos enterado.

## Ficheros previstos

| Fichero         | Contenido                                          | Fase          |
| --------------- | -------------------------------------------------- | ------------- |
| `canary.json`   | Autocomprobación del mecanismo                     | F0.10         |
| `evaluate.json` | Expresiones de cifras válidas e inválidas          | F1.02 / F1.14 |
| `scoring.json`  | Puntuación de cifras y de letras, todos los tramos | F3.02         |
| `daily.json`    | Semillas del reto diario y su puzle exacto         | F7.02         |
| `elo.json`      | Fórmula de ELO                                     | F4.01         |
