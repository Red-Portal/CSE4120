
#include <stdio.h>
#include <stdlib.h>

#include "globals.h"
#include "scan.h"
#include "util.h"
#include "parse.h"

size_t lineno = 0;
_Bool trace_scan  = false;
_Bool trace_parse = true;
_Bool error       = false;

FILE* source;
FILE* listing;
FILE* code;

extern TokenType next_token(void);

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

    TreeNode* syntax_tree = parse();
    if (trace_parse) {
        fprintf(listing,"\nSyntax tree:\n");
        printTree(syntax_tree);
    }
}

