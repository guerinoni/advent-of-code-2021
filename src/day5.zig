// --- Day 5: Hydrothermal Venture ---
// You come across a field of hydrothermal vents on the ocean floor! These vents constantly produce large, opaque clouds, so it would be best to avoid them if possible.

// They tend to form in lines; the submarine helpfully produces a list of nearby lines of vents (your puzzle input) for you to review. For example:

// 0,9 -> 5,9
// 8,0 -> 0,8
// 9,4 -> 3,4
// 2,2 -> 2,1
// 7,0 -> 7,4
// 6,4 -> 2,0
// 0,9 -> 2,9
// 3,4 -> 1,4
// 0,0 -> 8,8
// 5,5 -> 8,2
// Each line of vents is given as a line segment in the format x1,y1 -> x2,y2 where x1,y1 are the coordinates of one end the line segment and x2,y2 are the coordinates of the other end. These line segments include the points at both ends. In other words:

// An entry like 1,1 -> 1,3 covers points 1,1, 1,2, and 1,3.
// An entry like 9,7 -> 7,7 covers points 9,7, 8,7, and 7,7.
// For now, only consider horizontal and vertical lines: lines where either x1 = x2 or y1 = y2.

// So, the horizontal and vertical lines from the above list would produce the following diagram:

// .......1..
// ..1....1..
// ..1....1..
// .......1..
// .112111211
// ..........
// ..........
// ..........
// ..........
// 222111....
// In this diagram, the top left corner is 0,0 and the bottom right corner is 9,9. Each position is shown as the number of lines which cover that point or . if no line covers that point. The top-left pair of 1s, for example, comes from 2,2 -> 2,1; the very bottom row is formed by the overlapping lines 0,9 -> 5,9 and 0,9 -> 2,9.

// To avoid the most dangerous areas, you need to determine the number of points where at least two lines overlap. In the above example, this is anywhere in the diagram with a 2 or larger - a total of 5 points.

// Consider only horizontal and vertical lines. At how many points do at least two lines overlap?

const std = @import("std");

const input = @embedFile("../input/day5.txt");

const Point = struct { x: u32, y: u32 };

const VentLine = struct {
    start: Point,
    end: Point,
};


const VentMap = struct {
    map: std.AutoHashMap(Point, u32) = std.AutoHashMap(Point, u32).init(std.testing.allocator),
    overlaps: u32 = 0,

    pub fn mark(self: *VentMap, x: u32, y: u32) void {
        const result = self.map.getOrPut(Point{ .x = x, .y = y }) catch unreachable;
        if (result.found_existing) {
            if (result.value_ptr.* == 1) {
                self.overlaps += 1;
            }
            result.value_ptr.* += 1;
        } else {
            result.value_ptr.* = 1;
        }
    }
};

pub fn solve() !void {
    var vents = blk: {
        var vents = std.ArrayList(VentLine).init(std.testing.allocator);
        defer vents.deinit();
        var lines = std.mem.tokenize(input, "\r\n");
        while (lines.next()) |line| {
            if (line.len == 0) {continue;}
            var parts = std.mem.tokenize(line, " ,->");
            vents.append(.{
                .start = .{
                    .x = try std.fmt.parseInt(u32, parts.next().?, 10),
                    .y = try std.fmt.parseInt(u32, parts.next().?, 10),
                },
                .end = .{
                    .x = try std.fmt.parseInt(u32, parts.next().?, 10),
                    .y = try std.fmt.parseInt(u32, parts.next().?, 10),
                },
            }) catch unreachable;
        }
        break :blk vents.toOwnedSlice();
    };
    
    std.log.info("Day5 \n\tpart 1 -> {}\n\tpart 2 -> {}", .{part1(vents), part2()});
}

fn part1(vents: []VentLine) !u32 {
    var map: VentMap = .{};
    for (vents) |it| {
        if (it.start.x == it.end.x) {
            var curr_y = std.math.min(it.start.y, it.end.y);
            const end_y = std.math.max(it.start.y, it.end.y);
            while (curr_y <= end_y) : (curr_y += 1) {
                map.mark(it.start.x, curr_y);
            }
        } else if (it.start.y == it.end.y) {
            var curr_x = std.math.min(it.start.x, it.end.x);
            const end_x = std.math.max(it.start.x, it.end.x);
            while (curr_x <= end_x) : (curr_x += 1) {
                map.mark(curr_x, it.start.y);
            }
        }
    }

    return map.overlaps;
}

fn part2() !u32 {
    return 0;
}