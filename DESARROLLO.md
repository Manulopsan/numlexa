# DESARROLLO.md — NUMLEXA

> **Fuente única de verdad del avance.** Si no está aquí, no ha pasado.
> Lee `CLAUDE.md` antes de tocar este archivo.

---

## TAREA ACTUAL

```
F0.11
```

**Leyenda:** `[ ]` pendiente · `[~]` en curso · `[x]` hecha · `[!]` bloqueada · `[-]` descartada

---

## F0 — Fundaciones

- [x] **F0.01** — Auditar Letrixa. → *Hecha. Resultados en `INVENTARIO LETRIXA` y en `D-07`…`D-11`.*
- [x] **F0.02** — **Decidir el tier de Supabase con `pg_cron` disponible** antes de escribir una sola tarea programada. → *Decisión registrada con el coste mensual. Si no hay pg_cron, se asume conscientemente el patrón de GitHub Actions cron y se documenta por qué.* `DESARROLLO.md`
- [x] **F0.03** — **Decidir el alcance de iOS.** Letrixa es solo Android y no tiene carpeta `ios/`. Si iOS entra, entra desde F5, no al final. → *Decisión registrada; `F11.05` ajustada en consecuencia.* `DESARROLLO.md`
- [x] **F0.04** — Inicializar monorepo con Melos: `packages/` Dart puros + `apps/mobile` + `supabase/`. → *`melos bootstrap` resuelve sin error.* `pubspec.yaml` *(no `melos.yaml`: ver `D-16`)*
- [x] **F0.05** — `analysis_options.yaml` estricto: `strict-casts`, `strict-inference`, sin `print()`, warnings **bloqueantes**. Letrixa usa `flutter_lints` por defecto con warnings no bloqueantes; aquí no. → *Falla ante una violación de prueba.* `analysis_options.yaml`
- [x] **F0.06** — Tests y cobertura con umbral 90% en `packages/`. → *`melos run test` reporta cobertura por paquete.* `pubspec.yaml` *(clave `melos:`, ver `D-16`)*
- [x] **F0.07** — Script `melos run verify` = analyze + format + test **+ ignores**. → *Un solo comando devuelve 0 con el repo limpio.* `pubspec.yaml` *(clave `melos:`, ver `D-16`)*
- [x] **F0.08** — **CI que ejecuta `verify` en cada push.** No existe en Letrixa: los 5 workflows actuales son solo cron. → *Workflow verde en el primer push, bloqueante en PR.* `.github/workflows/ci.yml`
- [x] **F0.09** — **CI de despliegue**: `supabase db push` y `functions deploy` automatizados. En Letrixa es manual y ya provocó divergencia entre repo y producción (dolor #5). → *Un merge a `main` despliega migraciones y funciones.* `.github/workflows/deploy.yml`
- [x] **F0.10** — **Infraestructura de vectores de conformidad**: `conformance/*.json` con casos dorados, consumidos por los tests de Dart y por los de Deno. → *Un cambio de fórmula en un solo lado rompe el build. Ver `D-08`.* `conformance/`
- [ ] **F0.11** — Git LFS para `data/dist/`, `.gitignore` para `data/raw/`. → *Un binario de prueba se versiona por LFS.* `.gitattributes`
- [ ] **F0.12** — **Script `run.ps1`** que cargue las credenciales (URL y `anon` de Supabase vía `--dart-define`) y lance la app en el móvil, en lugar de invocar `flutter run` a pelo. Depende de `F5.01`: no hay app que lanzar antes. → *`./run.ps1` arranca en dispositivo Android con las credenciales inyectadas; el repo no contiene ninguna clave `service_role`.* `run.ps1`

---

## F1 — Motor de cifras

> Net-new. Letrixa no tiene nada numérico. Bloquea niveles, bot y reto diario.

- [ ] **F1.01** — Tipos en `numlexa_numbers`: `Tile`, `TileSet`, `Target`, `Expression`, `Solution`, `PuzzleMeta`. → *Sin estados imposibles representables.* `packages/numlexa_numbers/lib/src/types.dart`
- [ ] **F1.02** — `evaluate(expr)`, que devuelve `null` si algún paso intermedio no es entero positivo o si hay división inexacta. → *`100/3` → null · `3-5` → null · `(75+25)*7` → 700.* `packages/numlexa_numbers/lib/src/evaluate.dart`
- [ ] **F1.03** — Enumerar los multiconjuntos válidos de 6 fichas (0–4 grandes). → *La cuenta coincide con el cálculo combinatorio hecho a mano y documentado en la bitácora.* `packages/numlexa_numbers/lib/src/enumerate.dart`
- [ ] **F1.04** — DP sobre subconjuntos: `reachable(tiles)` recorriendo particiones `S = A ⊎ B`. → *Para `[25,50,75,100,3,6]` contiene 952 y no contiene 1000000.* `packages/numlexa_numbers/lib/src/dp.dart`
- [ ] **F1.05** — Bitmap de alcanzabilidad: 899 bits por multiconjunto. → *Popcount plausible y estable entre ejecuciones.* `packages/numlexa_numbers/lib/src/bitmap.dart`
- [ ] **F1.06** — Solver `solve(tiles, target)`: exacta con mínimo de operaciones, o mejor aproximación. → *20 casos conocidos en <200 ms cada uno.* `packages/numlexa_numbers/lib/src/solve.dart`
- [ ] **F1.07** — Métricas de dificultad: nº de soluciones, ops mínimas, si exige división intermedia, si exige las 6 fichas. → *`PuzzleMeta` completo para cualquier par alcanzable.* `packages/numlexa_numbers/lib/src/difficulty.dart`
- [ ] **F1.08** — Generador offline paralelizado que vuelca bitmaps y estadísticas por mezcla. → *Termina en <60 min y produce `data/dist/numbers-bitmap.bin`.* `tools/gen_numbers`
- [ ] **F1.09** — **Analizar estadísticas por nº de fichas grandes (0–4)** y escribir la tabla real en `REGISTRO DE DECISIONES`. → *Datos medidos, no estimados. Punto de parada obligatorio.* `DESARROLLO.md`
- [ ] **F1.10** — Definir las 4 bandas de dificultad con umbrales derivados de F1.09. → *Cada banda con volumen suficiente, documentado.* `packages/numlexa_numbers/lib/src/bands.dart`
- [ ] **F1.11** — Pool curado: ~50.000 puzles muestreados por banda, en binario con su `PuzzleMeta`. → *`data/dist/numbers-pool.bin` <2 MB.* `tools/gen_numbers_pool`
- [ ] **F1.12** — Lector del pool con acceso por banda e índice. → *Ida y vuelta: 1000 puzles leídos coinciden con los generados.* `packages/numlexa_numbers/lib/src/pool.dart`
- [ ] **F1.13** — **Invariante global: todo puzle del pool tiene solución exacta verificable.** → *5000 puzles al azar verificados con el solver, 0 fallos.* `packages/numlexa_numbers/test/invariant_test.dart`
- [ ] **F1.14** — **Port del evaluador a TypeScript** para la Edge Function de validación, verificado contra los vectores de conformidad de F0.10. → *Dart y TS coinciden en los 500 casos dorados. Ver `D-08`.* `supabase/functions/_shared/evaluate.ts`

---

## F2 — Motor de letras

> Letrixa es tipo Boggle (rejilla + DFS con poda). NUMLEXA es atril de 9 letras.
> **Los diccionarios se heredan; la estructura de búsqueda no.** Ver `D-09`.

- [ ] **F2.01** — **Importar los 12 diccionarios ya limpios de Letrixa** (`assets/dictionary/*_words.json`) a `data/raw/`, con su historial de limpieza. → *Los 7 idiomas objetivo cubiertos sin reconstruir nada desde cero.* `data/raw/`
- [ ] **F2.02** — **Portar la tabla de normalización desde `INTEGRACION_NUEVOS_IDIOMAS.md` de Letrixa** a una capa genérica: turco `İ/I` distintas y prohibición de `toLowerCase()`/`toUpperCase()` en todo el pipeline; alemán `ß`; ñ como ficha propia; tildes plegadas; `ll`/`ch` no son fichas. → *Tests por idioma con los casos que ya mordieron en Letrixa.* `packages/numlexa_letters/lib/src/normalize.dart`
- [ ] **F2.03** — **Resolver la licencia de los diccionarios.** En Letrixa no consta atribución ni licencia. → *Origen y licencia documentados por idioma, o sustituidos por fuentes de licencia conocida.* `data/raw/LICENSES.md`
- [ ] **F2.04** — Ingestor: normaliza, filtra (sin nombres propios ni abreviaturas, longitud 2–9) y emite lista limpia. → *Procesa los 7 idiomas y reporta qué entra y por qué se descarta lo demás.* `tools/ingest_dict`
- [ ] **F2.05** — Integrar listas de frecuencia y producir el **diccionario de referencia** con rango por palabra. → *Cada palabra tiene rango o marca de "sin datos".* `tools/ingest_freq`
- [ ] **F2.06** — **Construir DAWG y serializarlo.** Letrixa carga un `Set<String>` plano en memoria (7,4 MB en portugués) y además lo duplica en `SharedPreferences`. Aquí no. → *DAWG de español <1,5 MB, `contains()` correcto en 10.000 casos.* `tools/build_dawg`, `packages/numlexa_letters/lib/src/dawg.dart`
- [ ] **F2.07** — Índice anagramático: firma ordenada → palabras. → *`lookup("aeimnrs")` devuelve el conjunto esperado.* `packages/numlexa_letters/lib/src/anagram.dart`
- [ ] **F2.08** — `solveBoard(letters)`: 512 subconjuntos, todas las palabras posibles por longitud. → *Tablero de test resuelto en <50 ms.* `packages/numlexa_letters/lib/src/solve_board.dart`
- [ ] **F2.09** — Bolsa de letras por idioma derivada del diccionario de referencia ponderado por frecuencia. Letrixa usa 12 tablas manuales; aquí se derivan de los datos. → *Distribuciones plausibles, suman 1, documentadas.* `tools/gen_bags`
- [ ] **F2.10** — Generador de tableros con ≥3 vocales y ≥4 consonantes. → *10.000 tableros cumplen al 100%.* `packages/numlexa_letters/lib/src/generate_board.dart`
- [ ] **F2.11** — Filtro de nivel por banda de frecuencia. → *Ningún tablero Fácil exige una palabra fuera del top 5.000.* `packages/numlexa_letters/lib/src/bands.dart`
- [ ] **F2.12** — Pool de tableros por idioma y banda. → *7 idiomas × 4 bandas, mínimo 5.000 cada uno.* `tools/gen_letters_pool`
- [ ] **F2.13** — **Invariante: todo tablero del pool tiene palabra válida de su longitud objetivo dentro de su banda.** En Letrixa el tablero multijugador es relleno aleatorio sin ninguna garantía. → *5.000 tableros por idioma, 0 fallos.* `packages/numlexa_letters/test/invariant_test.dart`

---

## F3 — Núcleo compartido

- [ ] **F3.01** — Tipos de partida en `numlexa_core`: `Round`, `RoundKind`, `Move`, `Declaration`, `Score`, `MatchState`. → *`RoundKind` genérico desde el día uno: cifras y letras son iguales ante el modelo. Letrixa tipó el tablero como `List<List<String>>` en decenas de sitios y eso es exactamente lo que no se repite.* `packages/numlexa_core/lib/src/types.dart`
- [ ] **F3.02** — Marcador: cifras (10/7/5/0 por distancia) y letras (longitud + bonus de 9). → *Tests de todos los tramos, alimentados por los vectores de conformidad.* `packages/numlexa_core/lib/src/scoring.dart`
- [ ] **F3.03** — Máquina de estados de ronda con transiciones exhaustivas, incluida la declaración previa. → *Toda transición inválida falla en compilación o lanza.* `packages/numlexa_core/lib/src/round_machine.dart`
- [ ] **F3.04** — RNG determinista sembrado. → *Misma semilla, mismo puzle, en 1.000 iteraciones y entre procesos.* `packages/numlexa_core/lib/src/rng.dart`
- [ ] **F3.05** — **Utilidad de día de calendario en UTC** (`challengeNumberFor(date)`), nunca diferencias de `Duration`. → *Test explícito del cambio de hora de marzo. Ver dolor #1.* `packages/numlexa_core/lib/src/calendar.dart`
- [ ] **F3.06** — Protocolo cliente↔servidor con validación por esquema en el borde. → *Un mensaje malformado se rechaza antes de entrar en la lógica.* `packages/numlexa_core/lib/src/protocol.dart`

---

## F4 — Capa competitiva (adaptar, no construir)

> `record_match(p_score_a INT, p_score_b INT, …)` no sabe nada de palabras: compara dos
> números. ELO, emparejamiento, ligas, amigos y anti-farmeo son reutilizables casi tal cual.
> Esta fase es sobre todo trasplante. Ver `D-07`.

- [ ] **F4.01** — Trasplantar el esquema de ELO y `matches` de Letrixa (migración 032) y sus tests de Postgres. → *Los ~39 asertos pasan en el proyecto nuevo.* `supabase/migrations/`
- [ ] **F4.02** — Trasplantar emparejamiento: `find-match`, `matchmaking_queue`, `FOR UPDATE/SKIP LOCKED`, ventana de ELO progresiva, roster de bots. → *El test de concurrencia pasa.* `supabase/functions/find-match/`
- [ ] **F4.03** — Trasplantar identidad por `device_id` y la comprobación de posesión en cada envío de puntuación. → *Toda RPC de puntuación tiene `EXECUTE` revocado a `anon`.* `supabase/migrations/`
- [ ] **F4.04** — Generalizar `player_words` a **`player_moves`**, con `payload JSONB` en vez de `word TEXT`, para que sirva a cifras y letras. → *Una jugada de cifras y una de letras conviven en la misma tabla.* `supabase/migrations/`
- [ ] **F4.05** — **Validación de jugada en servidor al cerrar la partida**, incluida la re-evaluación de la expresión de cifras. Letrixa recalcula el marcador pero no comprueba que la palabra exista: aquí sí. → *Una expresión falsificada se rechaza y no puntúa.* `supabase/functions/close-match/`
- [ ] **F4.06** — Adoptar el modelo de reloj **ancla + reconstrucción**: `started_at` como única verdad, cliente calcula el restante, resync tras desbloqueo de pantalla. → *Dos clientes con relojes desfasados 3 s ven la misma cuenta atrás ±100 ms.* `apps/mobile/lib/game/clock.dart`
- [ ] **F4.07** — Rate limiting y topes anti-farmeo, heredados de Letrixa. → *Los límites diarios se aplican.* `supabase/migrations/`

---

## F5 — Cliente base e identidad

- [ ] **F5.01** — Inicializar Flutter con `com.numlexa.app`, **solo Android** (`flutter create --platforms=android`, sin carpeta `ios/`). Ver `D-15`. → *Compila y arranca en un dispositivo Android; el repo no contiene `apps/mobile/ios/`.* `apps/mobile/`
- [ ] **F5.02** — Design system NUMLEXA partiendo de `AppColors` de Letrixa: dualidad NUM/LEX, tema oscuro por defecto, tokens centralizados. → *Ningún color suelto en widgets.* `apps/mobile/lib/theme/`
- [ ] **F5.03** — Componente `Tile` con variantes de número y de letra: misma silueta, color distinto. → *Ambas variantes renderizan; test de golden.* `apps/mobile/lib/widgets/tile.dart`
- [ ] **F5.04** — Componente `Clock` con aceleración visual y sonora en los últimos 10 s. → *Sincronizado con el ancla de servidor.* `apps/mobile/lib/widgets/clock.dart`
- [ ] **F5.05** — Extraer de Letrixa los widgets genéricos aprovechables: barra inferior, avatar, tarjeta de jugador, marcador, gráficos, selector de idioma, diálogo de consentimiento. → *Compilan en NUMLEXA sin arrastrar dependencias de Letrixa.* `apps/mobile/lib/widgets/`
- [ ] **F5.06** — Pantalla de ronda de letras: pedir vocal/consonante, componer, declarar longitud, revelar. → *Flujo completo jugable.* `apps/mobile/lib/screens/letters_round.dart`
- [ ] **F5.07** — Pantalla de ronda de cifras: fichas servidas, construir expresión, declarar, revelar. → *Flujo completo jugable.* `apps/mobile/lib/screens/numbers_round.dart`
- [ ] **F5.08** — Pantalla de resultado con la solución óptima. → *Muestra la mejor palabra y la solución de cifras del solver.* `apps/mobile/lib/screens/round_result.dart`
- [ ] **F5.09** — **Descarga de paquetes de idioma bajo demanda.** Letrixa empaqueta 12 diccionarios JSON en el APK. Aquí no se embarca más que el idioma inicial. → *El bundle base no contiene los 7 idiomas.* `apps/mobile/lib/data/language_packs.dart`

---

## F6 — Un jugador y modo sin conexión

- [ ] **F6.01** — Progresión de niveles y mezcla de rondas. Net-new: `GameDifficulty` de Letrixa es código muerto. → *Cada nivel referencia bandas concretas de F1.10 y F2.11.* `packages/numlexa_core/lib/src/levels.dart`
- [ ] **F6.02** — Motor local embarcado: pool de cifras, DAWG, bolsas y solver en dispositivo. → *Ronda de cifras y de letras jugadas y puntuadas sin red.* `apps/mobile/lib/engine/`
- [ ] **F6.03** — Arranque en frío medido y optimizado. → *Cargar un idioma y servir la primera ronda en <1,5 s en gama media.* `apps/mobile/lib/engine/`
- [ ] **F6.04** — **Persistencia local con Drift (SQLite).** Letrixa usa solo `SharedPreferences` con JSON serializado a mano; no aguanta pools ni historial. → *Migraciones versionadas y test de ida y vuelta.* `apps/mobile/lib/db/`
- [ ] **F6.05** — **Cola de sincronización única y persistida.** Letrixa tiene tres mecanismos distintos sin unificar, y uno de ellos vive solo en memoria y se pierde al cerrar la app. → *Jugar 5 rondas en avión y reconectar sincroniza las 5 exactamente una vez.* `apps/mobile/lib/sync/`
- [ ] **F6.06** — Todo resultado local marcado como **no clasificatorio** de extremo a extremo. → *El servidor rechaza que un resultado local toque el ELO.* `packages/numlexa_core/`, `supabase/`
- [ ] **F6.07** — Mapa de niveles. → *Refleja el progreso real, funciona sin red.* `apps/mobile/lib/screens/levels.dart`
- [ ] **F6.08** — **Ningún `catch` silencioso alrededor de operaciones que dependan de permisos o de red.** Todo fallo se registra y se hace visible. → *Regla verificada por lint o por revisión. Ver dolor #2.* `apps/mobile/`
- [ ] **F6.09** — Test E2E en modo avión: descargar un idioma, cortar la red, jugar un nivel entero. → *Sin errores ni cargas colgadas.* `apps/mobile/integration_test/offline_test.dart`

---

## F7 — Reto diario

> Se adopta el patrón de Letrixa: **generación determinista en cliente**, 100% offline,
> con el servidor limitando y verificando solo el envío al ranking. Ver `D-10`.

- [ ] **F7.01** — Generación determinista local: semilla fija + `challengeNumberFor(fecha UTC)` de F3.05, sobre los pools de cifras y letras. → *Todos los dispositivos obtienen el mismo puzle el mismo día, sin red.* `apps/mobile/lib/daily/`
- [ ] **F7.02** — **Epoch y numeración fijados de una vez y documentados.** Renumerar después obliga a romper las rachas de todos, como pasó en Letrixa. → *Epoch escrito en el registro de decisiones antes del primer build público.* `DESARROLLO.md`
- [ ] **F7.03** — Verificación del envío al ranking en servidor: recomputa el puzle del día, valida la jugada, aplica 1 intento por día e idioma. → *Un resultado inventado se rechaza.* `supabase/functions/submit-daily/`
- [ ] **F7.04** — Rachas **con una recuperación al mes**. Letrixa no tiene ninguna gracia. → *Fallar rompe la racha; la clemencia la conserva y se agota.* `apps/mobile/lib/daily/streak.dart`
- [ ] **F7.05** — Rachas respaldadas en servidor, no solo en el dispositivo. → *Reinstalar conserva la racha.* `supabase/`
- [ ] **F7.06** — Tarjeta compartible sin spoilers, adaptando la de Letrixa, con enlace a `letrixa.app/numlexa` (ver `D-13`). → *No permite deducir la solución.* `apps/mobile/lib/share/`
- [ ] **F7.07** — Publicación al día siguiente de la mejor palabra y la solución de cifras más corta, con nick. → *Aparece en el diario del día posterior.* `supabase/functions/daily-highlights/`

---

## F8 — Multijugador

- [ ] **F8.01** — Adaptar salas y `game_rounds` a `RoundKind` genérico. → *Una sala alterna rondas de cifras y de letras.* `supabase/migrations/`, `apps/mobile/lib/game/`
- [ ] **F8.02** — Salas privadas por código y QR, trasplantadas de Letrixa. → *Un código creado en un dispositivo abre en otro.* `apps/mobile/lib/game/`
- [ ] **F8.03** — Adaptar reconexión y "reenganche" (`rejoinable_room`). → *Cortar la red 5 s y volver conserva la ronda.* `apps/mobile/lib/services/reconnection.dart`
- [ ] **F8.04** — Fase de **declaración previa** antes de revelar. Net-new. → *No se puede revelar sin haber declarado.* `packages/numlexa_core/`, `apps/mobile/`
- [ ] **F8.05** — **Modo cifras interidioma**: 1 vs 1 solo de números entre jugadores de idiomas distintos. → *Un cliente en `tr` y otro en `pt` juegan la misma partida.* `supabase/functions/find-match/`
- [ ] **F8.06** — Ranking separado: casual (salas privadas) y competitivo (emparejamiento). Heredado. → *Las privadas no tocan el ELO.* `supabase/`
- [ ] **F8.07** — Detección de anomalías: óptimo instantáneo repetido, tiempos imposibles. → *Marca cuentas sospechosas sin banear.* `supabase/functions/`

---

## F9 — Bot rival

- [ ] **F9.01** — Bot de letras que juega la mejor palabra **de su banda de frecuencia**, con ruido. → *En Fácil no juega palabras fuera del top 50.000.* `packages/numlexa_core/lib/src/bot/letters.dart`
- [ ] **F9.02** — Bot de cifras calibrado por ops mínimas. → *En Fácil falla el exacto un % configurable.* `packages/numlexa_core/lib/src/bot/numbers.dart`
- [ ] **F9.03** — Curva de tiempo humana. → *Distribución de tiempos plausible.* `packages/numlexa_core/lib/src/bot/timing.dart`
- [ ] **F9.04** — Reutilizar el roster de 540 perfiles de bot de Letrixa, con K-factor mitad y techo de ELO. → *Los bots no inflan el ranking.* `supabase/migrations/`

---

## F10 — Sitio web informativo

> **En la web no se juega.** Letrixa ya tiene `boogle-web/` (Vite+React con App Links): patrón probado.

- [ ] **F10.01** — Inicializar `apps/web` siguiendo el patrón de `boogle-web`, con rutas por idioma. → *Sirve las 7 rutas.* `apps/web/`
- [ ] **F10.02** — Landing con propuesta de valor, capturas y enlaces a tienda. → *Lighthouse >90.* `apps/web/`
- [ ] **F10.03** — Aterrizaje de enlaces compartidos, sin spoilers. → *No revela nada del puzle.* `apps/web/`
- [ ] **F10.04** — Open Graph por idioma. → *Previsualización correcta en WhatsApp, X y Telegram.* `apps/web/`
- [ ] **F10.05** — Legales en los 7 idiomas. → *Cumplen requisitos de publicación.* `apps/web/`
- [ ] **F10.06** — **Android App Links** (`assetlinks.json`), trasplantados de Letrixa, bajo `letrixa.app` y sin pisar los de Letrixa. Sin Universal Links de Apple mientras rija `D-15`. → *Un enlace abre la app Android si está instalada.* `apps/web/public/.well-known/`
- [ ] **F10.07** — Desplegar en **`numlexa.vercel.app`** y publicar bajo **`letrixa.app/numlexa`**. Ver `D-13`. → *Producción accesible en ambas rutas y CI desplegando.* `apps/web/`

---

## F11 — Cierre y publicación

- [ ] **F11.01** — i18n con `gen-l10n`, mismo mecanismo que Letrixa, claves nuevas. → *Ninguna cadena hardcodeada.* `apps/mobile/lib/l10n/`
- [ ] **F11.02** — Analítica sin PII, con envío diferido sin red. → *Documentado qué se recoge y qué no.* `apps/mobile/`
- [ ] **F11.03** — Accesibilidad, incluido modo daltónico para la dualidad de color. → *Auditoría pasada.* `apps/mobile/`
- [ ] **F11.04** — Ficha de **Google Play** por idioma, sin marcas ajenas en el nombre. Sin App Store mientras rija `D-15`. → *Revisado contra `CLAUDE.md §8`.* `store/`
- [ ] **F11.05** — **Build Android firmado**: keystore de subida fuera del repo, `key.properties` ignorado, secreto en GitHub Actions, App Bundle (`.aab`) release. Sin iOS: ver `D-15`. → *El `.aab` firmado sube a la pista interna de Play sin rechazos.* `apps/mobile/`
- [ ] **F11.06** — **Verificar que producción y repositorio coinciden** antes de publicar. → *Migraciones y funciones desplegadas == las del repo. Ver dolor #5.* `supabase/`

---

## REGISTRO DE DECISIONES

### D-01 — Motores como paquetes Dart puros
Los motores corren dentro del cliente (modo sin conexión) y deben testearse sin levantar Flutter. `numlexa_core`, `numlexa_numbers` y `numlexa_letters` no dependen de Flutter.

### D-02 — Bitmap de alcanzabilidad + pool curado
El producto cartesiano multiconjuntos × objetivos son decenas de millones de filas: no es embarcable. Se envía bitmap compacto (garantiza existencia de solución) más pool curado con metadatos, y se resuelve en dispositivo solo para mostrar la solución.

### D-03 — El jugador no elige la mezcla de fichas
La fija el generador y pasa a ser la palanca principal de dificultad. Efectos secundarios: arranque instantáneo de ronda y solvencia garantizada por construcción.

### D-04 — Flutter y Dart · CERRADA
Existe Letrixa en Flutter con multijugador y reto diario en producción. El riesgo que se estimaba en abstracto ya está atravesado. No reabrir.

### D-05 — La web no es jugable
El juego vive solo en móvil. `apps/web` es informativa. Se asume perder el "juega sin instalar" del enlace compartido, mitigado con aterrizaje limpio y App Links.

### D-06 — Dos regímenes de autoridad
Régimen local (un jugador, niveles, diario) validado en cliente y **siempre no clasificatorio**. Régimen servidor (1 vs 1, competitivo) autoritativo, sin modo degradado. Regla de desempate: si el resultado puede afectar a otro jugador, lo valida el servidor.

### D-07 — Backend: Supabase, trasplantado de Letrixa
**Contexto:** la auditoría revela que la capa social y competitiva de Letrixa ya trata las partidas como dos números que se comparan. `record_match(p_score_a INT, p_score_b INT, …)` no sabe nada de palabras.
**Decisión:** Supabase (Postgres + Edge Functions en Deno/TS). Se trasplantan ELO, emparejamiento con `SKIP LOCKED`, roster de bots, amigos, ligas, temporadas, rate limiting e identidad por `device_id`, con sus tests de Postgres.
**Lo que sí hay que rehacer:** `player_words` → `player_moves` con `payload JSONB`, y validación real de la jugada al cerrar (Letrixa recalcula el marcador pero no comprueba que la palabra exista).

### D-08 — Vectores de conformidad, obligatorios
**Contexto:** el servidor es TypeScript y el cliente es Dart. Las reglas van a existir dos veces. Letrixa ya vive esto con `word_points` duplicado en Dart y SQL, sincronizado a mano mediante comentarios de "si cambia aquí, cambia allá" (dolor #4).
**Decisión:** `conformance/*.json` con casos dorados de puntuación y de evaluación de expresiones, ejecutados por los tests de ambos lados en CI. Una divergencia rompe el build en vez de aparecer como una partida injusta meses después.
**Alcance:** puntuación de cifras y letras, evaluación de expresiones, numeración del reto diario, fórmula de ELO.

### D-09 — Los diccionarios se heredan; la estructura de búsqueda no
**Contexto:** Letrixa es tipo Boggle —rejilla, DFS con poda por prefijo— y NUMLEXA es atril de 9 letras, que se resuelve con índice anagramático. Además Letrixa carga un `Set<String>` plano (7,4 MB en portugués) y lo duplica en `SharedPreferences`.
**Decisión:** se importan los 12 diccionarios ya limpios y, sobre todo, el conocimiento de normalización por idioma, que costó incidentes reales. Se descartan la estructura de búsqueda y las 12 tablas manuales de frecuencia de letras, sustituidas por DAWG e índice anagramático y por bolsas derivadas de los datos.
**Pendiente:** la licencia de los diccionarios no consta en Letrixa. Se resuelve en `F2.03`.

### D-10 — El reto diario se genera en cliente · REVISADA
**Decisión anterior:** descargar el puzle del servidor para impedir que adelantar la fecha del dispositivo dé acceso a los retos futuros.
**Por qué cambia:** eso rompe el requisito de jugar sin conexión, y Letrixa demuestra en producción que la generación determinista local funciona.
**Decisión:** generación local determinista, 100% offline. El servidor recomputa el puzle del día, valida la jugada y aplica un intento por día e idioma **solo en el envío al ranking**. Un tramposo puede adelantarse el reto en su móvil, pero no puede meter ese resultado en la clasificación.
**Condición innegociable:** la numeración del día se calcula siempre por **fecha de calendario en UTC**, nunca por diferencia de instantes. Ese bug ya costó una renumeración completa en Letrixa.

### D-11 — Higiene de proceso, elevada a requisito
**Contexto:** tres dolores de Letrixa son de proceso, no de código: despliegue manual con divergencia entre repo y producción, un `catch` silencioso que ocultó un fallo durante meses, y ~0% de cobertura en la app.
**Decisión:** CI bloqueante desde `F0.08`, despliegue automatizado desde `F0.09`, prohibición de `catch` silencioso en `F6.08`, cobertura 90% en `packages/`, y verificación repo-vs-producción antes de publicar en `F11.06`.

### D-12 — Tier de Supabase: Free permanente · cron en GitHub Actions
**Contexto:** `pg_cron` está disponible en **todos** los planes de Supabase, Free incluido. Lo que cambia entre planes no es la extensión, sino la fiabilidad: un proyecto Free se **pausa tras ~7 días sin actividad** y con él dejan de correr sus tareas programadas. Proyecto verificado vivo y despierto (`ggnnesmpuqgjkqarwphm`).
**Decisión:** se permanece en **Free, 0 $/mes, de forma indefinida**. Ninguna tarea programada de producción dependerá de `pg_cron`: se asume **conscientemente** el patrón de Letrixa —un workflow de GitHub Actions con `schedule:` que invoca una Edge Function—, que es exactamente el **dolor #3** de `CLAUDE.md §10`.
**Por qué se asume ese dolor a sabiendas:** el proyecto no genera ingresos y un coste fijo mensual no es asumible antes de tenerlos. La contrapartida técnica es real pero acotada: el patrón ya está probado en producción en Letrixa, y las tareas programadas de NUMLEXA son pocas y no críticas —`F7.07` (destacados del día siguiente), cierre de temporadas y ligas de `F4`, limpieza de rate limiting—. Bajo `D-10` el reto diario se genera en cliente, así que **ningún cron está en la ruta crítica del juego**: si un workflow falla, no hay partida rota, solo un dato tardío.
**Efecto lateral favorable:** el propio cron de GitHub Actions golpea el proyecto periódicamente, lo que lo mantiene despierto y neutraliza en la práctica la pausa por inactividad del plan Free.
**Coste mensual:** Supabase **0 $/mes**. Alternativa descartada: Pro **~25 $/mes por organización** (incluye ~10 $ de créditos de compute, sin pausas, backups diarios) — precios a reconfirmar en el panel antes de cualquier salto. GitHub Actions: gratis en repositorio público; en privado consume de los 2.000 min/mes del plan Free de GitHub, muy por encima de lo que estas tareas exigen.
**Reglas vinculantes que se derivan:**
1. Ningún workflow programado sin **reintento** y sin **alerta visible al fallar**. Un cron que muere en silencio es el dolor #2 con otra ropa.
2. Toda tarea programada debe ser **idempotente**: GitHub Actions no garantiza ejecución puntual ni exactamente una vez; puede retrasarse o repetir.
3. `pg_cron` puede usarse en local o para mantenimiento interno de la BD, pero **nada de producción puede depender de él** mientras esta decisión esté vigente.
**Condición de revisión:** se reabre en cuanto la app genere ingresos recurrentes que cubran el Pro, o antes si aparece una tarea programada que sí sea crítica para poder jugar.

### D-13 — La web es `numlexa.vercel.app` bajo `letrixa.app/numlexa`
**Decisión anterior:** `numlexa.com`.
**Por qué cambia:** no se compra dominio propio. La web se despliega en **Vercel** (`numlexa.vercel.app`) y se publica bajo el dominio ya existente **`letrixa.app/numlexa`**.
**Efectos:** corregidas `F10.07` y `F7.06`. `F10.06` (App Links) debe declarar el `assetlinks.json` bajo **`letrixa.app`**, no bajo un dominio nuevo, y convivir con el de Letrixa sin pisarlo. `D-05` (la web no es jugable) sigue intacta.

### D-14 — Español primero, el resto de idiomas después
**Decisión:** todo el desarrollo se hace **en español**. Los demás idiomas —inglés, francés, alemán, italiano, y turco por decidir— entran después, uno a uno, cuando el juego esté cerrado en español.
**Efectos sobre el plan:** los criterios de `F2.01`, `F2.04`, `F2.05`, `F2.12` y `F5.09` se leen como *"español completo primero; cada idioma adicional repite el mismo pipeline al incorporarse"*. **No se relaja `F2.02`:** la capa de normalización se construye genérica desde el día uno, porque la prohibición de `toLowerCase()`/`toUpperCase()` en el pipeline es una regla estructural, no un detalle de turco; retrofitearla después es justamente el incidente que ya pagó Letrixa. `F11.01` (i18n con `gen-l10n`) se monta desde el principio aunque solo haya un idioma cargado: no se hardcodean cadenas «porque de momento solo hay español».
**Nota de material:** el diccionario español ya está aportado en la raíz (`spanish_words.json`, 131.655 entradas). Ver `BACKLOG` para su estado real.

### D-15 — Solo Android · iOS aplazado y condicionado
**Contexto:** Letrixa es solo Android y no tiene carpeta `ios/`. Publicar en iOS exige cuenta de desarrollador de Apple (**99 $/año, recurrente**), que hoy no existe, más un Mac para compilar y firmar. Google Play es **25 $ pago único** y la cuenta ya existe por Letrixa (confirmar antes de `F11.05`).
**Decisión:** **NUMLEXA se construye solo para Android.** No se crea carpeta `ios/`: `F5.01` inicializa con `flutter create --platforms=android`. iOS se reabre **solo si la app despega en Play Store**, y entonces entra como **fase propia (`F12`), no colada al final de `F11`** — precisamente la trampa que `F0.03` advertía.
**Por qué se decide así y no «por si acaso»:** una carpeta `ios/` que nadie compila ni prueba no es una opción abierta, es deuda invisible que se pudre y da falsa sensación de portabilidad. Es preferible no tenerla y pagar el port entero el día que haya razón para pagarlo.
**Coste evitado:** 99 $/año de Apple más el tiempo de mantener una plataforma sin usuarios.
**Seguro barato que sí se paga desde hoy** — reglas vinculantes para que el port futuro sea caro pero no imposible:
1. Todo lo de `packages/` es **Dart puro y sin Flutter** (`D-01`): ya es portable por construcción, y eso es la mayor parte del valor del proyecto.
2. **Ninguna dependencia exclusiva de Android sin equivalente iOS conocido.** Si no lo hay, se anota en `BACKLOG` al añadirla, no después.
3. **Nada de `Platform.isAndroid` esparcido por la UI.** Cualquier diferencia de plataforma vive detrás de una única capa, no repartida en widgets.
4. La identidad por `device_id` heredada de Letrixa (`F4.03`) debe seguir siendo **agnóstica de plataforma**: no se ata a un identificador que solo exista en Android.
**Efectos sobre el plan:** ajustadas `F5.01` (solo Android), `F10.06` (Android App Links, sin Universal Links), `F11.04` (solo ficha de Play) y `F11.05` (build `.aab` firmado para Play, keystore fuera del repo). `F0.12` (`run.ps1`) ya apuntaba a Android.
**Condición de revisión:** tracción real en Play Store. Se reabre entonces, con `F12` propia y presupuesto explícito.

### D-16 — Melos 8 se configura en `pubspec.yaml`; toolchain de Windows desde WSL
**Contexto:** `DESARROLLO.md` daba por supuesto un `melos.yaml`, que es como funcionaba Melos hasta la 6. La versión que resuelve hoy es **Melos 8.3.0**, que se apoya en los **pub workspaces** de Dart 3: los paquetes se declaran en la clave `workspace:` de `pubspec.yaml` y la configuración de Melos vive en ese mismo fichero bajo la clave `melos:`. Comprobado en F0.04: con un `melos.yaml` presente, `ide.intellij.enabled: false` **no surtía efecto**; movido a `pubspec.yaml`, sí. Un `melos.yaml` en la raíz **se ignora en silencio**, que es la peor forma de fallar.
**Decisión:** no existe `melos.yaml` en este repositorio. Toda la configuración de Melos —paquetes, IDE y los futuros scripts de `F0.07`— vive en `pubspec.yaml`. Corregidas las referencias de fichero de `F0.04`, `F0.06` y `F0.07`.
**Segunda mitad, sobre el entorno:** la instalación de Flutter y Dart es de **Windows** (`C:\Users\manul\develop\flutter`), no de WSL, y el repositorio vive en una ruta de Windows. Desde WSL el script `bin/dart` falla porque busca un `dart-sdk` de Linux que no existe; hay que invocar **`dart.exe` / `flutter.bat`** por interop. Consecuencias vinculantes: `F0.12` (`run.ps1`) es PowerShell y es el camino natural de ejecución; `F0.08` (CI) corre sobre runners Linux con su propio SDK y por tanto **el CI es la única verificación que no depende de esta particularidad local**, razón de más para que sea bloqueante; y ningún script del repo puede asumir que existe un `dart` en el `PATH` de Linux.
**Versiones fijadas:** Dart SDK 3.10.4 · Melos 8.3.0 · constraint `sdk: ^3.10.0` en los tres paquetes.

### D-17 — Repositorio público, y lo que eso obliga a resolver antes de F7.01
**Contexto:** el criterio de `F0.08` exige que el check `verify` sea **bloqueante en PR**, y GitHub reserva la protección de rama —tanto la clásica como los rulesets— a repositorios **públicos o de plan Pro**. Con el repositorio privado, la API devuelve `403: Upgrade to GitHub Pro or make this repository public`. Pagar Pro contradice `D-12`, que fijó no asumir costes fijos hasta que la app genere ingresos.
**Decisión:** el repositorio pasa a **público**. Cierra `F0.08` sin coste y además convierte los minutos de Actions en ilimitados, lo que refuerza `D-12` en vez de contradecirlo.
**Configuración aplicada:** check `verify` requerido en `main`, `strict: true` (la rama debe estar al día), sin force-push y sin borrado de rama. **`enforce_admins: false` a propósito**, para que el flujo de este proyecto —un commit por tarea directamente sobre `main`— siga siendo posible. El bloqueo aplica a los PR, que es lo que pide el criterio.
**Consecuencia que hay que resolver, y que no es menor:** por `D-10` el reto diario se genera **en cliente de forma determinista**. Con el repositorio público, la semilla y el algoritmo quedan a la vista y cualquiera puede precomputar los retos futuros. Hoy ese código no existe, así que no hay nada expuesto todavía, pero **antes de `F7.01` y `F7.02` hay que decidir cómo se protege la semilla** —no embarcarla en el repositorio, derivarla de un secreto entregado por el servidor, o aceptar explícitamente la exposición apoyándose en que `F7.03` valida el envío al ranking en servidor—. Queda como bloqueo declarado de F7, no como sorpresa.
**Además:** nada de secretos en el repositorio. La clave `anon` de Supabase es pública por diseño y puede ir en el cliente; la `service_role` y el keystore de `F11.05` **jamás**. Eso ya estaba escrito, pero ahora deja de ser higiene y pasa a ser crítico.

---

## INVENTARIO LETRIXA

> Auditoría cerrada. `EXTRAER` = se trasplanta · `ADAPTAR` = se desenreda · `REESCRIBIR` = sale más barato de cero.

| Pieza | Estado | Acoplado a letras | Veredicto | Esfuerzo |
|---|---|---|---|---|
| ELO y `matches` | sólido, con tests | **no** | EXTRAER | días |
| Emparejamiento + `SKIP LOCKED` | sólido, con test de concurrencia | no | EXTRAER | días |
| Roster de 540 bots | sólido | no | EXTRAER | horas |
| Identidad por `device_id` | sólido | no | EXTRAER | días |
| Amigos, ligas, temporadas | sólido | no | EXTRAER | días |
| Rate limiting y anti-farmeo | sólido | no | EXTRAER | horas |
| Tema y tokens (`AppColors`) | sólido | no | EXTRAER | horas |
| Reto diario (patrón determinista) | sólido | contenido sí, patrón no | ADAPTAR | días |
| Salas y `game_rounds` | frágil; SQL agnóstico, Dart tipado a `List<List<String>>` | medio | ADAPTAR | días |
| Reconexión y reenganche | frágil pero probado | no | ADAPTAR | horas-días |
| i18n (`gen-l10n`, 12 idiomas) | sólido | no | ADAPTAR | días |
| Widgets genéricos | frágiles | bajo-medio | ADAPTAR | días |
| App Links y web | sólido | no | ADAPTAR | horas |
| Rachas | frágil, sin gracia, solo local | no | ADAPTAR | horas |
| **Diccionarios (12 idiomas limpios)** | sólido | — | **EXTRAER** | horas |
| **Normalización por idioma** | documentada, ganada con incidentes | — | **EXTRAER** | horas |
| Sincronización diferida | a medias, 3 mecanismos, uno en memoria | no | REESCRIBIR | días |
| Persistencia (`SharedPreferences`) | insuficiente para pools | no | REESCRIBIR (Drift) | días |
| Estructura de búsqueda (DFS Boggle) | inadecuada para atril | alto | REESCRIBIR | — |
| Generación de tableros | sin garantía de solución | alto | REESCRIBIR | — |
| `player_words.word TEXT` | asume palabra | alto | REESCRIBIR (`player_moves`) | días |
| `word_points` duplicado Dart/SQL | frágil por diseño | alto | REESCRIBIR con conformidad | días |
| Validación de jugada | **no existe** | — | CONSTRUIR | días |
| Niveles de dificultad | código muerto | — | CONSTRUIR | días |
| **Motor de cifras** | **no existe** | — | **CONSTRUIR** | semanas |
| CI de app y despliegue | **no existe** | — | CONSTRUIR | días |
| Tests de la app | ~0% | — | CONSTRUIR | continuo |

---

## BITÁCORA

**2026-08-19 · F0.10 — CERRADA** — La red de seguridad de `D-08` existe y **se ha visto fallar**, que es la única prueba que vale. `conformance/canary.json` se ejecuta desde Dart y desde TypeScript, 8 casos en cada lado, y la matriz de divergencia sale exactamente como debe:

| Se toca | Dart | Deno |
|---|---|---|
| Nada (sincronizados) | PASA | PASA |
| Solo la fórmula Dart | **FALLA** | PASA |
| Solo la fórmula TypeScript | PASA | **FALLA** |
| Solo el vector dorado | **FALLA** | **FALLA** |

La cuarta fila es la que cierra el argumento: el JSON es la autoridad, y cambiarlo sin tocar ninguna implementación rompe las dos. Eso es justo lo que hace imposible «arreglar» un test editando el vector.
**El canario no es una regla del juego y está escrito que no lo es.** Es el test de regresión del propio mecanismo, y no se borra nunca: si algún día deja de fallar al desincronizar los lados, la red está rota y nadie se habría enterado. Su contrato imita a propósito la forma de `evaluate()` de `F1.02` —devuelve `null` ante entrada inválida—, así que el formato queda probado con `null` **antes** de que haga falta, en vez de descubrir en F1.02 que el envoltorio no soportaba nulos.
**Decisiones de diseño que van dentro:**
- Los dos cargadores son **espejo deliberado**: mismas comprobaciones y mismos mensajes. Un fichero vacío o con `id` repetidos se rechaza en ambos lados, porque un fichero de vectores sin casos pasaría en verde sin comprobar nada — el dolor #2 disfrazado de test que aprueba.
- Ambos **buscan `conformance/` subiendo por el árbol** en vez de usar rutas relativas del tipo `../../conformance`, que se rompen según desde dónde se lance el test.
- El lado TypeScript **no tiene dependencias externas**, ni siquiera la librería de asertos: el CI no debe caerse porque un registro de paquetes vaya lento.
- La implementación TS vive en `supabase/functions/_shared/`, y los tests en `supabase/tests/`. **No es cosmético:** la guarda de `deploy.yml` excluye los directorios que empiezan por `_`, así que un `supabase/functions/tests/` habría intentado desplegarse como si fuera una Edge Function. Verificado que la guarda sigue diciendo «no hay funciones».
- Las dos mitades corren **en el mismo job `verify` del CI**, no en jobs separados. El check requerido por la protección de rama se llama `verify`; un job aparte no bloquearía el merge y la red de seguridad sería decorativa. Añadido también `deno check` para que un error de tipos de TypeScript caiga igual.
**Hueco declarado, no escondido:** `melos run verify` en local sigue siendo solo Dart, porque Deno no está instalado en la máquina de desarrollo. La mitad TypeScript se ejecuta con `melos run conformance` y, sobre todo, en el CI, que es bloqueante. En `BACKLOG` queda instalar Deno y plegarlo dentro de `verify` local.

**2026-08-19 · F0.09 — CERRADA** — Despliegue verde de extremo a extremo: `Finished supabase link` → `Connecting to remote database... Remote database is up to date` → `No hay Edge Functions todavia; nada que desplegar`. Los tres pasos hicieron exactamente lo previsto, incluida la guarda de funciones.
**Costó cinco intentos, y los cuatro fallos merecen quedar escritos porque ninguno era el mismo:**
1. **No se ejecutó.** GitHub omite los workflows con filtro de rutas cuando el push **crea la rama**. Por eso el primer push disparó CI pero no Deploy. Se lanzó a mano con `workflow_dispatch`.
2. **`Failed to resolve latest Supabase CLI release: rate limit exceeded`.** Culpa mía: `version: latest` hace que `supabase/setup-cli` consulte la API de GitHub **sin autenticar** para resolver la última release. Incoherencia flagrante, porque `D-16` ya había fijado el SDK de Dart justamente para no depender de versiones flotantes, y dejé el CLI de Supabase como excepción. Fijado a `2.115.0`.
3. **`Unexpected error retrieving remote project status`.** El token pertenecía a otra cuenta de Supabase. Diagnóstico enredado por un detalle propio: el `supabase` del entorno WSL es una instalación vieja (2.53.6) con una sesión antigua, y listaba tres proyectos ajenos. El CLI bueno es el de Windows (2.65.5) en `scoop/shims`. **Regla que queda:** para cualquier diagnóstico de Supabase se usa el CLI de Windows, nunca el de WSL.
4. **`Authorization failed for the access token and project ref pair`.** El token ya autenticaba pero estaba acotado a una organización que no era la del proyecto. El proyecto `ggnnesmpuqgjkqarwphm` («numlexa», creado el 2026-08-19, West EU Ireland) vive en la organización `mhbpjekupwujvheutlvr` («Manulopsan»), y el usuario tiene tres organizaciones. Resuelto con un token de permisos amplios sobre esa organización.
**Que el mensaje de error cambiara entre el intento 3 y el 4 fue lo que permitió avanzar:** «no puedo leer el proyecto» y «no estás autorizado para este par token/proyecto» son diagnósticos distintos, y tratarlos como el mismo habría costado varias rondas más.
**Detalle menor con consecuencia real:** `db push` imprimió `Skipping migration .gitkeep... (file name must match pattern "<timestamp>_name.sql")`. Es inofensivo hoy, pero **ese mismo mensaje será la alarma de una migración mal nombrada** más adelante. Anotado en `BACKLOG`: quitar el `.gitkeep` en `F4.01`, cuando exista la primera migración de verdad.

**2026-08-19 · F0.08 — CERRADA** — Workflow **verde en el primer push** (`91f02ab`) y también en el siguiente (`b25760a`): los 7 pasos del job `verify` en success, incluido el propio `melos run verify` corriendo sobre Linux con SDK propio. Esa era la mitad fácil.
**La mitad difícil obligó a una decisión nueva (`D-17`):** «bloqueante en PR» resultó **imposible** con el repositorio privado. GitHub reserva la protección de rama a repos públicos o a plan Pro y devolvía `403: Upgrade to GitHub Pro or make this repository public`. Pagar contradice `D-12`. Decidido con el usuario: **repositorio público**, que además hace ilimitados los minutos de Actions. Configurado el check `verify` como requerido en `main`, con `strict: true`, sin force-push y sin borrado de rama, y **`enforce_admins: false` a propósito** para que el flujo de un commit por tarea directamente sobre `main` siga funcionando. Confirmado en la práctica: el siguiente push devolvió `remote: - Required status check "verify" is expected`.
**Contrapartida registrada, no barrida bajo la alfombra:** un repositorio público expone la semilla del reto diario, que por `D-10` se genera en cliente. Hay que resolverlo **antes de `F7.01`**; está escrito en `D-17` y en `BLOQUEOS`.

**2026-08-19 · F0.09 (en curso)** — Escrito `.github/workflows/deploy.yml`: `supabase link` → `db push` → `functions deploy`, disparado al empujar a `main` **solo si cambia algo desplegable** (`paths: supabase/**`), más ejecución manual. Añadido también `supabase/config.toml` mediante `supabase init`: sin él el CLI no reconoce el directorio como proyecto y ningún paso del workflow podría funcionar.
**Decisiones que van dentro, y por qué:**
- `concurrency` con `cancel-in-progress: false`. Un despliegue **no se cancela a medias**: dejaría migraciones aplicadas parcialmente sin que el workflow lo reporte. Se encolan.
- Un paso previo que **comprueba que los secretos existen y falla diciendo cuáles faltan**, en vez de reventar más adelante con un error de autenticación que no explica nada. Dolor #2 aplicado al CI.
- El ref del proyecto **no es un secreto** —aparece en la URL pública—, así que va como variable de repositorio con el actual por defecto. Solo `SUPABASE_ACCESS_TOKEN` y `SUPABASE_DB_PASSWORD` son secretos.
- Guarda antes de `functions deploy`: el comando falla si no hay ninguna función, y hasta `F1.14` no la habrá. Se informa y se sigue, en vez de dejar el workflow en rojo por algo normal en esta fase.
- **No se activa `--prune`.** Borraría del proyecto las funciones ausentes del repositorio, que es justo la garantía que persigue el dolor #5, pero es destructivo. Se decide cuando exista la primera función real, no antes.
**Verificado lo verificable:** YAML válido, sintaxis de shell de los pasos correcta, y la guarda de funciones probada en sus cuatro casos —solo `.gitkeep`, solo `_shared/`, con una función real, y limpio de nuevo—; distingue bien `_shared/` de una función, que es exactamente lo que `F1.14` va a crear.
**Por qué queda `[~]`:** el criterio pide que *un merge a `main` despliegue migraciones y funciones*, y eso no es comprobable sin push ni sin los dos secretos configurados. Mismo bloqueo que `F0.08`, anotado en `BLOQUEOS`.

**2026-08-19 · F0.08 (en curso)** — Escrito `.github/workflows/ci.yml`: `verify` sobre `ubuntu-latest`, disparado en push a `main`, en cada pull request y a mano. SDK de Dart **fijado a 3.10.4**, no `stable`: que el SDK cambie solo es justo la deriva que este proyecto no quiere (`D-16`). Cache de `~/.pub-cache` por hash de `pubspec.lock`, `concurrency` para cancelar ejecuciones superadas, `permissions: contents: read` por mínimo privilegio —los secretos son cosa de `deploy.yml` en `F0.09`— y `timeout-minutes: 20`.
**Verificado lo verificable:** YAML válido y, desde estado limpio (`.dart_tool` y `coverage` borrados), la secuencia exacta del workflow —`dart pub get` → `dart run melos bootstrap` → `dart run melos run verify`— devuelve **rc=0** en los tres pasos.
**Por qué queda `[~]` y no `[x]`:** el criterio pide *workflow verde en el primer push* y *bloqueante en PR*, y **ninguna de las dos mitades es verificable desde aquí**. No hay credenciales de GitHub en este entorno (`git ls-remote` falla con «could not read Username») y `gh` no está instalado, así que no puedo pushear ni comprobar que la ejecución sale verde. Y lo de «bloqueante» no es una propiedad del fichero: es la protección de rama de GitHub marcando el check `verify` como requerido, que es una configuración del repositorio, no del repo. Marcarla `[x]` sería exactamente el dolor #5 —dar por terminado algo que no está desplegado—, así que se queda abierta con los dos pasos pendientes anotados en `BLOQUEOS`.

**2026-08-19 · F0.07** — `melos run verify` existe y devuelve **0** con el repositorio limpio. Cuatro puertas encadenadas, en orden de coste creciente para que falle pronto: `format` → `analyze` → `ignores` → `test`. Cada una es también un script suelto, para que el CI de `F0.08` pueda reutilizarlas por separado sin duplicar comandos.
**Añadida una cuarta puerta que la tarea no pedía:** `ignores`, que ejecuta `scripts/check_ignores.dart`. `CLAUDE.md §7` prohíbe `// ignore:` sin justificar y **no existe lint que lo compruebe**; quedó anotado en `BACKLOG` durante F0.05 y este era su sitio natural. Convención fijada: una directiva está justificada si la línea inmediatamente anterior es un comentario `//` con texto que no sea otra directiva. Limitación asumida y documentada en el propio script: analiza texto plano, así que un `// ignore:` dentro de un literal de cadena contaría; se prefiere ese falso positivo, que se ve y se corrige, a dejar pasar uno de verdad.
**`analyze` usa `--fatal-infos --fatal-warnings`,** no solo las reglas que F0.05 elevó a `error`. Así bloquea también lo que se quede en severidad `info`, que es donde por defecto viven casi todos los lints.
**Criterio verificado en las cuatro direcciones, no solo en verde:** repo limpio → **rc=0**; un fichero mal formateado → falla en `format` y `verify` para ahí, rc=1; un `print()` → falla en `analyze`, rc=1; un `// ignore_for_file:` sin explicación → falla en `ignores`, rc=1; y la cobertura ya se verificó en F0.06. En los cuatro casos `verify` **aborta en el paso que falla** y no sigue ejecutando los siguientes.
**Nota de invocación:** el comando real es `dart run melos run verify`. `melos run verify` a secas exige `dart pub global activate melos`, que no se ha hecho para no tocar la máquina; el pipeline es autocontenido a propósito (`D-16`).
**A partir de aquí, el paso 5 del ciclo de `CLAUDE.md §2` deja de ser documental:** todas las tareas siguientes pasan por `verify` antes del commit.

**2026-08-19 · F0.06** — `melos run test` reporta cobertura por paquete y aplica el umbral del 90%. Tres pasos encadenados con `steps:`: `dart test --coverage` en cada paquete, `format_coverage` a lcov, y `scripts/check_coverage.dart`, que suma los registros `DA:` de cada `lcov.info` e imprime una tabla por paquete. Añadidos `test` y `coverage` como dev-dependencies de los tres paquetes y un test de andamio en cada uno, marcado como tal, para que `dart test` no falle por ausencia de ficheros; se sustituye por los tests reales de reglas en F1.02, F2.02 y F3.02, que por `CLAUDE.md §7` van antes que la implementación.
**Criterio verificado en las tres direcciones, no solo en verde:** con código deliberadamente mal cubierto, `25.0% (2/8) FALLA` y `melos run test` termina en **rc=1**; cubriéndolo entero, `100.0% (8/8) OK` y **rc=0**; y borrando un `lcov.info`, `SIN INFORME DE COBERTURA FALLA` con rc=1. Ese tercer caso es deliberado: un paquete cuyos tests no llegaron a correr no puede pasar por silencio, que es el dolor #2 con otra ropa.
**Tropiezo:** los `steps:` de Melos se ejecutan en la shell del sistema, y `melos` no está en el `PATH` porque lo invocamos con `dart run melos`. Los pasos que llamaban a `melos exec` reventaban con «no se reconoce como un comando». Resueltos como `dart run melos exec …`, que además deja el pipeline **autocontenido**: no exige activar Melos globalmente en ninguna máquina, lo que importa para el CI de `F0.08`.
**El script no usa `print()`**, sino `stdout.writeln`: `avoid_print` es error desde F0.05, y la primera víctima de una regla nueva suele ser el propio tooling.
**Agujero conocido, anotado en `BACKLOG`:** hoy los tres paquetes reportan «sin líneas ejecutables todavía» y eso cuenta como pase. Es correcto ahora —no hay código— pero significa que un fallo de instrumentación pasaría desapercibido hasta que haya código real.

**2026-08-19 · F0.05** — `analysis_options.yaml` estricto en la raíz, aplicando a todo el monorepo. `strict-casts`, `strict-inference` y además `strict-raw-types`, que es la tercera vía por la que `dynamic` se cuela sin que nadie lo escriba. Sobre `lints/recommended`, una lista corta y deliberada de reglas extra, y **quince diagnósticos elevados a `error`** en `analyzer.errors` para que tumben el build por sí solos, sin depender de que alguien recuerde pasar `--fatal-infos`. `todo: ignore`: lo que bloquea es el `BACKLOG`, no un comentario.
**Criterio verificado de verdad, no por inspección:** escribí un fichero con violaciones deliberadas y `dart analyze` devolvió **rc=3** con 8 incidencias; borrado el fichero, vuelve a rc=0. Comprobadas una por una, en tres tandas, todas las reglas escaladas: `always_declare_return_types`, `invalid_assignment` por strict-casts, `strict_raw_type`, `inference_failure`, `avoid_dynamic_calls`, `unused_local_variable`, `avoid_print`, `unrelated_type_equality_checks`, `literal_only_boolean_expressions`, `unawaited_futures` y `dead_code`.
**Sorpresa, y de la misma familia silenciosa que la de F0.04:** `avoid_print` **no saltaba**. Escalar una regla en `analyzer.errors` **no la activa**; si no está en `linter.rules` ni viene de `lints/recommended`, la severidad se ignora sin decir nada. O sea que la prohibición de `print()` de `CLAUDE.md §7` estaba escrita en el fichero y no se aplicaba. Solo se vio porque la prueba de violación la buscaba explícitamente. Añadida a `linter.rules` con un comentario que explica la trampa, y auditado el resto de la lista de `errors:` en vez de darla por buena.
**Aprendizaje de método:** dos tareas seguidas con un fallo silencioso de configuración. Una regla de calidad que no se ha visto fallar no está activa; está escrita, que no es lo mismo.

**2026-08-19 · F0.04** — Monorepo inicializado. `melos bootstrap` resuelve sin error con **3 paquetes**: `numlexa_core`, `numlexa_numbers` y `numlexa_letters`, los tres Dart puros, sin Flutter y con `resolution: workspace`. Añadido el esqueleto de `supabase/` (`migrations/`, `functions/`, `tests/`) con un README que deja escritas las dos restricciones que condicionan lo que entre ahí: tier Free sin `pg_cron` en producción (`D-12`) y vectores de conformidad obligatorios (`D-08`). `dart analyze` limpio.
**Sorpresa, y de las que fallan en silencio:** `melos.yaml` **no funciona** con Melos 8. La configuración va en `pubspec.yaml` bajo la clave `melos:`, y un `melos.yaml` en la raíz se ignora sin avisar — lo detecté porque `ide.intellij.enabled: false` no hacía nada hasta moverlo. Gana el código (`CLAUDE.md §3`): borrado `melos.yaml`, corregidas las referencias de fichero de `F0.04`, `F0.06` y `F0.07`, y registrado en `D-16`.
**Segunda sorpresa:** Flutter y Dart están instalados **en Windows**, no en WSL, así que desde aquí hay que llamar a `dart.exe` por interop; el `bin/dart` de Linux revienta buscando un `dart-sdk` que no existe. También en `D-16`, porque afecta a `F0.07`, `F0.08` y `F0.12`.
**Lo que NO he creado, a propósito:** `apps/mobile` no existe todavía. La tarea lo nombra, pero crear una carpeta vacía sería estructura falsa: la app la inicializa `flutter create --platforms=android` en `F5.01`. La clave `workspace:` de `pubspec.yaml` ya tiene comentado dónde se añade. Tampoco se han creado `conformance/`, `tools/` ni `data/`: son de `F0.10`, F1/F2 y `F0.11`. `.gitignore` sí se ha creado, mínimo y solo para artefactos de Dart; las reglas de `data/` y LFS son de `F0.11`.

**2026-08-19 · F0.03** — Alcance de plataformas cerrado: **solo Android** (`D-15`). Sin cuenta de desarrollador de Apple, y no se abre una por especulación: 99 $/año recurrentes frente a los 25 $ de pago único de Play, que además ya está cubierto por Letrixa (confirmar antes de `F11.05`). Decisión deliberada de **no crear la carpeta `ios/`**: una plataforma que nadie compila ni prueba no es una opción abierta, es deuda que se pudre. A cambio se pagan hoy cuatro seguros baratos para que el port no sea imposible más tarde —`packages/` ya es Dart puro y portable, prohibición de dependencias solo-Android sin equivalente, nada de `Platform.isAndroid` disperso por la UI, y `device_id` agnóstico de plataforma—. Si iOS vuelve, vuelve como **fase `F12` propia**, no colado al final de `F11`, que es justo lo que la tarea advertía. Ajustadas en consecuencia `F5.01`, `F10.06`, `F11.04` y `F11.05`. Verificación documental de nuevo: sigue sin existir `melos.yaml` (`F0.04` es la siguiente).

**2026-08-19 · F0.02** — Tier de Supabase decidido: **Free permanente, 0 $/mes** (`D-12`). Comprobado que `pg_cron` no es la variable —está en todos los planes— sino la fiabilidad: el Free se pausa tras ~7 días de inactividad. Se asume a sabiendas el patrón de GitHub Actions cron, o sea el dolor #3, con la razón escrita y tres reglas vinculantes que lo hacen sostenible (reintento + alerta visible, idempotencia, nada de producción sobre `pg_cron`). Sorpresa útil: el propio cron de GitHub mantiene el proyecto despierto, así que la pausa del Free deja de ser un problema práctico. Verificado que el proyecto `ggnnesmpuqgjkqarwphm` responde y está despierto; el plan no es consultable con la clave `anon`, lo aportó el usuario. No se ha ejecutado `melos run verify`: aún no existe `melos.yaml` (`F0.04`), la verificación de esta tarea es documental. Detectada además una discrepancia entre plan y realidad (`CLAUDE.md §3`): `F0.01` figuraba como `[x]` pero **el repositorio no tenía ningún commit**, así que este es el commit inicial y arrastra también `CLAUDE.md`. `spanish_words.json` e `icon.webp` se dejan **sin versionar** a propósito hasta `F0.11` (LFS y `.gitignore`) y `F2.01`. **Además, registradas tres desviaciones del plan indicadas por el usuario, sin implementar ninguna:** `D-13` (la web pasa a `numlexa.vercel.app` bajo `letrixa.app/numlexa`, corregidas `F10.07` y `F7.06`), `D-14` (español primero) y la nueva tarea `F0.12` (script `run.ps1` de arranque con credenciales, que depende de `F5.01`).

**2026-08-19 · F0.01** — Auditoría de Letrixa cerrada. Hallazgo principal: la capa competitiva es agnóstica de contenido y se trasplanta casi entera. Hallazgo que cambia la arquitectura: el backend es Supabase con Edge Functions en TypeScript, así que las reglas vivirán en dos lenguajes y los vectores de conformidad pasan de recomendables a obligatorios (`D-08`). Corregida `D-10`: el reto diario se genera en cliente, no se descarga. Añadidas `D-07` a `D-11`.

---

## BACKLOG

- Migraciones 045–048 de Letrixa no cubiertas por sus tests: revisar antes de trasplantar.
- Decidir si el modo "Explorador" de Letrixa (tablero con solución garantizada por backtracking) inspira algún modo de NUMLEXA.
- Evaluar si conviene soportar los 12 idiomas de Letrixa en vez de 7, dado que los diccionarios ya existen.
- **`spanish_words.json` aportado en la raíz** (131.655 entradas, lista plana sin frecuencias). Inspección rápida: contiene **nombres propios** (`abraham`, `alemania`, `afganistan`, `alcalá`) y **siglas** (`abs`, `adn`, `adsl`), justo lo que `F2.04` debe filtrar. Además, al no traer rangos de frecuencia, `F2.05` necesitará una lista externa. Moverlo a `data/raw/` en `F2.01`, no antes.
- **`icon.webp` en la raíz.** Colocarlo en `apps/mobile` cuando exista (`F5.01`/`F5.02`), generar densidades y adaptive icon. No tocar hasta entonces.
- **Tensión de marca a cerrar en `F5.02`:** el usuario fija **colores pastel suaves** y `CLAUDE.md §8` fija **tema oscuro por defecto** y tono seco. No son incompatibles —pastel sobre fondo oscuro es una dirección legítima— pero hay que resolverlo explícitamente con el icono delante, no por acumulación de decisiones sueltas. Afecta también a `F11.03` (contraste y modo daltónico).
- **`F0.11` debe incluir `* text=auto eol=lf` en `.gitattributes`, no solo las reglas de LFS.** Ya ha pasado una vez: un editor de Windows reescribió `spanish_words.json` en CRLF y git marcó las 131.656 líneas como modificadas sin que cambiara una sola palabra. Se restauró sin pérdida, pero si le ocurre a un `.dart` la puerta `format` del CI falla en Linux por algo que en local se ve perfecto — el peor tipo de fallo, el que no se reproduce en la máquina de quien lo causó.
- **`icon.webp` y `spanish_words.json` entraron en el historial de git** en el commit `91f02ab` («first upload»), en la raíz y **sin LFS** (1,8 MB el diccionario). No es grave y no se reescribe historia ya empujada, pero: cuando `F2.01` mueva el diccionario a `data/raw/` —que va ignorado— hay que **dejar de versionar la copia de la raíz**, y `F0.11` debe cubrir `data/dist/` con LFS antes de que aparezca el primer binario generado, que sí será grande.
- **Instalar Deno en la máquina de desarrollo y meter `conformance` dentro de `verify` local.** Hoy `melos run verify` solo cubre la mitad Dart; la mitad TypeScript se verifica en el CI, que es bloqueante, y con `melos run conformance` a mano. Deno hará falta igualmente en `F1.14`. Valorar entonces añadir también `deno fmt --check`, que hoy se deja fuera para no exigir Deno en local.
- **Acotar el `SUPABASE_ACCESS_TOKEN`.** Hoy es un token de permisos amplios sobre la organización `Manulopsan`, elegido a propósito para dejar de adivinar scopes tras cuatro intentos fallidos. Ahora que el workflow pasa, se puede mirar qué llamadas hace realmente y reducirlo con datos en vez de por suposición.
- **Quitar `supabase/migrations/.gitkeep` en `F4.01`.** `db push` imprime `Skipping migration .gitkeep...` en cada ejecución. Es inofensivo, pero ese mismo mensaje es el que avisará de una migración mal nombrada, y no conviene que haya uno permanente de fondo con el que confundirlo.
- **Diagnósticos de Supabase: usar el CLI de Windows** (`/mnt/c/Users/manul/scoop/shims/supabase.exe`, 2.65.5), no el del entorno WSL (2.53.6), que tiene una sesión antigua de otra cuenta y devuelve una lista de proyectos engañosa. Costó un diagnóstico erróneo en `F0.09`.
- **`deploy.yml`: valorar un `supabase db push --dry-run` en cada PR** que toque `supabase/**`, para ver las migraciones pendientes antes de fusionarlas. Se dejó fuera de `F0.09` por alcance.
- **`deploy.yml`: decidir `--prune` en `functions deploy` y `environment: production`** cuando exista la primera Edge Function real (`F1.14`). Lo primero garantiza que producción no tenga funciones que ya no están en el repo (dolor #5); lo segundo deja traza y permite exigir aprobación manual antes de tocar la base de datos.
- **Cerrar el agujero de «sin líneas ejecutables» en `scripts/check_coverage.dart`.** Hoy un paquete sin líneas medibles pasa, que es lo correcto mientras `packages/` esté vacío. En cuanto `F1.01` y `F3.01` metan código real, ese caso debe convertirse en **FALLA**: si no, un fallo de instrumentación de cobertura dejaría el umbral del 90% en verde sin medir nada.
- **Credenciales:** la clave `anon` de Supabase es pública por diseño y puede viajar en el `run.ps1` y en el binario. La `service_role` **no entra jamás** en el repo, ni en el script, ni en un `--dart-define`; su sitio son los secretos de GitHub Actions (`F0.09`).

---

## BLOQUEOS

- **`F7.01` / `F7.02` — proteger la semilla del reto diario** ahora que el repositorio es público. Ver `D-17`. Debe decidirse antes de escribir la generación determinista, no después.