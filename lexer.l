%option noyywrap yylineno

%x MLSTR STR CHR QIDENT

%{
#include <iostream>
#include <string>
#include <cstdlib>
#include <cerrno>

static std::string ml;
static std::string literal;
static int literal_line;

static unsigned long long int_value(const char* text, int base);
static double float_value(const char* text);
static int count_codepoints(const std::string& text);
static void append_utf8(std::string& out, unsigned long codepoint);
static const char* literal_kind(int state);
%}

DEC [0-9](_?[0-9])*
HEX [0-9a-fA-F](_?[0-9a-fA-F])*
BIN [01](_?[01])*
OCT [0-7](_?[0-7])*

%%

    /* Comments */

"//!"[^\r\n]* { std::cout << "Top-level documentation comment: " << yytext << '\n'; }

"////"[^\r\n]* { std::cout << "Four slash single-line comment: " << yytext << '\n'; }

"///"[^\r\n]* { std::cout << "Documentation comment: " << yytext << '\n'; }

"//"[^\r\n]* { std::cout << "Single-line comment: " << yytext << '\n'; }

    /* Character and string literals */

' { literal.clear(); literal_line = yylineno; BEGIN(CHR); }

\" { literal.clear(); literal_line = yylineno; BEGIN(STR); }

@\" { literal.clear(); literal_line = yylineno; BEGIN(QIDENT); }

<CHR>[^\\'\n]+ { literal += yytext; }

<STR,QIDENT>[^\\"\n]+ { literal += yytext; }

    /* Escape sequences */

<CHR,STR,QIDENT>\\n { literal += '\n'; }
<CHR,STR,QIDENT>\\r { literal += '\r'; }
<CHR,STR,QIDENT>\\t { literal += '\t'; }
<CHR,STR,QIDENT>\\\\ { literal += '\\'; }
<CHR,STR,QIDENT>\\' { literal += '\''; }
<CHR,STR,QIDENT>\\\" { literal += '"'; }
<CHR,STR,QIDENT>\\x[0-9a-fA-F]{2} { literal += (char)strtol(yytext + 2, nullptr, 16); }
<CHR,STR,QIDENT>\\u\{[0-9a-fA-F]+\} { append_utf8(literal, strtoul(yytext + 3, nullptr, 16)); }

<CHR,STR,QIDENT>\\.? { std::cerr << "Line " << yylineno << ": invalid escape sequence: " << yytext << '\n'; }

    /* Closing delimiters */

<STR>\" { std::cout << "String literal: " << literal << '\n'; BEGIN(INITIAL); }

<QIDENT>\" { std::cout << "Quoted identifier: " << literal << '\n'; BEGIN(INITIAL); }

<CHR>' {
    if (count_codepoints(literal) == 1) {
        std::cout << "Char literal: " << literal << '\n';
    } else {
        std::cerr << "Line " << literal_line << ": character literal must hold exactly one character\n";
    }

    BEGIN(INITIAL);
}

    /* Unterminated literals */

<CHR,STR,QIDENT>\n { std::cerr << "Line " << literal_line << ": unterminated " << literal_kind(YY_START) << '\n'; BEGIN(INITIAL); }

<CHR,STR,QIDENT><<EOF>> { std::cerr << "Line " << literal_line << ": unterminated " << literal_kind(YY_START) << '\n'; BEGIN(INITIAL); }

    /* Strings */

\\\\ { ml.clear(); BEGIN(MLSTR); }

<MLSTR>[^\r\n]+ { ml += yytext; }

<MLSTR>\r?\n[ \t]*\\\\ { ml += '\n'; }

<MLSTR>\r?\n { std::cout << "Multiline string literal: " << ml << '\n'; BEGIN(INITIAL); }

<MLSTR><<EOF>> { std::cout << "Multiline string literal: " << ml << '\n'; BEGIN(INITIAL); }

    /* Numbers */

0x{HEX}(\.{HEX})?[pP][+-]?{DEC} { double v = float_value(yytext); std::cout << "Hex float literal: " << v << '\n'; }

