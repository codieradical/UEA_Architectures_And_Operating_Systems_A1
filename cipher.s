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
.balign 4
sorted_private_key: .skip 104
private_key: .skip 104
order: .skip 104
column_count: .skip 1
row_count: .skip 2
message_length: .skip 2
message: .skip 1000
newline: .asciz "\n"
char_format: .asciz "%c"
test_format: .asciz "test: %d\n"
test_format2: .asciz "test: %c\n"

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
    STR r6, [r0]		@Store col count.

    @test print pk
    @LDR r0, =private_key 
    @BL printf

    @test print order
    LDR r0, =test_format
    LDR r1, =order
    LDRSB r1, [r1]
    BL printf
    LDR r0, =test_format
    LDR r1, =order
    LDRSB r1, [r1, #1]
    BL printf
    LDR r0, =test_format
    LDR r1, =order
    LDRSB r1, [r1, #2]
    BL printf
    LDR r0, =test_format
    LDR r1, =order
    LDRSB r1, [r1, #3]
    BL printf
    LDR r0, =test_format
    LDR r1, =order
    LDRSB r1, [r1, #4]
    BL printf
    LDR r0, =test_format
    LDR r1, =order
    LDRSB r1, [r1, #5]
    BL printf

    @test print sorted
    LDR r0, =test_format2
    LDR r1, =sorted_private_key
    LDRSB r1, [r1]
    BL printf
    LDR r0, =test_format2
    LDR r1, =sorted_private_key
    LDRSB r1, [r1, #1]
    BL printf
    LDR r0, =test_format2
    LDR r1, =sorted_private_key
    LDRSB r1, [r1, #2]
    BL printf
    LDR r0, =test_format2
    LDR r1, =sorted_private_key
    LDRSB r1, [r1, #3]
    BL printf
    LDR r0, =test_format2
    LDR r1, =sorted_private_key
    LDRSB r1, [r1, #4]
    BL printf
    LDR r0, =test_format2
    LDR r1, =sorted_private_key
    LDRSB r1, [r1, #5]
    BL printf

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

    CMP r5, #0x1A
    STREQ r5, [r10, r6]	@Store character in private key array.
    ADDEQ r6, r6, #1	@Increment r6, current pos in private key arr.

    @Prepare reloop
    BL getchar
    MOV r5, r0
    CMP r5, #-1
    BGT parse_message_char

    @test print msg
    LDR r0, =test_format
    LDR r1, =order
    BL printf

    LDR r0, =message_length
    STRH r6, [r0]
    LDR r0, =row_count
    LDR r1, =column_count
    LDRSB r1, [r1]
    UDIV r1, r6, r1
    ADD r1, r1, #1
    STRH r1, [r0]


    @test print msg
    @LDR r0, =sorted_private_key
    @BL printf

    LDR r0, =sorted_private_key
    LDR r1, =column_count
    LDRB r1, [r1]
    BL bubblesort

    @test print msg
    LDR r0, =test_format
    LDR r1, =sorted_private_key
    @BL printf

    @test print msg
    LDR r0, =test_format
    LDR r1, =order
    BL printf

    LDR, r8, =order
    CMP r12, #1 
    LDREQ r9, =sorted_private_key
    LDREQ r10, =private_key
    LDRNE r10, =sorted_private_key
    LDRNE r9, =private_key

    MOV r5, #0
  decrypt_outer:
    MOV r7, #1
    LDRSB r4, [r10, r5]
    MOV r6, #0
  decrypt_inner:
    LDRSB r0, [r9, r6]
    CMP r0, r4
    STREQ r4, [r9, r6]
    STREQ r0, [r10, r5]
    MOVEQ r7, #1
    PUSHEQ {r0, r3}
    ADDEQ r0, r8, r5
    ADDEQ r1, r8, r6
    BLEQ swapChar
    POPEQ {r0, r3}

    CMP r6, r3
    ADDLT r6, r6, #1
    BLT decrypt_inner

    CMP r7, #1
    CMPLT r5, r3
    ADDLT r5, r5, #1
    BLT decrypt_outer
 

    @test print order
    LDR r0, =test_format
    LDR r1, =order
    LDRSB r1, [r1]
    BL printf
    LDR r0, =test_format
    LDR r1, =order
    LDRSB r1, [r1, #1]
    BL printf
    LDR r0, =test_format
    LDR r1, =order
    LDRSB r1, [r1, #2]
    BL printf
    LDR r0, =test_format
    LDR r1, =order
    LDRSB r1, [r1, #3]
    BL printf
    LDR r0, =test_format
    LDR r1, =order
    LDRSB r1, [r1, #4]
    BL printf
    LDR r0, =test_format
    LDR r1, =order
    LDRSB r1, [r1, #5]
    BL printf

    @test print sorted
    LDR r0, =test_format2
    LDR r1, =sorted_private_key
    LDRSB r1, [r1]
    BL printf
    LDR r0, =test_format2
    LDR r1, =sorted_private_key
    LDRSB r1, [r1, #1]
    BL printf
    LDR r0, =test_format2
    LDR r1, =sorted_private_key
    LDRSB r1, [r1, #2]
    BL printf
    LDR r0, =test_format2
    LDR r1, =sorted_private_key
    LDRSB r1, [r1, #3]
    BL printf
    LDR r0, =test_format2
    LDR r1, =sorted_private_key
    LDRSB r1, [r1, #4]
    BL printf
    LDR r0, =test_format2
    LDR r1, =sorted_private_key
    LDRSB r1, [r1, #5]
    BL printf

    LDR r0, =newline
    @BL printf

    LDR r0, =char_format
    LDR r4, =message
    LDR r10, =message_length
    LDRH r10, [r10]
    MOV r5, #0		@row
print_row:
    MUL r6, r5, r3 	@get rowPosition
    MOV r7, #0		@index
print_column:
    @LDR r0, =test_format
    @LDRSB r1, [r9, r7]
    @BL printf

    MOV r1, #0x7	@default character.
    LDRSB r8, [r9, r7]	@get order[index] 
    ADD r8, r8, r6	@
    CMP r8, r10
    
    LDRLT r1, [r4, r8]
    LDR r0, =char_format
    BL printf	

    
    LDR r3, =column_count
    LDRSB r3, [r3]

    ADD r7, r7, #1
    CMP r7, r3
    BLT print_column

    LDR r2, =row_count
    LDRH r2, [r2]
    ADD r5, r5, #1
    CMP r5, r2
    BLT print_row

    LDR r0, =newline 	
    BL printf		
    LDR r0, =newline
    BL printf		

    POP {lr}
    POP {r4, r12}
    BX lr