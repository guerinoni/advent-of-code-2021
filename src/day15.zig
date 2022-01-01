// --- Day 15: Chiton ---
// 
// You've almost reached the exit of the cave, but the walls are getting closer together. Your submarine can barely still fit, though; the main problem is that the walls of the cave are covered in chitons, and it would be best not to bump any of them.
// 
// The cavern is large, but has a very low ceiling, restricting your motion to two dimensions. The shape of the cavern resembles a square; a quick scan of chiton density produces a map of risk level throughout the cave (your puzzle input). For example:
// 
// 1163751742
// 1381373672
// 2136511328
// 3694931569
// 7463417111
// 1319128137
// 1359912421
// 3125421639
// 1293138521
// 2311944581
// 
// You start in the top left position, your destination is the bottom right position, and you cannot move diagonally. The number at each position is its risk level; to determine the total risk of an entire path, add up the risk levels of each position you enter (that is, don't count the risk level of your starting position unless you enter it; leaving it adds no risk to your total).
// 
// Your goal is to find a path with the lowest total risk. In this example, a path with the lowest total risk is highlighted here:
// 
// 1163751742
// 1381373672
// 2136511328
// 3694931569
// 7463417111
// 1319128137
// 1359912421
// 3125421639
// 1293138521
// 2311944581
// 
// The total risk of this path is 40 (the starting position is never entered, so its risk is not counted).
// 
// What is the lowest total risk of any path from the top left to the bottom right?

const std = @import("std");

const input = @embedFile("../input/day15.txt");

pub fn solve() !void {
    var map = std.ArrayList(u8).init(std.testing.allocator);
    defer map.deinit();
    var width : usize = 0;
    {
        var maybeWidth : ?usize = null;
        var lines = std.mem.tokenize(u8, input, "\r\n");
        while (lines.next()) | line | {
            if (maybeWidth == null) {
                maybeWidth = line.len;
            }
        
            for (line) | c | { try map.append(c - '0'); }
        }

        width = maybeWidth.?;
    }

    std.log.info("Day15 \n\tpart 1 -> {}\n\tpart 2 -> {}", .{part1(map, width), part2()});
}

fn part1(map: std.ArrayList(u8), width: usize) !u64 {
    return try a_star(map, width);
}

fn a_star(map: std.ArrayList(u8), width: usize) !usize {
    var open_set = std.ArrayList(usize).init(std.testing.allocator);
    defer open_set.deinit();
    try open_set.append(0);

    var costs = std.ArrayList(u32).init(std.testing.allocator);
    defer costs.deinit();

    try costs.appendNTimes(std.math.maxInt(u32) - 10, map.items.len);
    costs.items[0] = 0;

    while (open_set.items.len > 0) {
        const current = open_set.orderedRemove(0);
        if (current == (map.items.len - 1)) {
            return costs.items[current] + map.items[current] - map.items[0];
        }

        const x = current % width;
        const y = current / width;
        const cost = map.items[current] + costs.items[current];

        if (x > 0) {
            const neighbour = current - 1;

            if (cost < costs.items[neighbour]) {
                costs.items[neighbour] = cost;
                try append_neighbour(neighbour, &open_set, costs);
            }
        }

        if (x < (width - 1)) {
            const neighbour = current + 1;

            if (cost < costs.items[neighbour]) {
                costs.items[neighbour] = cost;
                try append_neighbour(neighbour, &open_set, costs);
            }
        }

        if (y > 0) {
            const neighbour = current - width;
            if (cost < costs.items[neighbour]) {
                costs.items[neighbour] = cost;
                try append_neighbour(neighbour, &open_set, costs);
            }
        }

        if (y < (width - 1)) {
            const neighbour = current + width;
            if (cost < costs.items[neighbour]) {
                costs.items[neighbour] = cost;
                try append_neighbour(neighbour, &open_set, costs);
            }
        }
    }
    
    unreachable;
}

fn append_neighbour(neighbour : usize, open_set : *std.ArrayList(usize), costs : std.ArrayList(u32)) !void {
    var insertIndex : ?usize = null;
    for (open_set.items) | item, i | {
        if (compare(costs, item, neighbour)) { continue; }
        insertIndex = i;
        break;
    }

    if (insertIndex == null) {
        try open_set.append(neighbour);
    } else {
        try open_set.insert(insertIndex.?, neighbour);
        {
            var index = insertIndex.? + 1;
            while (index < open_set.items.len) : (index += 1) {
                const item = open_set.items[index];
                if (item == neighbour) {
                    _ = open_set.orderedRemove(index);
                    break;
                }
            }
        }
    }
}

fn compare(costs: std.ArrayList(u32), a: usize, b: usize) bool {
    return costs.items[a] < costs.items[b];
}

fn part2() !u64 {
    return 0;
}
