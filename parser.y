%token CHAR
%token STRING
%token FLOAT INT
%token PRIMITIVE_TYPE

%token RETURN BREAK
%token IF ELSE WHILE FOR
%token AND OR
%token CONST VAR STRUCT FN

%token TRUE FALSE
%token NULL UNDEFINED

%token VOID

%token ID
%token QUOTED_ID

%token ERROR

%token ENUM
%token UNION

%token BUILTIN

%token DOT_DOT

%token UNDERSCORE

%left OR
%left AND
%nonassoc EQUAL NOTEQUAL
%nonassoc '<' '>' LESS_EQUAL GREAT_EQUAL
%left '|'
%left '+' '-'
%left '*' '/' '%'
%right '!'
%right '?'
%right PTR_TYPE
%right UMINUS
%precedence '(' '[' '.' /* Function calls and class member accesses '(' never conflict with each other, so no associativity. */

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

type: PRIMITIVE_TYPE
    | named_type
    | pointer_type
    | optional_type
    | error_union_type
    | array_type
    | slice_type
    | function_type
    | enum_type
    | union_type
    | error_set_type
    | '(' type ')'
    ;

named_type: ID
          | QUOTED_ID
          ;

optional_type: '?' type
             ;

array_type: '[' INT ']' type
          | '[' UNDERSCORE ']' type
          ;

slice_type: '[' ']' type
          | '[' ':' expr ']' type
          ;

pointer_type: '*' type %prec PTR_TYPE
            | '[' '*' ']' type
            ;

error_union_type: '!' type
                | ID '!' type
                | error_set_type '!' type
                ;

error_set_type: ERROR '{' error_field_list_opt '}'
              ;

error_field_list_opt: %empty
                    | error_field_list
                    ;

error_field_list: error_field
                | error_field_list error_field
                ;

error_field: ID ','
           | ID
           ;

enum_type: ENUM '{' enum_field_list_opt '}'
         ;

enum_field_list_opt: %empty
                   | enum_field_list
                   ;

enum_field_list: enum_field
               | enum_field_list enum_field
               ;

enum_field: ID ','
          | ID
          | ID '=' expr ','
          | ID '=' expr
          ;

union_type: UNION '{' container_field_list_opt '}'
          | UNION '(' ENUM ')' '{' container_field_list_opt '}'
          | UNION '(' type ')' '{' container_field_list_opt '}'
          ;
          
function_type: FN '(' fn_param_list_opt ')' type
             ;

fn_param_list_opt: %empty
                 | fn_param_list
                 ;

fn_param_list: fn_param
             | fn_param_list ',' fn_param
             ;

fn_param: ID ':' type
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

block: '{' stmt_list '}'
     ;

stmt_list: %empty
         | stmt_list stmt
         ;

stmt: var_decl
    | RETURN expr ';'
    | BREAK ':' ID expr ';'
    | stmt_expr '=' expr ';'
    | stmt_expr ';'
    | if_stmt
    | while_stmt
    | for_stmt
    | block
    | ID ':' block
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

expr: operand
    | block
    | ID ':' block
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

stmt_expr: operand
         | stmt_expr '(' arg_list_opt ')'
         | stmt_expr '.' ID
         | stmt_expr '[' expr ']'

         | stmt_expr '+' expr
         | stmt_expr '-' expr
         | stmt_expr '*' expr
         | stmt_expr '/' expr
         | stmt_expr '%' expr

         | stmt_expr '<' expr
         | stmt_expr '>' expr
         | stmt_expr LESS_EQUAL expr
         | stmt_expr GREAT_EQUAL expr
         | stmt_expr EQUAL expr
         | stmt_expr NOTEQUAL expr

         | stmt_expr AND expr
         | stmt_expr OR expr

         | '-' expr %prec UMINUS
         | '!' expr
         ;

operand: INT
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
       ;

arg_list_opt: %empty
            | arg_list
            ;

arg_list: expr
        | arg_list ',' expr
        ;

%%
