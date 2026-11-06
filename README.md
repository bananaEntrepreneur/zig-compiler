# zig-0.17-compiler

Reference for the subset of Zig.

## Notation

Lowercase names are nonterminals, uppercase names are tokens, and a quoted character is a token of its own. Lists are left recursive, and a name ending in `_opt` may be empty. The `expr` rule is split across sections, and each section holds the alternatives for its own construct.

```yacc
%token CONST VAR FN PUB IF ELSE WHILE FOR BREAK CONTINUE RETURN STRUCT ENUM
%token AND OR TRUE FALSE UNDEFINED
%token ID INT FLOAT CHAR STRING PRIMITIVE_TYPE BUILTIN
%token EQUAL NOT_EQUAL LESS_EQUAL GREAT_EQUAL DOT_DOT
%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN
```

`AND` and `OR` are the words `and` and `or`. `ID` is an identifier, and `BUILTIN` is `@` followed by a name. `INT`, `FLOAT`, `CHAR` and `STRING` are literals. `EQUAL`, `NOT_EQUAL`, `LESS_EQUAL` and `GREAT_EQUAL` are `==`, `!=`, `<=` and `>=`. `DOT_DOT` is `..`, and the `*_ASSIGN` tokens are `+=`, `-=`, `*=`, `/=` and `%=`.

## Declaration

A source file is a list of declarations. `const` binds a name to a value that cannot change, `var` declares a variable that can, and `fn` declares a function. A variable must be initialized, and `undefined` stands for "no value yet". The type after the name may be left out when the value fixes it. `pub` makes a declaration visible to other files, and the entry point `main` has to be `pub`. A top-level declaration can be used above the line that declares it. File is implicit struct.

## Primitive type

Integers, floats, `bool` and `void`. The integers are `i8`, `i16`, `i32`, `i64`, and `u8`, `u16`, `u32`, `u64`. The floats are `f32` and `f64`. Zig allows an integer of any width up to 65535 bits. The semantic stage decides which of them the compiler supports.

A type is a primitive type, the name of a user-defined type, or an array type.

## User-defined type

In other words, a container: struct and enum. A container is a value, so it is declared by assigning it to a `const`, as in `const Point = struct { ... };`.

A struct lists fields with their types. A function declared inside the struct is a method, and `value.method(args)` calls it with the value as the first argument. An enum lists names, and an integer tag type may follow the keyword: `enum(u2)`. An enum value is written as `Color.green`, or as `.green` when the context gives its type.

One `members` rule serves both containers. The parser takes a typed or an untyped field anywhere, and the semantic stage checks that the field fits its container. Fields come first, then declarations, and every field ends with a comma.

## Operator

The precedence follows the table in the language reference, tightest first: member access, call and index; prefix `-` and `!`; `*` `/` `%`; `+` `-`; comparisons; `and`; `or`. Binary operators group to the left. Comparisons do not chain, so `a < b < c` is an error. Zig spells the logical operators as words, `and` and `or`, and negation as `!`. Both words skip the right operand when the left one decides the result. Assignment is the loosest operator in the table, but Zig treats it as a statement, so it is described under Block.

`ELSE` is in the list for the `if` expression, which takes everything to its right: `if (c) a else b + 1` is `if (c) a else (b + 1)`. `{` is there so that `a + P{ .x = 1 }` attaches the literal to `P`.

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

Blocks are used to limit the scope of variable declarations. A block is a list of statements between `{` and `}`, and a name declared inside it is not visible outside. In Zig a block is also an expression, but here it is only a statement. Treating it as an expression makes `{ ... } -x;` ambiguous, because it reads both as two statements and as one subtraction.

A statement is a local declaration, an expression followed by `;` (in practice a call), an assignment, `return`, `break`, `continue`, a nested block, or an `if`, `while` or `for`.

An assignment writes to a variable, a field or an array item. The compound forms apply the operator first, so `x += 1` is `x = x + 1`. Assignment is a statement, so `a = b = c` is an error.

## While

A while loop is used to repeatedly execute a block until some condition is no longer true. Use `break` to exit a while loop early. A while loop supports a continue expression after the condition, which runs each time the loop continues, and `continue` runs it too before the condition is tested again. The continue expression is an assignment.

## For

A for loop goes over the items of an array and names each one between `|` and `|`. A range `a..b` goes over the integers from `a` up to but not including `b`. The name has to be there, and `_` can stand in when the item is not used.

## If

An `if` runs its first block when the condition is true and the block after `else` otherwise. `else if` chains another test. Braces are required around every block.

As an expression, `if` picks one of two values and needs the `else` part. Zig has no `?:` operator, and this form takes its place.

## Example

This program uses every construct above.

```zig
const std = @import("std");

const Point = struct {
    x: f32,
    y: f32,

    pub fn dot(self: Point, other: Point) f32 {
        return self.x * other.x + self.y * other.y;
    }
};

const Color = enum(u2) {
    red,
    green,
    blue,
};

fn sign(n: i32) i32 {
    if (n < 0) {
        return -1;
    } else if (n == 0) {
        return 0;
    }
    return 1;
}

pub fn main() void {
    const items = [_]i32{ 1, 2, 3 };
    const p = Point{ .x = 1.5, .y = 2.0 };
    const color: Color = .green;
    var buf: [10]u8 = undefined;
    var sum: i32 = 0;
    var i: i32 = 0;

    while (i < 10) : (i += 1) {
        if (i == 5) {
            continue;
        }
        sum += sign(i - 5);
    }

    for (items) |v| {
        sum += v;
    }

    for (0..10) |k| {
        buf[k] = 'a';
    }

    const big = if (sum > 5 and !(i == 0)) 47 else 3089;
    std.debug.print("{} {} {}\n", .{ sum, p.dot(p), big });
}
```
