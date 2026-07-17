# TECHNICAL_REVIEW — BattleshipARM

Fecha de revisión: 2026-07-16
Método: análisis estático del ensamblador, enunciado (`docs/Enunciado_Battleship_PY03.md`), Makefile, CI y git. No se ejecutó el binario en esta pasada (toolchain ARM/QEMU no instalado en el sandbox); CI compila con el toolchain real (build-only, sin ejecución).

## 1. Comprensión del proyecto

Battleship por consola escrito íntegramente en ensamblador ARM (~1,132 líneas, 6 módulos), ensamblado con GNU as/ld y ejecutado vía `qemu-arm`. Proyecto PY03 del curso (arquitectura de computadores). Es el diferenciador de bajo nivel del portafolio junto a `RISCMatrixApp` y `TicTacToe-x86-ASM`.

## 2. Cumplimiento del enunciado

| Requisito | Estado | Evidencia |
|---|---|---|
| 2.1 Mapa estándar o personalizado + guardado de configuración | ✅ | `main.s` → `set_custom_map`, `save_config`; `data.s` → `current_map_size` |
| 2.2 Tamaños 10×10 a 20×20 | 🟦 | `current_map_size` parametriza `board.s` (render y límites); rango exacto no re-verificado por ejecución |
| 2.3 Cinco barcos con orientación H/V | ✅ | `ships.s`; nombres en `data.s` (`ship_name_1..5`) |
| 2.4 Solitario vs oponente aleatorio válido | ✅ | LCG `rand` en `main.s` (semilla en registro callee-saved) |
| 2.4 Multijugador por sockets (opcional) | ⛔ No implementado | Sin llamadas a socket en `src/` |
| CLI funcional | 🟦 | Syscalls read/write en `io.s`; UI ANSI en `data.s` |

## 3. Fortalezas

1. Disciplina de convención de llamada visible: comentarios de alineación de pila a 8 bytes (AAPCS) en cada push/pop (`board.s`, `main.s`) — señal de comprensión real, no copia.
2. Modularización genuina en ASM (6 archivos con interfaces `.global`), algo poco común en proyectos de curso.
3. E/S sin libc: syscalls Linux directas; RNG propio (LCG) en lugar de dependencias.
4. CI que compila con el toolchain ARM real en cada push.

## 4. Debilidades y riesgos

| Hallazgo | Severidad | Nota |
|---|---|---|
| Sin ejecución automatizada en CI (solo build) — una prueba de humo con `qemu-arm` + entrada guionizada sería viable | Media | |
| Strings de debug (`dbg_1..3`) residuales en `data.s` | Baja | Código muerto |
| Comentarios de razonamiento en vivo ("Wait, 24 is 8-byte aligned?") en `board.s` | Baja | Limpiar para presentación |
| ~~Binario `battleship` trackeado en git~~ | — | Corregido: `git rm --cached` + `.gitignore`; pendiente de commit |
| ~~README con link de imagen roto (`screenshots/`)~~ | — | Corregido: README reescrito (EN + resumen ES) |

## 5. Evaluación profesional

- 30 segundos: "juego completo en ensamblador ARM con CI" — alto impacto diferenciador; pocos portafolios lo tienen.
- 5 minutos: el código sostiene la impresión (alineación AAPCS comentada, módulos limpios); los restos de debug la rebajan levemente.
- Nivel demostrado: **Junior+ / Mid en sistemas de bajo nivel**. La pieza no evalúa ingeniería de software amplia sino dominio de arquitectura; en ese eje es evidencia fuerte.

## 6. Recomendaciones

Ver `IMPROVEMENT_ROADMAP.md`. P1: smoke test en CI con QEMU; limpiar debug strings.
