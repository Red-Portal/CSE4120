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
    case ASSIGN:    return "=";
    case EQ:        return "==";
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
        t->is_array  = false;
        t->kind.stmt = kind;
        t->lineno    = lineno;
        t->nodekind  = StmtK;
        t->sibling   = NULL;
        t->type      = VOID;
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
        for (i=0;i<MAXCHILDREN;i++)
            t->child[i] = NULL;
        t->is_array = false;
        t->kind.exp = kind;
        t->lineno   = lineno;
        t->nodekind = ExpK;
        t->sibling  = NULL;
        t->type     = VOID;
    }
    return t;
}

void destroyNode(TreeNode* node)
{
    if(node == NULL)
        return;

    if((node->nodekind == StmtK
        && node->kind.stmt == VarK)
       || (node->nodekind == ExpK
           && node->kind.exp == IdK))
    {
        free(node->attr.name);
        node->attr.name = NULL;
    }

    if(node->sibling != NULL)
    {
        destroyNode(node->sibling);
        node->sibling = NULL;
    }

    for(size_t i = 0; i < MAXCHILDREN; ++i)
    {
        destroyNode(node->child[i]);
        node->child[i] = NULL;
    }
    free(node);
    node = NULL;
}

static size_t indentno = 0;
#define INDENT indentno+=2
#define UNINDENT indentno-=2

static void printSpaces(void)
{
    for (size_t i = 0; i < indentno; ++i)
        fprintf(listing," ");
}


void printTree(TreeNode* tree)
{
    INDENT;
    while (tree != NULL)
    {
        printSpaces();
        if (tree->nodekind == StmtK)
        {
            switch (tree->kind.stmt) {
            case IfK:
                fprintf(listing,"if statement\n");
                break;
            case RepeatK:
                fprintf(listing,"repeat statement\n");
                break;
            case AssignK:
                fprintf(listing,"assignment statement\n");
                break;
            case VarK:
                fprintf(listing,"variable declaration statement\n");
                printSpaces();
                fprintf(listing," * name: %s\n", tree->attr.name);
                printSpaces();
                fprintf(listing," * type: %s\n", serializeToken(tree->type));
                if(tree->is_array)
                {
                    printSpaces();
                    fprintf(listing," * array size: %d\n", tree->value);
                }
                break;
            case FunK:
                fprintf(listing,"function declaration statement\n");
                printSpaces();
                fprintf(listing," * name: %s\n", tree->attr.name);
                printSpaces();
                fprintf(listing," * return type: %s\n", serializeToken(tree->type));
                break;
            case CmpdK:
                fprintf(listing,"compound statement\n");
                break;
            case RetK:
                fprintf(listing,"return statement\n");
                break;
            default:
                fprintf(listing,"Unknown kind of statement\n");
                break;
            }
        }
        else if (tree->nodekind == ExpK)
        {
            switch (tree->kind.exp)
            {
            case OpK:
                fprintf(listing, "operation: %s\n", serializeToken(tree->attr.op));
                break;
            case ConstK:
                fprintf(listing, "constant: %d\n", tree->value);
                break;
            case IdK:
                fprintf(listing,"id: %s\n", tree->attr.name);
                break;
            case CallK:
                fprintf(listing, "call: %s\n", tree->attr.name);
                break;
            default:
                fprintf(listing,"Unknown kind of expression\n");
                break;
            }
        }
        else
            fprintf(listing,"Unknown kind of node\n");

        for (size_t i = 0; i < MAXCHILDREN; ++i)
            printTree(tree->child[i]);

        tree = tree->sibling;
    }
    UNINDENT;
}
