/************************************************************************

File        : cipher.c

Date        : Tuesday 13th November 2018

Description : Cipher essential functionality.

History     : 13/11/2018 - v1.00

Author      : Alex H. Newark

***********************************************************************/

#include <stdio.h>
#include <stdlib.h>

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

    printf("%s", argv[1]);
    printf("%c", executionMode);
    
    return EXIT_SUCCESS;
}

/**********************************************************************/
