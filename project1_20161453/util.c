
#include "util.h"

char const*
serialize_token(token_t token)
{
#define SERIALIZE_CASE(TOKEN) case TOKEN: return #TOKEN;
    switch(token)
    {
        SERIALIZE_CASE(IF);
        SERIALIZE_CASE(ELSE);
        SERIALIZE_CASE(VOID);
        SERIALIZE_CASE(RETURN);
        SERIALIZE_CASE(INT);
        SERIALIZE_CASE(NUM);
        SERIALIZE_CASE(ID);
        SERIALIZE_CASE(ERROR);
    case ASSIGN:    return "==";
    case EQ:        return "=";
    case GT:        return ">";
    case LT:        return "<";
    case GE:        return ">=";
    case LE:        return "<=";
    case PLUS:      return "+";
    case MINUS:     return "-";
    case ASTER:     return "*";
    case DIV:       return "/";
    case LPAREN:    return "(";
    case RPAREN:    return ")";
    case LSQUARE:   return "[";
    case RSQUARE:   return "]";
    case LCURLY:    return "{";
    case RCURLY:    return "}";
    case COLON:     return ":";
    case SEMICOLON: return ";";
    case COMMA:     return ",";
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
