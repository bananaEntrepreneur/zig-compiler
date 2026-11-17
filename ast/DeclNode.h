#ifndef ZIG_COMPILER_DECLNODE_H
#define ZIG_COMPILER_DECLNODE_H
#include <string>
#include <vector>

#include "NodeId.h"

class TypeNode;
class ExprNode;
class StmtNode;

enum DeclNodeType {
    ENUM_DECL_LIST,
    ENUM_DECL_CONST,
    ENUM_DECL_VAR,
    ENUM_DECL_FN,
    ENUM_DECL_PARAM,
    ENUM_DECL_FIELD,
};

class DeclNode {
    friend class DotPrinter;
protected:
    int id;
    DeclNodeType nodeType;

    bool isPublic = false;
    std::string name;
    TypeNode* declType = nullptr;
    ExprNode* initValue = nullptr;
    ExprNode* defaultValue = nullptr;

    std::vector<DeclNode*> params;
    TypeNode* returnType = nullptr;
    bool returnsError = false;
    StmtNode* body = nullptr;

    std::vector<DeclNode*> items;

    DeclNode() { id = NextNodeId(); }

    static DeclNode* CreateListImpl(DeclNode* first);
    static DeclNode* CreateEmptyListImpl();

public:
    static DeclNode* CreateDeclList(DeclNode* first);
    static DeclNode* CreateEmptyDeclList();
    static DeclNode* AddToDeclList(DeclNode* declList, DeclNode* newDecl);

    static DeclNode* CreateConstDecl(const std::string& name, TypeNode* type, ExprNode* initValue);
    static DeclNode* CreateVarDecl(const std::string& name, TypeNode* type, ExprNode* initValue);

    static DeclNode* CreateFnDecl(const std::string& name, DeclNode* paramList,
                                  TypeNode* returnType, bool returnsError, StmtNode* body);

    static DeclNode* CreateParamList(DeclNode* firstParam);
    static DeclNode* CreateEmptyParamList();
    static DeclNode* AddToParamList(DeclNode* paramList, DeclNode* newParam);

    static DeclNode* CreateParamDecl(const std::string& name, TypeNode* type);

    static DeclNode* CreateField(const std::string& name, TypeNode* type, ExprNode* defaultValue);

    static DeclNode* CreateMemberList(DeclNode* firstMember);
    static DeclNode* AddToMemberList(DeclNode* memberList, DeclNode* newMember);

    static DeclNode* CreateMembers(DeclNode* memberList);
    static DeclNode* AddFieldToMembers(DeclNode* members, DeclNode* field);

    std::vector<DeclNode*>& getItems()  { return items; }
    std::vector<DeclNode*>& getParams() { return params; }
    void setPublic(bool v)              { isPublic = v; }
};

#endif // ZIG_COMPILER_DECLNODE_H
