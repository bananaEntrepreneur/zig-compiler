%token CHAR
%token STRING
%token FLOAT INT
%token PRIMITIVE_TYPE
%token VOID

%token RETURN BREAK TRY
%token IF ELSE WHILE FOR SWITCH
%token AND OR ORELSE CATCH
%token CONST VAR STRUCT FN PUB

%token TRUE FALSE
%token NULL UNDEFINED UNREACHABLE

%token ID
%token QUOTED_ID

%token ERROR

%token ENUM
%token UNION

%token BUILTIN

%token DOT_DOT DOT_DOT_DOT
%token ARROW

%token PLUS_EQUAL MINUS_EQUAL ASTERISK_EQUAL SLASH_EQUAL PERCENT_EQUAL

%token UNDERSCORE

%precedence NO_ELSE
%precedence ELSE RETURN BREAK
%left OR
%left AND
%nonassoc EQUAL NOTEQUAL
%nonassoc '<' '>' LESS_EQUAL GREAT_EQUAL
%left '|' ORELSE CATCH
%left '+' '-'
%left '*' '/' '%'
%right '!'
%right '?'
%right UMINUS
%left '(' '[' '.'

%%

program: decl_list
       ;

decl_list: %empty
         | decl_list decl
         ;

decl: var_decl
    | fn_decl
    | PUB var_decl
    | PUB fn_decl
    ;

var_decl: CONST ID ':' type '=' expr ';'      
        | CONST ID '=' expr ';'               
        | VAR ID ':' type '=' expr ';'
        | VAR ID '=' expr ';'
        ;

fn_decl: FN ID '(' fn_param_list_opt ')' type block
       | FN ID '(' fn_param_list_opt ')' VOID block
       ;

type: PRIMITIVE_TYPE
    | named_type
    | optional_type
    | error_union_type
    | array_type
    | slice_type
    | function_type
    | error_set_type
    | '(' type ')'
    | container_type
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

error_union_type: '!' type
                | named_type '!' type
                | error_set_type '!' type
                ;

error_set_type: ERROR '{' error_field_list_opt '}'
              ;

error_field_list_opt: %empty
                    | error_field_list
                    | error_field_list ','
                    ;

error_field_list: ID
                | error_field_list ',' ID
                ;

container_type: STRUCT '{' container_members '}'
              | UNION '{' container_members '}'
              | UNION '(' ENUM ')' '{' container_members '}'
              | UNION '(' type ')' '{' container_members '}'
              | ENUM '{' enum_field_list_opt '}'
              ;

container_members: %empty
                 | container_members container_member
                 ;

container_member: container_field
                | decl
                ;

container_field: ID ':' type ','
               | ID ':' type '=' expr ','
               ;

enum_field_list_opt: %empty
                   | enum_field_list
                   | enum_field_list ','
                   ;

enum_field_list: enum_field
               | enum_field_list ',' enum_field
               ;

enum_field: ID
          | ID '=' expr
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

block: '{' stmt_list '}'
     ;

stmt_list: %empty
         | stmt_list stmt
         ;

stmt: var_decl
    | assign_expr ';'
    | unpack_list '=' expr ';'
    | if_stmt
    | switch_expr
    | while_stmt
    | for_stmt
    | block
    | ID ':' block
    | ';'
    ;

assign_expr: postfix
           | postfix assign_op expr %prec NO_ELSE
           | assign_expr expr_tail
           ;

assign_op: '='
         | PLUS_EQUAL
         | MINUS_EQUAL
         | ASTERISK_EQUAL
         | SLASH_EQUAL
         | PERCENT_EQUAL
         ;

unpack_list: unpack_target ',' unpack_target
           | unpack_list ',' unpack_target
           ;

unpack_target: CONST ID
             | CONST ID ':' type
             | VAR ID
             | VAR ID ':' type
             | postfix
             ;

if_stmt: if_prefix block
       | if_prefix block ELSE stmt
       | if_prefix block ELSE capture stmt
       | if_prefix assign_expr ';'
       | if_prefix assign_expr ELSE stmt
       | if_prefix assign_expr ELSE capture stmt
       ;

if_prefix: IF '(' expr ')'
         | IF '(' expr ')' capture
         ;

capture: '|' capture_name '|'
       ;

index_capture: capture
             | '|' capture_name ',' capture_name '|'
             ;

capture_name: ID
            | UNDERSCORE
            ;

switch_expr: SWITCH '(' expr ')' '{' switch_branch_list_opt '}'
           ;

switch_branch_list_opt: %empty
                      | switch_branch_list
                      | switch_branch_list ','
                      ;

switch_branch_list: switch_branch
                  | switch_branch_list ',' switch_branch
                  ;

switch_branch: switch_case ARROW branch_body
             | switch_case ARROW index_capture branch_body
             ;

branch_body: expr
           | expr assign_op expr
           ;

switch_case: switch_item_list
           | switch_item_list ','
           | ELSE
           ;

switch_item_list: switch_item
                | switch_item_list ',' switch_item
                ;

switch_item: expr
           | expr DOT_DOT_DOT expr
           ;

while_stmt: WHILE '(' expr ')' block
          ;

for_stmt: FOR '(' for_input ')' '|' ID '|' block
        ;

for_input: expr
         | expr DOT_DOT expr
         ;

expr: postfix %prec NO_ELSE
    | block
    | ID ':' block
    | if_prefix expr %prec NO_ELSE
    | if_prefix expr ELSE expr
    | if_prefix expr ELSE capture expr
    | switch_expr
    | expr expr_tail
    ;

expr_tail: '+' expr
         | '-' expr
         | '*' expr
         | '/' expr
         | '%' expr

         | '<' expr
         | '>' expr
         | LESS_EQUAL expr
         | GREAT_EQUAL expr
         | EQUAL expr
         | NOTEQUAL expr

         | AND expr
         | OR expr
         | ORELSE expr
         | CATCH expr
         | CATCH capture expr
         ;

postfix: operand
       | postfix '(' arg_list_opt ')'
       | postfix '.' ID
       | postfix '[' expr ']'
       ;

operand: INT
       | FLOAT
       | CHAR
       | STRING
       | TRUE
       | FALSE
       | NULL
       | UNDEFINED
       | UNREACHABLE
       | ID
       | UNDERSCORE
       | BUILTIN '(' arg_list_opt ')'
       | '(' expr ')'
       | '.' '{' arg_list_opt '}'
       | '.' '{' field_init_list '}'
       | container_type

       | '-' expr %prec UMINUS
       | '!' expr
       | TRY expr %prec UMINUS

       | RETURN
       | RETURN expr
       | BREAK
       | BREAK expr
       | BREAK ':' ID %prec BREAK
       | BREAK ':' ID expr %prec BREAK
       ;

arg_list_opt: %empty
            | arg_list
            ;

arg_list: expr
        | arg_list ',' expr
        ;

field_init_list: field_init
               | field_init_list ',' field_init
               ;

field_init: '.' ID '=' expr
          ;

%%
