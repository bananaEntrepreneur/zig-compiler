#ifndef ZIG_COMPILER_PROGRAMNODE_H
#define ZIG_COMPILER_PROGRAMNODE_H
#include <string>

#include "NodeId.h"

class DeclNode;

class ProgramNode {
    friend class DotPrinter;
protected:
    int id;
    std::string name;
    DeclNode* decls = nullptr;

    ProgramNode() { id = NextNodeId(); }

public:
    static ProgramNode* Create(const std::string& name, DeclNode* decls);
    std::string getName() const { return name; }
};

#endif // ZIG_COMPILER_PROGRAMNODE_H
