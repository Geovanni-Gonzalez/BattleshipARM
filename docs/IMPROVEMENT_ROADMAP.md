# IMPROVEMENT_ROADMAP — BattleshipARM

Backlog priorizado. Impacto/Esfuerzo: Alto/Medio/Bajo.

## Quick Wins

| # | Mejora | Impacto | Esfuerzo | Prioridad |
|---|---|---|---|---|
| 1 | Commitear el untracking del binario `battleship` (aplicado en esta revisión) | Medio | Bajo | P0 |
| 2 | Eliminar strings de debug `dbg_1..3` de `data.s` y comentarios de razonamiento en vivo de `board.s` | Medio | Bajo | P1 |
| 3 | GitHub Topics: `arm`, `assembly`, `qemu`, `low-level`, `game`, `makefile` + descripción | Medio | Bajo | P1 |
| 4 | GIF corto de gameplay en `docs/img/` (asciinema o captura de terminal) — el ASCII banner a color luce bien | Medio | Bajo | P1 |

## Mejoras técnicas

| # | Mejora | Impacto | Esfuerzo | Prioridad |
|---|---|---|---|---|
| 5 | Smoke test en CI: instalar `qemu-user`, ejecutar con entrada guionizada (heredoc) y verificar salida esperada — convierte el build-only en evidencia de ejecución | Alto | Medio | P1 |
| 6 | Semilla RNG desde el reloj (syscall `gettimeofday`) en vez de constante | Bajo | Bajo | P2 |
| 7 | Documentar el mapa de registros por módulo (qué registros usa cada rutina como scratch/preservados) en un `docs/REGISTERS.md` | Medio | Bajo | P2 |

## Mejoras arquitectónicas

| # | Mejora | Impacto | Esfuerzo | Prioridad |
|---|---|---|---|---|
| 8 | Multijugador por sockets (punto opcional del enunciado): syscalls `socket/bind/accept` — subiría el techo técnico del proyecto de forma notable | Alto | Alto | P3 |

## Mejoras de GitHub

Ya presentes: badge CI, LICENSE, `.gitignore`, enunciado en `docs/`, imagen. Faltan: Topics/descripción (item 3), demo animada (item 4).
