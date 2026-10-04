%token CONST
%token FN
%token RETURN
%token ID
%token INT
%token PRIMITIVE_TYPE

%%

program: decl_list
       ;

decl_list: %empty
         | decl_list decl
         ;

decl: var_decl
    | FN ID '(' ')' expr block
    ;

var_decl: CONST ID '=' expr ';'
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
    | PRIMITIVE_TYPE
    ;

%%
