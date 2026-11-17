%option noyywrap yylineno

%x MLSTR STR CHR QIDENT

%{
#include <iostream>
#include <string>
#include <cstdlib>

#include "parser.tab.h"

static std::string ml;
static std::string literal;
static int literal_line;

static unsigned long long int_value(const char* text, int base);
static double float_value(const char* text);
static const char* literal_type_from_condition(int condition);
static void report(int line, const std::string& message);
static bool validate_int_size(const char* text);
%}

    /* Only DEC numbers can not start with zero */

DEC 0|[1-9](_?[0-9])*
HEX [0-9a-fA-F](_?[0-9a-fA-F])*
BIN [01](_?[01])*
OCT [0-7](_?[0-7])*

%%

    /* Comment. Match any comment. Anyway, they will be deleted by parser. */

"//"[^\r\n]* { std::cout << "Comment: " << yytext << '\n'; }

    /* Character literal */

' { literal.clear(); literal_line = yylineno; BEGIN(CHR); }

<CHR>[^\\'\n] { literal += yytext; }

<CHR>' {
    if (literal.size() == 1) {
        std::cout << "Char literal: " << literal << '\n';
    } else {
        report(literal_line, "character literal must hold exactly one character");
    }

    BEGIN(INITIAL);
}

    /* String literal */

\" { literal.clear(); literal_line = yylineno; BEGIN(STR); }

<STR,QIDENT>[^\\"\n]+ { literal += yytext; }

<STR>\" { std::cout << "String literal: " << literal << '\n'; BEGIN(INITIAL); }

    /* Quoted identifier. Backslash and escape sequences can be used - it will be just an id. */

@\" { literal.clear(); literal_line = yylineno; BEGIN(QIDENT); }

<QIDENT>\" { std::cout << "Quoted identifier: " << literal << '\n'; BEGIN(INITIAL); }

    /* Escape sequences */

<CHR,STR,QIDENT>\\n { literal += '\n'; }
<CHR,STR,QIDENT>\\r { literal += '\r'; }
<CHR,STR,QIDENT>\\t { literal += '\t'; }
<CHR,STR,QIDENT>\\\\ { literal += '\\'; }
<CHR,STR,QIDENT>\\' { literal += '\''; }
<CHR,STR,QIDENT>\\\" { literal += '"'; }
<CHR,STR,QIDENT>\\x[0-9a-fA-F]{2} { literal += (char)strtol(yytext + 2, nullptr, 16); }

    /* Other escape */

<CHR,STR,QIDENT>\\.? { report(yylineno, std::string("invalid escape sequence: ") + yytext); }

    /* No closing delimiter before the line or the file ends. Report which type of literal was left open. */

<CHR,STR,QIDENT>\n { report(literal_line, std::string("unterminated ") + literal_type_from_condition(YY_START)); BEGIN(INITIAL); }

<CHR,STR,QIDENT><<EOF>> { report(literal_line, std::string("unterminated ") + literal_type_from_condition(YY_START)); BEGIN(INITIAL); }

    /* Multiline string. Extra \n between last line and ';' don't count. */

\\\\ { ml.clear(); BEGIN(MLSTR); }

<MLSTR>[^\r\n]+ { ml += yytext; }

<MLSTR>\r?\n[ \t]*\\\\ { ml += '\n'; } // Может быть несколько пустых строчек между многострочными строчками

<MLSTR>\r?\n { std::cout << "Multiline string literal: " << ml << '\n'; BEGIN(INITIAL); }

<MLSTR><<EOF>> { std::cout << "Multiline string literal: " << ml << '\n'; BEGIN(INITIAL); }

    /* Numbers */
    /* Hex float may contain either a fractional part, or an exponential part, or both simultaneously. */
    /* Examples:  0x1.1p+1, 0x1.1, 0x11p+10, 0x1.1p10 */
0x{HEX}(\.{HEX}([pP][+-]?{DEC})?|[pP][+-]?{DEC}) { double v = float_value(yytext); std::cout << "Hex float literal: " << v << '\n'; }

