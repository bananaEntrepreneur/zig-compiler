%token CONST VAR FN PUB ID PRIMITIVE_TYPE BUILTIN
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

program: decl_list
       ;

decl_list: %empty
         | decl_list decl
         ;
        
decl: pub_opt var_decl ';'
    | pub_opt fn_decl
    ;

pub_opt: %empty
       | PUB
       ;

var_decl: CONST ID '=' expr
        | CONST ID ':' type '=' expr
        | VAR ID '=' expr
        | VAR ID ':' type '=' expr
        ;

type: PRIMITIVE_TYPE
    | ID
    | array_type
    | container_type
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

container_type: STRUCT '{' members '}'
              | ENUM '{' members '}'
              | ENUM '(' type ')' '{' members '}'
              ;

members: member_list
       | member_list field
       ;

member_list: %empty
           | member_list field ','
           | member_list decl
           ;

field: ID
     | ID ':' type
     | ID '=' expr
     ;

array_type: '[' expr ']' type
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

fn_decl: FN ID '(' param_list_opt ')' type block
       | FN ID '(' param_list_opt ')' '!' type block
       | FN ID '(' param_list_opt ')' VOID block
       | FN ID '(' param_list_opt ')' '!' VOID block
       ;

param_list_opt: %empty
              | param_list
              ;

param_list: param
          | param_list ',' param
          ;

param: ID ':' type
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
