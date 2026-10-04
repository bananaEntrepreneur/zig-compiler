%token CONST
%token ID
%token INT

%%

program: def_list
       ;

def_list: %empty
        | def_list def
        ;

def: CONST ID '=' expr ';'
   ;

expr: INT
    ;

%%
