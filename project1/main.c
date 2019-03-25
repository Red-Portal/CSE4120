
#include <stdio.h>
#include <stdlib.h>

#include "globals.h"
#include "scan.h"

size_t lineno = 0;
_Bool trace_scan = true;

FILE* source;
FILE* listing;
FILE* code;

extern token_t next_token(void);

int main(int argc, char** argv)
{
    char filename[20];
    if(argc != 2)
    {
        fprintf(stderr, "usage: %s <filename>\n", argv[0]);
        exit(1);
    }
    strcpy(filename, argv[1]);
    if(strchr(filename, '.') == NULL)
        strcat(filename, ".tny"); 
    source = fopen(filename, "r");
    if(source == NULL)
    {
        fprintf(stderr, "File %s not found!\n", filename);
        exit(1);
    }
    listing = stdout;

    while(true) 
    {
        token_t token = next_token();
        if(token == COMMENT)
            continue;
        else if(token == 0)
            break;
        else if(token == ERROR)
            continue;
    }
}
