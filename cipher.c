/************************************************************************

File        : cipher.c

Date        : Tuesday 13th November 2018

Description : Cipher essential functionality.

History     : 13/11/2018 - v1.00

Author      : Alex H. Newark

***********************************************************************/

#include <stdio.h>
#include <stdlib.h>

#include "cipher.h"

// Stores the bubble sorted private key, an arrau pf 104 characters.
static char sortedPrivateKey[104];
// Stores the private key, an array of 104 characters.
static char privateKey[104];
/* Stores the column count, which is equal to the length of
    the primary key, and therefore 104 maximum. This can
    be stored in a char (byte) as chars have a maximum of 255. */
static char columnCount;
/* Stores the column count, which is equal to the length of the message
    divided by the row count. This must be stored in a short (word) as
    it's maximum is over 255, the limit of a char. */
static short rowCount;
/* Stores the length of the message, which has a maximum of 1000,
    so must also be stored as a short (word) */
static short messageLength;
/* Stores the message as an array of 1000 characters. */
static char message[1000];
/*Stores the read order of the messages's columns, as an array of
  characters. Each character represents one column, and has a
  numeric value representing it's order value. EG

  order: 2, 3, 1
  array: a, b, c

  would produce the output:
  c, a, b */
static char order[104];

int main(int argc, char *argv[]) 
{
    //
    //  Parse the Command Line Arguments and STDIN.
    //

    /*Argc represents the argument count.
    The first argument is always the name of the executable.
    And two additional arguments are used, 0/1 (encrypt/decrypt) and the private key.
    So the argument count should be 3.*/
    if (argc != 3) {
        return EXIT_FAILURE;
    }

    /*Argument 1 should be a character, 0 or 1 to represent the execution mode.
    Character '0' is ascii 48, so subtracting 48 from the character will return 0
    if the character is '0'. Similarly, '1' is 49, therefore 49-48 = 1.*/
    char decrypting = argv[1][0] - 48;

    //Command line argument index, private key index, parsingPrimaryKey flag.    
    char claIndex = 0, pkIndex = 0;

    //The primary key is argument 3 (index 2).
    char* claPK = argv[2];
    char pkChar = claPK[claIndex];

    //While the private key is still being parsed.
    /*Command line arguments are NULL terminated. A null char is 0.
    Therefore, if the current character is 0, the end of the private key
    has been reached.*/
    while(pkChar != 0) {

        //If the maximum private key size has been reached, break.
        if(pkIndex > 103) {
            break;
        }

        //If the current character is inbetween ASCII 64 and 91 (A-Z)...
        if(pkChar > 64 && pkChar < 91) {
            //Add 32 (lower case characters are 32 greater than upper case.)
            pkChar = pkChar + 32;
        }

        //If the current character is inbetween ASCII 96 and 123 (a-z)
        if(pkChar > 96 && pkChar < 123) {
            //Add it to the private key array.
            privateKey[pkIndex] = pkChar;
            //Also add it to the sorted private key array, for now this is
            //just a clone of the private key array.
            sortedPrivateKey[pkIndex] = pkChar;
            //Also add to the order array (0, 1, 2, 3...)
            order[pkIndex] = pkIndex;
            //Incremene to the next position in the private key array.
            pkIndex++;
        }

        //Increment to the next position in the command line argument
        //private key character array.
        claIndex++;

        //Get the next character in the cla private key.
        pkChar = claPK[claIndex];
    }

    //The column count is equal to the current private key character index.
    columnCount = pkIndex;
    
    //The current position in the message array.
    short messageIndex = 0;
    //Flag 
    char parsingMessage = 1;
    char messageChar = getchar();

    while(messageChar != -1) {

        //If the message array is full, break and ignore the rest.
        if(messageIndex > 999) {
            break;
        }

        //Similar to above:
        //If the current character is a capital letter...
        if(messageChar > 64 && messageChar < 91) {
            //Change it to lower case.
            messageChar = messageChar + 32;
        }

        //If the character is a lower case letter OR an ASCII substitute...
        //Substitute represents leftover space in a row.
        if((messageChar > 96 && messageChar < 123) || messageChar == 0x1A) {
            //Add the character to the message array.
            message[messageIndex] = messageChar;
            //Move to the next position...
            messageIndex++;
        }

        //Get the next character and restart the loop.
        messageChar = getchar();
    }

    //The message length is equal to the current position.
    messageLength = messageIndex;
    //The amount of rows in the message array is equal to the length of the message,
    //divided by the amount of columns, +1 for the remainder.
    rowCount = (messageLength / columnCount) + 1;
    
    //
    //  Encrypy /Decrypt.
    //

    //BUBBLE SORT
    //This sorts the sortedPrivateKey...
    //Outer loop
    for(char loopIndex = 0; loopIndex < columnCount; loopIndex++) {
        //This flag is used to break early, if no further changes are required.
        char inOrder = 1;
        //Inner loop
        for(char compareIndex = 0; compareIndex < columnCount - 1; compareIndex++) {
            //If the current character is greater in value than the following character,
            //swap them!
            if(sortedPrivateKey[compareIndex] > sortedPrivateKey[compareIndex + 1]) {
                swap(&sortedPrivateKey[compareIndex], &sortedPrivateKey[compareIndex + 1]);

                //If encrypting, swap elements in the order array too.
                if(!decrypting) {
                    swap(&order[compareIndex], &order[compareIndex + 1]);
                }
                //If a change was required, the key is not yet in order.
                inOrder = 0;
            }
        }
        if(inOrder) break;
    }

    //If decrypting...
    if(decrypting) {
        //Outer loop
        for(char sortedIndex = 0; sortedIndex < columnCount; sortedIndex++) {
            //Another break early flag, identical to the one used in the sort loops above.
            char inOrder = 1;
            //The unsorted character is what the character should be, if the key wasn't sorted.
            char unsortedChar = privateKey[sortedIndex];
            //Inner loop
            for(char compareIndex = sortedIndex; compareIndex < columnCount; compareIndex++) {
                //If the character from the inner loop is equal to the unsorted character...
                if(sortedPrivateKey[compareIndex] == unsortedChar) {
                    //Swap it, with the current character, to bring it to where it should be.
                    swap(&sortedPrivateKey[sortedIndex], &sortedPrivateKey[compareIndex]);
                    //Also ammend the order array so that the print order is corrected.
                    swap(&order[sortedIndex], &order[compareIndex]);
                    inOrder = 0;
                }
            }
            if(inOrder) break;
        }
    } 

    //
    //  Now print the result...
    //

    //Print a newline.
    printf("\n");

    //For each row...
    for(short row = 0; row < rowCount; row++) {
        //The row position is equal to the current row index multiplied by the amount of columns.
        short rowPosition = row * columnCount;
        //For each column (in order).
        for(char index = 0; index < columnCount; index++) {
            /*The default character is 0x1A, this represents an ASCII substitute.
               I chose this character as it's rarer than an x.*/
            char elementChar = 0x1A;
            /*Get the character in the message at the element:
                row*columnCount (to get to the right row)
                    + 
                order[index] (to get characters in the desired order.)*/
            if(rowPosition + order[index] < messageLength) {
                //If the end of the message hasn't been reached, get the current character.
                elementChar = message[rowPosition + order[index]];
            }
            //Print the character.
            printf("%c", elementChar);
        }
    }

    //Print a couple of newlines for spacing.
    printf("\n\n");

    
    return EXIT_SUCCESS;
}

//Swaps value of two characters.
void swap(char* a, char* b)
{
    //Temporarily store character A so that it isn't lost when overwritten.
    char temporary = *a;
    //set A to B
    *a = *b;
    //Since A is now B, A must be retrieved from the temporary value.
    *b = temporary;
}

/**********************************************************************/
