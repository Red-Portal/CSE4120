/****************************************************/
/* File: globals.h                                  */
/* Global types and vars for TINY compiler          */
/* must come before other include files             */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

#ifndef _GLOBALS_H_
#define _GLOBALS_H_

#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

#define MAXRESERVED 8

typedef enum 
{
    IF = 258,
    WHILE = 259,
    ELSE = 260,
    RETURN = 261,
    ASSIGN = 262,
    EQ = 263,
    NE = 264,
    LT = 265,
    LE = 266,
    GT = 267,
    GE = 268,
    PLUS = 269,
    MINUS = 270,
    ASTER = 271,
    DIV = 272,
    LPAREN = 273,
    RPAREN = 274,
    LSQUARE = 275,
    RSQUARE = 276,
    LCURLY = 277,
    RCURLY = 278,
    SEMICOLON = 279,
    COMMA = 280,
    COMMENT = 281,
    ERROR = 282,
    COMMENT_ERROR = 283,
    VOID = 284,
    INT = 285,
    ID = 286,
    NUM = 287
} TokenType;

extern FILE* source; /* source code text file */
extern FILE* listing; /* listing output text file */
extern FILE* code; /* code text file for TM simulator */
extern size_t lineno; /* source line number for listing */

typedef enum { StmtK, ExpK } NodeKind;
typedef enum { IfK, RepeatK, AssignK, VarK, FunK, CmpdK, RetK } StmtKind;
typedef enum { OpK, ConstK, IdK, CallK } ExpKind;

//typedef enum { Void, Integer} ExpType;

#define MAXCHILDREN 3

typedef struct treeNode
{
    struct treeNode* child[MAXCHILDREN];
    struct treeNode* sibling;
    int lineno;
    NodeKind nodekind;
    union { StmtKind stmt; ExpKind exp;} kind;
    union { TokenType op; char* name; } attr;
    TokenType type;
    int value;
    _Bool is_array;
} TreeNode;

/**************************************************/
/***********   Flags for tracing       ************/
/**************************************************/

extern _Bool echo_source;
extern _Bool trace_scan;
extern _Bool trace_parse;
extern _Bool error;

#define YYTOKENTYPE TokenType

#endif
