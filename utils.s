.global rand
.global rand_init
.global parse_coord
.global string_to_int

.section .data
seed: .long 123456789

.text

/*
 * rand_init
 * Inicializa la semilla (por ahora fija, idealmente usar tiempo).
 */
rand_init:
    push {lr}
    @ TODO: Usar syscall gettimeofday para semilla real
    pop {pc}

/*
 * rand
 * Generador de números pseudoaleatorios (LCG).
 * Salida: R0 = Número aleatorio
 */
rand:
    push {r1, r2, lr}
    ldr r1, =seed
    ldr r2, [r1]
    
    @ LCG: seed = (seed * 1103515245 + 12345)
    ldr r3, =1103515245
    mov r0, r2
    mul r2, r3, r0      @ Rd=r2, Rm=r0 (OK)
    ldr r3, =12345
    add r2, r2, r3
    
    str r2, [r1]        @ Guardar nueva semilla
    mov r0, r2          @ Retornar valor
    pop {r1, r2, pc}

/*
 * parse_coord
 * Convierte "A5" -> índice (0-99).
 * Entrada: R0 = Buffer string (ej. "A5")
 * Salida: R0 = Índice (0-99) o -1 si error.
 */
parse_coord:
    push {r1, r2, r3, lr}
    
    ldrb r1, [r0]       @ Leer Letra (Fila)
    ldrb r2, [r0, #1]   @ Leer Dígito (Columna)
    
    @ Validar Fila (A-J / a-j)
    cmp r1, #'a'
    blt check_upper
    sub r1, r1, #'a'
    b check_row_range
check_upper:
    sub r1, r1, #'A'
check_row_range:
    cmp r1, #0
    blt invalid_coord
    cmp r1, #9
    bgt invalid_coord
    
    @ Validar Columna (Hagamos un parse de hasta 2 dígitos si es necesario?)
    @ El prompt dice "A5". Si es "A15", necesitamos leer más.
    @ Ajustemos parse_coord para leer un entero de la parte numérica.
    
    sub r2, r2, #'0'
    @ Si el siguiente char es dígito, r2 = r2*10 + (char-'0')
    ldrb r3, [r0, #2]
    cmp r3, #'0'
    blt calc_final_index
    cmp r3, #'9'
    bgt calc_final_index
    
    @ Es un número de 2 dígitos (ej. 15)
    mov r3, #10
    mov r12, r2         @ Use r12 as temp
    mul r2, r12, r3     @ r2 = r2 * 10
    ldrb r3, [r0, #2]   @ r0 is the string pointer
    sub r3, r3, #'0'
    add r2, r2, r3
    b calc_final_index

calc_final_index:
    ldr r3, =current_map_size
    ldr r3, [r3]
    
    @ Validar Columna < current_map_size
    cmp r2, #0
    blt invalid_coord
    cmp r2, r3
    bge invalid_coord
    
    @ Validar Fila < current_map_size (r1 tiene la fila 0-9...)
    cmp r1, r3
    bge invalid_coord

    @ Calcular índice: Fila * current_map_size + Columna
    mov r12, r1         @ Use r12 to avoid Rd==Rm
    mul r1, r12, r3
    add r0, r1, r2
    
    pop {r1, r2, r3, pc}

invalid_coord:
    mov r0, #-1
    pop {r1, r2, r3, pc}
