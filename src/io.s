.global print_str
.global read_str
.global exit_program
.global print_char
.global print_num

.text

/* 
 * print_str
 * Entrada: R0 = Dirección de la cadena
 */
print_str:
    push {r0, r1, r2, r3, r7, lr} @ 6 regs (Aligned)
    mov r1, r0                 @ R1 = Buffer
    
    mov r2, #0                 @ R2 = Contador (longitud)
calc_len:
    ldrb r3, [r0, r2]
    cmp r3, #0
    beq do_write
    add r2, r2, #1
    b calc_len

do_write:
    mov r0, #1                 @ STDOUT
    mov r7, #4                 @ WRITE
    svc #0
    
    pop {r0, r1, r2, r3, r7, pc}

/*
 * read_str
 * Entrada: R0 = Buffer, R1 = Tamaño máximo
 */
read_str:
    push {r1, r2, r7, lr}      @ 4 regs (Aligned)
    mov r2, r1
    mov r1, r0
    mov r0, #0                 @ STDIN
    mov r7, #3                 @ READ
    svc #0
    pop {r1, r2, r7, pc}

/*
 * exit_program
 */
exit_program:
    mov r7, #1                 @ EXIT
    svc #0

/*
 * print_char
 * Entrada: R0 = Carácter
 */
print_char:
    push {r0, r1, r2, r3, r7, lr} @ 6 regs (Aligned)
    sub sp, sp, #8             @ Aligned buffer space
    strb r0, [sp]
    
    mov r0, #1                 @ STDOUT
    mov r1, sp
    mov r2, #1                 @ Length = 1
    mov r7, #4                 @ WRITE
    svc #0
    
    add sp, sp, #8
    pop {r0, r1, r2, r3, r7, pc}

/*
 * print_num
 * Prints R0 as a decimal number followed by newline.
 */
print_num:
    push {r0, r1, r2, r3, r4, r5, r7, lr} @ 8 regs (Aligned)
    sub sp, sp, #16             @ Buffer for digits
    
    mov r4, r0                  @ R4 = Number
    mov r5, sp                  @ R5 = Buffer Pointer
    add r5, r5, #15             @ Start from end
    mov r1, #0
    strb r1, [r5]               @ Null terminator? No need, we print chars.
    
    mov r1, #10
    
    cmp r4, #0
    bne loop_digits
    sub r5, r5, #1
    mov r2, #'0'
    strb r2, [r5]
    b done_digits

loop_digits:
    cmp r4, #0
    beq done_digits
    udiv r2, r4, r1             @ R2 = Num / 10
    mul r3, r2, r1              @ R3 = (Num/10)*10
    sub r3, r4, r3              @ R3 = Num % 10 (Digit)
    add r3, r3, #'0'            @ ASCII
    sub r5, r5, #1
    strb r3, [r5]
    mov r4, r2
    b loop_digits

done_digits:
    mov r0, r5                  @ String start
    bl print_str
    
    ldr r0, =newline
    bl print_str
    
    add sp, sp, #16
    pop {r0, r1, r2, r3, r4, r5, r7, pc}
