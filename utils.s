/****************************************************************************************************************************

File        : utils.s

Date        : Thursday 15th November 2018

Description : Cipher program utilities.

History     : 13/11/2018 - v1.00

Author      : Alex H. Newark

****************************************************************************************************************************/

/****************************************************************************************************************************
bubblesort

Arguments   : r0  - Array pointer.
              r1  - Array length. 
****************************************************************************************************************************/

.text

.global bubblesort                  @ void bubblesort(char* string, char length)
bubblesort:
    PUSH {r4, r11}                  @ Subroutine prologue: preserve registers on stack.
    PUSH {lr}                       @ Preserve return address.

    mov r10, r0                     
    mov r4,r1   
    b loop                          @Enter the first cycle
loop:
    mov r7,pc                       @Point to the first position of the string
    MOV r7, r10
    sub r4,r4,#1
    cmp r4,#0                       @R4 is compared to 0, and if r4 is equal to 0, 
                                    @end up,print result 
                                    @greater than it goes into the second cycle
    beq stop    
    mov r5,#0   
    b loop1                         @The entrance to the second cycle
    b loop


loop1:

    ldrb r9,[r7]                    @R1 is pointing to the memory address of the value of 
                                    @the assignment to the r3 register
    ldrb r6,[r7,#1] 

    cmp r9,r6
    MOVGT r0, r7
    ADDGT r1, r7, #1
    BLGT swapbyte

    add r7,r7,#1                    @R1 points to the next character
    add r5,r5,#1        
    cmp r5,r4                       @r5 r4 compared
    bne loop1                       @r5<r4 next loop1
    b loop                          @r5=r4，Jump out of the second cycle and return to the 
                                    @first cycle

stop:

    POP {lr}                        @ Pop return address.
    POP {r4, r11}                   @ Pop registers from stack.

    BX lr                           @ Return to return address.

/****************************************************************************************************************************
swapbyte

Arguments   : r0  - Byte 1 pointer.
              r1  - Byte 2 pointer.

Registers   : r2  - Byte 1.
              r3  - Byte 2.
****************************************************************************************************************************/

.global swapbyte                    @ void swapbyte(char* aPtr, char* bPtr)
 swapbyte:
    PUSH {r4, r11}                  @ Subroutine prologue: preserve registers on stack.
    PUSH {lr}                       @ Preserve return address.
      
    LDRB r2, [r0]                   @ Load the values in byte 1,
    LDRB r3, [r1]                   @ and byte 2.

    STRB r2, [r1]                   @ Store the value of byte 2 at byte 1,
    STRB r3, [r0]                   @ and the value of byte 1 at byte 2.

    POP {lr}                        @ Pop return address.
    POP {r4, r11}                   @ Pop registers from stack.

    BX lr                           @ Return to return address.
