%x MLSTR

%{
#include <iostream>
#include <string>

static std::string ml;
%}

%%

    /* Comments */

"//!".* { std::cout << "Top-level documentation comment: " << yytext << '\n'; }

"////".* { std::cout << "Four slash single-line comment: " << yytext << '\n'; }

"///".* { std::cout << "Documentation comment: " << yytext << '\n'; }

"//".* { std::cout << "Single-line comment: " << yytext << '\n'; }

    /* Strings */

\"([^\"\\\n]|\\.)*\" { std::cout << "String literal: " << yytext << '\n'; }

\\\\ { ml.clear(); BEGIN(MLSTR); }

<MLSTR>[^\n]+ { ml += yytext; }

<MLSTR>\n[ \t]*\\\\ { ml += '\n'; }

<MLSTR>\n { std::cout << "Multiline string literal: " << ml << '\n'; BEGIN(INITIAL); }

<MLSTR><<EOF>> { std::cout << "Multiline string literal: " << ml << '\n'; BEGIN(INITIAL); }

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
