# supabase/

Backend de NUMLEXA: Postgres mas Edge Functions en Deno/TypeScript. Buena parte
se trasplanta de Letrixa en F4 (ver `D-07`).

| Carpeta       | Contenido                          | Fase                       |
| ------------- | ---------------------------------- | -------------------------- |
| `migrations/` | Migraciones de Postgres            | F4.01 en adelante          |
| `functions/`  | Edge Functions en Deno/TypeScript  | F1.14, F4.02, F4.05, F7.03 |
| `tests/`      | Tests con Node y Postgres embebido | F4.01 en adelante          |

Dos cosas que condicionan todo lo que entre aqui:

- **Tier Free permanente** (`D-12`): ninguna tarea programada de produccion
  puede depender de `pg_cron`. El cron vive en GitHub Actions, con reintento,
  alerta visible al fallar e idempotencia obligatoria.
- **Las reglas del juego viven dos veces**, en Dart y en TypeScript. Todo lo que
  se implemente aqui y tenga equivalente en `packages/` pasa por los vectores de
  conformidad de `conformance/` (`D-08`, F0.10).
