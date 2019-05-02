%{
#define YYPARSER

#include "globals.h"
#include "util.h"
#include "scan.h"
#include "parse.h"
#include <string.h>

int yyerror(char const* message);
static int yylex(void);
static TreeNode* saved_tree;
%}

%union {
    int value;
    char* name;
    TreeNode* node;
    TokenType type;
}

%token IF WHILE ELSE RETURN ASSIGN EQ NE LT LE GT GE PLUS MINUS ASTER
%token DIV LPAREN RPAREN LSQUARE RSQUARE LCURLY RCURLY SEMICOLON COMMA
%token COMMENT ERROR COMMENT_ERROR
%token <type> VOID INT
%token <name> ID
%token <value> NUM
%type  <type> type_spec relop addop mulop
%type  <node> prog decl_list decl var_decl fun_decl params param_list 
%type  <node> param compound_stmt local_decl stmt_list stmt expr_stmt 
%type  <node> selection_stmt iteration_stmt return_stmt expr var 
%type  <node> simple_expr additive_expr term factor call args args_list

%define parse.error verbose

%destructor { free($$); } <name>
%destructor { destroyNode($$); } <node>
%destructor {} <>

%start start

%%

start: prog          

prog: decl_list { saved_tree = $1; };

decl_list:
                decl_list decl {
                    TreeNode* t = $1;
                    if(t != NULL) {
                        while(t->sibling != NULL)
                            t = t->sibling;
                        t->sibling = $2;
                        $$ = $1;
                    } else {
                        $$ = $2;
                    }
                }
        |       decl { $$ = $1; };

decl:
                var_decl { $$ = $1; }
        |       fun_decl { $$ = $1; };

var_decl:
                type_spec ID SEMICOLON {
                    TreeNode* t  = newStmtNode(VarK);
                    t->type      = $1;
                    t->attr.name = $2;
                    t->lineno    = lineno;
                    t->is_array  = false;
                    $$           = t;
                }
        |       type_spec ID LSQUARE NUM RSQUARE SEMICOLON {
                    TreeNode* t  = newStmtNode(VarK);
                    t->type      = $1;
                    t->attr.name = $2;
                    t->value     = $4;
                    t->lineno    = lineno;
                    t->is_array  = true;
                    $$           = t;
                };

type_spec:
                INT  { $$ = INT; } 
        |       VOID { $$ = VOID; };

fun_decl: 
                type_spec ID LPAREN params RPAREN compound_stmt {
                    TreeNode* t  = newStmtNode(FunK);
                    t->lineno    = lineno;
                    t->type      = $1;
                    t->attr.name = $2;
                    t->child[0]  = $4;
                    t->child[1]  = $6;
                    $$           = t;
                };

params:
                param_list { $$ = $1; }
        |       VOID       { $$ = NULL; };

param_list:
                param_list COMMA param {
                    TreeNode* t = $1;
                    if(t != NULL) {
                        while(t->sibling != NULL)
                            t = t->sibling;
                        t->sibling = $3;
                        $$ = $1;
                    } else {
                        $$ = $3;
                    }
                }
        |       param { $$ = $1; };

param:
                type_spec ID {
                    TreeNode* t  = newStmtNode(VarK);
                    t->type      = $1;
                    t->attr.name = $2;
                    t->lineno    = lineno;
                    t->is_array  = false;
                    $$           = t;
                }
        |       type_spec ID LSQUARE RSQUARE {
                    TreeNode* t  = newStmtNode(VarK);
                    t->type      = $1;
                    t->attr.name = $2;
                    t->lineno    = lineno;
                    t->is_array  = true;
                    $$           = t;
                };

compound_stmt:
                LCURLY local_decl stmt_list RCURLY {
                    TreeNode* t = newStmtNode(CmpdK);
                    t->child[0] = $2;
                    t->child[1] = $3;
                    $$          = t;
                };

local_decl:
                %empty { $$ = NULL; }
        |       local_decl var_decl {
                     TreeNode* t = $1;
                     if(t != NULL) {
                         while(t->sibling != NULL)
                             t = t->sibling;
                         t->sibling = $2;
                         $$ = $1;
                     } else {
                         $$ = $2;
                     }
                };

stmt_list:
                %empty { $$ = NULL; }
        |       stmt_list stmt {
                    TreeNode* t = $1;
                    if(t != NULL) {
                        while(t->sibling != NULL)
                            t = t->sibling;
                        t->sibling = $2;
                        $$ = $1;
                    } else {
                        $$ = $2;
                    }
                };

stmt:
                expr_stmt      { $$ = $1; }
        |       compound_stmt  { $$ = $1; }
        |       selection_stmt { $$ = $1; }
        |       iteration_stmt { $$ = $1; }
        |       return_stmt    { $$ = $1; }
        |       error          { $$ = NULL; };

