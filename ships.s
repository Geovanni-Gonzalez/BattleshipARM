.global place_ships_player
.global place_ships_ai
.global ships_info

.text

/*
 * place_ships_player
 * Recorre la lista de barcos y pide al usuario ubicarlos.
 * Entrada: R0 = Dirección del tablero
 */
place_ships_player:
    push {r4, r5, r6, r8, lr}
    mov r8, r0              @ R8 = Guardar dirección tablero
    
    ldr r4, =ships_info     @ R4 = Puntero a info de barcos
    
loop_ships:
    ldrb r5, [r4]           @ Cargar ID del barco
    cmp r5, #0              @ ¿Fin de lista?
    beq end_placement
    
    ldrb r6, [r4, #1]       @ Cargar Tamaño del barco
    
    @ Prompt al usuario
    ldr r0, =msg_prompt_coord
    bl print_str
    
    @ Leer Input Coordenada
    ldr r0, =input_buffer
    mov r1, #10             @ Max length
    bl read_str
    
    @ Parsear Coordenada
    ldr r0, =input_buffer
    bl parse_coord
    
    cmp r0, #-1
    beq invalid_input
    
    mov r1, r0              @ R1 = Índice inicial (Index)
    
    @ Prompt Orientación
    ldr r0, =msg_prompt_orient
    bl print_str
    
    ldr r0, =input_buffer
    mov r1, #10
    bl read_str
    
    ldr r0, =input_buffer
    ldrb r0, [r0]           @ Cargar 'H' o 'V'
    
    @ Determinar Salto (Step)
    cmp r0, #'v'
    beq set_vertical
    cmp r0, #'V'
    beq set_vertical
    
    @ Por defecto Horizontal
    mov r7, #1
    b validate_placement

set_vertical:
    ldr r7, =current_map_size
    ldr r7, [r7]

validate_placement:
    @ TODO: Validar si el barco cabe en el tablero con este step
    
    mov r2, r8              @ R2 = Dirección Tablero (Arg)
    
    @ Marcar celdas
    mov r3, #0              @ Contador de celdas marcadas
loop_mark:
    cmp r3, r6              @ ¿Contador == Tamaño?
    beq next_ship
    
    mov r0, r5              @ Valor = ID del Barco (R5)
    strb r0, [r2, r1]       @ Guardar en tablero[index]
    
    add r1, r1, r7          @ Siguiente celda (Usa el paso: 1 o Width)
    add r3, r3, #1
    b loop_mark

next_ship:
    @ Imprimir tablero para feedback
    bl print_boards
    
    add r4, r4, #2          @ Avanzar en struct ships_info (ID, Size)
    b loop_ships

invalid_input:
    ldr r0, =msg_retry_ships
    bl print_str
    b loop_ships            @ Reintentar mismo barco

end_placement:
    pop {r4, r5, r6, r8, pc}

/*
 * place_ships_ai
 * Coloca los barcos del enemigo aleatoriamente.
 */
place_ships_ai:
    push {r4, r5, r6, r7, r8, lr}
    
    ldr r4, =ships_info     @ R4 = Ships Info
    
loop_ships_ai:
    ldrb r5, [r4]           @ ID
    cmp r5, #0
    beq end_ai_placement
    
    ldrb r6, [r4, #1]       @ Tamaño
    
try_place:
    @ Generar posición aleatoria (0-99)
    bl rand
    ldr r1, =current_map_size
    ldr r1, [r1]
    mov r3, r1
    mul r1, r3, r1          @ r1 = size * size (total cells)
    @ Modulo simple: r0 = r0 - (r0/r1)*r1
    push {r0}
    mov r2, r0
    udiv r0, r0, r1         
    mul r0, r1, r0          
    sub r0, r2, r0          @ r0 = r2 - r0 (Resto)
    pop {r2}
    
    mov r7, r0              @ R7 = Índice inicial
    
    @ Validar si cabe (Horizontal)
    push {r7}
    mov r0, r7
    bl get_col_from_index
    pop {r7}
    
    add r0, r0, r6          @ Col + Tamaño
    ldr r3, =current_map_size
    ldr r3, [r3]
    cmp r0, r3
    bgt try_place           @ Se sale del borde, reintentar
    
    @ Validar si hay overlap
    ldr r8, =board_enemy
    mov r2, #0              @ Counter
    mov r3, r7              @ Current Index
    
check_overlap:
    cmp r2, r6
    beq do_place_ai
    
    ldrb r0, [r8, r3]
    cmp r0, #0
    bne try_place           @ Ocupado, reintentar
    
    add r3, r3, #1
    add r2, r2, #1
    b check_overlap

do_place_ai:
    @ Colocar
    mov r2, #0
    mov r3, r7
place_loop_ai:
    cmp r2, r6
    beq next_ship_ai
    
    mov r0, r5              @ R5 = ID del Barco
    strb r0, [r8, r3]
    
    add r3, r3, #1
    add r2, r2, #1
    b place_loop_ai

next_ship_ai:
    add r4, r4, #2
    b loop_ships_ai

end_ai_placement:
    pop {r4, r5, r6, r7, r8, pc}

/* Helper inline: get_col_from_index (0-99 -> 0-9) */
get_col_from_index:
    @ r0 = index
    @ ret r0 = col
    push {r1, r2, lr}
    ldr r1, =current_map_size
    ldr r1, [r1]
    udiv r2, r0, r1
    mul r3, r2, r1          @ Rd=r3, Rm=r1 (OK)
    sub r0, r0, r3
    pop {r1, r2, pc}

/*
 * check_win
 * Verifica si quedan barcos intactos (valor 1) en el tablero dado.
 * Entrada: R0 = Dirección del tablero
 * Salida: R0 = 1 si GAME OVER (no quedan barcos), 0 si aun quedan.
 */
.global check_win
check_win:
    push {r1, r2, r3, r4, lr}
    mov r1, r0              @ r1 = board
    ldr r2, =current_map_size
    ldr r2, [r2]
    mov r0, r2
    mul r2, r0, r2          @ r2 = total cells
    
    mov r3, #0              @ counter
loop_check_win:
    cmp r3, r2
    beq game_over_found     @ Recorrimos todo y no hay barcos (R0=1)
    
    ldrb r4, [r1, r3]
    cmp r4, #0
    beq next_check
    cmp r4, #50             @ Hit
    beq next_check
    cmp r4, #51             @ Miss
    beq next_check
    
    @ Si llegamos aquí, es un ID (1-5) intacto
    b ships_alive         

next_check:
    add r3, r3, #1
    b loop_check_win

ships_alive:
    mov r0, #0
    pop {r1, r2, r3, r4, pc}

game_over_found:
    mov r0, #1
    pop {r1, r2, r3, r4, pc}

/*
 * is_ship_sunk
 * Verifica si un ID específico aún existe en el tablero.
 * Entrada: R0 = Board, R1 = Ship ID
 * Salida: R0 = 1 si HUNDIDO (no se encontró el ID), 0 si aun quedan partes.
 */
.global is_ship_sunk
is_ship_sunk:
    push {r2, r3, r4, r5, lr}
    mov r2, r0              @ board
    mov r3, r1              @ ship id
    
    ldr r4, =current_map_size
    ldr r4, [r4]
    mov r0, r4
    mul r4, r0, r4          @ total cells
    
    mov r5, #0
loop_is_sunk:
    cmp r5, r4
    beq sunk_confirmation
    
    ldrb r0, [r2, r5]
    cmp r0, r3
    beq ship_still_afloat
    
    add r5, r5, #1
    b loop_is_sunk

ship_still_afloat:
    mov r0, #0
    pop {r2, r3, r4, r5, pc}

sunk_confirmation:
    mov r0, #1
    pop {r2, r3, r4, r5, pc}

/*
 * save_config
 * Guarda current_map_size en "config.bin".
 */
.global save_config
save_config:
    push {r7, lr}
    
    @ open("config.bin", O_WRONLY | O_CREAT | O_TRUNC, 0644)
    ldr r0, =config_file
    mov r1, #577            @ O_WRONLY | O_CREAT | O_TRUNC (valores varían, usaremos creat)
    mov r2, #0644           @ Mode
    mov r7, #5              @ sys_open
    svc #0
    
    cmp r0, #0
    blt end_save            @ Error al abrir
    
    mov r4, r0              @ fd
    
    @ write(fd, &current_map_size, 4)
    mov r0, r4
    ldr r1, =current_map_size
    mov r2, #4
    mov r7, #4              @ sys_write
    svc #0
    
    @ close(fd)
    mov r0, r4
    mov r7, #6              @ sys_close
    svc #0

end_save:
    pop {r7, pc}

/*
 * load_config
 * Carga current_map_size desde "config.bin".
 */
.global load_config
load_config:
    push {r7, lr}
    
    @ open("config.bin", O_RDONLY)
    ldr r0, =config_file
    mov r1, #0              @ O_RDONLY
    mov r7, #5              @ sys_open
    svc #0
    
    cmp r0, #0
    blt end_load            @ No existe el archivo
    
    mov r4, r0              @ fd
    
    @ read(fd, &current_map_size, 4)
    mov r0, r4
    ldr r1, =current_map_size
    mov r2, #4
    mov r7, #3              @ sys_read
    svc #0
    
    @ close(fd)
    mov r0, r4
    mov r7, #6              @ sys_close
    svc #0

end_load:
    pop {r7, pc}

.section .data
config_file: .asciz "config.bin"
msg_retry_ships: .asciz "Coordenada inválida. Intente de nuevo.\n"
