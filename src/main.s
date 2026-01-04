.global _start

.text

_start:
    bl load_config          @ Intentar cargar config previa
    bl rand_init
    bl init_boards
    
    ldr r0, =msg_welcome
    bl print_str
    
    ldr r9, =12345          @ Init RNG Seed to r9 (Callee saved, Global)
    
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
    
    ldr r0, =input_buffer
    ldrb r1, [r0]       @ Decena
    ldrb r2, [r0, #1]   @ Unidad
    
    sub r1, r1, #'0'
    mov r3, #10
    mul r12, r1, r3
    mov r1, r12         @ r1 = res
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
    ldr r0, =board_player
    bl print_boards
    ldr r0, =board_player
    bl place_ships_player
    
    @ Check Mode
    ldr r1, =game_mode
    ldr r1, [r1]
    cmp r1, #0
    beq setup_ai
    
    @ Setup Player 2 (PvP)
    bl clear_screen
    ldr r0, =msg_p2_setup
    bl print_str
    ldr r0, =board_enemy
    bl print_boards
    ldr r0, =board_enemy
    bl place_ships_player
    bl clear_screen
    b start_combat

setup_ai:
    ldr r0, =dbg_trace
    bl print_str
    ldr r0, =msg_ai_placing
    bl print_str
    bl place_ships_ai
    b start_combat

start_combat:
    ldr r0, =msg_start_game
    bl print_str
    mov r4, #0  @ Turno P1

game_loop:
    cmp r4, #0
    beq turn_p1
    b turn_p2_or_ai

turn_p1:
    ldr r0, =msg_p1_turn
    bl print_str
    bl print_enemy_view
    
    ldr r0, =msg_prompt_coord
    bl print_str
    ldr r0, =input_buffer
    mov r1, #10
    bl read_str
    ldr r0, =input_buffer
    bl parse_coord
    
    cmp r0, #-1
    beq invalid_input_p1
    
    ldr r1, =board_enemy
    bl process_attack
    ldr r0, =dbg_4
    bl print_str
    
    ldr r0, =board_player
    bl check_win
    cmp r0, #1
    beq p1_wins
    
    mov r4, #1
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
    
    ldr r0, =msg_p2_turn
    bl print_str
    
    ldr r0, =board_player
    bl print_boards
    
    ldr r0, =msg_prompt_coord
    bl print_str
    ldr r0, =input_buffer
    mov r1, #10
    bl read_str
    ldr r0, =input_buffer
    bl parse_coord
    cmp r0, #-1
    beq invalid_input_p2
    ldr r1, =board_player
    bl process_attack
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
    bl rand
    
    @ Modulo 100
    mov r1, #100
    udiv r2, r0, r1
    mul r2, r1, r2         @ Fix: mul r2, r1, r2 (Rd != Rm)
    sub r0, r0, r2         @ r0 = r0 % 100
    
    mov r4, r0              @ Save Random Index
    ldr r0, =msg_ai_attk    @ (Mistake in previous code used r1)
    bl print_str
    
    mov r0, r4              @ Restore Index
    ldr r1, =board_player
    bl process_attack
    
    ldr r0, =board_player
    bl check_win
    cmp r0, #1
    beq ai_wins

ai_wins:
    ldr r0, =msg_ai_wins
    bl print_str
    b end_game

process_attack:
    push {r4, r5, r6, r7, r8, lr}
    
    mov r4, r0              @ Save Index (SAFE)
    mov r5, r1              @ Save Board (SAFE)
    
    ldr r0, =dbg_1
    bl print_str
    ldrb r6, [r5, r4]       
    cmp r6, #0
    beq mark_miss
    cmp r6, #50
    beq end_process_attack
    cmp r6, #51
    beq end_process_attack
    
    mov r2, #50             @ Hit
    strb r2, [r5, r4]
    ldr r0, =msg_hit
    bl print_str
    
    ldr r0, =dbg_2
    bl print_str
    
    mov r0, r5
    mov r1, r6
    bl is_ship_sunk
    cmp r0, #1
    beq notify_sunk
    b end_process_attack

notify_sunk:
    ldr r0, =msg_sunk
    bl print_str
    b end_process_attack

mark_miss:
    mov r2, #51
    strb r2, [r5, r4]
    ldr r0, =msg_miss
    bl print_str
    b end_process_attack

end_process_attack:
    ldr r0, =dbg_3
    bl print_str
    pop {r4, r5, r6, r7, r8, pc}

clear_screen:
    push {r0, lr}
    ldr r0, =ansi_cls
    bl print_str
    pop {r0, pc}

clear_screen_wait:
    bx lr

end_game:
    mov r0, #0
    bl exit_program

/*
 * rand (Moved from utils.s)
 */
.global rand
rand:
    @ Leaf function - uses r9 (Global Seed)
    add r9, r9, #13        @ Increment seed
    mov r0, r9             @ Return r9
    bx lr

.section .data
msg_menu_mode: .asciz "Seleccione Modo:\n[1] Jugador Vs IA\n[2] Jugador vs Jugador\nOpcion: "
msg_p1_setup: .asciz "\n--- CONFIGURACION JUGADOR 1 ---\n"
msg_p2_setup: .asciz "\n--- CONFIGURACION JUGADOR 2 ---\n"
msg_p1_turn:  .asciz "\n>>> TURNO JUGADOR 1 <<<\n"
msg_p2_turn:  .asciz "\n>>> TURNO JUGADOR 2 <<<\n"
msg_ai_attk:  .asciz "\nAI Ataca...\n"
msg_press_enter: .asciz "[Presione ENTER para continuar cambio de turno]"
@ ansi_cls removed (in data.s)
msg_menu_map:  .asciz "\nConfiguración de Mapa:\n[1] Estándar (10x10)\n[2] Personalizado\nOpción: "
msg_custom_size: .asciz "Ingrese tamaño (10-20): "
msg_start_game: .asciz "¡Comienza el combate!\n"
msg_ai_placing: .asciz "El enemigo está colocando sus barcos...\n"
msg_p1_wins:    .asciz "\n¡¡¡ JUGADOR 1 GANA !!!\n"
msg_p2_wins:    .asciz "\n¡¡¡ JUGADOR 2 GANA !!!\n"
msg_ai_wins:    .asciz "\n¡¡¡ LA IA TE HA DERROTADO !!!\n"
msg_retry:      .asciz "Entrada inválida.\n"
