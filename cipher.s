/****************************************************************************************************************************

File        : cipher.s

Date        : Tuesday 13th November 2018

Description : Cipher essential functionality.

History     : 14/11/2018 - v1.01 - Lots of refactoring.
              13/11/2018 - v1.00

Author      : Alex H. Newark

****************************************************************************************************************************/

.data                               @ Program data
.balign 1                           @ Align to next byte.
sorted_private_key: .skip 104       @ Stores the bubble-sorted private key.
private_key: .skip 104              @ Stores the private key.
order: .skip 104                    @ Stores chars representing primary key column position orders.
column_count: .skip 1               @ Stores the number of columns in the message array.
row_count: .skip 2                  @ Stores the number of rows in the message array. Skip 2 because it's a short (2 bytes)
message_length: .skip 2             @ Stores the length of the message array. Skip 2 because it's a short. (2 bytes)
message: .skip 1000                 @ Stores the message array.
newline: .asciz "\n"                @ String format for a new line.
char_format: .asciz "%c"            @ String format to print a character.

.text @Program code.
.global main
main:
    PUSH {r4, r11}                  @ Subroutine prologue: push r4-r11 onto stack.
    PUSH {lr}                       @ Push link register (return address) to stack for preservation.

/****************************************************************************************************************************
1/4         : Parse arguments.

Registers   : r6  - Loop iterator.
              r11 - Command line arguments array (argv).   
****************************************************************************************************************************/

