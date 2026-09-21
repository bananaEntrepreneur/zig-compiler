%option noyywrap

%x MLSTR

%{
#include <iostream>
#include <string>

static std::string ml;
%}

DEC [0-9](_?[0-9])*
HEX [0-9a-fA-F](_?[0-9a-fA-F])*
BIN [01](_?[01])*
OCT [0-7](_?[0-7])*

%%

    /* Comments */

"//!".* { std::cout << "Top-level documentation comment: " << yytext << '\n'; }

"////".* { std::cout << "Four slash single-line comment: " << yytext << '\n'; }

"///".* { std::cout << "Documentation comment: " << yytext << '\n'; }

"//".* { std::cout << "Single-line comment: " << yytext << '\n'; }

    /* Character literals */

'([^'\\\n][\x80-\xBF]*|\\([nrt'"\\]|x[0-9a-fA-F]{2}|u\{[0-9a-fA-F]+\}))' { std::cout << "Char literal: " << yytext << '\n'; }

    /* Strings */

\"([^\"\\\n]|\\.)*\" { std::cout << "String literal: " << yytext << '\n'; }

\\\\ { ml.clear(); BEGIN(MLSTR); }

<MLSTR>[^\n]+ { ml += yytext; }

<MLSTR>\n[ \t]*\\\\ { ml += '\n'; }

<MLSTR>\n { std::cout << "Multiline string literal: " << ml << '\n'; BEGIN(INITIAL); }

<MLSTR><<EOF>> { std::cout << "Multiline string literal: " << ml << '\n'; BEGIN(INITIAL); }

    /* Numbers */

0x{HEX} { std::cout << "Hex integer literal: " << yytext << '\n'; }

0b{BIN} { std::cout << "Binary integer literal: " << yytext << '\n'; }

0o{OCT} { std::cout << "Octal integer literal: " << yytext << '\n'; }

{DEC}\.{DEC}([eE][+-]?{DEC})? { std::cout << "Float literal: " << yytext << '\n'; }

{DEC}[eE][+-]?{DEC} { std::cout << "Float literal (exponent): " << yytext << '\n'; }

{DEC} { std::cout << "Integer literal: " << yytext << '\n'; }

    /* Keywords */

"addrspace" { std::cout << "Keyword: " << yytext << '\n'; }
"align" { std::cout << "Keyword: " << yytext << '\n'; }
"allowzero" { std::cout << "Keyword: " << yytext << '\n'; }
"and" { std::cout << "Keyword: " << yytext << '\n'; }
"anyframe" { std::cout << "Keyword: " << yytext << '\n'; }
"anytype" { std::cout << "Keyword: " << yytext << '\n'; }
"asm" { std::cout << "Keyword: " << yytext << '\n'; }
"async" { std::cout << "Keyword: " << yytext << '\n'; }
"await" { std::cout << "Keyword: " << yytext << '\n'; }
"break" { std::cout << "Keyword: " << yytext << '\n'; }
"callconv" { std::cout << "Keyword: " << yytext << '\n'; }
"catch" { std::cout << "Keyword: " << yytext << '\n'; }
"comptime" { std::cout << "Keyword: " << yytext << '\n'; }
"const" { std::cout << "Keyword: " << yytext << '\n'; }
"continue" { std::cout << "Keyword: " << yytext << '\n'; }
"defer" { std::cout << "Keyword: " << yytext << '\n'; }
"else" { std::cout << "Keyword: " << yytext << '\n'; }
"enum" { std::cout << "Keyword: " << yytext << '\n'; }
"errdefer" { std::cout << "Keyword: " << yytext << '\n'; }
"error" { std::cout << "Keyword: " << yytext << '\n'; }
"export" { std::cout << "Keyword: " << yytext << '\n'; }
"extern" { std::cout << "Keyword: " << yytext << '\n'; }
"fn" { std::cout << "Keyword: " << yytext << '\n'; }
"for" { std::cout << "Keyword: " << yytext << '\n'; }
"if" { std::cout << "Keyword: " << yytext << '\n'; }
"inline" { std::cout << "Keyword: " << yytext << '\n'; }
"linksection" { std::cout << "Keyword: " << yytext << '\n'; }
"noalias" { std::cout << "Keyword: " << yytext << '\n'; }
"noinline" { std::cout << "Keyword: " << yytext << '\n'; }
"nosuspend" { std::cout << "Keyword: " << yytext << '\n'; }
"opaque" { std::cout << "Keyword: " << yytext << '\n'; }
"or" { std::cout << "Keyword: " << yytext << '\n'; }
"orelse" { std::cout << "Keyword: " << yytext << '\n'; }
"packed" { std::cout << "Keyword: " << yytext << '\n'; }
"pub" { std::cout << "Keyword: " << yytext << '\n'; }
"resume" { std::cout << "Keyword: " << yytext << '\n'; }
"return" { std::cout << "Keyword: " << yytext << '\n'; }
"struct" { std::cout << "Keyword: " << yytext << '\n'; }
"suspend" { std::cout << "Keyword: " << yytext << '\n'; }
"switch" { std::cout << "Keyword: " << yytext << '\n'; }
"test" { std::cout << "Keyword: " << yytext << '\n'; }
"threadlocal" { std::cout << "Keyword: " << yytext << '\n'; }
"try" { std::cout << "Keyword: " << yytext << '\n'; }
"union" { std::cout << "Keyword: " << yytext << '\n'; }
"unreachable" { std::cout << "Keyword: " << yytext << '\n'; }
"usingnamespace" { std::cout << "Keyword: " << yytext << '\n'; }
"var" { std::cout << "Keyword: " << yytext << '\n'; }
"volatile" { std::cout << "Keyword: " << yytext << '\n'; }
"while" { std::cout << "Keyword: " << yytext << '\n'; }

    /* Constants */

"true" { std::cout << "Boolean literal: " << yytext << '\n'; }
"false" { std::cout << "Boolean literal: " << yytext << '\n'; }
"null" { std::cout << "Null literal: " << yytext << '\n'; }
"undefined" { std::cout << "Constant: " << yytext << '\n'; }

    /* Integer types */

u[0-9]+ { std::cout << "Unsigned integer type: " << yytext << '\n'; }
i[0-9]+ { std::cout << "Signed integer type: " << yytext << '\n'; }

    /* Float types */

f16 { std::cout << "Float type: " << yytext << '\n'; }
f32 { std::cout << "Float type: " << yytext << '\n'; }
f64 { std::cout << "Float type: " << yytext << '\n'; }
f80 { std::cout << "Float type: " << yytext << '\n'; }
f128 { std::cout << "Float type: " << yytext << '\n'; }

    /* Other primitive types */

"bool" { std::cout << "Bool type: " << yytext << '\n'; }
"void" { std::cout << "Void type: " << yytext << '\n'; }
"noreturn" { std::cout << "Noreturn type: " << yytext << '\n'; }
"type" { std::cout << "Type: " << yytext << '\n'; }
"anyerror" { std::cout << "Anyerror type: " << yytext << '\n'; }
"anyopaque" { std::cout << "Anyopaque type: " << yytext << '\n'; }
"comptime_int" { std::cout << "Comptime int type: " << yytext << '\n'; }
"comptime_float" { std::cout << "Comptime float type: " << yytext << '\n'; }

    /* Pointer-sized types */

"usize" { std::cout << "Usize type: " << yytext << '\n'; }
"isize" { std::cout << "Isize type: " << yytext << '\n'; }

    /* C-compatible types */

"c_char" { std::cout << "C char type: " << yytext << '\n'; }
"c_short" { std::cout << "C short type: " << yytext << '\n'; }
"c_ushort" { std::cout << "C ushort type: " << yytext << '\n'; }
"c_int" { std::cout << "C int type: " << yytext << '\n'; }
"c_uint" { std::cout << "C uint type: " << yytext << '\n'; }
"c_long" { std::cout << "C long type: " << yytext << '\n'; }
"c_ulong" { std::cout << "C ulong type: " << yytext << '\n'; }
"c_longlong" { std::cout << "C longlong type: " << yytext << '\n'; }
"c_ulonglong" { std::cout << "C ulonglong type: " << yytext << '\n'; }
"c_longdouble" { std::cout << "C longdouble type: " << yytext << '\n'; }

    /* Identifiers */

[A-Za-z_][A-Za-z0-9_]* { std::cout << "Identifier: " << yytext << '\n'; }

    /* Builtin identifiers (@...) */

@[a-zA-Z_][a-zA-Z0-9_]* { std::cout << "Builtin identifier: " << yytext << '\n'; }

    /* Quoted identifiers (@"...") */

@\"([^\"\\\n]|\\.)*\" { std::cout << "Quoted identifier: " << yytext << '\n'; }

    /* Punctuators */

"[" { std::cout << "Punctuator: " << yytext << '\n'; }
"]" { std::cout << "Punctuator: " << yytext << '\n'; }
"{" { std::cout << "Punctuator: " << yytext << '\n'; }
"}" { std::cout << "Punctuator: " << yytext << '\n'; }
"(" { std::cout << "Punctuator: " << yytext << '\n'; }
")" { std::cout << "Punctuator: " << yytext << '\n'; }

    /* Separators */

"," { std::cout << "Separator: " << yytext << '\n'; }
":" { std::cout << "Separator: " << yytext << '\n'; }
";" { std::cout << "Semicolon: " << yytext << '\n'; }

    /* Operators (array) */

"++" { std::cout << "Operator (array concat): " << yytext << '\n'; }
"**" { std::cout << "Operator (array repeat): " << yytext << '\n'; }

    /* Operators (arithmetic) */

"+" { std::cout << "Operator (arithmetic): " << yytext << '\n'; }
"-" { std::cout << "Operator (arithmetic): " << yytext << '\n'; }
"*" { std::cout << "Operator (arithmetic): " << yytext << '\n'; }
"/" { std::cout << "Operator (arithmetic): " << yytext << '\n'; }
"%" { std::cout << "Operator (arithmetic): " << yytext << '\n'; }

    /* Wrapping (%) and saturating (|) arithmetic */

"+%" { std::cout << "Operator (wrapping): " << yytext << '\n'; }
"-%" { std::cout << "Operator (wrapping): " << yytext << '\n'; }
"*%" { std::cout << "Operator (wrapping): " << yytext << '\n'; }
"+|" { std::cout << "Operator (saturating): " << yytext << '\n'; }
"-|" { std::cout << "Operator (saturating): " << yytext << '\n'; }
"*|" { std::cout << "Operator (saturating): " << yytext << '\n'; }

    /* Operators (comparison) */

"==" { std::cout << "Operator (comparison): " << yytext << '\n'; }
"!=" { std::cout << "Operator (comparison): " << yytext << '\n'; }
"<=" { std::cout << "Operator (comparison): " << yytext << '\n'; }
">=" { std::cout << "Operator (comparison): " << yytext << '\n'; }
"<" { std::cout << "Operator (comparison): " << yytext << '\n'; }
">" { std::cout << "Operator (comparison): " << yytext << '\n'; }

    /* Operators (logical) */

"!" { std::cout << "Operator (logical): " << yytext << '\n'; }

    /* Operators (bitwise) */

"<<" { std::cout << "Operator (bitwise): " << yytext << '\n'; }
">>" { std::cout << "Operator (bitwise): " << yytext << '\n'; }
"<<|" { std::cout << "Operator (saturating): " << yytext << '\n'; }
"&" { std::cout << "Operator (bitwise): " << yytext << '\n'; }
"|" { std::cout << "Operator (bitwise): " << yytext << '\n'; }
"^" { std::cout << "Operator (bitwise): " << yytext << '\n'; }
"~" { std::cout << "Operator (bitwise): " << yytext << '\n'; }

    /* Operators (assignment) */

"<<=" { std::cout << "Operator (assignment): " << yytext << '\n'; }
">>=" { std::cout << "Operator (assignment): " << yytext << '\n'; }
"+=" { std::cout << "Operator (assignment): " << yytext << '\n'; }
"-=" { std::cout << "Operator (assignment): " << yytext << '\n'; }
"*=" { std::cout << "Operator (assignment): " << yytext << '\n'; }
"/=" { std::cout << "Operator (assignment): " << yytext << '\n'; }
"%=" { std::cout << "Operator (assignment): " << yytext << '\n'; }
"&=" { std::cout << "Operator (assignment): " << yytext << '\n'; }
"|=" { std::cout << "Operator (assignment): " << yytext << '\n'; }
"^=" { std::cout << "Operator (assignment): " << yytext << '\n'; }
"+%=" { std::cout << "Operator (assignment): " << yytext << '\n'; }
"-%=" { std::cout << "Operator (assignment): " << yytext << '\n'; }
"*%=" { std::cout << "Operator (assignment): " << yytext << '\n'; }
"+|=" { std::cout << "Operator (assignment): " << yytext << '\n'; }
"-|=" { std::cout << "Operator (assignment): " << yytext << '\n'; }
"*|=" { std::cout << "Operator (assignment): " << yytext << '\n'; }
"<<|=" { std::cout << "Operator (assignment): " << yytext << '\n'; }
"=" { std::cout << "Operator (assignment): " << yytext << '\n'; }

    /* Operators (other) */

".*" { std::cout << "Operator (struct deref): " << yytext << '\n'; }
".?" { std::cout << "Operator (optional unwrap): " << yytext << '\n'; }
"..." { std::cout << "Operator (range): " << yytext << '\n'; }
".." { std::cout << "Operator (range): " << yytext << '\n'; }
"->" { std::cout << "Operator (return type): " << yytext << '\n'; }
"=>" { std::cout << "Operator (switch prong): " << yytext << '\n'; }
"." { std::cout << "Operator (member): " << yytext << '\n'; }
"?" { std::cout << "Operator (optional): " << yytext << '\n'; }

[ \t\r\n]+ { /* ignored */ }

%%

int main(int argc, char* argv[]) {
    extern FILE* yyin;

    if (argc < 2) {
        std::cerr << "Missing command line argument (source file path)!\n";
        return 1;
    }

    yyin = fopen(argv[1], "r");

    if (!yyin) {
        std::cout << "File was not found!\n";
        return 1;
    }

    yylex();

    fclose(yyin);
    return 0;
}
