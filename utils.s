/************************************************************************

File        : utils.s

Date        : Thursday 15th November 2018

Description : Cipher program utilities.

History     : 13/11/2018 - v1.00

Author      : Alex H. Newark

***********************************************************************/

/************************************

Arguments   : r1: Array Pointer
              r1: Array Length

***********************************/

.global bubblesort
bubblesort:
    PUSH {r4, r11}
    PUSH {lr}

    mov r10, r0
    mov r4,r1   
    b loop      @Enter the first cycle
loop:
    mov r7,pc   @Point to the first position of the string
    MOV r7, r10
    sub r4,r4,#1
    cmp r4,#0   @R4 is compared to 0, and if r4 is equal to 0, 
                @end up,print result 
                @greater than it goes into the second cycle
    beq stop    
    mov r5,#0   
    b loop1     @The entrance to the second cycle
    b loop


loop1:

    ldrb r9,[r7]    @R1 is pointing to the memory address of the value of 
                    @the assignment to the r3 register
    ldrb r6,[r7,#1] 

    cmp r9,r6
    MOVGT r0, r7
    ADDGT r1, r7, #1
    BLGT swapbyte

    add r7,r7,#1        @R1 points to the next character
    add r5,r5,#1        
    cmp r5,r4       @r5 r4 compared
    bne loop1       @r5<r4 next loop1
    b loop          @r5=r4，Jump out of the second cycle and return to the 
                    @first cycle

stop:

    POP {lr}
    POP {r4, r11}

    BX lr

/************************************

Arguments   : r0: Byte 1 Pointer
              r1: Byte 2 Pointer

Registers   : r2: Byte 1
              r3: Byte 2

***********************************/
.global swapbyte
 swapbyte:
    PUSH {r4, r11}
    PUSH {lr}
      
    LDRB r2, [r0]
    LDRB r3, [r1]

    STRB r2, [r1]
    STRB r3, [r0]

    POP {lr}
    POP {r4, r11}

    BX lr