0x{HEX} { unsigned long long v = int_value(yytext + 2, 16); std::cout << "Hex integer literal: " << v << '\n'; }

0b{BIN} { unsigned long long v = int_value(yytext + 2, 2); std::cout << "Binary integer literal: " << v << '\n'; }

0o{OCT} { unsigned long long v = int_value(yytext + 2, 8); std::cout << "Octal integer literal: " << v << '\n'; }

    /* DEC float may contain either a fractional part, or an exponential part, or both simultaneously. */
    /* Examples:  1.1e+1, 1.1, 11e+10, 1.1E10 */
{DEC}(\.{DEC}([eE][+-]?{DEC})?|[eE][+-]?{DEC}) { double v = float_value(yytext); std::cout << "Float literal: " << v << '\n'; }

{DEC} { unsigned long long v = int_value(yytext, 10); std::cout << "Integer literal: " << v << '\n'; }

    /* Keywords */

"and"        { return AND; }
"break"      { return BREAK; }
"catch"      { return CATCH; }
"const"      { return CONST; }
"continue"   { return CONTINUE; }
"else"       { return ELSE; }
"enum"       { return ENUM; }
"error"      { return ERROR; }
"fn"         { return FN; }
"for"        { return FOR; }
"if"         { return IF; }
"or"         { return OR; }
"pub"        { return PUB; }
"return"     { return RETURN; }
"struct"     { return STRUCT; }
"try"        { return TRY; }
"undefined"  { return UNDEFINED; }
"var"        { return VAR; }
"while"      { return WHILE; }
"addrspace"  { std::cout << "Keyword: " << yytext << '\n'; }
"align"      { std::cout << "Keyword: " << yytext << '\n'; }
"allowzero"  { std::cout << "Keyword: " << yytext << '\n'; }
"anyframe"   { std::cout << "Keyword: " << yytext << '\n'; }
"anytype"    { std::cout << "Keyword: " << yytext << '\n'; }
"asm"        { std::cout << "Keyword: " << yytext << '\n'; }
"callconv"   { std::cout << "Keyword: " << yytext << '\n'; }
"comptime"   { std::cout << "Keyword: " << yytext << '\n'; }
"defer"      { std::cout << "Keyword: " << yytext << '\n'; }
"errdefer"   { std::cout << "Keyword: " << yytext << '\n'; }
"export"     { std::cout << "Keyword: " << yytext << '\n'; }
"extern"     { std::cout << "Keyword: " << yytext << '\n'; }
"inline"     { std::cout << "Keyword: " << yytext << '\n'; }
"linksection"{ std::cout << "Keyword: " << yytext << '\n'; }
"noalias"    { std::cout << "Keyword: " << yytext << '\n'; }
"noinline"   { std::cout << "Keyword: " << yytext << '\n'; }
"nosuspend"  { std::cout << "Keyword: " << yytext << '\n'; }
"opaque"     { std::cout << "Keyword: " << yytext << '\n'; }
"orelse"     { std::cout << "Keyword: " << yytext << '\n'; }
"packed"     { std::cout << "Keyword: " << yytext << '\n'; }
"resume"     { std::cout << "Keyword: " << yytext << '\n'; }
"suspend"    { std::cout << "Keyword: " << yytext << '\n'; }
"switch"     { std::cout << "Keyword: " << yytext << '\n'; }
"test"       { std::cout << "Keyword: " << yytext << '\n'; }
"threadlocal"{ std::cout << "Keyword: " << yytext << '\n'; }
"union"      { std::cout << "Keyword: " << yytext << '\n'; }
"unreachable"{ std::cout << "Keyword: " << yytext << '\n'; }
"volatile"   { std::cout << "Keyword: " << yytext << '\n'; }
"null"       { std::cout << "Null literal: " << yytext << '\n'; }

    /* Constants */

"true"  { return BOOL; }
"false" { return BOOL; }

    /* Integer types. Number in [0,65535], no leading zero. */

