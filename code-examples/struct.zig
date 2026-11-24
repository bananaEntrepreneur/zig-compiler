const std = @import("std");

const Rectangle = struct {
    width: u32,
    height: u32,

    fn area(self: Rectangle) u32 {
        return self.width * self.height;
    }
};

const Config = struct {
    port: u16 = 8080,
    host: []const u8 = "localhost",
};

pub fn main() void {
    const x = 5;

    const y = [0]u8{};
    const i = [_]u8{};

    const conf1: Config = Config{};
    const conf2: Config = .{};

    _ = y;
    _ = i;
    _ = conf1;
    _ = conf2;

    std.debug.print("{d}", .{x});
}
