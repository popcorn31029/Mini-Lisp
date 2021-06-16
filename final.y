%{
#include<iostream>
#include<string>
#include <map>
using namespace std;
int yylex(void);
void yyerror(const char *message);

    
struct Node{
    char op;
    int val;
    int isDefineFun;
    char* name;
    Node *left;
    Node *right;
    Node *mid;
};
 
int isEqual;
int equalnum;
int first;
int recur = 0;
int isDefine = 0;
int isFun = 0;
int mapswitch = 0;

map<string, int> myDeclare;
//variables for function
map<string, int> myDecforFun;
map<string, Node*> myDecid;
map<string, Node*> myDecexp;
map<string, int>::iterator iter;

struct Node* root = NULL;
struct Node* funid = NULL;
struct Node* funexp = NULL;
Node* CreateNode(Node*,Node*,char);

void Traversal(Node*);
int Add(Node*);
int Sub(Node*);
int Multiply(Node*);
int Divide(Node*);
int Modules(Node*);
int AndOperand(Node*);
int OrOperand(Node*);
int GreatOperand(Node*);
int SmallOperand(Node*);
int EqualOperand(Node*);
void Bind(Node*, Node*);
%}

%union {
int val;
int boolval;
char* strval;
struct Node *node;
}

%token PRINT_NUM PRINT_BOOL MOD AND OR NOT IF DEFINE FUN
%token<val> NUMBER
%token<boolval> BOOL
%token<strval> ID
%type<node> program stmts stmt print_stmt exps exp num_op logical_op
%type<node> plus minus multiply divide modules and_op or_op not_op
%type<node> greater smaller equal
%type<node> if_exp test_exp then_exp else_exp
%type<node> def_stmt variable variables
%type<node> fun_exp fun_id fun_body fun_call fun_name param params

%left NUM
%left '+' '-'
%left '*' '/'  MOD
%left '(' ')'
%%
program         : stmts                         { root = $1; }
                ;
stmts           : stmt stmts                    { $$=CreateNode($1,$2,' '); }
                | stmt                          { $$=$1; }
                ;
stmt            : exp                           { $$=$1; }
                | print_stmt                    { $$=$1; }
                | def_stmt                      { $$=$1; }
                ;
print_stmt      : '(' PRINT_NUM exp ')'         { $$=CreateNode($3,NULL,'p'); }
                | '(' PRINT_BOOL exp ')'        { $$=CreateNode($3,NULL,'P'); }
                ;
exps            : exp exps                      { $$=CreateNode($1,$2,'e'); }
                | exp                           { $$=$1; }
                ;
exp             : NUMBER                        { $$=CreateNode(NULL,NULL,'n'); $$->val=$1; }
                | num_op                        { $$=$1; }
                | BOOL                          { $$=CreateNode(NULL,NULL,'b'); $$->val=$1; }
                | logical_op                    { $$=$1; }
                | if_exp                        { $$=$1; }        
                | variable                      { $$=$1; }
                | fun_exp                       { $$=$1; }
                | fun_call                      { $$=$1; }
                ;
num_op          : plus                          { $$=$1; }
                | minus                         { $$=$1; }
                | multiply                      { $$=$1; }
                | divide                        { $$=$1; }
                | modules                       { $$=$1; }
                | greater                       { $$=$1; }
                | smaller                       { $$=$1; }
                | equal                         { $$=$1; }
                ;
plus            : '(' '+' exp exps ')'          { $$=CreateNode($3,$4,'+'); }
                ;
minus           : '(' '-' exp exp ')'           { $$=CreateNode($3,$4,'-'); }
                ;
multiply        : '(' '*' exp exps ')'          { $$=CreateNode($3,$4,'*'); }
                ;
divide          : '(' '/' exp exp ')'           { $$=CreateNode($3,$4,'/'); }
                ;
modules         : '(' MOD exp exp ')'           { $$=CreateNode($3,$4,'%'); }
                ;
greater         : '(' '>' exp exp ')'           { $$=CreateNode($3,$4,'>'); }
                ;
smaller         : '(' '<' exp exp ')'           { $$=CreateNode($3,$4,'<'); }
                ;
equal           : '(' '=' exp exp ')'           { $$=CreateNode($3,$4,'='); }
                ;

logical_op      : and_op                        { $$=$1; }
                | or_op                         { $$=$1; }
                | not_op                        { $$=$1; }
                ;
