#include "TypeNode.h"

TypeNode* TypeNode::CreatePrimitiveType(const std::string& name) {
    TypeNode* result = new TypeNode();
    result->nodeType = ENUM_TYPE_PRIMITIVE;
    result->name = name;
    return result;
}

TypeNode* TypeNode::CreateNameType(const std::string& name) {
    TypeNode* result = new TypeNode();
    result->nodeType = ENUM_TYPE_NAME;
    result->name = name;
    return result;
}

TypeNode* TypeNode::CreateArrayType(ExprNode* arraySize, TypeNode* elementType) {
    TypeNode* result = new TypeNode();
    result->nodeType = ENUM_TYPE_ARRAY;
    result->arraySize = arraySize;
    result->elementType = elementType;
    return result;
}

TypeNode* TypeNode::CreateStructType(DeclNode* members) {
    TypeNode* result = new TypeNode();
    result->nodeType = ENUM_TYPE_STRUCT;
    result->members = members;
    return result;
}

TypeNode* TypeNode::CreateEnumType(TypeNode* enumBaseType, DeclNode* members) {
    TypeNode* result = new TypeNode();
    result->nodeType = ENUM_TYPE_ENUM;
    result->enumBaseType = enumBaseType;
    result->members = members;
    return result;
}
