# CLAUDE.md — Contrato permanente de NUMLEXA

> Este archivo se lee **al principio de cada sesión**, antes de tocar nada.
> `DESARROLLO.md` dice *qué* hacer ahora. Este archivo dice *cómo* hacerlo siempre.

---

## 1. Regla de oro

**Una tarea por vez. La que marca `TAREA ACTUAL` en `DESARROLLO.md`. Ni una más.**

Si detectas algo que hay que arreglar y no es la tarea actual, **no lo arregles**:
anótalo en la sección `BACKLOG` de `DESARROLLO.md` y sigue.

Está terminantemente prohibido:
- Empezar una tarea que no sea la actual "porque es rápida".
- Crear archivos, carpetas o dependencias que la tarea actual no exija.
- Refactorizar código que la tarea actual no toca.
- Adelantar fases.

Si la tarea actual está mal definida o es imposible, **para y pregunta**. No improvises alcance.

---

## 2. Ciclo de trabajo obligatorio

Cada tarea sigue exactamente estos 7 pasos:

1. **Leer** `CLAUDE.md` y `DESARROLLO.md`.
2. **Localizar** la primera línea con estado `[ ]` o `[~]`. Esa es la tarea.
3. **Anunciar**: escribe en el chat el ID, el objetivo y el criterio de aceptación
   tal y como aparece en `DESARROLLO.md`. Marca la línea como `[~]`.
4. **Implementar** solo eso. Tests incluidos si la tarea los pide.
5. **Verificar** contra el criterio de aceptación. Ejecuta `melos run verify`.
   Si falla, arregla antes de continuar. No se avanza con tests en rojo.
6. **Cerrar**: marca la línea como `[x]`, añade una entrada en `BITÁCORA`
   (fecha, ID, qué se hizo, decisiones tomadas, sorpresas).
7. **Commit** con mensaje `F<fase>.<num>: <descripción corta>`.

Luego **para y espera confirmación** antes de pasar a la siguiente tarea.
No encadenes tareas sin permiso explícito.

---

## 3. Estado y memoria

`DESARROLLO.md` es la **única fuente de verdad** sobre el avance del proyecto.
No confíes en tu memoria de la conversación: si no está escrito ahí, no ha pasado.

- Toda decisión de arquitectura no trivial va al `REGISTRO DE DECISIONES`.
- Toda desviación del plan se documenta. No se corrige el plan en silencio.
- Si `DESARROLLO.md` y el código se contradicen, **gana el código**: corrige el .md
  y anótalo en la bitácora.

---

## 4. Stack fijado

No se cambia sin registrar una decisión nueva.

| Capa | Elección |
|---|---|
| Monorepo | Melos (paquetes Dart) |
| Lenguaje cliente | **Dart**. `strict-casts`, `strict-inference`, warnings bloqueantes |
| Cliente móvil | **Flutter**. El juego vive aquí, y solo aquí |
| Estado cliente | Provider o Riverpod (Letrixa usa Provider con 2 providers globales) |
| Motores | Paquetes Dart puros en `packages/` — sin dependencias de Flutter |
| Backend | **Supabase**: Postgres + Edge Functions en Deno/TypeScript. Trasplantado de Letrixa |
| Tiempo real | Supabase Realtime sobre tablas. Reloj = ancla `started_at` + reconstrucción en cliente |
| Persistencia local | **Drift (SQLite)**. No `SharedPreferences`: no aguanta pools ni historial |
| Sitio web | Vite + React, patrón de `boogle-web`. **Informativo. No se juega** |
| Tests | `package:test` para motores, `flutter_test` + `integration_test` para UI, Node+Postgres para backend |
| Generación de datos | Scripts offline en `tools/`. Lenguaje libre |

**El backend es TypeScript y el cliente es Dart.** Eso significa que las reglas del juego
—puntuación, evaluación de expresiones, numeración del reto diario— van a existir **dos veces**.
No es evitable sin tirar el backend de Letrixa, que es la pieza más valiosa que hay.
Se gestiona con los **vectores de conformidad** de §6, que son obligatorios, no opcionales.

**Por qué Flutter y no React Native:** ya existe **Letrixa**, construida en Flutter, con reto
diario y multijugador funcionando. El oficio, los patrones y buena parte del código son
reutilizables. Además, para un juego de fichas con reloj y animación, el render de Flutter es
más consistente y predecible. Ver `D-04`.

