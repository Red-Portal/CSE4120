/****************************************************/
/* File: util.c                                     */
/* Utility function implementation                  */
/* for the TINY compiler                            */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

#include "globals.h"
#include "util.h"

char const*
serializeToken(TokenType token)
{
#define SERIALIZE_CASE(TOKEN) case TOKEN: return #TOKEN ;
    
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
    case SEMICOLON: return ";";
    case COMMA:     return ",";
        return "EOF";
    default:
        break;
    }
    return "Unknown";
}

void printToken( TokenType token, const char* tokenString )
{
    char const* serialized = serializeToken(token);
    fprintf(listing, "%-9s %s\n", serialized, tokenString);
}

TreeNode* newStmtNode(StmtKind kind)
{
    TreeNode* t = (TreeNode *) malloc(sizeof(TreeNode));
    if (t==NULL)
        fprintf(listing,"Out of memory error at line %zd\n",lineno);
    else
    {
        for (size_t i = 0; i < MAXCHILDREN; ++i)
            t->child[i] = NULL;
        t->sibling = NULL;
        t->nodekind = StmtK;
        t->kind.stmt = kind;
        t->lineno = lineno;
    }
    return t;
}

TreeNode* newExpNode(ExpKind kind)
{
    TreeNode* t = (TreeNode*)malloc(sizeof(TreeNode));
    int i;
    if (t==NULL)
        fprintf(listing, "Out of memory error at line %zd\n", lineno);
    else
    {
        for (i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;
        t->sibling = NULL;
        t->nodekind = ExpK;
        t->kind.exp = kind;
        t->lineno = lineno;
        t->type = Void;
    }
    return t;
}

/* Variable indentno is used by printTree to
 * store current number of spaces to indent
 */
static size_t indentno = 0;

/* macros to increase/decrease indentation */
#define INDENT indentno+=2
#define UNINDENT indentno-=2

/* printSpaces indents by printing spaces */
static void printSpaces(void)
{
    for (size_t i = 0; i < indentno; ++i)
        fprintf(listing," ");
}

/* procedure printTree prints a syntax tree to the 
 * listing file using indentation to indicate subtrees
 */
void printTree( TreeNode * tree )
{
    INDENT;
    while (tree != NULL)
    {
        printSpaces();
        if (tree->nodekind == StmtK)
        {
            switch (tree->kind.stmt) {
            case IfK:
                fprintf(listing,"If\n");
                break;
            case RepeatK:
                fprintf(listing,"Repeat\n");
                break;
            case AssignK:
                fprintf(listing,"Assign to: %s\n",tree->attr.name);
                break;
            case VarK:
                fprintf(listing,"Variable: %s\n",tree->attr.name);
                break;
            case FunK:
                fprintf(listing,"Function: %s\n", tree->attr.name);
                break;
            case CmpdK:
                fprintf(listing,"Compound Statement\n");
                break;
            case RetK:
                fprintf(listing,"Return Statement\n");
                break;
            default:
                fprintf(listing,"Unknown statement kind\n");
                break;
            }
        }
        else if (tree->nodekind == ExpK)
        {
            switch (tree->kind.exp)
            {
            case OpK:
                fprintf(listing,"Op: ");
                printToken(tree->attr.op,"\0");
                break;
            case ConstK:
                fprintf(listing,"Const: %d\n", tree->val);
                break;
            case IdK:
                fprintf(listing,"id: %s\n",tree->attr.name);
                break;
            case CallK:
                fprintf(listing,"Call: %s\n",tree->attr.name);
                break;
            default:
                fprintf(listing,"Unknown ExpNode kind\n");
                break;
            }
        }
        else
            fprintf(listing,"Unknown node kind\n");

        for (size_t i = 0; i < MAXCHILDREN; ++i)
            printTree(tree->child[i]);
        tree = tree->sibling;
    }
    UNINDENT;
}
