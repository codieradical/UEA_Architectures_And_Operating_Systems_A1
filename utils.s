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

Registers   : r5  - Outer loop iterator.
              r6  - Inner loop iterator.
              r7  - inOrder flag.
              r10 - Array pointer.
              r11 - Array length.
****************************************************************************************************************************/

.text

.global bubblesort                  @ void bubblesort(char* string, char length)
bubblesort:
    PUSH {r4, r11}                  @ Subroutine prologue: preserve registers on stack.
    PUSH {lr}                       @ Preserve return address.

    MOV r10, r0
    MOV r11, r1
    MOV r5, #0                      @ Initialize outer loop iterator.
outer_loop:
    MOV r7, #1                      @ Initialize inOrder flag.
    MOV r5, #0                      @ Initialize inner loop iterator.
inner_loop:
    MOV r0, [r10, r6]               @ Move string[innerIterator] to r0.
    ADD r2, r6, #1                  @ Move innerIterator + 1 to r2.
    MOV r1, [r10, r2]               @ Move string[innerIterator + 1] to r1.
    CMP r0, r1                      @ Compare the characters. if(string[innerIterator] > string[innerIterator + 1],,,
    ADDGT r0, r10, r6               @ calculate &string[innerIterator] pointer, move to r0...
    ADDGT r1, r10, r2               @ calculate &string[innerIterator + 1], pointer, move to r1...
    MOVGT r7, #0                    @ set inOrder flag to 0...
    BGT swapbyte                    @ and swap the bytes.

    SUB r0, r11, #1                 @ r0 = length - 1
    CMP r6, r2                      @ if innerIterator < length - 1...
    ADDLT r6, #1                    @ increment the inner iterator...
    BLT inner_loop                  @ and loop.

    CMP r7, #1                      @ Check the inOrder flag.
    CMPLT r5, r11                   @ If it's not set, check outerIterator < length,
    ADDLT r5, #1                    @ if true, increment the outer iterator,
    BLT outer_loop                  @ and loop.

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
