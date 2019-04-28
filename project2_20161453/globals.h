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

struct treeNode;

/* typedef enum
   {
   FILEEND,
   ERROR,
   IF,
   WHILE,
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
   } TokenType; */

extern FILE* source; /* source code text file */
extern FILE* listing; /* listing output text file */
extern FILE* code; /* code text file for TM simulator */
extern size_t lineno; /* source line number for listing */

typedef enum { StmtK, ExpK } NodeKind;
typedef enum { IfK, RepeatK, AssignK, VarK, FunK, CmpdK, RetK } StmtKind;
typedef enum { OpK, ConstK, IdK, CallK, TypeK } ExpKind;

typedef enum { Void, Integer, Boolean } ExpType;

#define MAXCHILDREN 3

typedef struct treeNode
{
    struct treeNode* child[MAXCHILDREN];
    struct treeNode* sibling;
    int lineno;
    NodeKind nodekind;
    union { StmtKind stmt; ExpKind exp;} kind;
    union { int op; char* name; } attr;
    int val;
    ExpType type;
} TreeNode;

/**************************************************/
/***********   Flags for tracing       ************/
/**************************************************/

extern _Bool echo_source;
extern _Bool trace_scan;
extern _Bool trace_parse;
extern _Bool error;

#define YYSTYPE TreeNode*
#include "bison.h"

typedef enum yytokentype TokenType;

#endif
