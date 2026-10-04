%token CONST
%token VAR
%token FN
%token RETURN
%token IF
%token ELSE
%token WHILE
%token FOR
%token ID
%token INT
%token PRIMITIVE_TYPE

%nonassoc '<'
%left '+'
%left '*'
%precedence '(' '.' /* Function calls and class member accesses '(' never conflict with each other, so no associativity. */

%%

program: decl_list
       ;

decl_list: %empty
         | decl_list decl
         ;

decl: var_decl
    | FN ID '(' fn_param_list_opt ')' expr block
    ;

var_decl: CONST ID type_opt '=' expr ';'
        | VAR ID type_opt '=' expr ';'
        ;

type_opt: %empty
        | ':' expr
        ;

fn_param_list_opt: %empty
                 | fn_param_list
                 ;

fn_param_list: fn_param
             | fn_param_list ',' fn_param
             ;

fn_param: ID ':' expr
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
    ;

if_stmt: IF '(' expr ')' block
       | IF '(' expr ')' block ELSE block
       ;

while_stmt: WHILE '(' expr ')' block
          ;

for_stmt: FOR '(' expr ')' '|' ID '|' block
        ;

expr: INT
    | ID
    | PRIMITIVE_TYPE
    | expr '<' expr
    | expr '+' expr
    | expr '*' expr
    | expr '(' arg_list_opt ')'
    | expr '.' ID
    ;

arg_list_opt: %empty
            | arg_list
            ;

arg_list: expr
        | arg_list ',' expr
        ;

%%
