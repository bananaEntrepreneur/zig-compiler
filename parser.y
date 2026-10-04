%token CONST
%token FN
%token ID
%token INT
%token PRIMITIVE_TYPE

%%

program: def_list
       ;

def_list: %empty
        | def_list def
        ;

def: var_def
   | FN ID '(' ')' expr block
   ;

var_def: CONST ID '=' expr ';'
       ;

block: '{' stmt_list '}'
     ;

stmt_list: %empty
         | stmt_list stmt
         ;

stmt: var_def
    ;

expr: INT
    | PRIMITIVE_TYPE
    ;

%%
