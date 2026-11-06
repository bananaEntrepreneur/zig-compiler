%token CONST VAR PUB ID PRIMITIVE_TYPE
%token IF ELSE WHILE CONTINUE BREAK RETURN STRUCT ENUM UNION

%right '='
%left OR
%left AND
%left '<' '>' LESS_EQUAL GREAT_EQUAL EQUAL NOT_EQUAL
%left '+' '-'
%left '*' '/' '%'
%right UMINUS NOT
%left '[' '.'
%nonassoc '('

%%

program: decl_list
       ;

decl_list: %empty
         | decl_list decl
         ;
        
decl: pub_opt var_decl
    | pub_opt fn_decl
    ;

pub_opt: %empty
       | PUB
       ;

var_decl: CONST ID '=' expr ';'
        | CONST ID ':' type '=' expr ';'
        | VAR ID '=' expr ';'
        | VAR ID ':' type '=' expr ';'
        ;

type: PRIMITIVE_TYPE
    | ID
    | array_type
    | container_type
    ;

expr: container_type
    | expr '.' ID
    | '.' ID
    ;

container_type: STRUCT '{' members '}'
              | ENUM '{' members '}'
              | ENUM '(' type ')' '{' members '}'
              | UNION '{' members '}'
              | UNION '(' ENUM ')' '{' members '}'
              | UNION '(' type ')' '{' members '}'
              ;

members: field_list_opt decl_list
       ;

field_list_opt: %empty
              | field_list
              ;

field_list: field
          | field_list field
          ;

field: ID ':' type ','
     | ID ','
     ;
