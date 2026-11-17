#include "ProgramNode.h"

ProgramNode* ProgramNode::Create(const std::string& name, DeclNode* decls) {
    ProgramNode* result = new ProgramNode();
    result->name = name;
    result->decls = decls;
    return result;
}
