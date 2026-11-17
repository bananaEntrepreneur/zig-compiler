#include "DotPrinter.h"

std::ostream* DotPrinter::out = nullptr;

void DotPrinter::Print(ProgramNode* root, std::ostream& stream) {
    out = &stream;
    *out << "digraph AST {\n";
    *out << "    node [shape=box, fontname=\"Helvetica\"];\n";
    if (root != nullptr) PrintNode(root);
    *out << "}\n";
}

void DotPrinter::Node(int id, const std::string& label) {
    *out << "    n" << id << " [label=\"" << Escape(label) << "\"];\n";
}

void DotPrinter::Edge(int from, int to, const std::string& label) {
    *out << "    n" << from << " -> n" << to;
    if (!label.empty()) {
        *out << " [label=\"" << Escape(label) << "\"]";
    }
    *out << ";\n";
}

std::string DotPrinter::Escape(const std::string& text) {
    std::string result;
    for (char c : text) {
        if (c == '"' || c == '\\') {
            result += '\\';
            result += c;
        } else if (c == '\n') {
            result += "\\n";
        } else if (c != '\r') {
            result += c;
        }
    }
    return result;
}

std::string DotPrinter::Join(const std::vector<std::string>& parts, const std::string& separator) {
    std::string result;
    for (size_t i = 0; i < parts.size(); ++i) {
        if (i > 0) result += separator;
        result += parts[i];
    }
    return result;
}

int DotPrinter::PrintNode(ProgramNode* p) {
    Node(p->id, "program: " + p->name);
    Link(p->id, p->decls, "decls");
    return p->id;
}

int DotPrinter::PrintNode(DeclNode* d) {
    if (d == nullptr) return 0;
    switch (d->nodeType) {
        case ENUM_DECL_LIST:
            Node(d->id, "decl list");
            LinkList(d->id, d->items, "item");
            break;
        case ENUM_DECL_CONST:
            Node(d->id, "const: " + d->name + (d->isPublic ? " (pub)" : ""));
            Link(d->id, d->declType, "type");
            break;
        case ENUM_DECL_VAR:
            Node(d->id, "var: " + d->name + (d->isPublic ? " (pub)" : ""));
            Link(d->id, d->declType, "type");
            break;
        case ENUM_DECL_FN: {
            std::string label = "fn: " + d->name + (d->isPublic ? " (pub)" : "");
            if (d->returnsError) label += " (!)";
            Node(d->id, label);
            LinkList(d->id, d->params, "param");
            Link(d->id, d->returnType, "returns");
            break;
        }
        case ENUM_DECL_PARAM:
            Node(d->id, "param: " + d->name);
            Link(d->id, d->declType, "type");
            break;
        case ENUM_DECL_FIELD:
            Node(d->id, "field: " + d->name);
            Link(d->id, d->declType, "type");
            break;
    }
    return d->id;
}

int DotPrinter::PrintNode(TypeNode* t) {
    if (t == nullptr) return 0;
    switch (t->nodeType) {
        case ENUM_TYPE_PRIMITIVE:
            Node(t->id, "primitive: " + t->name);
            break;
        case ENUM_TYPE_NAME:
            Node(t->id, "type name: " + t->name);
            break;
        case ENUM_TYPE_ARRAY:
            Node(t->id, "array");
            Link(t->id, t->elementType, "element");
            break;
        case ENUM_TYPE_STRUCT:
            Node(t->id, "struct");
            Link(t->id, t->members, "members");
            break;
        case ENUM_TYPE_ENUM:
            Node(t->id, "enum");
            Link(t->id, t->enumBaseType, "base");
            Link(t->id, t->members, "members");
            break;
    }
    return t->id;
}
