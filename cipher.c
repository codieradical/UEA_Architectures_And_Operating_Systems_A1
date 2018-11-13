/************************************************************************

File        : cipher.c

Date        : Tuesday 13th November 2018

Description : Cipher essential functionality.

History     : 13/11/2018 - v1.00

Author      : Alex H. Newark

***********************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static char privateKey[104];
static char rowSize;

enum executionModeFlags {
    Encrypting = 0, 
    Decrypting = 1
};

int main(int argc, char *argv[]) 
{
    if (argc != 3) {
        printf("Error: Invalid argument count.\n");
        return EXIT_FAILURE;
    }

    unsigned int executionMode = Encrypting;

    if (sscanf(argv[1], "%i", &executionMode) != 1 | executionMode > 1) {
        printf("Error: Unknown execution mode. Expected 0 or 1, got \"%s\".\n", argv[1]);
        return EXIT_FAILURE;
    }

    // The primary key could be up to 1000 characters long, but that'd be overkill.
    
    char claIndex = 0, pkIndex = 0, parsingPK = 1;

    while(parsingPK) {
        char* claPK = argv[2];
        char pkChar = claPK[claIndex];

        if(claPK[claIndex] == (char)NULL) {
            if(claIndex < 2) {
                printf("Error: Private key is too short. Must be more than 2 characters.");
                return EXIT_FAILURE;
            }
            parsingPK = 0;
        }

        if(pkIndex > 103) {
            printf("Error: Private key is too long. Must be less than 105 characters.");
            return EXIT_FAILURE;
        }

        if(pkChar >  64 && pkChar < 91) {
            pkChar = pkChar + 32;
        }

        if(pkChar > 96 && pkChar < 123) {
            privateKey[pkIndex] = pkChar;
            pkIndex++;
        }

        claIndex++;
    }
    

    printf("%s", privateKey);
    
    return EXIT_SUCCESS;
}

/**********************************************************************/
