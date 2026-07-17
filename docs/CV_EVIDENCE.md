# CV_EVIDENCE — BattleshipARM

Verifiable, interview-defensible material. All claims map to files in this repository.

## Resume bullets (pick & adapt)

- Implemented a complete console Battleship game in pure ARM assembly (~1,130 lines, 6 modules): game loop, ship placement/sinking logic, configurable 10×10–20×20 boards, and a computer opponent driven by a hand-rolled LCG random generator.
- Performed console I/O through direct Linux syscalls (no libc) and rendered an ANSI-colored UI, maintaining AAPCS calling-convention discipline with documented 8-byte stack alignment on every call frame.
- Set up cross-compilation (GNU as/ld for arm-linux-gnueabihf) with a pattern-rule Makefile and QEMU user-mode emulation, plus GitHub Actions CI building with the real ARM toolchain.

## Skills matrix

| Skill | Evidence | Depth | Confidence |
|---|---|---|---|
| ARM (ARMv7) assembly | All of `src/` — 1,132 hand-written lines | Medium-Deep | High |
| Calling conventions / stack discipline (AAPCS) | Alignment-annotated push/pop in `board.s`, `main.s` | Medium | High |
| Linux syscall interface | `io.s` (read/write via `svc`) | Medium | High |
| Low-level data layout | Byte-addressed 2-D boards, `.data` globals in `data.s` | Medium | High |
| PRNG implementation (LCG) | `rand`/`rand_init` in `main.s` | Basic-Medium | High |
| Cross-compilation & emulation (QEMU) | `Makefile`, CI workflow | Medium | High |
| Make | Pattern rules, phony targets in `Makefile` | Basic-Medium | High |

## What this project proves

- Portfolio differentiator: **comfort below the abstraction line** — most CS portfolios have no assembly at all; this one has a complete interactive program.
- First appearance of: ARM ISA, syscall-level I/O, QEMU, cross-toolchains.
- Reinforces: Make, CI (shared with RISCMatrixApp, which covers RISC-V/MIPS-adjacent skills).

## ATS keywords

ARM assembly, ARMv7, AAPCS, calling convention, Linux syscalls, low-level programming, embedded systems fundamentals, GNU toolchain, cross-compilation, QEMU, Makefile, GitHub Actions, CI, memory layout, pseudo-random number generation.
