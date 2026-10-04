%token CONST
%token FN
%token RETURN
%token ID
%token INT
%token PRIMITIVE_TYPE

%left '+'
%left '*'

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
    | ID
    | PRIMITIVE_TYPE
    | expr '+' expr
    | expr '*' expr
    ;

%%
