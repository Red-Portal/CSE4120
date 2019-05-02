%{
#include "globals.h"
#include "util.h"
#include "scan.h"
#include "globals.h"
#include "bison.h"
    char token_string[MAXTOKENLEN + 1];
%}

digit      [0-9]
number     {digit}+
letter     [a-zA-Z]
identifier {letter}+
newline    "\n"
whitespace [ \t]+

%%
%lalr-parser

"if"          { return IF; }
"while"       { return WHILE; }
"else"        { return ELSE; }
"void"        { return VOID; }
"int"         { return INT; }
"return"      { return RETURN; }
"="           { return ASSIGN; }
"=="          { return EQ; }
">"           { return GT; }
"<"           { return LT; }
">="          { return GE; }
"<="          { return LE; }
"+"           { return PLUS; }
"-"           { return MINUS; }
"*"           { return ASTER; }
"/"           { return DIV; }
"("           { return LPAREN; }
")"           { return RPAREN; }
"["           { return LSQUARE; }
"]"           { return RSQUARE; }
"{"           { return LCURLY; }
"}"           { return RCURLY; }
","           { return COMMA; }
";"           { return SEMICOLON; }
{number}      { yylval.value = atoi(yytext);   return NUM; }
{identifier}  { yylval.name  = strdup(yytext); return ID; }
{newline}     { lineno++; }
{whitespace}  {}
"/*" {
    typedef enum {st_idle, st_aster} state_t;
    char c;
    state_t current_state = st_idle;
    do
    {
        c = input();
        switch(current_state)
        {
        case st_idle:
            if(c == '*')
                current_state = st_aster;
            else if(c == '\n')
                ++lineno;
            break;
        case st_aster:
            if(c == '/')
                return COMMENT;
            else if(c != '*')
            {
                if(c == '\n')
                    ++lineno;
                current_state = st_idle;
            }
            break;
        default:
            break;
        }
    } while(c != EOF);
    return COMMENT_ERROR;
}
. {
    fprintf(stderr, "Parse error: Wrong input syntax.\n"); 
    return ERROR;
  }

%%

TokenType getToken(void)
{
    static _Bool first_time = true;
    TokenType current_token;
    if(first_time)
    {
        if(trace_scan)
        {
            fprintf(listing, " Line     Token     Lexeme\n");
            fprintf(listing, "---------------------------\n");
        }

        first_time = false;
        lineno++;
        yyin = source;
        yyout = listing;
    }
    current_token = yylex();

    if(current_token == COMMENT_ERROR)
    {
        current_token = ERROR;
        strncpy(token_string, "Comment Error", MAXTOKENLEN);
    }
    else if(current_token == COMMENT)
    {
        return current_token;
    }
    else
    {
        strncpy(token_string, yytext, MAXTOKENLEN);
    }

    if(trace_scan)
    {
        fprintf(listing, "\t%d ", (int)lineno);
        printToken(current_token, token_string);
    }
    return current_token;
}
