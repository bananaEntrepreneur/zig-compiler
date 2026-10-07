%token CHAR
%token STRING
%token FLOAT INT

%token RETURN
%token IF ELSE WHILE FOR
%token AND OR
%token CONST VAR STRUCT FN

%token TRUE FALSE
%token NULL UNDEFINED

%token UINT_TYPE SINT_TYPE
%token F16 F32 F64 F80 F128
%token BOOL VOID
%token USIZE ISIZE

%token ID

%token BUILTIN

%token DOT_DOT

%token UNDERSCORE

%right '='
%left OR
%left AND
%nonassoc EQUAL NOTEQUAL
%nonassoc '<' '>' LESS_EQUAL GREAT_EQUAL
%left '|'
%left '+' '-'
%left '*' '/' '%'
%right '!'
%right UMINUS
%precedence '(' '[' '{' '.' /* Function calls and class member accesses '(' never conflict with each other, so no associativity. */

%%

program: decl_list
       ;

decl_list: %empty
         | decl_list decl
         ;

decl: var_decl
    | fn_decl
    | struct_decl
    ;

var_decl: CONST ID ':' type '=' expr ';'      
        | CONST ID '=' expr ';'               
        | VAR ID ':' type '=' expr ';'
        | VAR ID '=' expr ';'
        ;

fn_decl: FN ID '(' fn_param_list_opt ')' type block
       ;

struct_decl: CONST ID '=' STRUCT '{' container_field_list_opt '}'
           ;

type: primitive_type
    | ID
    | type '[' ']'
    | type '[' INT ']'
    | type '[' UNDERSCORE ']'
    | '*' type
    | '(' type ')'
    ;

primitive_type: UINT_TYPE
              | SINT_TYPE
              | F16 | F32 | F64 | F80 | F128
              | BOOL | VOID
              | USIZE | ISIZE
              ;

fn_param_list_opt: %empty
                 | fn_param_list
                 ;

fn_param_list: fn_param
             | fn_param_list ',' fn_param
             ;

container_field_list_opt: %empty
                        | container_field_list
                        ;

container_field_list: container_field
                    | container_field_list container_field
                    ;

container_field: ID ':' type ','
               | ID ':' type '=' expr ','
               | CONST ID ':' type '=' expr ';'
               | VAR ID ':' type '=' expr ';'
               | fn_decl
               ;

fn_param: ID ':' type
        ;

block: '{' stmt_list '}'
     ;

stmt_list: %empty
         | stmt_list stmt
         ;

stmt: var_decl
    | RETURN expr ';'
    | expr '=' expr ';'
    | if_stmt
    | while_stmt
    | for_stmt
    | block
    | ';'
    ;

if_stmt: IF '(' expr ')' block
       | IF '(' expr ')' block ELSE block
       ;

while_stmt: WHILE '(' expr ')' block
          ;

for_stmt: FOR '(' for_input ')' '|' ID '|' block
        ;

for_input: expr
         | expr DOT_DOT expr
         ;

expr: INT
    | FLOAT
    | CHAR
    | STRING
    | TRUE
    | FALSE
    | NULL
    | UNDEFINED
    | ID
    | BUILTIN '(' arg_list_opt ')'
    | '(' expr ')'
    | expr '(' arg_list_opt ')'
    | expr '.' ID
    | expr '[' expr ']'

    | expr '+' expr
    | expr '-' expr
    | expr '*' expr
    | expr '/' expr
    | expr '%' expr

    | expr '<' expr
    | expr '>' expr
    | expr LESS_EQUAL expr
    | expr GREAT_EQUAL expr
    | expr EQUAL expr
    | expr NOTEQUAL expr

    | expr AND expr
    | expr OR expr

    | '-' expr %prec UMINUS
    | '!' expr
    ;

arg_list_opt: %empty
            | arg_list
            ;

arg_list: expr
        | arg_list ',' expr
        ;

%%
