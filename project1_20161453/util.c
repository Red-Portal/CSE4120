
#include "util.h"

char const*
serialize_token(token_t token)
{
#define SERIALIZE_CASE(TOKEN) case TOKEN: return #TOKEN ;
    
    switch(token)
    {
        SERIALIZE_CASE(IF);
        SERIALIZE_CASE(ELSE);
        SERIALIZE_CASE(VOID);
        SERIALIZE_CASE(RETURN);
        SERIALIZE_CASE(INT);
        SERIALIZE_CASE(ASSIGN);
        SERIALIZE_CASE(EQ);
        SERIALIZE_CASE(GT);
        SERIALIZE_CASE(LT);
        SERIALIZE_CASE(GE);
        SERIALIZE_CASE(LE);
        SERIALIZE_CASE(PLUS);
        SERIALIZE_CASE(MINUS);
        SERIALIZE_CASE(ASTER);
        SERIALIZE_CASE(DIV);
        SERIALIZE_CASE(LPAREN);
        SERIALIZE_CASE(RPAREN);
        SERIALIZE_CASE(LSQUARE);
        SERIALIZE_CASE(RSQUARE);
        SERIALIZE_CASE(LCURLY);
        SERIALIZE_CASE(RCURLY);
        SERIALIZE_CASE(COLON);
        SERIALIZE_CASE(SEMICOLON);
        SERIALIZE_CASE(NUM);
        SERIALIZE_CASE(ID);
        SERIALIZE_CASE(ERROR);
    case EOF_TOKEN:
        return "EOF";
    default:
        break;
    }
    return "Unknown";
}

void print_token(token_t token,
                 char const* token_string)
{
    char const* serialized = serialize_token(token);
    fprintf(listing, "%-9s %s\n", serialized, token_string);
}