u[0-9]+ { if (!validate_int_size(yytext)) return ERROR; yylval.StrVal = new std::string(yytext); return PRIMITIVE_TYPE; }
i[0-9]+ { if (!validate_int_size(yytext)) return ERROR; yylval.StrVal = new std::string(yytext); return PRIMITIVE_TYPE; }

    /* Float types */

f16  { yylval.StrVal = new std::string("f16");  return PRIMITIVE_TYPE; }
f32  { yylval.StrVal = new std::string("f32");  return PRIMITIVE_TYPE; }
f64  { yylval.StrVal = new std::string("f64");  return PRIMITIVE_TYPE; }
f80  { yylval.StrVal = new std::string("f80");  return PRIMITIVE_TYPE; }
f128 { yylval.StrVal = new std::string("f128"); return PRIMITIVE_TYPE; }

    /* Primitive types */

"bool"          { yylval.StrVal = new std::string("bool");         return PRIMITIVE_TYPE; }
"void"          { yylval.StrVal = new std::string("void");         return PRIMITIVE_TYPE; }
"noreturn"      { yylval.StrVal = new std::string("noreturn");     return PRIMITIVE_TYPE; }
"anyerror"      { yylval.StrVal = new std::string("anyerror");     return PRIMITIVE_TYPE; }
"anyopaque"     { yylval.StrVal = new std::string("anyopaque");    return PRIMITIVE_TYPE; }
"comptime_int"  { yylval.StrVal = new std::string("comptime_int"); return PRIMITIVE_TYPE; }
"comptime_float"{ yylval.StrVal = new std::string("comptime_float"); return PRIMITIVE_TYPE; }
"usize"         { yylval.StrVal = new std::string("usize");        return PRIMITIVE_TYPE; }
"isize"         { yylval.StrVal = new std::string("isize");        return PRIMITIVE_TYPE; }
"c_char"        { yylval.StrVal = new std::string("c_char");       return PRIMITIVE_TYPE; }
"c_short"       { yylval.StrVal = new std::string("c_short");      return PRIMITIVE_TYPE; }
"c_ushort"      { yylval.StrVal = new std::string("c_ushort");     return PRIMITIVE_TYPE; }
"c_int"         { yylval.StrVal = new std::string("c_int");        return PRIMITIVE_TYPE; }
"c_uint"        { yylval.StrVal = new std::string("c_uint");       return PRIMITIVE_TYPE; }
"c_long"        { yylval.StrVal = new std::string("c_long");       return PRIMITIVE_TYPE; }
"c_ulong"       { yylval.StrVal = new std::string("c_ulong");      return PRIMITIVE_TYPE; }
"c_longlong"    { yylval.StrVal = new std::string("c_longlong");   return PRIMITIVE_TYPE; }
"c_ulonglong"   { yylval.StrVal = new std::string("c_ulonglong");  return PRIMITIVE_TYPE; }
"c_longdouble"  { yylval.StrVal = new std::string("c_longdouble"); return PRIMITIVE_TYPE; }
"type"          { yylval.StrVal = new std::string("type");         return PRIMITIVE_TYPE; }

    /* Pointer-sized types */

"usize" { std::cout << "Usize type: " << yytext << '\n'; }
"isize" { std::cout << "Isize type: " << yytext << '\n'; }

    /* Identifiers */

[A-Za-z_][A-Za-z0-9_]*      { yylval.StrVal = new std::string(yytext); return ID; }

    /* Builtin identifiers. Lexer allows any identifier, but later only implecated functions will be allowed  */

@[a-zA-Z_][a-zA-Z0-9_]*     { yylval.StrVal = new std::string(yytext); return BUILTIN; }

/* Punctuators */

"[" { return '['; }
"]" { return ']'; }
"{" { return '{'; }
"}" { return '}'; }
"(" { return '('; }
")" { return ')'; }

    /* Separators */

"," { return ','; }
":" { return ':'; }
";" { return ';'; }

    /* Operators (array) */

"++" { std::cout << "Operator (array concat): " << yytext << '\n'; }
"**" { std::cout << "Operator (array repeat): " << yytext << '\n'; }

    /* Operators (arithmetic) */

