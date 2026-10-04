%token CONST
%token FN
%token RETURN
%token ID
%token INT
%token PRIMITIVE_TYPE

%left '+'
%left '*'
%precedence '('

%%

program: decl_list
       ;

decl_list: %empty
         | decl_list decl
         ;

decl: var_decl
    | FN ID '(' fn_param_list_opt ')' expr block
    ;

var_decl: CONST ID '=' expr ';'
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
    ;

expr: INT
    | ID
    | PRIMITIVE_TYPE
    | expr '+' expr
    | expr '*' expr
    | expr '(' arg_list_opt ')'
    ;

arg_list_opt: %empty
            | arg_list
            ;

arg_list: expr
        | arg_list ',' expr
        ;

%%
