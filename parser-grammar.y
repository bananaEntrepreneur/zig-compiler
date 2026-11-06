%token CONST VAR PUB ID PRIMITIVE_TYPE
%token IF ELSE WHILE CONTINUE BREAK RETURN STRUCT ENUM
%token INT FLOAT CHAR STRING TRUE FALSE UNDEFINED

%nonassoc ELSE
%left OR
%left AND
%nonassoc '<' '>' LESS_EQUAL GREAT_EQUAL EQUAL NOT_EQUAL
%left '+' '-'
%left '*' '/' '%'
%right UMINUS NOT
%left '.' '(' '[' '{'

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

    | expr OR expr
    | expr AND expr
    | expr EQUAL expr
    | expr NOT_EQUAL expr
    | expr '<' expr
    | expr '>' expr
    | expr LESS_EQUAL expr
    | expr GREAT_EQUAL expr
    | expr '+' expr
    | expr '-' expr
    | expr '*' expr
    | expr '/' expr
    | expr '%' expr
    | '-' expr %prec UMINUS
    | '!' expr %prec NOT

    | '(' expr ')'
    | ID
    | INT
    | FLOAT
    | CHAR
    | STRING
    | TRUE
    | FALSE
    | UNDEFINED

    | expr '[' expr ']'
    | array_type init_body

    | '.' init_body
    | expr init_body
    ;

container_type: STRUCT '{' members '}'
              | ENUM '{' members '}'
              | ENUM '(' type ')' '{' members '}'
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

array_type: '[' expr ']' type
          ;

init_body: '{' init_list_opt '}'
         ;

init_list_opt: %empty
             | init_list
             | init_list ','
             ;

init_list: init_item
         | init_list ',' init_item
         ;

init_item: expr
         | '.' ID '=' expr
         ;
