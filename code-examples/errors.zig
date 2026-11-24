const std = @import("std");

pub fn main() !void {
    const value: i32 = -5;

    greaterThanZero(value) catch |err| {
        std.debug.print("Error: {}\n", .{err});
    };
}

fn greaterThanZero(value: i32) !void {
    if (value < 0) {
        return error.LessThanZero;
    } else if (value == 0) {
        return error.EqualToZero;
    } else {
        std.debug.print("Value is greater than zero: {}\n", .{value});
    }
}
