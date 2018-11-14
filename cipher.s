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
order: .skip 104
column_count: .skip 1
.balign 2
row_count: .skip 2
message_length: .skip 2
.balign 1
message: .skip 1000
.balign 4
test_print: .ascii "test: %d\n"

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
    LDR r8, =sorted_private_key
    LDR r9, =order
parse_pk_char:
    @This is actually an if gt and lt.
    @The easiest way to do this is to flip the lt, so it's an if gt and gt.
    @Then the condition flags don't need adjustment.
    CMP r5, #64		@If the character is greater than ASCII 64..
    MOVGT r0, #91
    CMPGT r0, r5	@and less than ASCII 91... (a capital letter)
    ADDGT r5, r5, #32 	@add 32 (make it lower case).
    
    @Similar to above, an if gt and lt switched to if gt and gt.
    CMP r5, #96
    MOV r0, #123
    CMPGT r0, r5
    STRGT r5, [r7, r6]	@Store character in private key array.
    STRGT r5, [r8, r6]	@Also store in sorted private key array (to be sorted).
    STRGT r6, [r9, r6]  @Populate order array element
    ADDGT r6, r6, #1	@Increment r6, current pos in private key arr.

    @Prepare reloop
    ADD r4, r4, #1
    LDRSB r5, [r4]
    CMP r5, #0
    BGT parse_pk_char

    LDR r0, =column_count	@Temporarily grab a pointer to col count.
    STRH r6, [r0]		@Store col count.

    @test print pk
    @LDR r0, =private_key 
    @BL printf

    BL getchar
    MOV r5, r0
    MOV r6, #0
    LDR r10, =message
parse_message_char:

    CMP r5, #64		@If the character is greater than ASCII 64..
    MOVGT r0, #91
    CMPGT r0, r5	@and less than ASCII 91... (a capital letter)
    ADDGT r5, r5, #32 	@add 32 (make it lower case).

    CMP r5, #96
    MOV r0, #123
    CMPGT r0, r5
    STRGT r5, [r10, r6]	@Store character in private key array.
    ADDGT r6, r6, #1	@Increment r6, current pos in private key arr.

    @Prepare reloop
    BL getchar
    MOV r5, r0
    CMP r5, #-1
    BGT parse_message_char

    @test print msg
    @LDR r0, =message
    @BL printf

    LDR r0, =message_length
    STRH r6, [r0]
    LDR r0, =row_count
    LDR r1, =column_count
    LDRSB r1, [r1]
    UDIV r1, r6, r1
    ADD r1, r1, #1
    STRH r1, [r0]

    POP {lr}
    POP {r4, r12}
    BX lr
    