**Los generadores offline pueden escribirse en cualquier lenguaje.** El DP de cifras y la
construcción del DAWG se ejecutan una vez, en una máquina de desarrollo, y producen archivos
binarios. Nada de eso llega al dispositivo. Elige el lenguaje que resulte más cómodo para cada
generador y no lo conviertas en un debate. Lo único que importa es el formato binario de salida,
que sí debe estar documentado y ser estable.

### Estructura del monorepo

```
numlexa/
├── CLAUDE.md                  # este archivo
├── DESARROLLO.md              # el espinazo
├── packages/                  # paquetes Dart puros, sin Flutter
│   ├── numlexa_core/          # reglas: puntuación, máquina de ronda, RNG, calendario
│   ├── numlexa_numbers/       # motor de cifras: evaluación, solver, pool
│   └── numlexa_letters/       # motor de letras: DAWG, anagramas, bolsas
├── apps/
│   ├── mobile/                # Flutter. El juego vive aquí, y solo aquí
│   └── web/                   # sitio informativo. NO se juega
├── supabase/
│   ├── migrations/            # Postgres. Buena parte trasplantada de Letrixa
│   ├── functions/             # Edge Functions en Deno/TypeScript
│   └── tests/                 # Node + Postgres embebido
├── conformance/               # vectores dorados Dart ↔ TypeScript (§6)
├── tools/                     # generadores offline. Lenguaje libre
└── data/
    ├── raw/                   # diccionarios y frecuencias (no versionar)
    └── dist/                  # artefactos generados (LFS)
```

---

## 5. Reglas del juego que nunca se violan

Estas son de producto, no negociables por conveniencia técnica:

**Cifras**
- 6 fichas. Bolsa grande {25, 50, 75, 100} (una de cada). Bolsa pequeña 1–10 (dos de cada).
- **El jugador NO elige la mezcla.** La determina el generador según el nivel.
- Objetivo entero en [101, 999].
- Solo `+ − × ÷`. Todo resultado intermedio debe ser **entero y estrictamente positivo**.
  División solo si es exacta. Cada ficha se usa como máximo una vez. No hace falta usarlas todas.
- **Todo puzle servido tiene solución exacta garantizada.** Sin excepciones.
- Puntos: 10 exacto · 7 a distancia ≤5 · 5 a distancia ≤10 · 0 en otro caso.

**Letras**
- 9 letras, pedidas de una en una eligiendo vocal o consonante.
- Mínimo 3 vocales y mínimo 4 consonantes.
- Puntúa la longitud de la palabra. Palabra de 9 = bonus.
- **Dos diccionarios por idioma**: uno *amplio* para validar (nunca castigar al culto)
  y uno *filtrado por frecuencia* para generar tableros, sugerir y alimentar al bot.
- Un tablero solo entra en un nivel si contiene una palabra de la longitud objetivo
  dentro de la banda de frecuencia de ese nivel.

**Ambas**
- 30 s en letras, 45 s en cifras.
- **Declaración previa**: antes de revelar, el jugador declara la longitud de su palabra
  o si tiene el exacto. Solo después se muestra. Es la defensa anti-trampas del formato.

**Idiomas soportados:** es, en-US, de, it, fr, pt, tr.

---

## 6. Modelo de autoridad

El juego sin conexión es un requisito de producto. Eso obliga a **dos regímenes distintos**,
y confundirlos es la peor cosa que le puede pasar a este proyecto.

### Régimen A — Local (un jugador, niveles, reto diario ya descargado)

- El cliente genera el puzle desde el pool embarcado, lleva el reloj y valida contra el DAWG local.
- Funciona en modo avión, de principio a fin.
- **Los resultados obtenidos en local son SIEMPRE no clasificatorios.** Nunca tocan el ranking
  competitivo ni el ELO. Se sincronizan como progreso personal y racha, nada más.
- Es aceptable que un usuario haga trampa aquí: solo se engaña a sí mismo, y no contamina a nadie.

### Régimen B — Servidor autoritativo (1 vs 1, salas, ranking competitivo)

- El servidor genera el puzle, lleva el reloj y valida cada jugada. El cliente solo pinta.
- El reloj del cliente es cosmético, sincronizado por handshake de offset.
- Toda jugada de cifras se envía como expresión completa y se re-evalúa en servidor.
- Nunca se envía al cliente la solución antes de que termine la ronda.
- **Sin conexión no hay régimen B.** No existe un modo degradado: o hay servidor, o no hay partida.

### Reto diario

Caso híbrido, y por eso tiene reglas propias:

- El puzle del día **se descarga del servidor**, no se calcula en el cliente. Si el cliente lo
  derivara de la fecha local, bastaría con adelantar el reloj del móvil para jugar los futuros.