and_op          : '(' AND exp exps ')'          { $$=CreateNode($3,$4,'&'); }
                ;
or_op           : '(' OR exp exps ')'           { $$=CreateNode($3,$4,'|'); }
                ;
not_op          : '(' NOT exp')'                { $$=CreateNode($3,NULL,'~'); }
                ;
if_exp          : '(' IF test_exp then_exp else_exp ')' { $$=CreateNode($3,$5,'i'); $$->mid=$4; }
                ;
test_exp        : exp                           { $$=$1; }
                ;   
then_exp        : exp                           { $$=$1; }
                ;
else_exp        : exp                           { $$=$1; }
                ;
def_stmt        : '(' DEFINE variable exp ')'   { $$ = CreateNode($3, $4, 'd'); $3->val=$4->val; $$->isDefineFun=$4->isDefineFun; }
                ;
variable        : ID                            { $$ = CreateNode(NULL, NULL, 'v'); $$->name = $1;}
                ;




fun_exp         : '(' FUN fun_id fun_body ')'   { $$ = CreateNode($3, $4, 'c'); $$->isDefineFun=1;} 
                ;
fun_id          : '(' variables ')'                   { $$ = $2; }
                ;
variables       : variable variables            { $$ = CreateNode($1, $2, 'v'); }
                |                               { $$ = CreateNode(NULL, NULL, 'v'); }
                ;
fun_body        : exp                           { $$ = $1;}
                ;
fun_call        : '(' fun_exp params ')'         { $$ = CreateNode($2, $3, 'c'); }
                | '(' fun_name params ')'        { $$ = CreateNode($2, $3, 'C'); }
                ;
params          : param params                  { $$ = CreateNode($1, $2, 'n'); }
                |                               { $$ = CreateNode(NULL, NULL, 'n'); }
                ;
param           : exp                           { $$ = $1; }
                ;
fun_name        : variable                       { $$ = CreateNode($1, NULL, 'a'); $$->name = $1->name;}
                ;
%%

Node* CreateNode(Node* left,Node* right,char op){
    Node *newNode = new Node;
    newNode->left = left;
    newNode->right = right;
    newNode->mid = NULL;
    newNode->name = NULL;
    newNode->op = op;
    newNode->val = 0;
    
    return newNode;
}

void Traversal(Node* node){
    if(node == NULL){
        return;
    }
    switch(node->op){
        case '+':
            Traversal(node->left);
            Traversal(node->right);
            node->val = Add(node);
            break;
        case '-':
            Traversal(node->left);
            Traversal(node->right);
            node->val = Sub(node);
            break;
        case '*':
            Traversal(node->left);
            Traversal(node->right);
            node->val = Multiply(node);
            break;
        case '/':
            Traversal(node->left);
            Traversal(node->right);
            node->val = Divide(node);
            break;
        case '%':
            Traversal(node->left);
            Traversal(node->right);
            node->val = Modules(node);
            break;
        case '&':
            Traversal(node->left);
            Traversal(node->right);
            node->val = AndOperand(node);
            break;
        case '|':
            Traversal(node->left);
            Traversal(node->right);
            node->val = OrOperand(node);
            break;
        case '~':
            Traversal(node->left);
            node->val = !node->left->val;
            break;
        case '>':
            Traversal(node->left);
            Traversal(node->right);
            node->val = GreatOperand(node);
            break;
        case '<':
            Traversal(node->left);
            Traversal(node->right);
            node->val = SmallOperand(node);
            break;
        case '=':
            Traversal(node->left);
            Traversal(node->right);
            isEqual = 1;
            equalnum = 0;
            EqualOperand(node);
            node->val = isEqual;
            break;
        case 'p':
            Traversal(node->left);
            printf("%d\n",node->left->val);
            mapswitch = 0;
            recur = 0;
            for(iter = myDecforFun.begin(); iter != myDecforFun.end(); iter++)
                iter->second = 0;
            break;
        case 'P':
            Traversal(node->left);
            if(node->left->val)
                printf("#t\n");
            else 
                printf("#f\n");
            break;
        case 'i':
            Traversal(node->left);
            Traversal(node->mid);
            Traversal(node->right);
            if(node->left->val)
                node->val = node->mid->val;
            else 
                node->val = node->right->val;
            break;
        case 'd':
            
            if(!node->isDefineFun)
            {
                Traversal(node->right);
                myDeclare[node->left->name] = node->right->val;
            }
            else
            {
                if(node->right->left->left == NULL)
                {
                    myDecexp[node->left->name] = node->right->right;
                }
                else
                {
                    funid = node->right->left;
                    funexp = node->right->right;
                    myDecid[node->left->name] = funid;
                    myDecexp[node->left->name] = funexp;
                }
            }
            break;
        case 'v':
            if(mapswitch)
                node->val= myDecforFun.find(node->name)->second;
            else
                node->val= myDeclare.find(node->name)->second;
            break;
        case 'c':
            //bind id node and param node
            Bind(node->left->left, node->right);
            //change to receive from Decforfun
            mapswitch=1;
            Traversal(node->left->right);
            node->val = node->left->right->val;
            break;
        case 'C': 
            //bind id node and param node
            Traversal(node->right);
            Bind(myDecid.find(node->left->name)->second, node->right);
            mapswitch=1;
            Traversal(myDecexp.find(node->left->name)->second);
            node->val = myDecexp.find(node->left->name)->second->val + recur;
            
            recur = node->val;
            break;
        default:
            Traversal(node->left);
            Traversal(node->right);
            break;
    }
}

