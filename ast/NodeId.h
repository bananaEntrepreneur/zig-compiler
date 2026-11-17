#ifndef ZIG_COMPILER_NODEID_H
#define ZIG_COMPILER_NODEID_H

inline int NextNodeId() {
    static int counter = 0;
    return ++counter;
}

#endif // ZIG_COMPILER_NODEID_H
