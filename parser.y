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

def: CONST ID '=' expr ';'
   | FN ID '(' ')' expr block
   ;

block: '{' '}'
     ;

expr: INT
    | PRIMITIVE_TYPE
    ;

%%