int Add(Node *node){
    int sum = 0;
    if(node->left != NULL){
        sum += node->left->val;
        if(node->left->op == 'e'){
            sum += Add(node->left);
        }
    }
    if(node->right != NULL){
        sum += node->right->val;
        if(node->right->op == 'e'){
            sum += Add(node->right);
        }
    }
    return sum;
}
int Sub(Node *node){
    return node->left->val - node->right->val;
}
int Multiply(Node *node){
    int sum = 1;
    if(node->left != NULL){
        if(node->left->op == 'e'){
            sum *= Multiply(node->left);
        }
        else{
            sum *= node->left->val;
        }
    }
    if(node->right != NULL){
        if(node->right->op == 'e'){
            sum *= Multiply(node->right);
        }
        else{
            sum *= node->right->val;
        }
    }
    return sum;
}
int Divide(Node *node){
    return node->left->val / node->right->val;
}
int Modules(Node *node){
    return node->left->val % node->right->val;
}
int AndOperand(Node *node){
    int sum = 1;
    if(node->left != NULL){
        if(node->left->op == 'e'){
            sum = sum & AndOperand(node->left);
        }
        else{
            sum = sum & node->left->val;
        }
    }
    if(node->right != NULL){
        if(node->right->op == 'e'){
            sum = sum & AndOperand(node->right);
        }
        else{
            sum = sum & node->right->val;
        }
    }
    return sum;
}
int OrOperand(Node *node){
    int sum = 0;
    if(node->left != NULL){
        if(node->left->op == 'e'){
            sum = sum | OrOperand(node->left);
        }
        else{
            sum = sum | node->left->val;
        }
    }
    if(node->right != NULL){
        if(node->right->op == 'e'){
            sum = sum | OrOperand(node->right);
        }
        else{
            sum = sum | node->right->val;
        }
    }
    return sum;
}
int GreatOperand(Node *node){
    return node->left->val > node->right->val;
}
int SmallOperand(Node *node){
    return node->left->val < node->right->val;
}
int EqualOperand(Node *node){
    if(node->left != NULL){
        if(node->left->op == 'e'){
            EqualOperand(node->left);
        }
        else
        {
            if(first==0)
            {
                equalnum=node->left->val;
                first=1;
            }
            else
            {
                if(node->left->val != equalnum)
                    isEqual=0;
            }
        }
    }
    if(node->right != NULL){
        if(node->right->op == 'e'){
            EqualOperand(node->right);
        }
        else
        {
            if(first==0)
            {
                equalnum=node->right->val;
                first=1;
            }
            else
            {
                if(node->right->val != equalnum)
                    isEqual=0;
            }
        }
    }
}

void Bind(Node *node1, Node *node2)
{
    if(node1 == NULL || node2 == NULL){
        return;
    }
    if(node1->op=='v' && node2->op=='n')
    {
        Bind(node1->left, node2->left);
        Bind(node1->right, node2->right);
        if(node1->name != NULL && node2 != NULL)
        {
            myDecforFun[node1->name] = node2->val;
        }
    }
}



void yyerror (const char *message)
{
    fprintf (stderr, "%s\n",message);
}

int main(int argc, char *argv[]) {
    /*
    #ifdef YYDEBUG
    yydebug = 1;
    #endif
    */
    yyparse();
    Traversal(root);
    return(0);
}