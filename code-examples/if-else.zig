const direction = enum {
    North,
    East,
    South,
    West,
};

const Color = enum(u8) {
    Red = 0,
    Green = 8,
    Blue = 255,
};

const Rectangle = struct {
    width: u8,
    height: u8,
    color: Color = Color.Red,
    direction: direction,

    pub fn area(self: Rectangle) u8 {
        return self.width * self.height;
    }

    fn isSquare(self: Rectangle) bool {
        return self.width == self.height;
    }
};

pub fn main() !void {
    var rectangle = Rectangle{
        .width = 6,
        .height = 4,
        .direction = direction.North,
    };
    const square: Rectangle = .{
        .width = 5,
        .height = 5,
        .color = .Blue,
        .direction = .West,
    };

    if (rectangle.width > rectangle.height) {
        const width = rectangle.width;
        rectangle.width = rectangle.height;
        rectangle.height = width;
        rectangle.direction = .East;
    }

    rectangle.color = if (rectangle.isSquare()) .Blue else if (rectangle.area() >= 20) .Green else rectangle.color;
    const larger = if (rectangle.area() > square.area()) rectangle else square;

    const shapes = [2]Rectangle{ rectangle, square };
    const selected = shapes[if (rectangle.direction == .East) 0 else 1];

    var total_area: u16 = 0;
    for (0..(if (selected.isSquare()) 1 else 2)) |index| {
        const shape = shapes[index];
        if (shape.isSquare()) continue;
        total_area += shape.area();
    }

    while (rectangle.width < rectangle.height) : (rectangle.width += 1) {
        if (rectangle.width == larger.width) rectangle.color = larger.color;
    }

    if (total_area != 24 or !rectangle.isSquare()) return error.UnexpectedResult;

    const condition = false;
    const result = if (condition) 42;
    std.debug.print("{}\n", .{result}); // выведет void

    const condition = true;
    const result = if (condition) 42;
    std.debug.print("{}\n", .{result}); // выведет 42

}
