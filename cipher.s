/************************************************************************

File        : cipher.c

Date        : Tuesday 13th November 2018

Description : Cipher essential functionality.

History     : 13/11/2018 - v1.00

Author      : Alex H. Newark

***********************************************************************/

.data @ code section starts here
.balign 4
sorted_private_key: .skip 104
private_key: .skip 104
order: .skip 104
decrypting: .skip 1
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

    LDR r0,[r11, #4] 	@Move address of argument 2 (execution mode) to r0
    LDRB r0, [r0]	@Move first character of second argument to r0.
    SUBS r0, r0, #48	@Subtract 44 (ascii position of 0) from first character and store permantly in r12.
    LDR r1, =decrypting
    STRB r0, [r1]
    
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

    CMP r5, #0x7
    STREQ r5, [r10, r6]	@Store character in private key array.
    ADDEQ r6, r6, #1	@Increment r6, current pos in private key arr.

    @Prepare reloop
    BL getchar
    MOV r5, r0
    CMP r5, #-1
    BGT parse_message_char

    @test print msg
    @LDR r0, =test_format
    @LDR r1, =order
    @BL printf

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
    @LDR r0, =test_format
    @LDR r1, =sorted_private_key
    @BL printf

    @test print msg
    @LDR r0, =test_format
    @LDR r1, =order
    @BL printf

    @REGISTERS
    @r4: compareChar
    @r5: Outer iterator
    @r6: Inner iterator
    @r7: inOrder
    @r8: order
    @r9: from array
    @r10: to array
    @r11: column count

    LDR r8, =order
    LDR r0, =decrypting
    LDRB r0, [r0]
    CMP r0, #0
    LDREQ r9, =private_key
    LDREQ r10, =sorted_private_key
    LDRNE r9, =sorted_private_key
    LDRNE r10, =private_key
    LDR r11, =column_count
    LDRB r11, [r11]

    MOV r5, #0 @outerIterator
  decrypt_outer:
    MOV r7, #1 @inOrder
    LDRSB r4, [r10, r5] @compareChar
    MOV r6, #0 @innerIterator
  decrypt_inner:
    LDRSB r0, [r9, r6] @fromArray[innerIterator]
    CMP r0, r4 @if(fromArray[innerIterator] == compareChar) {
    MOVEQ r7, #0 @inOrder = 0

    ADDEQ r0, r9, r6 @swap chars
    ADDEQ r1, r9, r5
    BLEQ swapbyte

    ADDEQ r0, r8, r5 @swap order
    ADDEQ r1, r8, r6
    BLEQ swapbyte

    CMP r6, r11
    ADDLT r6, r6, #1
    BLT decrypt_inner

    CMP r7, #1
    CMPLT r5, r11
    ADDLT r5, r5, #1
    BLT decrypt_outer

    LDR r0, =newline
    BL printf

    @REGISTERS
    @r1: current character
    @r2: rowPosition + order[index]
    @r3: row count
    @r4: message
    @r5: outer iterator
    @r6: row position
    @r7: inner iterator
    @r8: character format
    @r9: order
    @r10: message length
    @r11: column count

    LDR r3, = row_count
    LDRH r3, [r3]
    LDR r4, =message
    MOV r5, #0		@row
    LDR r8, =char_format
    LDR r9, =order
    LDR r10, =message_length
    LDRH r10, [r10]
    LDR r11, =column_count
    LDRB r11, [r11]
print_row:
    MUL r6, r5, r11 	@get rowPosition
    MOV r7, #0		@index
print_column:
    MOV r1, #0x7	@default character.
    LDRSB r2, [r9, r7]	@get order[index] 
    ADD r2, r2, r6	@rowPosition + order[index]
    CMP r2, r10		@if(rowPosition + order[index] < messageLength)
    LDRLT r1, [r4, r2] 	@currentCharacter = message[rowPosition + order[index]]

    MOV r0, r8
    PUSH {r3} @preserve r3 from the print. I noticed this was being lost.
    BL printf
    POP {r3}	

    ADD r7, r7, #1
    CMP r7, r11
    BLT print_column

    ADD r5, r5, #1
    CMP r5, r3
    BLT print_row

    LDR r0, =newline 	
    BL printf		
    LDR r0, =newline
    BL printf		

    POP {lr}
    POP {r4, r12}
    BX lr
