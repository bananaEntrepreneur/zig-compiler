/* ===== Character literal ===== */
%token CHAR

/* ===== String literal ===== */
%token STRING

/* ===== Quoted identifier ===== */
%token QUOTED_ID

/* ===== Multiline string ===== */
%token MULTILINE_STRING

/* ===== Numbers ===== */
%token FLOAT INT

/* ===== Keywords ===== */
%token ADDRSPACE ALIGN ALLOWZERO AND ANYFRAME ANYTYPE ASM
%token BREAK CALLCONV CATCH COMPTIME CONST CONTINUE DEFER
%token ELSE ENUM ERRDEFER ERROR EXPORT EXTERN FN FOR
%token IF INLINE LINKSECTION NOALIAS NOINLINE NOSUSPEND
%token OPAQUE OR ORELSE PACKED PUB RESUME RETURN STRUCT
%token SUSPEND SWITCH TEST THREADLOCAL TRY UNION UNREACHABLE
%token VAR VOLATILE WHILE NULL UNDEFINED

/* ===== Constants ===== */
%token TRUE FALSE

/* ===== Integer types ===== */
%token UINT_TYPE SINT_TYPE

/* ===== Float types ===== */
%token F16 F32 F64 F80 F128

/* ===== Other primitive types ===== */
%token BOOL VOID NORETURN TYPE
%token ANYERROR ANYOPAQUE
%token COMPTIME_INT COMPTIME_FLOAT

/* ===== Pointer-sized types ===== */
%token USIZE ISIZE

/* ===== C-compatible types ===== */
%token C_CHAR C_SHORT C_USHORT C_INT C_UINT
%token C_LONG C_ULONG C_LONGLONG C_ULONGLONG C_LONGDOUBLE

/* ===== Identifiers ===== */
%token ID

/* ===== Builtin identifiers ===== */
%token BUILTIN

/* ===== Operators (array) ===== */
%token PLUS_PLUS STAR_STAR

/* ===== Wrapping and saturating operators ===== */
%token PLUS_PERCENT MINUS_PERCENT STAR_PERCENT
%token PLUS_PIPE MINUS_PIPE STAR_PIPE SHL_PIPE

/* ===== Operators (comparison) ===== */
%token EQUAL NOTEQUAL LESS_EQUAL GREAT_EQUAL

/* ===== Operators (bitwise) ===== */
%token SHL SHR

/* ===== Operators (assignment) ===== */
%token SHL_EQ SHR_EQ PLUS_EQ MINUS_EQ STAR_EQ SLASH_EQ PERCENT_EQ
%token AMP_EQ PIPE_EQ CARET_EQ
%token PLUS_PERCENT_EQ MINUS_PERCENT_EQ STAR_PERCENT_EQ
%token PLUS_PIPE_EQ MINUS_PIPE_EQ STAR_PIPE_EQ SHL_PIPE_EQ

/* ===== Operators (other) ===== */
%token DOT_STAR DOT_QUESTION RANGE DOT_DOT ARROW PIPE_PIPE

/* ===== Operator Precedence ===== */

%right '='
%right PLUS_EQ MINUS_EQ STAR_EQ SLASH_EQ PERCENT_EQ
%right AMP_EQ PIPE_EQ CARET_EQ SHL_EQ SHR_EQ
%right PLUS_PERCENT_EQ MINUS_PERCENT_EQ STAR_PERCENT_EQ
%right PLUS_PIPE_EQ MINUS_PIPE_EQ STAR_PIPE_EQ SHL_PIPE_EQ

%right ORELSE
%left OR
%left AND

%nonassoc EQUAL NOTEQUAL
%nonassoc '<' '>' LESS_EQUAL GREAT_EQUAL

%left '|'
%left '^'
%left '&'
%left SHL SHR SHL_PIPE

%left '+' '-' PLUS_PLUS
%left PLUS_PERCENT MINUS_PERCENT PLUS_PIPE MINUS_PIPE

%left '*' '/' '%' STAR_STAR
%left STAR_PERCENT STAR_PIPE

%right NOT
%right UMINUS
%right '~'

%left '?' DOT_STAR DOT_QUESTION

%token UNDERSCORE

%precedence '(' '[' '{' '.' /* Function calls and class member accesses '(' never conflict with each other, so no associativity. */

%%

type
    : primitive_type
    | pointer_type
    | optional_type
    | error_union_type
    | array_type
    | slice_type
    | function_type
    | container_type
    | error_set_type
    | named_type
    | '(' type ')'
    ;

primitive_type
    : UINT_TYPE
    | SINT_TYPE
    | F16 | F32 | F64 | F80 | F128
    | BOOL | VOID | NORETURN | TYPE
    | ANYERROR | ANYOPAQUE | ANYTYPE | ANYFRAME
    | COMPTIME_INT | COMPTIME_FLOAT
    | USIZE | ISIZE
    | C_CHAR | C_SHORT | C_USHORT | C_INT | C_UINT
    | C_LONG | C_ULONG | C_LONGLONG | C_ULONGLONG | C_LONGDOUBLE
    ;

