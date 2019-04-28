%{
#define YYPARSER

#include "globals.h"
#include "util.h"
#include "scan.h"
#include "parse.h"
#include <string.h>

#define YYSTYPE TreeNode*

int yyerror(char* message);
static int yylex(void);

static char* saved_name;
static int saved_lineno;
static int saved_value;
static TreeNode* saved_tree;
%}

%token IF
%token WHILE
%token ELSE
%token RETURN
%token VOID
%token INT
%token ID
%token NUM
%token ASSIGN
%token EQ
%token NE
%token LT
%token LE
%token GT
%token GE
%token PLUS
%token MINUS
%token ASTER
%token DIV
%token LPAREN
%token RPAREN
%token LSQUARE
%token RSQUARE
%token LCURLY
%token RCURLY
%token SEMICOLON
%token COLON
%token COMMENT
%token ERROR
%token COMMENT_ERROR

%%

prog: decl_list { saved_tree = $1; };

decl_list:
                decl_list decl {
                    YYSTYPE t = $1;
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
                type_spec ID {
                    saved_name   = strdup(identifier);
                    saved_lineno = lineno;
                }
                SEMICOLON {
                    $$            = newStmtNode(VarK);
                    $$->attr.name = saved_name;
                    $$->type      = $1->type;
                    $$->lineno    = saved_lineno;
                    free($1);
                }
        |       type_spec ID {
                    saved_name   = strdup(identifier);
                    saved_lineno = lineno;
                }
                LSQUARE NUM       { saved_value = atoi(token_string); }
                RSQUARE SEMICOLON {
                    $$            = newStmtNode(VarK);
                    $$->attr.name = strdup(token_string);
                    $$->val       = saved_value;
                    $$->type      = $1->type;
                    $$->lineno    = saved_lineno;
                    free($1);
                };
type_spec:
                INT  {
                    $$       = newExpNode(TypeK);
                    $$->type = Integer;
                }
        |       VOID {
                    $$       = newExpNode(TypeK);
                    $$->type = Void;
                };

fun_decl:
                type_spec ID {
                    saved_name   = strdup(identifier);
                    saved_lineno = lineno;
                }
                LPAREN params RPAREN compound_stmt {
                    $$ = newStmtNode(FunK);
                    $$->attr.name = saved_name;
                    $$->lineno    = saved_lineno;
                    $$->type      = $1->type; 
                    $$->child[0]  = $5;
                    $$->child[1]  = $7;
                    free($1);
                };

params:
                param_list { $$ = $1; }
        |       VOID { $$ = NULL; };

param_list:
                param_list COLON param {
                    YYSTYPE t = $1;
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
                    $$->attr.name = strdup(identifier);
                    $$->type      = $1->type;
                    $$->lineno    = lineno;
                    free($1);
                }
        |       type_spec ID {
                    saved_name   = strdup(identifier);
                    saved_lineno = lineno;
                }
                LSQUARE RSQUARE {
                    $$            = newStmtNode(VarK);
                    $$->attr.name = saved_name;
                    $$->type      = $1->type;
                    $$->lineno    = saved_lineno;
                    free($1);
                };

compound_stmt:
                LCURLY local_decl stmt_list RCURLY {
                    $$           = newStmtNode(CmpdK);
                    $$->child[0] = $2;
                    $$->child[1] = $3;
                };

local_decl:
                %empty { $$ = NULL; }
        |       local_decl var_decl {
                    YYSTYPE t = $1;
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
                    YYSTYPE t = $1;
                    if(t != NULL) {
                        while(t->sibling != NULL)
                            t = t->sibling;
                        t->sibling = $2;
                        $$ = $1;
                    } else {
                        $$ = $2;
                    }
                };

stmt:           expr_stmt      { $$ = $1; }
        |       compound_stmt  { $$ = $1; }
        |       selection_stmt { $$ = $1; }
        |       iteration_stmt { $$ = $1; }
        |       return_stmt    { $$ = $1; }
        |       error          { $$ = NULL; };

selection_stmt:
                IF LPAREN expr RPAREN stmt ELSE stmt
                {
                    $$           = newStmtNode(IfK); 
                    $$->lineno   = lineno;
                    $$->child[0] = $3;
                    $$->child[1] = $5;
                    $$->child[2] = $7;
                };
        |       IF LPAREN expr RPAREN stmt
                {
                    $$           = newStmtNode(IfK); 
                    $$->lineno   = lineno;
                    $$->child[0] = $3;
                    $$->child[1] = $5;
                }

iteration_stmt:
                WHILE LPAREN expr RPAREN stmt {
                    $$           = newStmtNode(RepeatK); 
                    $$->lineno   = lineno;
                    $$->child[0] = $3;
                    $$->child[1] = $5;
                };
return_stmt:
                RETURN SEMICOLON {
                    $$ = newStmtNode(RetK); 
                }
        |       RETURN expr SEMICOLON {
                    $$           = newStmtNode(RetK); 
                    $$->lineno   = lineno;
                    $$->child[0] = $2;
                };

expr_stmt:
                expr SEMICOLON { $$ = $1; }
        |       SEMICOLON { $$ = NULL; };

expr:
                var ASSIGN expr {
                    $$           = newStmtNode(AssignK); 
                    $$->lineno   = lineno;
                    $$->child[0] = $1;
                    $$->child[1] = $3;
                }
        |       simple_expr { $$ = $1; };

var:
                ID {
                    $$            = newExpNode(IdK);
                    $$->attr.name = strdup(identifier);
                    $$->lineno    = lineno;
                }
        |       ID {
                    saved_name = strdup(identifier);
                }
                LSQUARE expr RSQUARE {
                    $$            = newExpNode(IdK); 
                    $$->lineno    = lineno;
                    $$->attr.name = saved_name;
                    $$->child[0]  = $4;
                };
simple_expr:
                additive_expr relop additive_expr {
                    $$           = newExpNode(OpK); 
                    $$->type     = Boolean;
                    $$->lineno   = lineno;
                    $$->child[0] = $1;
                    $$->child[1] = $2;
                    $$->child[2] = $3;
                }
        |       additive_expr { $$ = $1; };

relop:
                LT {
                    $$ = newExpNode(OpK); 
                    $$->attr.op = LT;
                }
        |       LE {
                    $$ = newExpNode(OpK); 
                    $$->attr.op = LE;
                }
        |       GT {
                    $$ = newExpNode(OpK); 
                    $$->attr.op = GT;
                }
        |       GE {
                    $$ = newExpNode(OpK); 
                    $$->attr.op = GE;
                }
        |       EQ {
                    $$ = newExpNode(OpK); 
                    $$->attr.op = EQ;
                }
        |       NE {
                    $$ = newExpNode(OpK); 
                    $$->attr.op = NE;
                };

additive_expr:
                additive_expr addop term {
                    $$           = newExpNode(OpK); 
                    $$->lineno   = lineno;
                    $$->type     = Integer;
                    $$->child[0] = $1;
                    $$->child[1] = $2;
                    $$->child[2] = $3;
                }
        |       term { $$ = $1; };

addop:
                PLUS {
                    $$          = newExpNode(OpK); 
                    $$->attr.op = PLUS;
                }
        |       MINUS {
                    $$          = newExpNode(OpK); 
                    $$->attr.op = MINUS;
                };

term:
                term mulop factor {
                    $$            = newExpNode(OpK); 
                    $$->attr.op   = $1->attr.op;
                    $$->type      = Integer;
                    $$->child[0]  = $1;
                    $$->child[1]  = $2;
                    $$->child[2]  = $3;
                }
        |       factor { $$ = $1; };

mulop:
                ASTER {
                    $$          = newExpNode(OpK); 
                    $$->attr.op = MINUS;
                }
        |       DIV {
                    $$          = newExpNode(OpK); 
                    $$->attr.op = MINUS;
                };

factor:
                LPAREN expr RPAREN { $$ = $2; }
        |       var                { $$ = $1; }
        |       call               { $$ = $1; }
        |       NUM                {
                    $$      = newExpNode(ConstK); 
                    $$->val = atoi(token_string);
                };

call:
                ID { saved_name = strdup(identifier); }
                LPAREN args RPAREN {
                    $$            = newExpNode(CallK); 
                    $$->lineno    = lineno;
                    $$->attr.name = saved_name;
                    $$->child[0]  = $4;
                };

args:
                %empty    { $$ = NULL; }
        |       args_list { $$ = $1; };

args_list:
                args_list COLON expr {
                    YYSTYPE t = $1;
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
int yyerror(char* message)
{
    fprintf(listing, "Syntax error at line %zd: %s\n", lineno, message);
    fprintf(listing, "Current Token: ");
    printToken(yychar, token_string);
    error = true;
    return 0;
}

static int yylex(void)
{
    TokenType token;
    do
    {
        token = getToken();
    } while(token == COMMENT);
    return token;
}

TreeNode* parse(void)
{
    yyparse();
    return saved_tree;
}




