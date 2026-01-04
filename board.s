.global init_boards
.global print_boards
.global print_enemy_view

.text

@ --- INICIALIZACIÓN ---
init_boards:
    push {r0, r1, r2, r3, r4, lr} @ 6 regs = 24 bytes (Aligned? No. 6*4=24. 24%8=0. YES Aligned.)
    @ Wait, 24 is 8-byte aligned? Yes. 8*3=24.
    ldr r0, =board_player
    mov r1, #400
    mov r2, #0
    bl memset_custom
    
    ldr r0, =board_enemy
    mov r1, #400
    mov r2, #0
    bl memset_custom
    pop {r0, r1, r2, r3, r4, pc}

memset_custom:
    push {r3, r4} @ Align
loop_memset:
    cmp r1, #0
    beq end_memset
    strb r2, [r0], #1
    sub r1, r1, #1
    b loop_memset
end_memset:
    pop {r3, r4}
    bx lr

@ --- TABLERO GENERICO ---
@ R0 = Dirección del tablero
print_boards:
    push {r0, r1, r2, r3, r4, r5, r6, r7, r8, lr} @ 10 regs = 40 bytes (Aligned)
    @ sub sp, sp, #4 removed
    
    mov r4, r0              @ Board pointer
    ldr r7, =current_map_size
    ldr r7, [r7]
    
    @ Header
    mov r0, #' '
    bl print_char
    bl print_char
    bl print_char
    mov r6, #0
loop_h:
    cmp r6, r7
    beq end_h
    mov r1, #10
    udiv r2, r6, r1
    mul r3, r2, r1
    sub r0, r6, r3
    add r0, r0, #'0'
    bl print_char
    mov r0, #' '
    bl print_char
    add r6, r6, #1
    b loop_h

end_h:
    ldr r0, =newline
    bl print_str

    mov r5, #0
loop_rows:
    cmp r5, r7
    beq end_p
    mov r0, #'A'
    add r0, r0, r5
    bl print_char
    mov r0, #' '
    bl print_char
    
    mov r6, #0
loop_cols:
    cmp r6, r7
    beq next_row
    
    @ idx = r5 * r7 + r6
    mul r3, r5, r7          @ r3 = row * width
    add r3, r3, r6          @ + col
    ldrb r0, [r4, r3]
    
    cmp r0, #0
    beq p_w
    cmp r0, #50
    beq p_h
    cmp r0, #51
    beq p_m
    mov r0, #'O'
    b p_out
p_w: mov r0, #'~'
    b p_out
p_h: mov r0, #'X'
    b p_out
p_m: mov r0, #'*'
p_out:
    bl print_char
    mov r0, #' '
    bl print_char
    add r6, r6, #1
    b loop_cols

next_row:
    ldr r0, =newline
    bl print_str
    add r5, r5, #1
    b loop_rows

end_p:
    @ add sp, sp, #4 removed
    pop {r0, r1, r2, r3, r4, r5, r6, r7, r8, pc}

@ --- VISTA ENEMIGO ---
print_enemy_view:
    push {r0, r1, r2, r3, r4, r5, r6, r7, r8, lr}
    @ sub sp, sp, #4 removed
    
    ldr r0, =msg_header_enemy
    bl print_str
    ldr r7, =current_map_size
    ldr r7, [r7]
    
    mov r0, #' '
    bl print_char
    bl print_char
    bl print_char
    mov r6, #0
loop_he:
    cmp r6, r7
    beq end_he
    mov r1, #10
    udiv r2, r6, r1
    mul r3, r2, r1
    sub r0, r6, r3
    add r0, r0, #'0'
    bl print_char
    mov r0, #' '
    bl print_char
    add r6, r6, #1
    b loop_he

end_he:
    ldr r0, =newline
    bl print_str

    ldr r4, =board_enemy
    mov r5, #0
loop_re:
    cmp r5, r7
    beq end_pe
    mov r0, #'A'
    add r0, r0, r5
    bl print_char
    mov r0, #' '
    bl print_char
    
    mov r6, #0
loop_ce:
    cmp r6, r7
    beq next_re
    
    mul r3, r5, r7
    add r3, r3, r6
    ldrb r0, [r4, r3]
    
    cmp r0, #50
    beq pe_h
    cmp r0, #51
    beq pe_m
    mov r0, #'~'
    b pe_out
pe_h: mov r0, #'X'
    b pe_out
pe_m: mov r0, #'*'
pe_out:
    bl print_char
    mov r0, #' '
    bl print_char
    add r6, r6, #1
    b loop_ce

next_re:
    ldr r0, =newline
    bl print_str
    add r5, r5, #1
    b loop_re

end_pe:
    @ add sp, sp, #4 removed
    pop {r0, r1, r2, r3, r4, r5, r6, r7, r8, pc}
