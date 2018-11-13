/************************************************************************

File        : cipher.c

Date        : Tuesday 13th November 2018

Description : Cipher essential functionality.

History     : 13/11/2018 - v1.00

Author      : Alex H. Newark

***********************************************************************/

/************************************************************************

REGISTERS:
r0: General temporary storage.
r11: argv pointer
r12: Executition Mode (0 = encrypting, 1 = decrypting)

***********************************************************************/

.data @ code section starts here
.balign 1
sorted_private_key: .skip 104
private_key: .skip 104
column_count: .skip 1
.balign 2
row_count: .skip 2
message_length: .skip 2
.balign 1
message: .skip 1000
.balign 4
test_print: .ascii "test: %c\n"

.text
.global main
main:
    PUSH {r4, r12}
    PUSH {lr}

    MOV r11, r1 	@Move address of arguments array to r11 for permanant storage.

    @LDR r0, =test_print
    LDR r0,[r11, #4] 	@Move address of argument 2 (execution mode) to r0
    @ADDS r1, r0, #4	@Move to second argument (execution mode)
    LDRSB r0, [r0]	@Move first character of second argument to r0.
    SUBS r12, r0, #44	@Subtract 44 (ascii position of 0) from first character and store permantly in r12.
    @MOV r1, r12
    @MOV r12, r1		@Move r1 to r12 for permenant storage.
    @MOV r0, r1
    @ADDS r0, r0, #4	@move r0 to the third argument (private key)
    @BL printf
    
    LDR r4, [r11, #8] 	@Move address of argument 3 (private key) to r0.
    LDRSB r5, [r4] 
    MOV r6, #0
    LDR r7, =private_key 
parse_pk_char:
    
    @LDR r0, =test_print
    @MOV r1, r5
    @BL printf
    @ADDS r4, r4, #1
    @LDRSB r5, [r4]
    @CMP r1, #-1
    @BNE parse_pk_char

    @LDR r4, [r11, #8] 	@Move address of argument 3 (private key) to r0.
    @LDRSB r5, [r4]
    @LDR r0, =test_print
    @MOV r1, r5
    @BL printf
    @ADDS r4, r4, #1
    @LDRSB r5, [r4]
    @LDR r0, =test_print
    @BL printf
    @MOV r1, r5
    @LDRSB r, [r4
    @MOV r1, r5
    @BL printf
 
    
    @Prepare reloop
    ADDS r4, r4, #1
    LDRSB r5, [r4]
    CMP r5, #0
    BGT parse_pk_char


    

    POP {lr}
    POP {r4, r12}
    BX lr

  test_branch:
    MOV r1, #7
    BL printf
    
