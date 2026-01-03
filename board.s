.global init_boards
.global print_boards
.global print_enemy_view
.global get_cell_addr

.text

/*
 * init_boards
 * Limpia los tableros (llena con 0).
 */
init_boards:
    push {r0, r1, r2, lr}
    
    @ Limpiar Tablero Jugador
    ldr r0, =board_player
    mov r1, #400            @ Limpiar hasta 20x20
    mov r2, #0              @ Valor 0 (Agua)
    bl memset_custom
    
    @ Limpiar Tablero Enemigo
    ldr r0, =board_enemy
    mov r1, #400
    mov r2, #0
    bl memset_custom
    
    pop {r0, r1, r2, pc}

/*
 * memset_custom
 * Rellena memoria con un byte constante.
 * R0 = Dirección, R1 = Tamaño, R2 = Valor
 */
memset_custom:
    push {r3}
loop_memset:
    cmp r1, #0
    beq end_memset
    strb r2, [r0], #1      @ Guardar byte y avanzar puntero
    sub r1, r1, #1         @ Decrementar contador
    b loop_memset
end_memset:
    pop {r3}
    bx lr

/*
 * print_boards
 * Imprime el estado visual del tablero del jugador.
 * 0 = ~ (Agua), 1 = O (Barco), 2 = X (Tocado), 3 = * (Fallo)
 */
print_boards:
    push {r0, r1, r2, r3, r4, r5, lr}
    
    ldr r0, =header_msg
    bl print_str
    
    ldr r4, =board_player   @ R4 = Puntero al tablero
    mov r5, #0              @ R5 = Fila (0-9)
    ldr r7, =current_map_size
    ldr r7, [r7]            @ R7 = Max size
    
loop_rows:
    cmp r5, r7
    beq end_print
    
    @ ... (letra de fila) ...
    mov r0, #'A'
    add r0, r0, r5
    bl print_char
    mov r0, #' '
    bl print_char
    
    mov r6, #0              @ R6 = Columna (0-9)
    
loop_cols:
    cmp r6, r7
    beq end_cols
    
    @ Obtener celda: [R4 + (R5*Width + R6)]
    mul r3, r5, r7          @ Fila * Width
    add r3, r3, r6          @ + Columna
    ldrb r0, [r4, r3]       @ Cargar valor de celda
    
    @ Decodificar valor visualmente
    cmp r0, #0
    beq print_water
    cmp r0, #50
    beq print_hit
    cmp r0, #51
    beq print_miss
    
    @ Si no es agua, hit o miss, es un barco (1-5)
    b print_ship
    
print_water:
    mov r0, #'~'
    b do_print_char
print_ship:
    mov r0, #'O'
    b do_print_char
print_hit:
    mov r0, #'X'
    b do_print_char
print_miss:
    mov r0, #'*'
    
do_print_char:
    bl print_char
    mov r0, #' '
    bl print_char
    
    add r6, r6, #1
    b loop_cols
    
end_cols:
    @ Nueva línea al final de la fila
    ldr r0, =newline
    bl print_str
    
    add r5, r5, #1
    b loop_rows

end_print:
    pop {r0, r1, r2, r3, r4, r5, pc}

/*
 * print_enemy_view
 * Muestra el tablero enemigo ocultando los barcos.
 */
print_enemy_view:
    push {r0, r1, r2, r3, r4, r5, lr}
    
    ldr r0, =header_enemy
    bl print_str
    
    ldr r4, =board_enemy    @ R4 = Enemigo
    mov r5, #0              @ Fila
    ldr r7, =current_map_size
    ldr r7, [r7]            @ R7 = Max size
    
loop_rows_e:
    cmp r5, r7
    beq end_print_e
    
    @ Fila Char
    mov r0, #'A'
    add r0, r0, r5
    bl print_char
    mov r0, #' '
    bl print_char
    
    mov r6, #0              @ Col
    
loop_cols_e:
    cmp r6, r7
    beq end_cols_e
    
    @ Calc index
    mul r3, r5, r7
    add r3, r3, r6
    ldrb r0, [r4, r3]
    
    @ Decodificar (Ocultando Barco)
    cmp r0, #0
    beq print_water_e
    cmp r0, #50
    beq print_hit_e
    cmp r0, #51
    beq print_miss_e
    
    @ Barco Intacto (1-5) -> Mostrar Agua
    b print_water_e
    
print_water_e:
    mov r0, #'~'
    b do_print_char_e
print_hit_e:
    mov r0, #'X'
    b do_print_char_e
print_miss_e:
    mov r0, #'*'

do_print_char_e:
    bl print_char
    mov r0, #' '
    bl print_char
    
    add r6, r6, #1
    b loop_cols_e

end_cols_e:
    ldr r0, =newline
    bl print_str @ newline is already defined in data section
    
    add r5, r5, #1
    b loop_rows_e

end_print_e:
    pop {r0, r1, r2, r3, r4, r5, pc}

.section .data
header_msg: .asciz "   0 1 2 3 4 5 6 7 8 9\n"
header_enemy: .asciz "\n=== ENEMIGO ===\n   0 1 2 3 4 5 6 7 8 9\n"
