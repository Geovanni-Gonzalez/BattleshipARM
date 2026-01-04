.global place_ships_player
.global place_ships_ai
.global check_win
.global is_ship_sunk
.global save_config
.global load_config

.text

@ --- COLOCACIÓN JUGADOR ---
place_ships_player:
    push {r4, r5, r6, r7, r8, r9, r10, r11, r12, lr} @ 10 regs
    @ sub sp, sp, #4 removed
    
    mov r8, r0              @ Board addr
    ldr r4, =ships_info
    
loop_ships:
    ldrb r5, [r4]
    cmp r5, #0
    beq end_p_func
    ldrb r6, [r4, #1]
    
try_p:
    ldr r0, =msg_prompt_coord
    bl print_str
    ldr r0, =input_buffer
    mov r1, #10
    bl read_str
    
    ldr r0, =input_buffer
    bl parse_coord
    cmp r0, #-1
    beq inv_p
    mov r10, r0             @ index
    
    ldr r0, =msg_prompt_orient
    bl print_str
    ldr r0, =input_buffer
    mov r1, #10
    bl read_str
    
    ldr r0, =input_buffer
    ldrb r0, [r0]
    cmp r0, #'v'
    beq set_v
    cmp r0, #'V'
    beq set_v
    mov r11, #1
    b val_p
set_v:
    ldr r11, =current_map_size
    ldr r11, [r11]

val_p:
    ldr r7, =current_map_size
    ldr r7, [r7]
    cmp r11, #1
    beq val_h
    @ Val V
    sub r0, r6, #1
    mul r1, r0, r7
    add r2, r1, r10
    mul r3, r7, r7
    cmp r2, r3
    bge inv_p
    b val_ov
val_h:
    mov r0, r10
    bl get_col_indexed
    add r0, r0, r6
    cmp r0, r7
    bgt inv_p

val_ov:
    mov r3, #0
    mov r1, r10
loop_ov:
    cmp r3, r6
    beq do_p
    ldrb r0, [r8, r1]
    cmp r0, #0
    bne inv_p
    add r1, r1, r11
    add r3, r3, #1
    b loop_ov

do_p:
    mov r1, r10
    mov r3, #0
loop_m:
    cmp r3, r6
    beq next_s
    strb r5, [r8, r1]
    add r1, r1, r11
    add r3, r3, #1
    b loop_m

next_s:
    mov r0, r8
    bl print_boards
    add r4, r4, #2
    b loop_ships

inv_p:
    ldr r0, =msg_retry_ships
    bl print_str
    b try_p

end_p_func:
    @ add sp, sp, #4 removed
    pop {r4, r5, r6, r7, r8, r9, r10, r11, r12, pc}

get_col_indexed:
    push {r1, r2, r3, lr} @ Align
    ldr r1, =current_map_size
    ldr r1, [r1]
    udiv r2, r0, r1
    mul r3, r2, r1
    sub r0, r0, r3
    pop {r1, r2, r3, pc}

@ --- COLOCACIÓN AI ---
place_ships_ai:
    push {r4, r5, r6, r7, r8, r9, r10, r11, r12, lr}
    @ sub sp, sp, #4 removed
    
    ldr r8, =board_enemy
    ldr r4, =ships_info
loop_ai:
    ldrb r5, [r4]
    cmp r5, #0
    beq end_ai
    ldrb r6, [r4, #1]
try_ai:
    bl rand
    ldr r1, =current_map_size
    ldr r1, [r1]
    mov r2, r1
    mul r3, r2, r1          @ size*size
    mov r2, r0              @ rand
    udiv r0, r0, r3
    mul r1, r3, r0
    sub r10, r2, r1         @ index
    
    bl rand
    tst r0, #1
    beq h_ai
    ldr r11, =current_map_size
    ldr r11, [r11]
    b val_ai
h_ai:
    mov r11, #1

val_ai:
    ldr r7, =current_map_size
    ldr r7, [r7]
    cmp r11, #1
    beq vh_ai
    sub r0, r6, #1
    mul r1, r0, r7
    add r2, r1, r10
    mul r3, r7, r7
    cmp r2, r3
    bge try_ai
    b vov_ai
vh_ai:
    mov r0, r10
    bl get_col_indexed
    add r0, r0, r6
    cmp r0, r7
    bgt try_ai

vov_ai:
    mov r2, #0
    mov r3, r10
ai_ov:
    cmp r2, r6
    beq do_ai
    ldrb r0, [r8, r3]
    cmp r0, #0
    bne try_ai
    add r3, r3, r11
    add r2, r2, #1
    b ai_ov

do_ai:
    mov r1, r10
    mov r3, #0
ai_m:
    cmp r3, r6
    beq next_ai
    strb r5, [r8, r1]
    add r1, r1, r11
    add r3, r3, #1
    b ai_m
next_ai:
    add r4, r4, #2
    b loop_ai
end_ai:
    @ add sp, sp, #4 removed
    pop {r4, r5, r6, r7, r8, r9, r10, r11, r12, pc}

@ --- WIN CONDITION ---
check_win:
    push {r1, r2, r3, r4, r5, r6, r7, lr} @ 8 regs
    
    mov r4, r0              @ Save Board Addr to R4 (Safe)
    
    mov r1, r4              @ Restore Board to R1
    
    ldr r2, =current_map_size
    ldr r2, [r2]
    mov r0, r2
    mul r3, r0, r2
    mov r2, r3
    
    mov r3, #0
cw_l:
    cmp r3, r2
    beq cw_w
    ldrb r4, [r1, r3]
    cmp r4, #1
    blt cw_n
    cmp r4, #5
    bgt cw_n
    
    mov r0, #0              @ Boat found!
    pop {r1, r2, r3, r4, r5, r6, r7, pc}
cw_n:
    add r3, r3, #1
    b cw_l
cw_w:
    mov r0, #1
    pop {r1, r2, r3, r4, r5, r6, r7, pc}

@ --- SUNK CHECK ---
is_ship_sunk:
    push {r1, r2, r3, r4, r5, r6, r7, lr} @ 8 regs = 32 bytes (Aligned)
    
    mov r2, r0              @ board
    mov r3, r1              @ ship id
    ldr r4, =current_map_size
    ldr r4, [r4]
    mov r0, r4
    mul r1, r0, r4          @ total
    mov r4, r1
    mov r5, #0
iss_l:
    cmp r5, r4
    beq iss_s
    ldrb r0, [r2, r5]
    cmp r0, r3
    beq iss_f
    add r5, r5, #1
    b iss_l
iss_f:
    mov r0, #0
    pop {r1, r2, r3, r4, r5, r6, r7, pc}
iss_s:
    mov r0, #1
    pop {r1, r2, r3, r4, r5, r6, r7, pc}

@ --- CONFIG ---
save_config:
    push {r0, r1, r2, r3, r4, r7, lr} @ 7 + 1 = 8
    sub sp, sp, #4
    ldr r0, =config_file
    mov r1, #577
    mov r2, #0644
    mov r7, #5
    svc #0
    cmp r0, #0
    blt sc_e
    mov r4, r0
    ldr r1, =current_map_size
    mov r2, #4
    mov r7, #4
    svc #0
    mov r0, r4
    mov r7, #6
    svc #0
sc_e:
    add sp, sp, #4
    pop {r0, r1, r2, r3, r4, r7, pc}

load_config:
    push {r0, r1, r2, r3, r4, r7, lr}
    sub sp, sp, #4
    ldr r0, =config_file
    mov r1, #0
    mov r7, #5
    svc #0
    cmp r0, #0
    blt lc_e
    mov r4, r0
    ldr r1, =current_map_size
    mov r2, #4
    mov r7, #3
    svc #0
    mov r0, r4
    mov r7, #6
    svc #0
lc_e:
    add sp, sp, #4
    pop {r0, r1, r2, r3, r4, r7, pc}

.section .data
config_file: .asciz "config.bin"
msg_retry_ships: .asciz "Ubicación inválida o solapada. Intente de nuevo.\n"
