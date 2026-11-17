#include "DeclNode.h"

DeclNode* DeclNode::CreateListImpl(DeclNode* first) {
    DeclNode* result = new DeclNode();
    result->nodeType = ENUM_DECL_LIST;
    result->items.push_back(first);
    return result;
}

DeclNode* DeclNode::CreateEmptyListImpl() {
    DeclNode* result = new DeclNode();
    result->nodeType = ENUM_DECL_LIST;
    return result;
}

DeclNode* DeclNode::CreateDeclList(DeclNode* first) {
    return CreateListImpl(first);
}

DeclNode* DeclNode::CreateEmptyDeclList() {
    return CreateEmptyListImpl();
}

DeclNode* DeclNode::AddToDeclList(DeclNode* declList, DeclNode* newDecl) {
    declList->items.push_back(newDecl);
    return declList;
}

DeclNode* DeclNode::CreateConstDecl(const std::string& name, TypeNode* type, ExprNode* initValue) {
    DeclNode* result = new DeclNode();
    result->nodeType = ENUM_DECL_CONST;
    result->name = name;
    result->declType = type;
    result->initValue = initValue;
    return result;
}

DeclNode* DeclNode::CreateVarDecl(const std::string& name, TypeNode* type, ExprNode* initValue) {
    DeclNode* result = new DeclNode();
    result->nodeType = ENUM_DECL_VAR;
    result->name = name;
    result->declType = type;
    result->initValue = initValue;
    return result;
}

DeclNode* DeclNode::CreateFnDecl(const std::string& name, DeclNode* paramList,
                                 TypeNode* returnType, bool returnsError, StmtNode* body) {
    DeclNode* result = new DeclNode();
    result->nodeType = ENUM_DECL_FN;
    result->name = name;
    result->params = paramList->items;
    result->returnType = returnType;
    result->returnsError = returnsError;
    result->body = body;
    return result;
}

DeclNode* DeclNode::CreateParamList(DeclNode* firstParam) {
    return CreateListImpl(firstParam);
}

DeclNode* DeclNode::CreateEmptyParamList() {
    return CreateEmptyListImpl();
}

DeclNode* DeclNode::AddToParamList(DeclNode* paramList, DeclNode* newParam) {
    paramList->items.push_back(newParam);
    return paramList;
}

DeclNode* DeclNode::CreateParamDecl(const std::string& name, TypeNode* type) {
    DeclNode* result = new DeclNode();
    result->nodeType = ENUM_DECL_PARAM;
    result->name = name;
    result->declType = type;
    return result;
}

DeclNode* DeclNode::CreateField(const std::string& name, TypeNode* type, ExprNode* defaultValue) {
    DeclNode* result = new DeclNode();
    result->nodeType = ENUM_DECL_FIELD;
    result->name = name;
    result->declType = type;
    result->defaultValue = defaultValue;
    return result;
}

DeclNode* DeclNode::CreateMemberList(DeclNode* firstMember) {
    return CreateListImpl(firstMember);
}

DeclNode* DeclNode::AddToMemberList(DeclNode* memberList, DeclNode* newMember) {
    memberList->items.push_back(newMember);
    return memberList;
}

DeclNode* DeclNode::CreateMembers(DeclNode* memberList) {
    return CreateListImpl(memberList);
}

DeclNode* DeclNode::AddFieldToMembers(DeclNode* members, DeclNode* field) {
    members->items.push_back(field);
    return members;
}