pointer_type
    : '*' type
    | '*' CONST type
    | '*' VOLATILE type
    | '*' ALLOWZERO type
    | '*' ALIGN '(' expr ')' type
    | '*' ADDRSPACE '(' expr ')' type
    | '[' '*' ']' type
    | '[' '*' ']' ALIGN '(' expr ')' type
     ;

optional_type
    : '?' type
    ;

error_union_type
    : '!' type
    | type '!' type
    ;

array_type
    : '[' expr ']' type
    | '[' UNDERSCORE ']' type
    | '[' expr ']' ALIGN '(' expr ')' type
    ;

slice_type
    : '[' ']' type
    | '[' ':' expr ']' type
    | '[' ']' ALIGN '(' expr ')' type
    | '[' ':' expr ']' ALIGN '(' expr ')' type
    ;

function_type
    : FN '(' fn_type_param_list_opt ')' type
    | FN '(' fn_type_param_list_opt ')' type callconv_spec
    | FN '(' fn_type_param_list_opt ')' type callconv_spec ALIGN '(' expr ')'
    ;

fn_type_param_list_opt
    : %empty
    | fn_type_param_list
    ;

fn_type_param_list
    : fn_type_param
    | fn_type_param_list ',' fn_type_param
    ;

fn_type_param
    : type
    | NOALIAS type
    | COMPTIME ID ':' type
    | COMPTIME type
    | ID ':' type
    | ANYTYPE
    | RANGE
    ;

callconv_spec
    : CALLCONV '(' '.' ID ')'
    ;

/* ===== Container types (struct / enum / union / opaque) ===== */

container_type
    : STRUCT '{' container_field_list_opt '}'
    | UNION '{' container_field_list_opt '}'
    | UNION '(' ENUM ')' '{' container_field_list_opt '}'
    | UNION '(' expr ')' '{' container_field_list_opt '}'
    | ENUM '{' enum_field_list_opt '}'
    | ENUM '(' expr ')' '{' enum_field_list_opt '}'
    | OPAQUE '{' '}'
    | OPAQUE '(' expr ')' '{' '}'
    | EXTERN STRUCT '{' container_field_list_opt '}'
    | EXTERN UNION '{' container_field_list_opt '}'
    | PACKED STRUCT '{' container_field_list_opt '}'
    | PACKED UNION '{' container_field_list_opt '}'
    ;

container_field_list_opt
    : %empty
    | container_field_list
    ;

container_field_list
    : container_field
    | container_field_list container_field
    ;

container_field
    : ID ':' type ','
    | ID ':' type '=' expr ','
    | PUB ID ':' type ','
    | PUB ID ':' type '=' expr ','
    | ID ':' type ALIGN '(' expr ')' ','
    | ID ':' type ALIGN '(' expr ')' '=' expr ','
    | PUB ID ':' type ALIGN '(' expr ')' ','
    | PUB ID ':' type ALIGN '(' expr ')' '=' expr ','
    | COMPTIME ID ':' type '=' expr ','
    | UNDERSCORE ':' type ','

    | fn_method
    | pub_fn_method

    | CONST ID '=' expr ';'
    | CONST ID ':' type '=' expr ';'
    | VAR ID '=' expr ';'
    | VAR ID ':' type '=' expr ';'
    | VAR ID ':' type ';'
    | PUB CONST ID '=' expr ';'
    | PUB CONST ID ':' type '=' expr ';'
    | PUB VAR ID '=' expr ';'
    | PUB VAR ID ':' type '=' expr ';'
    | PUB VAR ID ':' type ';'

    | USINGNAMESPACE expr ';'
    | PUB USINGNAMESPACE expr ';'
    | TEST STRING block
    | COMPTIME block
    ;

fn_method
    : fn_method_modifiers_opt ID '(' fn_param_list_opt ')' type fn_method_modifiers_opt block
    ;

pub_fn_method
    : PUB fn_method
    ;

fn_method_modifiers_opt
    : %empty
    | INLINE
    | NOINLINE
    | callconv_spec
    | ALIGN '(' expr ')'
    | INLINE callconv_spec
    | NOINLINE callconv_spec
    | callconv_spec ALIGN '(' expr ')'
    ;

enum_field_list_opt
    : %empty
    | enum_field_list
    ;

enum_field_list
    : enum_field
    | enum_field_list enum_field
    ;

enum_field
    : ID ','
    | ID '=' expr ','
    | PUB ID ','
    | PUB ID '=' expr ','
    ;

error_set_type
    : ERROR '{' error_field_list_opt '}'
    ;

error_field_list_opt
    : %empty
    | error_field_list
    ;

error_field_list
    : error_field
    | error_field_list error_field
    ;

error_field
    : ID ','
    | ID
    ;

named_type
    : ID
    | QUOTED_ID
    | BUILTIN
    | BUILTIN '(' arg_list_opt ')'
    ;

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

for_stmt: FOR '(' for_input ')' '|' ID '|' block
        ;

for_input: expr
         | expr DOT_DOT expr
         ;

expr
    : INT
    | ID
    | primitive_type
    | named_type
    | container_type
    | error_set_type
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
