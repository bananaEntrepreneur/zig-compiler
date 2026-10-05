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

%precedence '(' '[' '{' '.' /* Function calls and class member accesses '(' never conflict with each other, so no associativity. */

%%

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

expr: INT
    | ID
    | PRIMITIVE_TYPE
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
