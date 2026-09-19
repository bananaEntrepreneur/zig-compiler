#!/bin/sh

set -e

cd "$(dirname "$0")/.."

out=$(mktemp -d)

flex -o "$out/lexer.cpp" lexer.l

g++ -o "$out/lexer" "$out/lexer.cpp"

for f in tests/*/*.zig; do
    "$out/lexer" "$f" 2>&1 | diff -u "${f%.zig}.expected" - || exit 1
done

echo "OK"