"+" { return '+'; }
"-" { return '-'; }
"*" { return '*'; }
"/" { return '/'; }
"%" { return '%'; }

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
"<" { return '<'; }
">" { return '>'; }

    /* Operators (logical) */

"!" { return '!'; }

    /* Operators (bitwise) */

"<<" { std::cout << "Operator (bitwise): " << yytext << '\n'; }
">>" { std::cout << "Operator (bitwise): " << yytext << '\n'; }
"&" { std::cout << "Operator (bitwise): " << yytext << '\n'; }
"|" { return '|'; }
"^" { std::cout << "Operator (bitwise): " << yytext << '\n'; }
"~" { std::cout << "Operator (bitwise): " << yytext << '\n'; }

    /* Operators (assignment) */

"<<=" { std::cout << "Operator (assignment): " << yytext << '\n'; }
">>=" { std::cout << "Operator (assignment): " << yytext << '\n'; }
"+=" { return ADD_ASSIGN; }
"-=" { return SUB_ASSIGN; }
"*=" { return MUL_ASSIGN; }
"/=" { return DIV_ASSIGN; }
"%=" { return MOD_ASSIGN; }
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
"=" { return '='; }

    /* Operators (other) */

".*" { std::cout << "Operator (struct deref): " << yytext << '\n'; }
".?" { std::cout << "Operator (optional unwrap): " << yytext << '\n'; }
"..." { std::cout << "Operator (range): " << yytext << '\n'; }
".." { return DOT_DOT; }
"=>" { std::cout << "Operator (switch prong): " << yytext << '\n'; }
"||" { std::cout << "Operator (error set merge): " << yytext << '\n'; }
"." { return '.'; }
"?" { std::cout << "Operator (optional): " << yytext << '\n'; }

[ \t\r\n]+ { /* ignored */ }

    /* Errors */

<*>. { report(yylineno, std::string("unexpected character: ") + yytext); }

%%

/*! Print an error in the format "error: <message> in line: <line>". */
static void report(int line, const std::string& message) {
    std::cerr << "error: " << message << " in line: " << line << '\n';
}

/*! Get type of literal that lexer reads in a start condition.
 *  \param[in] condition number of start condition.
 *  \return the type of literal, or an empty string for a condition that reads no literal.
 */
static const char* literal_type_from_condition(int condition) {
    switch (condition) {
        case CHR:    return "character literal";
        case STR:    return "string literal";
        case QIDENT: return "quoted identifier";
    }

    return "";
}

/*! Validate integer size. A bit count above 65535
 *  or with a leading zero is reported as an error.
 *  \param[in] text type name, such as u8 or i32.
 *  \return whether the name is a valid integer type.
 */
static bool validate_int_size(const char* text) {
    std::string name = text;

    if (name.size() >= 3 && name[1] == '0') {
        report(yylineno, "primitive integer type '" + name + "' has leading zero");
        return false;
    }

    if (name.size() > 6 || strtoul(text + 1, nullptr, 10) > 65535) {
        report(yylineno, "primitive integer type '" + name + "' exceeds maximum bit width of 65535");
        return false;
    }

    return true;
}

static std::string strip_underscores(const char* text) {
    std::string digits;

    for (; *text; ++text) {
        if (*text != '_') digits += *text;
    }

    return digits;
}

/*! Parse an integer literal into its value.
 *  \param[in] text literal with skipped base prefix.
 *  \param[in] base 2, 8, 10 or 16.
 *  \return the value, saturated at ULLONG_MAX.
 */
static unsigned long long int_value(const char* text, int base) {
    std::string digits = strip_underscores(text);

    unsigned long long value = strtoull(digits.c_str(), nullptr, base);

    return value;
}

/*! Parse a floating-point literal into its value.
 *  Handles both decimal and hexadecimal forms.
 *  \param[in] text full literal text, prefix included.
 *  \return the value.
 */
static double float_value(const char* text) {
    std::string digits = strip_underscores(text);

    double value = strtod(digits.c_str(), nullptr);

    return value;
}