//const std = @import("std");

pub fn main() void {
    const x = 5;
    const y = 3;
    //var nums = [_]u8{ 1, 2, 3 };

    x = if (true) {
        4 + 5;
    } else false;

    x = return 4;

    _ = .{ x, y };
}
