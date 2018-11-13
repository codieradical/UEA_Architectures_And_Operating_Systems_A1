/************************************************************************

File        : cipher.c

Date        : Tuesday 13th November 2018

Description : Cipher essential functionality.

History     : 13/11/2018 - v1.00

Author      : Alex H. Newark

***********************************************************************/

.text @ code section starts here
.balign 1
sorted_primary_key: .skip 104
primary_key: .skip 104
column_count: .skip 1
row_count: .skip 1
messafe_length: .skip 1
message: .skip 1000

.balign 4
.global main
main:
    PUSH r4, r12
    MOV r1, #3      @move immediate into r1
    ADDS r0,r1,#2   @r0=r1+immediate
    BX lr           @ return summation result to OS
    
