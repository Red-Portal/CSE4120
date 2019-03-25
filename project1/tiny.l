%{
#include "global.h"
#include "util.h"
#include "scan.h"
    char token_string[MAXTOKENLEN + 1];
    %}

digit      [0-9]
number     {digit}+
letter     [a-zA-Z]
identifier {letter}+
newline    \n
whitespace [ \t]+

%%

"if"	     {return IF;}
"then"       {return THEN;}
"else"	     {return ELSE;}
"end"	     {return END;}
"repeat"     {return REPEAT;}
"until"	     {return UNTIL;}
"read"	     {return READ;}
"write"	     {return WRITE;}
":="	     {return ASSIGN;}
"="	     {return EQ;}
"<"	     {return LT;}
"+"	     {return PLUS;}
"-"	     {return MINUS;}
"*"	     {return TIMES;}
"/"	     {return OVER;}
"("	     {return LPAREN;}
")"	     {return RPAREN;}
";"	     {return SEMI;}
{number}     {return NUM;}
{identifier} {return ID;}
{newline}    {return lineno++;}
{whitespace} {}
"{"          {
    char c;
    do {
        c = input();
        if(c == '\n')
            lineno++;
    }while(c != '\n');
}
.             {return ERROR;}

%%

token_t next_token(void)
{
    static _Bool first_time = true;
    token_t current_token;
    if(first_time)
    {
        first_time = false;
        lineno++;
        yyin = source;
        yyout = listing;
    }
    current_token = yylex();
    strncpy(token_string, yytext, MAXTOKENLEN);
    if(trace_scan)
    {
        fprintf(listing, "\t%d: ", lineno);
        print_token(current_token, token_string);
    }
    return current_token;
}
