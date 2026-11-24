const std = @import("std");

pub fn main() !void {
    const a = [_]u8{ 1, 2, 3 };
    const b = [_]u8{ 4, 5, 6 };
    const c = [_]u8{ 7, 8, 9 };

    // not implementing
    for (a, b, c) |x, y, z| {
        try std.debug.print("{d}+{d}+{d}={d}\n", .{ x, y, z, x + y + z });
    }
}
