.section .data
.global board_player
.global board_enemy
.global msg_welcome
.global msg_prompt_coord
.global msg_hit
.global msg_miss
.global newline

/* Tableros de hasta 20x20 bytes (400 bytes cada uno) */
board_player: .skip 400
board_enemy:  .skip 400

.global current_map_size
current_map_size: .word 10
.global seed
seed: .long 123456789  /* Default 10x10 */

/* Mensajes de texto */
@ ASCII Art & ANSI Colors
msg_welcome:
    .ascii "\033[1;36m"
    .ascii "    ____        __  __  __          __    _        \n"
    .ascii "   / __ )____ _/ /_/ /_/ /__  _____/ /_  (_)____   \n"
    .ascii "  / __  / __ `/ __/ __/ / _ \\/ ___/ __ \\/ / __ \\ \n"
    .ascii " / /_/ / /_/ / /_/ /_/ /  __(__  ) / / / / /_/ /   \n"
    .ascii "/_____/\\__,_/\\__/\\__/_/\\___/____/_/ /_/_/ .___/    \n"
    .ascii "                                       /_/         \n"
    .ascii "\033[0m\n"
    .asciz "\033[1;33m>>> Bienvenido Comandante al Sistema de Defensa Naval <<<\033[0m\n"
.global msg_prompt_coord
msg_prompt_coord: .asciz "Ingrese coordenadas (ej. A5): "
.global msg_prompt_orient
msg_prompt_orient: .asciz "Orientación (H=Horizontal, V=Vertical): "
.global msg_hit
msg_hit:          .asciz "\033[1;31m[!] IMPACTO CONFIRMADO EN EL OBJETIVO\033[0m\n"
.global msg_miss
msg_miss:         .asciz "\033[1;34m[-] Proyectil en el agua...\033[0m\n"
.global msg_sunk
msg_sunk:         .asciz "\033[1;32m[+] OBJETIVO DESTRUIDO: \033[0m"

ship_name_1: .asciz "Portaaviones"
ship_name_2: .asciz "Acorazado"
ship_name_3: .asciz "Submarino"
ship_name_4: .asciz "Crucero"
ship_name_5: .asciz "Destructor"
.align 4
.global ship_names_ptr
ship_names_ptr: .word ship_name_1, ship_name_2, ship_name_3, ship_name_4, ship_name_5

newline:          .asciz "\n"
.global msg_header_enemy
msg_header_enemy: .asciz "\n=== VISTA ENEMIGO ===\n"
.global ansi_cls
ansi_cls: .asciz "\033[H\033[J"

/* Estructuras de Barcos (ID, Tamaño, Nombre) */
/* Se implementará como bytes: ID, Size, <Chars para Nombre> */
.align 4
.global ships_info
ships_info:
    .byte 1, 5  /* Carrier */
    .byte 2, 4  /* Battleship */
    .byte 3, 3  /* Submarine */
    .byte 4, 3  /* Cruiser */
    .byte 5, 2  /* Destroyer */
    .byte 0     /* Fin de lista */

@ Moved to .data to simplify memory layout
.section .data
.global input_buffer
input_buffer: .skip 32
.align 4
.align 4
.global game_mode
game_mode: .word 0      /* 0 = PvPC, 1 = PvP */

.global dbg_1
.global dbg_2
.global dbg_3
.global dbg_4
.global dbg_5
.global dbg_6
dbg_1: .asciz "[DBG] Enter Process Attack\n"
dbg_2: .asciz "[DBG] After Hit\n"
dbg_3: .asciz "[DBG] Pop Stack\n"
dbg_4: .asciz "[DBG] Returned to Main\n"
dbg_5: .asciz "[DBG] Inside Check Win\n"
dbg_6: .asciz "[DBG] Before Loop\n"
.global msg_debug_addr
msg_debug_addr: .asciz "[DBG] Addr: "
.global dbg_trace
dbg_trace: .asciz "[DBG] Trace\n"
