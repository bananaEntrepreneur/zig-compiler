const std = @import("std");

const size: usize = 10;
const SIZE: usize = 20;
const condition = true;

const MyType = struct {
    value: i32,
};

const User = struct {
    id: u32,
    age: u8,
};

const Color = enum {
    red,
    green,
    blue,
};

const Direction = enum(u8) {
    north,
    south,
    east,
    west,
};

const Config = struct {
    array: struct {
        size: usize,
    },
};

const Object = struct {
    pub fn getSize(self: Object) usize {
        _ = self;
        return 5;
    }
};

fn getSize(value: usize) usize {
    return value;
}

fn getOptionalSize() ?usize {
    return 10;
}

fn getErrorSize() error{Failed}!usize {
    return 10;
}

pub fn main() void {
    // ограничить var для контейнеров
    var MyType2 = struct {
        value: u8,
    };

    const b1 = MyType2{ .value = 2 };
    _ = b1;

    MyType2 = struct {
        value1: u8,
    };
    const a1: [5]i32 = .{ 1, 2, 3, 4, 5 };

    const a2: [10]MyType = .{
        .{ .value = 10 },
        .{ .value = 20 },
        .{ .value = 30 },
        .{ .value = 40 },
        .{ .value = 50 },
        .{ .value = 60 },
        .{ .value = 70 },
        .{ .value = 80 },
        .{ .value = 90 },
        .{ .value = 100 },
    };

    const a3: [2][3][4]u8 = undefined;

    const a8: [2 + 3 * 4]i32 = undefined;

    const a11: [if (5 == 5) 10 else 20]i32 = undefined;

    const config = Config{
        .array = .{ .size = 5 },
    };
    const a12: [config.array.size]i32 = undefined;

    const a13: [getSize(5)]i32 = undefined;

    const object = Object{};
    const a14: [object.getSize()]i32 = undefined;

    const a15: [@sizeOf(i32)]u8 = undefined;

    const a16: [try getErrorSize()]i32 = undefined;

    const a17: [if (condition) 10 else 5]i32 = undefined;

    const a19: [
        getErrorSize() catch |err| switch (err) {
            error.Failed => 5,
        }
    ]i32 = undefined;

    const a20: [(2 + 3) * 4]i32 = undefined;

    const source = [_]usize{ 5, 10, 15 };
    const a21: [source[0]]i32 = undefined;

    const a22 = [3]i32{ 1, 2, 3 };

    const a23 = [2][2]i32{
        .{ 1, 2 },
        .{ 3, 4 },
    };

    _ = .{
        SIZE,
        a1,
        a2,
        a3,
        a8,
        a11,
        a12,
        a13,
        a14,
        a15,
        a16,
        a17,
        a19,
        a20,
        a21,
        a22,
        a23,
    };
}