0x{HEX} { unsigned long long v = int_value(yytext + 2, 16); std::cout << "Hex integer literal: " << v << '\n'; }

0b{BIN} { unsigned long long v = int_value(yytext + 2, 2); std::cout << "Binary integer literal: " << v << '\n'; }

0o{OCT} { unsigned long long v = int_value(yytext + 2, 8); std::cout << "Octal integer literal: " << v << '\n'; }

{DEC}\.{DEC}([eE][+-]?{DEC})? { double v = float_value(yytext); std::cout << "Float literal: " << v << '\n'; }

{DEC}[eE][+-]?{DEC} { double v = float_value(yytext); std::cout << "Float literal (exponent): " << v << '\n'; }

{DEC} { unsigned long long v = int_value(yytext, 10); std::cout << "Integer literal: " << v << '\n'; }

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

    /* Wrapping (%) and saturating (|) operators */

"+%" { std::cout << "Operator (wrapping): " << yytext << '\n'; }
"-%" { std::cout << "Operator (wrapping): " << yytext << '\n'; }
"*%" { std::cout << "Operator (wrapping): " << yytext << '\n'; }
"+|" { std::cout << "Operator (saturating): " << yytext << '\n'; }
"-|" { std::cout << "Operator (saturating): " << yytext << '\n'; }
"*|" { std::cout << "Operator (saturating): " << yytext << '\n'; }
"<<|" { std::cout << "Operator (saturating): " << yytext << '\n'; }

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
"=>" { std::cout << "Operator (switch prong): " << yytext << '\n'; }
"||" { std::cout << "Operator (error set merge): " << yytext << '\n'; }
"." { std::cout << "Operator (member): " << yytext << '\n'; }
"?" { std::cout << "Operator (optional): " << yytext << '\n'; }

[ \t\r\n]+ { /* ignored */ }

    /* Errors */

. { std::cerr << "Line " << yylineno << ": unexpected character: " << yytext << '\n'; }

%%

static void append_utf8(std::string& out, unsigned long codepoint) {
    if (codepoint < 0x80) {
        out += (char)codepoint;
    } else if (codepoint < 0x800) {
        out += (char)(0xC0 | (codepoint >> 6));
        out += (char)(0x80 | (codepoint & 0x3F));
    } else if (codepoint < 0x10000) {
        out += (char)(0xE0 | (codepoint >> 12));
        out += (char)(0x80 | ((codepoint >> 6) & 0x3F));
        out += (char)(0x80 | (codepoint & 0x3F));
    } else {
        out += (char)(0xF0 | (codepoint >> 18));
        out += (char)(0x80 | ((codepoint >> 12) & 0x3F));
        out += (char)(0x80 | ((codepoint >> 6) & 0x3F));
        out += (char)(0x80 | (codepoint & 0x3F));
    }
}

static const char* literal_kind(int state) {
    switch (state) {
        case CHR:    return "character literal";
        case QIDENT: return "quoted identifier";
        default:     return "string literal";
    }
}

static int count_codepoints(const std::string& text) {
    int count = 0;

    for (unsigned char c : text) {
        if ((c & 0xC0) != 0x80) {
            ++count;
        }
    }

    return count;
}

static std::string strip_underscores(const char* text) {
    std::string digits;

    for (; *text; ++text) {
        if (*text != '_') {
            digits += *text;
        }
    }

    return digits;
}

static unsigned long long int_value(const char* text, int base) {
    std::string digits = strip_underscores(text);

    errno = 0;
    unsigned long long value = strtoull(digits.c_str(), nullptr, base);

    if (errno == ERANGE) {
        std::cerr << "Line " << yylineno << ": integer literal out of range\n";
    }

    return value;
}

static double float_value(const char* text) {
    std::string digits = strip_underscores(text);

    errno = 0;
    double value = strtod(digits.c_str(), nullptr);

    if (errno == ERANGE) {
        std::cerr << "Line " << yylineno << ": float literal out of range\n";
    }

    return value;
}

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
