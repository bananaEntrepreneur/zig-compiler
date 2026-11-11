# zig-0.17-compiler

Reference for the subset of Zig. It's based on official Zig reference, but implement it's own logic. [parser-grammar.y](parser-grammar.y) contain only this grammar.

## Declaration

A source file is a list of declarations. `const` binds a name to a value that cannot change, `var` declares a variable that can, and `fn` declares a function. A variable must be initialized, and `undefined` stands for "no value yet". The type after the name may be left out when the value fixes it. `pub` makes a declaration visible to other files, and the entry point `main` has to be `pub`. A top-level declaration can be used above the line that declares it. **File is implicit struct.**

## Primitive type

Integers, floats, `bool` and `void`. `void` is allowed only as a function's return type. The integers are `i8`, `i16`, `i32`, `i64`, and `u8`, `u16`, `u32`, `u64`. The floats are `f32` and `f64`. Zig allows an integer of any width up to 65535 bits. Signed integer can't have bit width 0.

## User-defined type

In other words, a container: struct and enum. A container is a value, so it is declared by assigning it to a `const`, as in `const Point = struct { ... };`.

A struct lists fields with their types. A function declared inside the struct is a method, and `value.method(args)` calls it with the value as the first argument. 

An enum lists names, and an integer tag type may follow the keyword: `enum(u2)`. A name can take a value, as in `b = 5`, and the semantic stage then requires the tag type. An enum value is written as `Color.green`, or as `.green` when the context gives its type.

One `members` rule serves both containers. A field is a name, a name with a type, or a name with a value. The parser takes any of them in either container, and the semantic stage checks that the field fits. Fields and declarations may come in any order. A comma ends every field except the last member, so `enum { red, green }` is valid.

## Operator

The precedence follows the table in the language reference, tightest first: member access, call and index; prefix `-`, `!` and `try`; `*` `/` `%`; `+` `-`; `catch`; comparisons; `and`; `or`. Binary operators group to the left. Comparisons do not chain, so `a < b < c` is an error. Zig spells the logical operators as words, `and` and `or`, and negation as `!`. Both words skip the right operand when the left one decides the result. Assignment is the loosest operator in the table, but Zig treats it as a statement, so it is described under Block.

`ELSE` is in the precedence list for the `if` expression, which takes everything to its right: `if (c) a else b + 1` is `if (c) a else (b + 1)`. `{` is there so that `a + P{ .x = 1 }` attaches the literal to `P`.

An operand is a name, a literal, or an expression in parentheses.

## Array

`[N]T` is an array of `N` items of type `T`. `N` is an expression known at compile time, and `[_]T{ ... }` lets the compiler count the items. `array[i]` reads an item, and `array.len` is the length. Arrays nest, so `[4][5]f32` is four arrays of five floats.

`_` in `[_]` is read as an `ID`, and the semantic stage gives it the meaning "count the items".

### Anonymous struct literal

`.{ .x = 1, .y = 2 }` builds a struct value without naming its type, which comes from the place that receives the value. `.{ a, b }` is the same form with plain expressions, and `.{}` is empty. The call `std.debug.print("{} {}\n", .{ a, b })` uses it to pass its arguments. A type in front of the braces, as in `Point{ .x = 1, .y = 2 }` or `[_]i32{ 1, 2, 3 }`, gives the literal that type. A comma may follow the last item, so a literal can be split over several lines.

`expr init_body` also accepts forms with no meaning, such as `1{}` or `.{ 1, .x = 2 }`, and the semantic stage rejects them.

## Function

A function is declared with `fn`, a name, a parameter list in parentheses, a return type and a body block. Every parameter has a type, and a function that returns nothing has the return type `void`. `return` leaves the function and carries a value unless the return type is `void`.

A call is an expression followed by arguments in parentheses. A builtin call is the same with a name that starts with `@`. The parser takes any such name, and the semantic stage decides which builtins exist. `@import("std")` is the one the smallest program needs.

## Block

Blocks are used to limit the scope of variable declarations. A block is a list of statements between `{` and `}`, and a name declared inside it is not visible outside. In Zig a block is also an expression, but here it is only a statement. Treating it as an expression makes `{ ... } -x;` not supported, because it reads both as two statements and as one subtraction.

A statement is a local declaration, an expression followed by `;` (in practice a call), an assignment, `return`, `break`, `continue`, a nested block, or an `if`, `while` or `for`.

An assignment writes to a variable, a field or an array item. The compound forms apply the operator first, so `x += 1` is `x = x + 1`. Assignment is a statement, so `a = b = c` is an error.

## While

A while loop is used to repeatedly execute a block until some condition is no longer true. Use `break` to exit a while loop early. A while loop supports a continue expression after the condition, which runs each time the loop continues, and `continue` runs it too before the condition is tested again. The continue expression is an assignment.

## For

A for loop goes over the items of an array and names each one between `|` and `|`. A range `a..b` goes over the integers from `a` up to but not including `b`. The name has to be there, and `_` used when the item is not used.

## If

An `if` runs its first block when the condition is true and the block after `else` otherwise. `else if` chains another test. Braces are required around every block.

As an expression, `if` picks one of two values and needs the `else` part.

## Error

A function that can fail declares its return type as `!T`, which means a value of type `T` or an error. This is an error union. The `!` goes in front of the return type and nowhere else, and `!void` is a function that returns no value but can still fail.

`error.Name` is an error value. The name needs no declaration, and `return error.DivByZero;` makes the function fail. All errors form one set, so the type does not list which ones a function may return.

The parser reads `error` as an ordinary operand, so `error.Name` is a member access. The semantic stage accepts `error` only with a name right after it, as in `error.Name`, and rejects `error` alone and longer chains such as `error.A.B`.

An error union cannot be used as a `T` until it is unwrapped. `try x` gives the value of `x`, or returns the error from the current function when `x` failed, so it belongs in a function whose own return type is `!T`. `x catch d` gives the value of `x` or, on an error, the value of `d`. `x catch |e| h(e)` does the same and names the error `e` inside the handler.

The handler is an expression. `return` and a block are statements here, so `catch return` and `catch |e| { ... }` are not supported. `try` passes an error on, and a call in the handler deals with it.

Zig also names a set of errors, as in `error{ A, B }!T`. That is not supported. The semantic stage checks that the operand of `try` and `catch` is an error union and that the handler has the type `T`.

## Not implemented

Control flow: `switch`, `defer` and `errdefer`, `else` after a loop, and captures on `if` and `while`, as in `if (x) |v|`. Labeled blocks and loops, with `break :label` and `continue :label`, will not be implemented. A block, `return`, `break` and `continue` are statements, so `const x = { ... };` and `catch return` do not parse.

Types: pointers, slices, optionals (`?T`), unions, function types and `anytype`. The only type built from another type is the array `[N]T`.

Errors: a named set of errors (`error{ A, B }` and `E!T`), `orelse`, `unreachable`, and a block as a `catch` handler. `!T` is allowed only as a return type.

Operators: bitwise operators and shifts, and the array operators `++` and `**`.

Declarations: `comptime` and generics, `test` blocks, `extern`, `export` and `inline`.
