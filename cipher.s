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
sorted_primary_key: .skip 104
primary_key: .skip 104
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

    MOV r11, r1

    LDR r0, =test_print
    LDR r12,[r11, #4] 	@Move address of argv to r0
    @ADDS r1, r0, #4	@Move to second argument (execution mode)
    LDRSB r12, [r12]	@Move first character of second string to r1.
    SUBS r12, r12, #44
    MOV r1, r12
    @MOV r12, r1		@Move r1 to r12 for permenant storage.
    @MOV r0, r1
    @ADDS r0, r0, #4	@move r0 to the third argument (private key)
    BL printf

    
    @LDR r1, [r11, #8]
    

    POP {lr}
    POP {r4, r12}
    BX lr
    
