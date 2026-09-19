%{
#include <iostream>
%}

%%

// Comments

"///".* { std::cout << "Documentation comment: " << yytext << '\n'; }

"//!".* { std::cout << "Top-level documentation comment: " << yytext << '\n'; }

"//".* { std::cout << "Single-line comment: " << yytext << '\n'; }

'([^'\\\n]|\\.)' { std::cout << "Char literal: " << yytext << '\n'; }

// String

\"([^\"\\\n]|\\.)*\" { std::cout << "String literal: " << yytext << '\n'; }

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
