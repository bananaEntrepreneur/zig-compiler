#ifndef ZIG_COMPILER_TYPENODE_H
#define ZIG_COMPILER_TYPENODE_H
#include <string>
#include <vector>

#include "NodeId.h"

class ExprNode;
class DeclNode;

enum TypeNodeType {
    ENUM_TYPE_PRIMITIVE,
    ENUM_TYPE_NAME,
    ENUM_TYPE_ARRAY,
    ENUM_TYPE_STRUCT,
    ENUM_TYPE_ENUM,
};

class TypeNode {
    friend class DotPrinter;
protected:
    int id;
    TypeNodeType nodeType;

    std::string name;
    ExprNode* arraySize = nullptr;
    TypeNode* elementType = nullptr;
    TypeNode* enumBaseType = nullptr;
    DeclNode* members = nullptr;

    TypeNode() { id = NextNodeId(); }

public:
    static TypeNode* CreatePrimitiveType(const std::string& name);
    static TypeNode* CreateNameType(const std::string& name);
    static TypeNode* CreateArrayType(ExprNode* arraySize, TypeNode* elementType);
    static TypeNode* CreateStructType(DeclNode* members);
    static TypeNode* CreateEnumType(TypeNode* enumBaseType, DeclNode* members);
};

#endif // ZIG_COMPILER_TYPENODE_H
