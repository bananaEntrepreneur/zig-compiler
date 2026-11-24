const std = @import("std");

pub fn main(init: std.process.Init) !void {
    var buffer: [4096]u8 = undefined;
    var stdout = std.Io.File.stdout().writerStreaming(init.io, &buffer);

    const string = " banana, apple, cherry ";
    const trimmed_str = std.mem.trim(u8, string, &std.ascii.whitespace);
    var it = std.mem.splitScalar(u8, trimmed_str, ',');

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var list: std.ArrayList([]const u8) = .empty;

    while (it.next()) |item| {
        const fruit = std.mem.trim(u8, item, " ");
        try stdout.interface.print("fruit: {s}\n", .{fruit});
        try list.append(allocator, fruit);

        if (std.mem.eql(u8, fruit, "banana")) {
            var na_count: usize = 0;
            var rest = fruit;

            while (std.mem.indexOf(u8, rest, "na")) |index| {
                na_count += 1;
                rest = rest[index + 2 ..];
            }

            try stdout.interface.print(
                "banana has {d} 'na'\n",
                .{na_count},
            );
        }
    }

    const joined = try std.mem.join(allocator, "; ", list.items);
    try stdout.interface.print("joined fruits: {s}\n", .{joined});

    try stdout.flush();
}
