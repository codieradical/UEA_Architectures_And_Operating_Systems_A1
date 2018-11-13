/************************************************************************

File        : cipher.c

Date        : Tuesday 13th November 2018

Description : Cipher essential functionality.

History     : 13/11/2018 - v1.00

Author      : Alex H. Newark

***********************************************************************/

#include <stdio.h>
#include <stdlib.h>

static char privateKey[104];
static char rowSize, columnSize;
static short messageLength;
static char message[1000];
static char order[104];

void printMessage() {
    
    printf("\n%s\n\n", privateKey);

    for(short i = 0; i < messageLength; i++)
    {
        printf("%c", message[i]);

        if((i + 1) % rowSize == 0) {
            printf("\n");
        }
    }

    printf("\n\n");
}

void encrypt() {

    printMessage();

    // for(char i = 0; i < rowSize; i++) {
    //     char
    // }
    
}

void decrypt() {
    printMessage();
}

int main(int argc, char *argv[]) 
{
    if (argc != 3) {
        printf("Error: Invalid argument count.\n");
        return EXIT_FAILURE;
    }

    char encrypting = argv[1][0] - 48;

    // The primary key could be up to 1000 characters long, but that'd be overkill.
    
    char claIndex = 0, pkIndex = 0, parsingPK = 1;

    while(parsingPK) {
        char* claPK = argv[2];
        char pkChar = claPK[claIndex];

        if(claPK[claIndex] == 0) {
            if(pkIndex < 3) {
                printf("Error: Private key is too short. Must be more than 2 characters.\n");
                return EXIT_FAILURE;
            }
            parsingPK = 0;
        }

        if(pkIndex > 103) {
            printf("Error: Private key is too long. Must be less than 105 characters.\n");
            return EXIT_FAILURE;
        }

        if(pkChar > 64 && pkChar < 91) {
            pkChar = pkChar + 32;
        }

        if(pkChar > 96 && pkChar < 123) {
            privateKey[pkIndex] = pkChar;
            pkIndex++;
        }

        claIndex++;
    }

    rowSize = pkIndex;
    
    short messageIndex = 0;
    char parsingMessage = 1;

    while(parsingMessage) {
        char messageChar = getchar();

        if(messageIndex > 999) {
            printf("Error: Message is too long. Must be less than or equal to 1000 characters.");
            return EXIT_FAILURE;
        }

        if(messageChar == -1) {
            if(messageIndex < 2) {
                printf("Error: Please provide a message.\n");
                return EXIT_FAILURE;
            }
            parsingMessage = 0;
        }

        if(messageChar > 64 && messageChar < 91) {
            messageChar = messageChar + 32;
        }

        if(messageChar > 96 && messageChar < 123) {
            message[messageIndex] = messageChar;
            messageIndex++;
        }
    }

    messageLength = messageIndex;
    columnSize = (messageLength / rowSize) + 1;
    

    if(encrypting) {
        encrypt();
    } else {
        decrypt();
    }

    
    return EXIT_SUCCESS;
}


/**********************************************************************/
