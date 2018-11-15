/************************************************************************

File        : utils.c

Date        : Wednesday 14th November 2018

Description : Cipher program utilities.

History     : 14/11/2018 - v1.00

Author      : Alex H. Newark

***********************************************************************/

#include "utils.h"

void bubbleSort(char* string, char length) {
    //BUBBLE SORT
    //This sorts the sortedPrivateKey...
    //Outer loop
    for(char outerIterator = 0; outerIterator < length; outerIterator++) {
        //This flag is used to break early, if no further changes are required.
        char inOrder = 1;
        //Inner loop
        for(char innerIterator = 0; innerIterator < length - 1; innerIterator++) {
            //If the current character is greater in value than the following character,
            //swap them!
            if(string[innerIterator] > string[innerIterator + 1]) {
                swap(&string[innerIterator], &string[innerIterator + 1]);

                //If a change was required, the key is not yet in order.
                inOrder = 0;
            }
        }
        if(inOrder) break;
    }
}

//Swaps the value at two pointers.
void swap(char* aPtr, char* bPtr)
{
    //Temporarily store character A so that it isn't lost when overwritten.
    char temporary = *aPtr;
    //set A to B
    *aPtr = *bPtr;
    //Since A is now B, A must be retrieved from the temporary value.
    *bPtr = temporary;
}