- Una vez descargado, se juega sin conexión.
- El resultado se encola y se envía al recuperar la red. El servidor rechaza envíos con
  marca temporal incoherente respecto a cuándo se sirvió el puzle.

### Regla que resuelve las dudas

Ante cualquier duda sobre dónde validar algo: **si el resultado puede afectar a otro jugador,
lo valida el servidor. Si solo afecta a quien juega, puede ser local.**

### Vectores de conformidad

Si el servidor **no** es Dart, las reglas del juego existen implementadas dos veces. Eso es
tolerable, pero solo con una red de seguridad automática:

- `conformance/` contiene ficheros JSON dorados generados por los `tools/`:
  expresiones de cifras válidas e inválidas con su resultado, tableros de letras con sus
  palabras válidas, casos de puntuación en todos los tramos, y semillas del reto diario
  con el puzle exacto que deben producir.
- **Cliente y servidor ejecutan los mismos vectores en CI.** Si uno diverge, el build se cae.
- Cualquier cambio en las reglas empieza por regenerar los vectores, nunca por tocar una
  de las dos implementaciones.

Si el servidor es Dart, los vectores siguen siendo útiles como test de regresión, pero dejan
de ser críticos.

---

## 6bis. Reutilización de Letrixa

Ya existe **Letrixa**, en Flutter, con reto diario y multijugador funcionando. No se parte de cero.

- Antes de construir cualquier pieza de infraestructura —salas, emparejamiento, reconexión,
  autenticación, rachas, sincronización, pipeline de diccionarios— **mira primero si Letrixa
  ya la resuelve**. Si la resuelve, se extrae a un paquete compartido; no se reimplementa.
- Lo que se extraiga se convierte en paquete Dart independiente, versionado, consumible por
  ambas apps. No se copia y pega entre proyectos.
- Lo que sí es nuevo y no existe en Letrixa: **todo el motor de cifras**. Esa es la parte
  que hay que construir de verdad.

---

## 7. Calidad

- Sin `dynamic` evitable, sin `// ignore:` sin justificar, sin `print()` en producción.
- Todo lo de `packages/` es **puro, sin dependencias de Flutter, y testeado**.
- Cobertura mínima en `packages/`: 90%.
- Los tests de reglas del juego se escriben **antes** que la implementación.
- `melos run verify` = `analyze` + `format` + `test`. Debe pasar antes de cada commit.
- Comentarios en español. Nombres de código en inglés.

---

## 8. Marca

- Nombre: **NUMLEXA**. Paquete: `com.numlexa.app`.
- Identidad: dualidad NUM / LEX. Dos familias de ficha, misma silueta, color distinto.
- Tema oscuro por defecto. Tono seco y tenso, de juego de reloj. Nada de confeti.
- **Nunca** usar la marca "Cifras y Letras" ni "Countdown" en el nombre, icono, capturas
  o textos de ficha de tienda. Solo como keyword de búsqueda, si acaso.

---

## 9. Cuando dudes

Orden de prioridad ante un conflicto:

1. Corrección de las reglas del juego
2. Imposibilidad de trampas
3. Latencia percibida
4. Elegancia del código

Y si sigues dudando: **pregunta**. Una pregunta cuesta 30 segundos; una fase mal
construida cuesta una semana.


---

## 10. Lecciones heredadas de Letrixa

Cinco cosas que ya costaron caro una vez. No las repitas.

1. **Los días se cuentan por fecha de calendario en UTC, nunca por diferencia de instantes.**
   Contar `Duration` transcurrida desincronizó el contador del reto diario tras el cambio de
   hora y obligó a renumerar todos los retos desde cero, rompiendo las rachas de todos.

2. **Ningún `catch` que solo registre.** Una migración de seguridad revocó un permiso del que
   dependía una limpieza en el cliente; el `catch` solo hacía `debugPrint` y el fallo fue
   invisible durante meses. Si algo falla, tiene que verse.

3. **Decide el tier de Supabase con `pg_cron` antes de escribir tareas programadas.** No
   tenerlo obligó a replicar cinco veces el mismo patrón de cron en GitHub Actions.

4. **Ninguna regla de negocio duplicada sin vectores de conformidad.** `word_points` vive en
   Dart y en SQL sincronizados por un comentario que dice "si cambia aquí, cambia allá". Eso
   aguanta hasta que alguien cambia solo un lado.

5. **Nada terminado que no esté desplegado.** Una rama larga acumuló migraciones y funciones
   completas en local pero nunca aplicadas en producción. El repo y lo que corre dejan de
   coincidir y nadie se entera hasta el siguiente incidente.