@ Get execution mode (argument 2)

    MOV r11, r1                     @ Move address of arguments array to r11 for future access.
    LDR r0,[r11, #4] 	              @ Move address of argument 2 (execution mode) to r0
    LDRB r0, [r0]	                  @ Move first character of argument 2 (execution mode) to r0.
    SUBS r0, r0, #48	              @ Subtract 48 (ascii position of 0) from first character and...
    LDR r1, =decrypting             @ load the address of the decrypting flag...
    STRB r0, [r1]                   @ to store it there.

@ Get private key (argument 3)

    LDR r4, [r11, #8] 	            @ Move address of argument 3 (private key) to r4.
    LDRB r5, [r4]                   @ Get the first byte of r4 (the first character.)
    MOV r6, #0                      @ Current position in arrays.
    LDR r7, =private_key            @ Load array pointers for data storage later on.
    LDR r8, =sorted_private_key     @
    LDR r9, =order                  @

parse_pk_char:                      @ This label is used for looping. From here one of many characters
                                    @ is parsed.
    CMP r5, #64		                  @ This is actually an if gt and lt.
                                    @ The easiest way to do this is to flip the lt, so it's an if gt and gt.
                                    @ Then the condition flags don't need adjustment.
                                    @ If the character is greater than ASCII 64..
    MOVGT r0, #91                   @ (load 91 for next condition, easier than comparing outright, see above.)
    CMPGT r0, r5	                  @ and less than ASCII 91... (a capital letter)
    ADDGT r5, r5, #32 	            @ add 32 (make it lower case).
                                
    CMP r5, #96                     @ Similar to above, an if gt and lt switched to if gt and gt.
    MOV r0, #123                    @ This time, the bounds (96-123) contain lower-case letters.
    CMPGT r0, r5                    @ If a character is lowercase, it's valid :)
    STRGT r5, [r7, r6]	            @ Store character in private key array.
    STRGT r5, [r8, r6]	            @ Also store in sorted private key array (to be sorted later).
    STRGT r6, [r9, r6]              @ Populate order array element. At the moment this is just 1,2,3...
                                    @ but since it's length is equal to the private key, this is a good
                                    @ place to assign it.

    ADDGT r6, r6, #1	              @ Increment r6, move to the next position in stored arrays.
    ADD r4, r4, #1                  @ r4 contains the address of the current position inside of 
                                    @ the private key string.
    LDRSB r5, [r4]                  @ Load the next character into r5.
    CMP r5, #0                      @ Compare the character with a NULL character (0).
                                    @ This is important as command line args are null-terminated.
    BGT parse_pk_char               @ If the char isn't null, there's more to go. Loop again.

    LDR r0, =column_count	          @ Temporarily grab a pointer to the column count. 
    STR r6, [r0]		                @ Store the column count.
                                    @ The column count is equal to the key length, which this iterator stops at.  

@ Get message (stdin)

    BL getchar                      @ getchar is a system function that returns the next char from stdin.
    MOV r5, r0                      @ Move the character into register 5.
    MOV r6, #0                      @ Here r6 starts to store the current position in the message array.
    LDR r10, =message               @ Load a pointer to the message array. This is wher chars will be stored.

parse_message_char:                 @ This label is used for looping.
    CMP r5, #64		                  @ Like earlier, if the character is greater than ASCII 64..
    MOVGT r0, #91
    CMPGT r0, r5	                  @ and less than ASCII 91... (a capital letter)
    ADDGT r5, r5, #32 	            @ add 32 (make it lower case).

    CMP r5, #96                     @ And again, check this character is lower case...
    MOV r0, #123                    @ 
    CMPGT r0, r5                    @
    STRGT r5, [r10, r6]	            @ If it is, store it in the message array.
    ADDGT r6, r6, #1	              @ Increment r6, move to the next position in message.

    CMP r5, #7                      @ Messages allow the character 0x7 (BELL) as a special case. This is used
                                    @ to fill the remainder of the final row. It's transparent and rare.
                                    @ so this checks if the current character is 0x7...
    STREQ r5, [r10, r6]	            @ and if it is, add it to the message array...
    ADDEQ r6, r6, #1	              @ and increment to the next position in message.

    BL getchar                      @ Get a new character in preperation for the next loop.
    MOV r5, r0                      @ Move it to register 5...
    CMP r5, #-1                     @ STDIN isn't null char terminated, it's null int (nullptr?) terminated (-1).
                                    @ So this checks if the end of the message has been reached.
    BGT parse_message_char          @ If not, loop and parse the next character.

    LDR r0, =message_length         @ Temporarily grab a pointer to the message length. 
    STRH r6, [r0]                   @ The iterator r6 currently holds the message length, so store it at the address.
    LDR r0, =row_count              @ Temporarily grab a pointer to the row count.
    LDR r1, =column_count           @ Temporarily grab a pointer to the column count. 
    LDRB r1, [r1]                   @ Load the column count into r1 from it's pointer.
    UDIV r1, r6, r1                 @ Divide the message length by column count, store in r6.
    ADD r1, r1, #1                  @ Add 1.
    STRH r1, [r0]                   @ Store the result at row count. rowCount = (messageLength & columnCount) + 1


/****************************************************************************************************************************
2/4         : Bubble Sort
****************************************************************************************************************************/

    LDR r0, =sorted_private_key     @ Grab a pointer to the sorted private key array, to pass to the bubblesort function.
    LDR r1, =column_count           @ Load a pointer to the column count...
    LDRB r1, [r1]                   @ then load the column count from it. The key length is equal to the column count.
    BL bubblesort                   @ Call bubblesort.

/****************************************************************************************************************************
3/4         : Encrypt / Decrypt

Description : This part compares the private key to the sorted key (or visa versa), and finds the changes
              necessary to replicate the changes. And also performs the changes on the order array.
              So if a private key has been bubblesorted, it can rearrange the order array matching the
              changes made during bubblesorting, or the reverse.

Registers   : r4  - compareChar.
              r5  - Outer iterator.
              r6  - Inner iterator.
              r7  - inOrder flag.
              r8  - Order array pointer.
              r9  - From array pointer.
              r10 - To array pointer.
              r11 - Column count.
****************************************************************************************************************************/

    LDR r8, =order                  @ Load order array pointer.
    LDR r0, =decrypting             @ Load decrypting flag pointer.
    LDRB r0, [r0]                   @ Load decrypting flag.
    CMP r0, #0                      @ If the decrypting flag is = (not decrypting)
    LDREQ r9, =private_key          @ Load the pointer of private_key into r9 (from array).
    LDREQ r10, =sorted_private_key  @ Load the pointer of sorted_private_key into r10 (to array).
    LDRNE r9, =sorted_private_key   @ Else, load them the other way around.
    LDRNE r10, =private_key         @
    LDR r11, =column_count          @ Load the pointer of column count into r11,
    LDRB r11, [r11]                 @ then load column count from pointer.

    MOV r5, #0                      @ r5 is an iterator for the outer loop, starting at 0.
decrypt_outer:                      @ Label used for looping.
    MOV r7, #1                      @ r7 is the 'inOrder' flag. If no changes have to be made during an inner loop,
                                    @ no further outer loops are required.
    LDRSB r4, [r10, r5]             @ Load "compareChar" from toArray[outerIterator]
    MOV r6, #0                      @ r6 is an iterator for the inner loop, starting at 0.
decrypt_inner:                      @ Label used for looping.
    LDRSB r0, [r9, r6]              @ Load char fron fromArray[innerIterator].
    CMP r0, r4                      @ if(fromArray[innerIterator] == compareChar)
    MOVEQ r7, #0                    @ Set the inOrder flag to 0, to represnet a necessary reorder.

    ADDEQ r0, r9, r6                @ Move a pointer to fromArray[outerIterator] to r0.
    ADDEQ r1, r9, r5                @ Move a pointer to fromArray[innerIterator] to r1.
    BLEQ swapbyte                   @ Use swapbyte to swap the values at both pointers.

    ADDEQ r0, r8, r5                @ Move a pointer to order[outerIterator] to r0.
    ADDEQ r1, r8, r6                @ Move a pointer to order[innerIterator] to r1.
    BLEQ swapbyte                   @ Use swapbyte to swap the values at both pointers.

    CMP r6, r11                     @ Compare the innter interator the column count,
    ADDLT r6, r6, #1                @ If it's lower, increment the iterator...
    BLT decrypt_inner               @ and loop.

    CMP r7, #1                      @ Check if the inOrder flag remains set.
    CMPLT r5, r11                   @ If it isn't (lower than 1), compare the outer iterator to the column count.
    ADDLT r5, r5, #1                @ If it's lower, increment the iterator...
    BLT decrypt_outer               @ and loop.

/****************************************************************************************************************************
3/4         : Printing the result.

Description : The message array is printed row by row. The colunns are printed in order of the contents of the order array.

Registers   : r1  - Current character.
              r2  - rowPosition + order[index]
              r3  - Row count.
              r4  - Message pointer.
              r5  - Outer iterator.
              r6  - Row position.
              r7  - Inner iterator.
              r8  - Character print format.
              r9  - Order array pointer.
              r10 - Message length.
              r11 - Column count.
****************************************************************************************************************************/

    LDR r0, =newline                @ Load the newline format string.
    BL printf                       @ Print it.

    LDR r3, = row_count             @ Load the column count pointer.
    LDRH r3, [r3]                   @ Load the column count.
    LDR r4, =message                @ Load the message pointer.
    MOV r5, #0                      @ Initialize the outer (row) iterator at 0.
    LDR r8, =char_format            @ Load the character print format pointer.
    LDR r9, =order                  @ Load the order array pointer.
    LDR r10, =message_length        @ Load the message length pointer.
    LDRH r10, [r10]                 @ Load the message length from it's pointer.
    LDR r11, =column_count          @ Load the column count pointer.
    LDRB r11, [r11]                 @ Load the column count from it's pointer.
print_row:                          @ Label used for looping.
    MUL r6, r5, r11                 @ rowPosition = outer iterator (row) * columnCount
    MOV r7, #0                      @ Initialize the inner (column) iterator at 0.
print_column:                       @ Label used for looping.
    MOV r1, #7                      @ As mentioned above, ASCII 7 is used as a substitute character.
    LDRSB r2, [r9, r7]	            @ Load column position (order[index]).
    ADD r2, r2, r6	                @ Add column position to row position.
    CMP r2, r10		                  @ If the position is less than the message length (within the message)...
    LDRLT r1, [r4, r2]            	@ Load the character at that position.

    MOV r0, r8                      @ Move the character print format for r0 as an argument...
    PUSH {r3}                       @ push r3 (row count) to the stack to preserve it's content....
    BL printf                       @ and call printf.
    POP {r3}	                      @ Pop r3 back off the stack.

    ADD r7, r7, #1                  @ Increment inner iterator.
    CMP r7, r11                     @ Compare it to the column count,
    BLT print_column                @ if it's lower, loop.

    ADD r5, r5, #1                  @ Increment the outer iterator.
    CMP r5, r3                      @ Compare it to the row count,
    BLT print_row                   @ if it's lower, loop.

    LDR r0, =newline 	              @Print a couple of new lines.
    BL printf		                    @
    LDR r0, =newline                @
    BL printf		                    @

    POP {lr}                        @ Subroutine epilogue: pop link register.
    POP {r4, r11}                   @ Pop r4-r11...
    BX lr                           @ Branch to the return address.
