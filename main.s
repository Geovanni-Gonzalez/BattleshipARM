.global _start

.text

_start:
    bl load_config          @ Intentar cargar config previa
    bl rand_init
    bl init_boards
    
    ldr r0, =msg_welcome
    bl print_str
    
    ldr r0, =msg_menu_map
    bl print_str
    
    ldr r0, =input_buffer
    mov r1, #10
    bl read_str
    
    ldr r0, =input_buffer
    ldrb r0, [r0]
    cmp r0, #'2'
    beq set_custom_map
    @ Por defecto 10x10
    b select_mode

set_custom_map:
    ldr r0, =msg_custom_size
    bl print_str
    ldr r0, =input_buffer
    mov r1, #10
    bl read_str
    
    @ Convertir input a entero (simplificado: asumiendo 1x o 20)
    @ Para simplificar, si empieza con '2' es 20, si es '1' y segundo char > '0' es ese numero
    @ Hagamos un parse basico para 10-20
    ldr r0, =input_buffer
    ldrb r1, [r0]       @ Decena
    ldrb r2, [r0, #1]   @ Unidad
    
    sub r1, r1, #'0'
    mov r3, #10
    mul r2, r1, r3      @ r2 = r1 * 10
    mov r1, r2          @ r1 = res
    ldrb r2, [r0, #1]
    sub r2, r2, #'0'
    add r1, r1, r2      @ R1 = Size
    
    cmp r1, #10
    blt size_error
    cmp r1, #20
    bgt size_error
    
    ldr r0, =current_map_size
    str r1, [r0]
    bl save_config
    b select_mode

size_error:
    ldr r0, =msg_retry
    bl print_str
    b set_custom_map

select_mode:
    ldr r0, =msg_menu_mode
    bl print_str
    
    ldr r0, =input_buffer
    mov r1, #10
    bl read_str
    
    @ ldr r0, =input_buffer
    @ bl string_to_int  <-- Removed, using ASCII check directly below
    @ Por simplicidad, chequeamos el caracter ascii
    ldr r0, =input_buffer
    ldrb r0, [r0]
    
    cmp r0, #'1'
    beq set_pvpc
    cmp r0, #'2'
    beq set_pvp
    
    ldr r0, =msg_retry
    bl print_str
    b select_mode

set_pvpc:
    ldr r1, =game_mode
    mov r2, #0              @ 0 = PvPC
    str r2, [r1]
    b setup_game

set_pvp:
    ldr r1, =game_mode
    mov r2, #1              @ 1 = PvP
    str r2, [r1]
    b setup_game

setup_game:
    @ --- FASE DE COLOCACION ---
    
    @ Jugador 1
    ldr r0, =msg_p1_setup
    bl print_str
    bl print_boards         @ Muestra P1 board
    ldr r0, =board_player
    bl place_ships_player
    
    @ Check Mode
    ldr r1, =game_mode
    ldr r1, [r1]
    cmp r1, #0
    beq setup_ai
    
    @ Setup Player 2 (PvP)
    bl clear_screen         @ Limpiar pantalla para que P1 no vea
    ldr r0, =msg_p2_setup
    bl print_str
    @ Mostrar board P2 (usamos board_enemy como tablero P2)
    @ Nota: print_boards esta hardcoded para board_player
    @ Necesitamos print_board_generic tambien?
    @ Por ahora, reusemos place_ships_player pasando board_enemy
    ldr r0, =board_enemy
    bl place_ships_player
    bl clear_screen
    b start_combat

setup_ai:
    ldr r0, =msg_ai_placing
    bl print_str
    bl place_ships_ai
    b start_combat

start_combat:
    ldr r0, =msg_start_game
    bl print_str
    
    @ Variable turno: 0=P1, 1=P2/AI
    mov r4, #0  @ Inicia P1

game_loop:
    cmp r4, #0
    beq turn_p1
    b turn_p2_or_ai

turn_p1:
    ldr r0, =msg_p1_turn
    bl print_str
    
    @ Mostrar vista de enemigo (Fog of War)
    bl print_enemy_view
    
    @ Input Ataque
    ldr r0, =msg_prompt_coord
    bl print_str
    ldr r0, =input_buffer
    mov r1, #10
    bl read_str
    ldr r0, =input_buffer
    bl parse_coord
    
    cmp r0, #-1
    beq invalid_input_p1
    
    @ Atacar board_enemy (que es AI o P2)
    ldr r1, =board_enemy
    bl process_attack
    
    @ Check Win P1
    ldr r0, =board_enemy
    bl check_win
    cmp r0, #1
    beq p1_wins
    
    mov r4, #1          @ Cambio turno
    bl clear_screen_wait
    b game_loop

p1_wins:
    ldr r0, =msg_p1_wins
    bl print_str
    b end_game

invalid_input_p1:
    ldr r0, =msg_retry
    bl print_str
    b turn_p1

turn_p2_or_ai:
    ldr r1, =game_mode
    ldr r1, [r1]
    cmp r1, #0
    beq ai_logic
    
    @ Lógica PvP - Turno Player 2
    ldr r0, =msg_p2_turn
    bl print_str
    
    @ Mostrar Tablero P1 (Fog of War) - Necesitamos funcion print_player_view (ver P1 desde perspectiva P2)
    @ Por ahora simplificado: P2 ataca a ciegas o ve el resultado anterior?
    @ Implementemos ataque simple
    
    ldr r0, =msg_prompt_coord
    bl print_str
    ldr r0, =input_buffer
    mov r1, #10
    bl read_str
    ldr r0, =input_buffer
    bl parse_coord
    
    cmp r0, #-1
    beq invalid_input_p2
    
    @ Atacar board_player
    ldr r1, =board_player
    bl process_attack
    
    @ Check Win P2
    ldr r0, =board_player
    bl check_win
    cmp r0, #1
    beq p2_wins
    
    mov r4, #0
    bl clear_screen_wait
    b game_loop

invalid_input_p2:
    ldr r0, =msg_retry
    bl print_str
    b turn_p2_or_ai

p2_wins:
    ldr r0, =msg_p2_wins
    bl print_str
    b end_game

ai_logic:
    @ AI Random Attack
    bl rand
    @ Modulo Size*Size
    ldr r1, =current_map_size
    ldr r1, [r1]
    mov r3, r1
    mul r1, r3, r1          @ total cells (Rd!=Rm fix)
    push {r0}
    mov r2, r0
    udiv r0, r0, r1
    mul r3, r1, r0          @ Use r3 for result to avoid Rd==Rm
    sub r0, r2, r3          @ r0 = r2 - r3 (Resto)
    pop {r2}
    
    ldr r1, =msg_ai_attk
    bl print_str
    
    ldr r1, =board_player
    bl process_attack
    
    @ Check Win AI
    ldr r0, =board_player
    bl check_win
    cmp r0, #1
    beq ai_wins
    
    mov r4, #0
    b game_loop

ai_wins:
    ldr r0, =msg_ai_wins
    bl print_str
    b end_game

/*
 * process_attack
 * R0 = Index, R1 = Board Address
 */
process_attack:
    push {r4, r5, r6, lr}
    mov r4, r0              @ Index
    mov r5, r1              @ Board
    
    ldrb r6, [r5, r4]       @ R6 = Valor actual (ID o Agua)
    
    cmp r6, #0
    beq mark_miss
    
    cmp r6, #50             @ Ya fue tocado
    beq end_process_attack
    cmp r6, #51             @ Ya fue fallo
    beq end_process_attack
    
    @ Es un barco (1-5)
    mov r2, #50             @ Marcar como Tocado
    strb r2, [r5, r4]
    
    ldr r0, =msg_hit
    bl print_str
    
    @ Verificar si se hundió el barco de ID R6
    mov r0, r5              @ Board
    mov r1, r6              @ Ship ID
    bl is_ship_sunk
    
    cmp r0, #1
    beq notify_sunk
    b end_process_attack

notify_sunk:
    ldr r0, =msg_sunk
    bl print_str
    
    @ R6 tiene el ID (1-5). Obtener nombre.
    sub r6, r6, #1          @ 0-indexed
    ldr r1, =ship_names_ptr
    lsl r6, r6, #2          @ 4 bytes per pointer
    ldr r0, [r1, r6]        @ Cargar puntero al nombre
    bl print_str
    ldr r0, =newline
    bl print_str
    b end_process_attack

mark_miss:
    mov r2, #51
    strb r2, [r5, r4]
    ldr r0, =msg_miss
    bl print_str
    b end_process_attack

end_process_attack:
    pop {r4, r5, r6, pc}

clear_screen:
    @ ANSI escape \033[H\033[J
    push {lr}
    ldr r0, =ansi_cls
    bl print_str
    pop {pc}

clear_screen_wait:
    push {lr}
    ldr r0, =msg_press_enter
    bl print_str
    ldr r0, =input_buffer
    mov r1, #2
    bl read_str
    bl clear_screen
    pop {pc}

end_game:
    mov r0, #0
    bl exit_program

.section .data
msg_menu_mode: .asciz "Seleccione Modo:\n[1] Jugador Vs IA\n[2] Jugador vs Jugador\nOpcion: "
msg_p1_setup: .asciz "\n--- CONFIGURACION JUGADOR 1 ---\n"
msg_p2_setup: .asciz "\n--- CONFIGURACION JUGADOR 2 ---\n"
msg_p1_turn:  .asciz "\n>>> TURNO JUGADOR 1 <<<\n"
msg_p2_turn:  .asciz "\n>>> TURNO JUGADOR 2 <<<\n"
msg_ai_attk:  .asciz "\nAI Ataca...\n"
msg_press_enter: .asciz "[Presione ENTER para continuar cambio de turno]"
ansi_cls:     .asciz "\033[H\033[J"
msg_menu_map:  .asciz "\nConfiguración de Mapa:\n[1] Estándar (10x10)\n[2] Personalizado\nOpción: "
msg_custom_size: .asciz "Ingrese tamaño (10-20): "
msg_start_game: .asciz "¡Comienza el combate!\n"
msg_ai_placing: .asciz "El enemigo está colocando sus barcos...\n"
msg_p1_wins:    .asciz "\n¡¡¡ JUGADOR 1 GANA !!!\n"
msg_p2_wins:    .asciz "\n¡¡¡ JUGADOR 2 GANA !!!\n"
msg_ai_wins:    .asciz "\n¡¡¡ LA IA TE HA DERROTADO !!!\n"
msg_retry:      .asciz "Entrada inválida.\n"
