<div align="center">

# Battleship ARM
### Battleship in pure ARM assembly — 1,100+ hand-written lines, no libc game logic

[![CI](https://github.com/Geovanni-Gonzalez/BattleshipARM/actions/workflows/ci.yml/badge.svg)](https://github.com/Geovanni-Gonzalez/BattleshipARM/actions/workflows/ci.yml)
![ARM](https://img.shields.io/badge/arch-ARMv7%20(gnueabihf)-red)
![Build](https://img.shields.io/badge/build-Make%20%2B%20GNU%20as%2Fld-blue)
![Run](https://img.shields.io/badge/run-QEMU%20user%20mode-lightgrey)

</div>

A complete console Battleship game written entirely in **ARM assembly** (~1,130 lines across 6 modules), assembled with the GNU toolchain and runnable on any x86 Linux via `qemu-arm`. Direct Linux syscalls for I/O, a custom LCG random generator for the computer opponent, ANSI-colored rendering, and configurable board sizes — all with manual register discipline and AAPCS-conscious stack alignment.

![Gameplay](docs/img/principalImage.png)

## Features

| Feature | Implementation |
|---|---|
| Standard 10×10 or custom board (up to 20×20) | `current_map_size` in `data.s`; parameterized rendering in `board.s` |
| 5 classic ships (Carrier→Destroyer), H/V orientation | placement + collision logic in `ships.s` |
| Solitaire vs. computer with valid random moves | LCG `rand` in `main.s` (seeded, callee-saved register) |
| Hit / miss / sunk detection with ship names | attack processing in `main.s`, messages in `data.s` |
| Config persistence | `save_config` flow in `main.s` |
| ANSI UI (colors, clear-screen, ASCII banner) | escape sequences in `data.s`, `io.s` |
| I/O without stdio | raw Linux syscalls (read/write) in `io.s` |

Not implemented: sockets multiplayer (optional item in the assignment — see [`docs/Enunciado_Battleship_PY03.md`](docs/Enunciado_Battleship_PY03.md)).

## Module layout

```
src/main.s    game loop, menus, RNG, attack logic   (334 lines)
src/ships.s   ship placement & sinking              (310)
src/board.s   board init & ANSI rendering           (195)
src/io.s      syscall-based console I/O             (113)
src/data.s    boards, strings, globals              (93)
src/utils.s   parsing & helpers                     (87)
```

## Build & run

Requires `binutils-arm-linux-gnueabihf` and `qemu-arm` (Debian/Ubuntu: `sudo apt install binutils-arm-linux-gnueabihf qemu-user`).

```bash
make        # assemble + link → ./battleship
make run    # run under qemu-arm
```

CI (GitHub Actions) installs the ARM toolchain and builds on every push.

## Skills demonstrated

ARM (ARMv7) assembly · AAPCS calling convention & 8-byte stack alignment · Linux syscall interface · manual memory layout (`.data`/`.text`, byte-addressed 2-D boards) · pseudo-random generation (LCG) · Makefile pattern rules · cross-compilation + emulation (QEMU).

## License

See [`LICENSE`](LICENSE).

## Author

**Geovanni González Aguilar** — Computer Engineering, Tecnológico de Costa Rica.

<details>
<summary><b>Resumen en español</b></summary>

Battleship completo por consola escrito íntegramente en ensamblador ARM (~1,130 líneas, 6 módulos): syscalls de Linux directas para E/S, generador pseudoaleatorio LCG propio para el oponente automático, tableros configurables de 10×10 a 20×20, colocación de 5 barcos con detección de hundimiento e interfaz ANSI a color. Compilado con GNU as/ld vía Makefile y ejecutable en cualquier Linux x86 con `qemu-arm`. CI en GitHub Actions compila con el toolchain ARM real. Multijugador por sockets (punto opcional del enunciado) no implementado.

</details>
