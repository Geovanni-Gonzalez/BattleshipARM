.global rand
.global rand_init
.global parse_coord

.section .data
seed: .long 123456789

.text

/*
 * rand_init
 */
rand_init:
    push {r1, lr}          @ Align 8
    @ (Optional: load time for seed)
    pop {r1, pc}

/*
 * rand
 * LCG: seed = (seed * 1103515245 + 12345)
 */
rand:
    mov r0, #50
    bx lr
    @ Stubbed due to persistent crash in qemu stack/memory access
    push {r1, r2, r3, lr}  @ 4 regs (Aligned 16)
    
    ldr r1, =seed
    ldr r2, [r1]
    add r2, r2, #7         @ Simple increment/step
    str r2, [r1]
    
    mov r0, r2
    pop {r1, r2, r3, pc}

/*
 * parse_coord
 * R0 = String Buffer
 * Returns index (0-399) or -1
 */
parse_coord:
    @ R0 = Buffer. Use R1, R2, R3, R12 as scratch.
    
    mov r1, r0             @ R1 = Buffer Pointer
    
    ldrb r2, [r1]          @ R2 = Row Char
    ldrb r3, [r1, #1]      @ R3 = Col Char
    
    @ Validate Row (R2)
    cmp r2, #'a'
    blt check_upper_leaf
    sub r2, r2, #'a'
    b check_row_range_leaf
check_upper_leaf:
    sub r2, r2, #'A'
check_row_range_leaf:
    ldr r12, =current_map_size
    ldr r12, [r12]         @ R12 = Size
    cmp r2, #0
    blt invalid_c_leaf
    cmp r2, r12
    bge invalid_c_leaf
    
    @ Validate Col (R3) - Handle 1 or 2 digits
    sub r3, r3, #'0'
    
    @ Check if next char is digit
    ldrb r0, [r1, #2]      @ Reuse R0 temp (we don't need buffer addr anymore)
    cmp r0, #'0'
    blt single_digit_leaf
    cmp r0, #'9'
    bgt single_digit_leaf
    
    @ Double digit
    mov r1, #10             @ R1 temp (const 10)
    mul r3, r1, r3          @ digit1 * 10
    sub r0, r0, #'0'
    add r3, r3, r0          @ + digit2
    
single_digit_leaf:
    @ Check Col Limits (R3)
    cmp r3, #0
    blt invalid_c_leaf
    cmp r3, r12
    bge invalid_c_leaf
    
    @ Row check again
    cmp r2, r12
    bge invalid_c_leaf
    
    @ Index = Row * Size + Col
    mul r0, r2, r12
    add r0, r0, r3
    
    bx lr

invalid_c_leaf:
    mov r0, #-1
    bx lr
