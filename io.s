.global print_str
.global read_str
.global exit_program
.global print_char
.global print_num

.text

/* 
 * print_str
 * Imprime una cadena terminada en nulo (ASCIZ) a STDOUT.
 * Entrada: R0 = Dirección de la cadena
 */
print_str:
    push {r0, r1, r2, r7, lr}  @ Guardar registros
    mov r1, r0                 @ R1 = Buffer (dirección de la cadena)
    
    @ Calcular longitud de la cadena
    mov r2, #0                 @ R2 = Contador (longitud)
calc_len:
    ldrb r3, [r0, r2]          @ Cargar byte de [R0 + R2]
    cmp r3, #0                 @ ¿Es nulo?
    beq do_write               @ Si es 0, terminar
    add r2, r2, #1             @ Incrementar longitud
    b calc_len

do_write:
    mov r0, #1                 @ R0 = STDOUT (1)
    mov r7, #4                 @ R7 = Syscall WRITE (4)
    svc #0                     @ Llamada al sistema
    
    pop {r0, r1, r2, r7, pc}   @ Restaurar registros y retornar

/*
 * read_str
 * Lee caracteres de STDIN hasta un salto de línea o buffer lleno.
 * Entrada: R0 = Buffer, R1 = Tamaño máximo
 * Salida: R0 = Número de bytes leídos
 */
read_str:
    push {r1, r2, r7, lr}
    mov r2, r1                 @ R2 = Tamaño máximo
    mov r1, r0                 @ R1 = Buffer
    mov r0, #0                 @ R0 = STDIN (0)
    mov r7, #3                 @ R7 = Syscall READ (3)
    svc #0
    pop {r1, r2, r7, pc}

/*
 * exit_program
 * Finaliza la ejecución del programa.
 * Entrada: R0 = Código de salida
 */
exit_program:
    mov r7, #1                 @ R7 = Syscall EXIT (1)
    svc #0

/*
 * print_char
 * Imprime un solo carácter.
 * Entrada: R0 = Carácter (ASCII)
 */
print_char:
    push {r0, r1, r2, r7, lr}
    sub sp, sp, #4             @ Reservar espacio en stack para el char
    strb r0, [sp]              @ Guardar byte en stack
    
    mov r0, #1                 @ STDOUT
    mov r1, sp                 @ Dirección del buffer (stack)
    mov r2, #1                 @ Longitud = 1
    mov r7, #4                 @ WRITE
    svc #0
    
    add sp, sp, #4             @ Restaurar stack
    pop {r0, r1, r2, r7, pc}
