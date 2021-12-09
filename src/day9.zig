// --- Day 9: Smoke Basin ---
// These caves seem to be lava tubes. Parts are even still volcanically active; small hydrothermal vents release smoke into the caves that slowly settles like rain.

// If you can model how the smoke flows through the caves, you might be able to avoid it and be that much safer. The submarine generates a heightmap of the floor of the nearby caves for you (your puzzle input).

// Smoke flows to the lowest point of the area it's in. For example, consider the following heightmap:

// 2199943210
// 3987894921
// 9856789892
// 8767896789
// 9899965678
// Each number corresponds to the height of a particular location, where 9 is the highest and 0 is the lowest a location can be.

// Your first goal is to find the low points - the locations that are lower than any of its adjacent locations. Most locations have four adjacent locations (up, down, left, and right); locations on the edge or corner of the map have three or two adjacent locations, respectively. (Diagonal locations do not count as adjacent.)

// In the above example, there are four low points, all highlighted: two are in the first row (a 1 and a 0), one is in the third row (a 5), and one is in the bottom row (also a 5). All other locations on the heightmap have some lower adjacent location, and so are not low points.

// The risk level of a low point is 1 plus its height. In the above example, the risk levels of the low points are 2, 1, 6, and 6. The sum of the risk levels of all low points in the heightmap is therefore 15.

// Find all of the low points on your heightmap. What is the sum of the risk levels of all low points on your heightmap?

const std = @import("std");

const input = @embedFile("../input/day9.txt");

pub fn solve() !void {
    var lines = std.mem.tokenize(input, "\n");
    var nums = std.ArrayList([]u8).init(std.testing.allocator);
    defer nums.deinit();    
    var row_len : u64 = 0;
    while (lines.next()) | line | {
        row_len = line.len;
        var row = std.ArrayList(u8).init(std.testing.allocator);
        for (line) | ch | {
            try row.append(ch - '0');
        }
        try nums.append(row.toOwnedSlice());
    }

    std.log.info("Day9 \n\tpart 1 -> {}\n\tpart 2 -> {}", .{part1(nums), part2()});
}

fn part1(nums: std.ArrayList([]u8)) !u64 {
    var row : u64 = 0;
    var risk : u64 = 0;
    while (row < nums.items.len) : (row += 1) {
        var col : u64 = 0;
        while (col < nums.items[row].len) : (col += 1) {
            var x = nums.items[row][col];
            var r = @intCast(i64, row);
            if (r - 1 >= 0) {
                var rr = r - 1;
                if (x >= nums.items[@intCast(usize, rr)][col]) {
                    continue;
                }
            }

            if (row + 1 < nums.items.len) {
                if (x >= nums.items[row + 1][col]) {
                    continue;
                }
            }

            var c = @intCast(i64, col);
            if (c - 1 >= 0) {
                var cc = c - 1;
                if (x >= nums.items[row][@intCast(usize, cc)]) {
                    continue;
                }
            }

            if (col + 1 < nums.items[row].len) {
                if (x >= nums.items[row][col + 1]) {
                    continue;
                }
            }

            risk += x + 1;
        }
    }

    return risk;
}

fn part2() !u64 {
    return 0;
}