selection_stmt:
                IF LPAREN expr RPAREN stmt ELSE stmt
                {
                    TreeNode* t = newStmtNode(IfK); 
                    t->lineno   = lineno;
                    t->child[0] = $3;
                    t->child[1] = $5;
                    t->child[2] = $7;
                    $$     = t;
                };
        |       IF LPAREN expr RPAREN stmt
                {
                    TreeNode* t = newStmtNode(IfK); 
                    t->lineno   = lineno;
                    t->child[0] = $3;
                    t->child[1] = $5;
                    $$     = t;
                }

iteration_stmt:
                WHILE LPAREN expr RPAREN stmt {
                    TreeNode* t = newStmtNode(RepeatK); 
                    t->lineno   = lineno;
                    t->child[0] = $3;
                    t->child[1] = $5;
                    $$          = t;
                };
return_stmt:
                RETURN SEMICOLON {
                    TreeNode* t = newStmtNode(RetK); 
                    t->lineno   = lineno;
                    $$          = t;
                }
        |       RETURN expr SEMICOLON {
                    TreeNode* t = newStmtNode(RetK); 
                    t->lineno   = lineno;
                    t->child[0] = $2;
                    $$          = t;
                };

expr_stmt:
                expr SEMICOLON { $$ = $1; }
        |       SEMICOLON      { $$ = NULL; };

expr:
                var ASSIGN expr {
                    TreeNode* t = newStmtNode(AssignK); 
                    t->lineno   = lineno;
                    t->child[0] = $1;
                    t->child[1] = $3;
                    $$          = t;
                }
        |       simple_expr { $$ = $1; };

var:
                ID {
                    TreeNode* t  = newExpNode(IdK);
                    t->attr.name = $1; 
                    t->lineno    = lineno;
                    $$           = t;
                }
        |       ID LSQUARE expr RSQUARE {
                    TreeNode* t  = newExpNode(IdK); 
                    t->lineno    = lineno;
                    t->attr.name = $1;
                    t->child[0]  = $3;
                    $$           = t;
                };
simple_expr:
                additive_expr relop additive_expr {
                    TreeNode* t = newExpNode(OpK); 
                    t->lineno   = lineno;
                    t->attr.op  = $2;
                    t->child[0] = $1;
                    t->child[1] = $3;
                    $$          = t;
                }
        |       additive_expr { $$ = $1; };

relop:
                LT { $$  = LT; }
        |       LE { $$  = LE; }
        |       GT { $$  = GT; }
        |       GE { $$  = GE; }
        |       EQ { $$  = EQ; }
        |       NE { $$  = NE; };

additive_expr:
                additive_expr addop term {
                    TreeNode* t = newExpNode(OpK); 
                    t->lineno   = lineno;
                    t->attr.op  = $2;
                    t->child[0] = $1;
                    t->child[1] = $3;
                    $$          = t;
                }
        |       term { $$ = $1; };

addop:
                PLUS  { $$ = PLUS; }
        |       MINUS { $$ = MINUS; };

term:
                term mulop factor {
                    TreeNode* t = newExpNode(OpK); 
                    t->attr.op   = $2;
                    t->child[0]  = $1;
                    t->child[1]  = $3;
                    $$           = t;
                }
        |       factor { $$ = $1; };

mulop:
                ASTER { $$ = ASTER; }
        |       DIV   { $$ = DIV;   };

factor:
                LPAREN expr RPAREN { $$ = $2; }
        |       var                { $$ = $1; }
        |       call               { $$ = $1; }
        |       NUM                {
                    TreeNode* t  = newExpNode(ConstK); 
                    t->lineno    = lineno;
                    t->value     = $1;
                    t->attr.name = NULL;
                    $$           = t;
                };

call:
                ID LPAREN args RPAREN {
                    TreeNode* t  = newExpNode(CallK); 
                    t->lineno    = lineno;
                    t->attr.name = $1;
                    t->child[0]  = $3;
                    $$           = t;
                };

args:
                %empty    { $$ = NULL; }
        |       args_list { $$ = $1; };

args_list:
                args_list COMMA expr {
                    TreeNode* t = $1;
                    if(t != NULL) {
                        while(t->sibling != NULL)
                            t = t->sibling;
                        t->sibling = $3;
                        $$ = $1;
                    } else {
                        $$ = $3;
                    }
                }
        |       expr { $$ = $1; };

%%
int yyerror(char const* message)
{
    fprintf(listing, "Syntax error at line %zd: %s\n", lineno, message);
    error = true;
    return 0;
}

static int yylex(void)
{
    TokenType token;
    do {  token = getToken(); } while(token == COMMENT);
    return token;
}

TreeNode* parse(void)
{
    yyparse();
    return saved_tree;
}




