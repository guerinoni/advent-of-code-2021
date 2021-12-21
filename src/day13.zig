// --- Day 13: Transparent Origami ---
// You reach another volcanically active part of the cave. It would be nice if you could do some kind of thermal imaging so you could tell ahead of time which caves are too hot to safely enter.

// Fortunately, the submarine seems to be equipped with a thermal camera! When you activate it, you are greeted with:

// Congratulations on your purchase! To activate this infrared thermal imaging
// camera system, please enter the code found on page 1 of the manual.
// Apparently, the Elves have never used this feature. To your surprise, you manage to find the manual; as you go to open it, page 1 falls out. It's a large sheet of transparent paper! The transparent paper is marked with random dots and includes instructions on how to fold it up (your puzzle input). For example:

// 6,10
// 0,14
// 9,10
// 0,3
// 10,4
// 4,11
// 6,0
// 6,12
// 4,1
// 0,13
// 10,12
// 3,4
// 3,0
// 8,4
// 1,10
// 2,14
// 8,10
// 9,0

// fold along y=7
// fold along x=5
// The first section is a list of dots on the transparent paper. 0,0 represents the top-left coordinate. The first value, x, increases to the right. The second value, y, increases downward. So, the coordinate 3,0 is to the right of 0,0, and the coordinate 0,7 is below 0,0. The coordinates in this example form the following pattern, where # is a dot on the paper and . is an empty, unmarked position:

// ...#..#..#.
// ....#......
// ...........
// #..........
// ...#....#.#
// ...........
// ...........
// ...........
// ...........
// ...........
// .#....#.##.
// ....#......
// ......#...#
// #..........
// #.#........
// Then, there is a list of fold instructions. Each instruction indicates a line on the transparent paper and wants you to fold the paper up (for horizontal y=... lines) or left (for vertical x=... lines). In this example, the first fold instruction is fold along y=7, which designates the line formed by all of the positions where y is 7 (marked here with -):

// ...#..#..#.
// ....#......
// ...........
// #..........
// ...#....#.#
// ...........
// ...........
// -----------
// ...........
// ...........
// .#....#.##.
// ....#......
// ......#...#
// #..........
// #.#........
// Because this is a horizontal line, fold the bottom half up. Some of the dots might end up overlapping after the fold is complete, but dots will never appear exactly on a fold line. The result of doing this fold looks like this:

// #.##..#..#.
// #...#......
// ......#...#
// #...#......
// .#.#..#.###
// ...........
// ...........
// Now, only 17 dots are visible.

// Notice, for example, the two dots in the bottom left corner before the transparent paper is folded; after the fold is complete, those dots appear in the top left corner (at 0,0 and 0,1). Because the paper is transparent, the dot just below them in the result (at 0,3) remains visible, as it can be seen through the transparent paper.

// Also notice that some dots can end up overlapping; in this case, the dots merge together and become a single dot.

// The second fold instruction is fold along x=5, which indicates this line:

// #.##.|#..#.
// #...#|.....
// .....|#...#
// #...#|.....
// .#.#.|#.###
// .....|.....
// .....|.....
// Because this is a vertical line, fold left:

// #####
// #...#
// #...#
// #...#
// #####
// .....
// .....
// The instructions made a square!

// The transparent paper is pretty big, so for now, focus on just completing the first fold. After the first fold in the example above, 17 dots are visible - dots that end up overlapping after the fold is completed count as a single dot.

// How many dots are visible after completing just the first fold instruction on your transparent paper?

const std = @import("std");

const input = @embedFile("../input/day13.txt");

const Point = struct { x: u32, y: u32 };
const Fold = union(enum) { x: u32, y: u32 };

pub fn solve() !void {
    var input_parts = std.mem.split(u8, input, "\n\n");

    var points = std.ArrayList(Point).init(std.testing.allocator);
    defer points.deinit();
    var dots = std.mem.split(u8, input_parts.next().?, "\n");
    while (dots.next()) | line | {
        var parts = std.mem.split(u8, line, ",");
        const dot = Point {
            .x = try std.fmt.parseInt(u16, parts.next().?, 10),
            .y = try std.fmt.parseInt(u16, parts.next().?, 10),
        };

        try points.append(dot);
    }

    var folds = std.ArrayList(Fold).init(std.testing.allocator);
    defer folds.deinit();
    var lines = std.mem.split(u8, input_parts.next().?, "\n");
    while (lines.next()) | line | {
        const eq = std.mem.indexOf(u8, line, "=").?;
        const num = try std.fmt.parseInt(u32, line[eq + 1..], 10);
        var f = switch (line[eq - 1]) {
            'x' => Fold{ .x = num },
            'y' => Fold{ .y = num },
            else => unreachable
        };

        try folds.append(f);
    }

    var d = points.toOwnedSlice();
    var f = folds.toOwnedSlice();


    std.log.info("Day13 \n\tpart 1 -> {}\n\tpart 2 -> (ascii art)", .{part1(f[0..1], d)});
    try part2(f, d);
}

fn part1(folds: []Fold, dots: []Point) !u64 {
    var visible = std.AutoHashMap(Point, void).init(std.testing.allocator);
    defer visible.deinit();
    for (folds) | fold | {
        for (dots) | *dot | {
            switch (fold) {
                .x => |at| dot.x = std.math.min(2*at - dot.x, dot.x),
                .y => |at| dot.y = std.math.min(2*at - dot.y, dot.y)
            }
        }
    }

    for (dots) | dot | try visible.put(dot, {});
    return visible.count();
}

// --- Part Two ---
// Finish folding the transparent paper according to the instructions. The manual says the code is always eight capital letters.

// What code do you use to activate the infrared thermal imaging camera system?

fn part2(folds: []Fold, dots: []Point) !void {
    for (folds) | fold | {
        for (dots) | *dot | {
            switch (fold) {
                .x => |at| dot.x = std.math.min(2*at - dot.x, dot.x),
                .y => |at| dot.y = std.math.min(2*at - dot.y, dot.y)
            }
        }
    }

    var max_x : u32 = 0;
    var max_y : u32 = 0;
    for (dots) |dot| {
        if (dot.x > max_x) {
            max_x = dot.x;
        }

        if (dot.y > max_y) {
            max_y = dot.y;
        }
    }

    var col : u64 = 0;
    while (col <= max_y) : (col += 1) {
        var row : u64 = 0;
        while (row <= max_x) : (row += 1) {
            var found = false;
            for (dots) |dot| {
                if (dot.x == row and dot.y == col) {
                    std.debug.print("#", .{});
                    found = true;
                    break;
                }
            }
            if (found == false) std.debug.print(" ", .{});
        }
        std.debug.print("\n", .{});
    }
}
