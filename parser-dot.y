
%code requires {
    #include "ast/DeclNode.h"
    #include "ast/TypeNode.h"
    #include "ast/ProgramNode.h"
}

%code {
    ProgramNode* programRoot = nullptr;
}

%union {
    bool                BoolVal;
    std::string*        StrVal;
    DeclNode*           Decl;
    TypeNode*           Type;
    ProgramNode*        Program;
}

%type <Program> program
%type <Decl> decl_list decl var_decl fn_decl param_list_opt param_list param members member_list field
%type <BoolVal> pub_opt
%type <Type>    type array_type container_type

%token<StrVal> ID
%token<StrVal> PRIMITIVE_TYPE

%token CONST VAR FN PUB BUILTIN
%token IF ELSE WHILE FOR CONTINUE BREAK RETURN STRUCT ENUM
%token INT FLOAT CHAR STRING BOOL UNDEFINED VOID
%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN
%token DOT_DOT
%token ERROR TRY CATCH

%nonassoc ELSE
%left OR
%left AND
%nonassoc '<' '>' LESS_EQUAL GREAT_EQUAL EQUAL NOT_EQUAL
%left CATCH
%left '+' '-'
%left '*' '/' '%'
%right UMINUS NOT TRY
%left '.' '(' '[' '{'

%%

program: decl_list  { programRoot = ProgramNode::Create("main", $1); $$ = programRoot; }
       ;

decl_list: %empty           { $$ = DeclNode::CreateEmptyDeclList(); }
         | decl_list decl   { $$ = DeclNode::AddToDeclList($1, $2); }
         ;
        
decl: pub_opt var_decl ';'  { $2->setPublic($1); $$ = $2; }
    | pub_opt fn_decl       { $2->setPublic($1); $$ = $2; }
    ;

pub_opt: %empty { $$ = false; }
       | PUB    { $$ = true; }
       ;

var_decl: CONST ID '=' expr             { $$ = DeclNode::CreateConstDecl(*$2, nullptr, $4); }
        | CONST ID ':' type '=' expr    { $$ = DeclNode::CreateConstDecl(*$2, $4, $6); }
        | VAR ID '=' expr               { $$ = DeclNode::CreateVarDecl(*$2, nullptr, $4); }
        | VAR ID ':' type '=' expr      { $$ = DeclNode::CreateVarDecl(*$2, $4, $6); }
        ;

type: PRIMITIVE_TYPE    { $$ = TypeNode::CreatePrimitiveType(*$1); }
    | ID                { $$ = TypeNode::CreateNameType(*$1); }
    | array_type        { $$ = $1; }
    | container_type    { $$ = $1; }
    ;

expr: container_type
    | expr '.' ID
    | '.' ID
    | ERROR

    | expr OR expr
    | expr AND expr
    | expr EQUAL expr
    | expr NOT_EQUAL expr
    | expr '<' expr
    | expr '>' expr
    | expr LESS_EQUAL expr
    | expr GREAT_EQUAL expr
    | expr '+' expr
    | expr '-' expr
    | expr '*' expr
    | expr '/' expr
    | expr '%' expr
    | '-' expr %prec UMINUS
    | '!' expr %prec NOT
    | TRY expr

    | '(' expr ')'
    | ID
    | INT
    | FLOAT
    | CHAR
    | STRING
    | BOOL
    | UNDEFINED

    | expr '[' expr ']'
    | array_type init_body

    | '.' init_body
    | expr init_body

    | expr '(' arg_list_opt ')'
    | BUILTIN '(' arg_list_opt ')'

    | IF '(' expr ')' expr ELSE expr

    | expr CATCH expr
    | expr CATCH '|' ID '|' expr %prec CATCH
    ;

container_type: STRUCT '{' members '}'              { $$ = TypeNode::CreateStructType($3); }
              | ENUM '{' members '}'                { $$ = TypeNode::CreateEnumType(nullptr, $3); }
              | ENUM '(' type ')' '{' members '}'   { $$ = TypeNode::CreateEnumType($3, $6); }
              ;

members: member_list        { $$ = DeclNode::CreateMembers($1); }
       | member_list field  { $$ = DeclNode::AddFieldToMembers(DeclNode::CreateMembers($1), $2); }
       ;

member_list: %empty                 { $$ = DeclNode::CreateEmptyDeclList(); }
           | member_list field ','  { $$ = DeclNode::AddToMemberList($1, $2); }
           | member_list decl       { $$ = DeclNode::AddToMemberList($1, $2); }
           ;

field: ID           { $$ = DeclNode::CreateField(*$1, nullptr, nullptr); }
     | ID ':' type  { $$ = DeclNode::CreateField(*$1, $3, nullptr); }
     | ID '=' expr  { $$ = DeclNode::CreateField(*$1, nullptr, $3); }
     ;

array_type: '[' expr ']' type   { $$ = TypeNode::CreateArrayType($2, $4); }
          ;

init_body: '{' init_list_opt '}'
         ;

init_list_opt: %empty
             | init_list
             | init_list ','
             ;

init_list: init_item
         | init_list ',' init_item
         ;

init_item: expr
         | '.' ID '=' expr
         ;

fn_decl: FN ID '(' param_list_opt ')' type block        { $$ = DeclNode::CreateFnDecl(*$2, $4, $6, false, $7); }
       | FN ID '(' param_list_opt ')' '!' type block    { $$ = DeclNode::CreateFnDecl(*$2, $4, $7, true,  $8); }
       | FN ID '(' param_list_opt ')' VOID block        { $$ = DeclNode::CreateFnDecl(*$2, $4, nullptr, false, $7); }
       | FN ID '(' param_list_opt ')' '!' VOID block    { $$ = DeclNode::CreateFnDecl(*$2, $4, nullptr, true,  $8); }
       ;

param_list_opt: %empty      { $$ = DeclNode::CreateEmptyParamList(); }
              | param_list  { $$ = $1; }
              ;

param_list: param                   { $$ = DeclNode::CreateParamList($1); }
          | param_list ',' param    { $$ = DeclNode::AddToParamList($1, $3); }
          ;

param: ID ':' type  { $$ = DeclNode::CreateParamDecl(*$1, $3); }
     ;

arg_list_opt: %empty
            | arg_list
            ;

arg_list: expr
        | arg_list ',' expr
        ;

block: '{' stmt_list_opt '}'
     ;

stmt_list_opt: %empty
             | stmt_list
             ;

stmt_list: stmt
         | stmt_list stmt
         ;

stmt: var_decl ';'
    | expr ';'
    | assign ';'
    | RETURN ';'
    | RETURN expr ';'
    | BREAK ';'
    | CONTINUE ';'
    | block
    | if_stmt
    | while_stmt
    | for_stmt
    ;

assign: expr '=' expr
      | expr ADD_ASSIGN expr
      | expr SUB_ASSIGN expr
      | expr MUL_ASSIGN expr
      | expr DIV_ASSIGN expr
      | expr MOD_ASSIGN expr
      ;

while_stmt: WHILE '(' expr ')' block
          | WHILE '(' expr ')' ':' '(' assign ')' block
          ;

for_stmt: FOR '(' for_input ')' '|' ID '|' block
        ;

for_input: expr
         | expr DOT_DOT expr
         ;

if_stmt: IF '(' expr ')' block
       | IF '(' expr ')' block ELSE block
       | IF '(' expr ')' block ELSE if_stmt
       ;
