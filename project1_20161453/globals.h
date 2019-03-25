
#ifndef _GLOBALS_H_
#define _GLOBALS_H_

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <stdbool.h>

#define MAXRESERVED 8
#define EOF_TOKEN 0

typedef enum
{
    FILEEND,
    ERROR,
    IF,
    ELSE,
    RETURN,
    VOID,
    INT,
    ID,
    NUM,
    ASSIGN,
    EQ,
    NE,
    LT,
    LE,
    GT,
    GE,
    PLUS,
    MINUS,
    ASTER,
    DIV,
    LPAREN,
    RPAREN,
    LSQUARE,
    RSQUARE,
    LCURLY,
    RCURLY,
    SEMICOLON,
    COLON,
    COMMENT,
    COMMENT_ERROR,
} token_t;

extern FILE*  source;
extern FILE*  listing;
extern FILE*  code;
extern size_t lineno;

extern _Bool trace_scan;

#endif
