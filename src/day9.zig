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
    var lines = std.mem.tokenize(u8, input, "\n");
    var nums = std.ArrayList([]u8).init(std.testing.allocator);
    defer nums.deinit();
    var row_len: u64 = 0;
    while (lines.next()) |line| {
        row_len = line.len;
        var row = std.ArrayList(u8).init(std.testing.allocator);
        for (line) |ch| {
            try row.append(ch - '0');
        }
        try nums.append(row.toOwnedSlice());
    }

    std.log.info("Day9 \n\tpart 1 -> {}\n\tpart 2 -> {}", .{ part1(nums), part2(nums) });
}

fn part1(nums: std.ArrayList([]u8)) !u64 {
    var row: u64 = 0;
    var risk: u64 = 0;
    while (row < nums.items.len) : (row += 1) {
        var col: u64 = 0;
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

// --- Part Two ---
// Next, you need to find the largest basins so you know what areas are most important to avoid.

// A basin is all locations that eventually flow downward to a single low point. Therefore, every low point has a basin, although some basins are very small. Locations of height 9 do not count as being in any basin, and all other locations will always be part of exactly one basin.

// The size of a basin is the number of locations within the basin, including the low point. The example above has four basins.

// The top-left basin, size 3:

// 2199943210
// 3987894921
// 9856789892
// 8767896789
// 9899965678
// The top-right basin, size 9:

// 2199943210
// 3987894921
// 9856789892
// 8767896789
// 9899965678
// The middle basin, size 14:

// 2199943210
// 3987894921
// 9856789892
// 8767896789
// 9899965678
// The bottom-right basin, size 9:

// 2199943210
// 3987894921
// 9856789892
// 8767896789
// 9899965678
// Find the three largest basins and multiply their sizes together. In the above example, this is 9 * 14 * 9 = 1134.

// What do you get if you multiply together the sizes of the three largest basins?

const Point = struct {
    x: i64,
    y: i64,
};

fn find_basin_size(row: i64, col: i64, nums: std.ArrayList([]u8), already_seen: *std.AutoHashMap(Point, bool)) u64 {
    if (col < 0 or row < 0) {
        return 0;
    }

    var r = @intCast(usize, row);
    if (row >= nums.items.len or col >= nums.items[r].len) {
        return 0;
    }

    var c = @intCast(usize, col);
    var x = nums.items[r][c];
    var saw = already_seen.contains(Point{ .x = row, .y = col });
    if (x == 9 or saw) {
        return 0;
    }

    already_seen.put(Point{ .x = row, .y = col }, true) catch unreachable;
    var size = find_basin_size(row + 1, col, nums, already_seen);
    size += find_basin_size(row - 1, col, nums, already_seen);
    size += find_basin_size(row, col + 1, nums, already_seen);
    size += find_basin_size(row, col - 1, nums, already_seen);
    return size + 1;
}

fn part2(nums: std.ArrayList([]u8)) !u64 {
    var already_seen = std.AutoHashMap(Point, bool).init(std.testing.allocator);
    defer already_seen.deinit();

    var basin = std.ArrayList(u64).init(std.testing.allocator);
    defer basin.deinit();

    var row: i64 = 0;
    while (row < nums.items.len) : (row += 1) {
        var col: i64 = 0;
        var r = @intCast(usize, row);
        while (col < nums.items[r].len) : (col += 1) {
            var size = find_basin_size(row, col, nums, &already_seen);
            if (size > 0) {
                try basin.append(size);
            }
        }
    }

    var basins = basin.toOwnedSlice();

    std.sort.sort(u64, basins, {}, comptime std.sort.desc(u64));
    return basins[0] * basins[1] * basins[2];
}
