// --- Day 12: Passage Pathing ---
// With your submarine's subterranean subsystems subsisting suboptimally, the only way you're getting out of this cave anytime soon is by finding a path yourself. Not just a path - the only way to know if you've found the best path is to find all of them.

// Fortunately, the sensors are still mostly working, and so you build a rough map of the remaining caves (your puzzle input). For example:

// start-A
// start-b
// A-c
// A-b
// b-d
// A-end
// b-end
// This is a list of how all of the caves are connected. You start in the cave named start, and your destination is the cave named end. An entry like b-d means that cave b is connected to cave d - that is, you can move between them.

// So, the above cave system looks roughly like this:

//     start
//     /   \
// c--A-----b--d
//     \   /
//      end
// Your goal is to find the number of distinct paths that start at start, end at end, and don't visit small caves more than once. There are two types of caves: big caves (written in uppercase, like A) and small caves (written in lowercase, like b). It would be a waste of time to visit any small cave more than once, but big caves are large enough that it might be worth visiting them multiple times. So, all paths you find should visit small caves at most once, and can visit big caves any number of times.

// Given these rules, there are 10 paths through this example cave system:

// start,A,b,A,c,A,end
// start,A,b,A,end
// start,A,b,end
// start,A,c,A,b,A,end
// start,A,c,A,b,end
// start,A,c,A,end
// start,A,end
// start,b,A,c,A,end
// start,b,A,end
// start,b,end
// (Each line in the above list corresponds to a single path; the caves visited by that path are listed in the order they are visited and separated by commas.)

// Note that in this cave system, cave d is never visited by any path: to do so, cave b would need to be visited twice (once on the way to cave d and a second time when returning from cave d), and since cave b is small, this is not allowed.

// Here is a slightly larger example:

// dc-end
// HN-start
// start-kj
// dc-start
// dc-HN
// LN-dc
// HN-end
// kj-sa
// kj-HN
// kj-dc
// The 19 paths through it are as follows:

// start,HN,dc,HN,end
// start,HN,dc,HN,kj,HN,end
// start,HN,dc,end
// start,HN,dc,kj,HN,end
// start,HN,end
// start,HN,kj,HN,dc,HN,end
// start,HN,kj,HN,dc,end
// start,HN,kj,HN,end
// start,HN,kj,dc,HN,end
// start,HN,kj,dc,end
// start,dc,HN,end
// start,dc,HN,kj,HN,end
// start,dc,end
// start,dc,kj,HN,end
// start,kj,HN,dc,HN,end
// start,kj,HN,dc,end
// start,kj,HN,end
// start,kj,dc,HN,end
// start,kj,dc,end
// Finally, this even larger example has 226 paths through it:

// fs-end
// he-DX
// fs-he
// start-DX
// pj-DX
// end-zg
// zg-sl
// zg-pj
// pj-he
// RW-he
// fs-DX
// pj-RW
// zg-RW
// start-pj
// he-WI
// zg-he
// pj-fs
// start-RW
// How many paths through this cave system are there that visit small caves at most once?

const std = @import("std");

const input = @embedFile("../input/day12.txt");

const Edge = struct {
    a: u8,
    b: u8,
};

pub fn solve() !void {
    var edges: []const Edge = undefined;
    var names: []const []const u8 = undefined;
    {
        var cave_ids = std.StringHashMap(u8).init(std.testing.allocator);
        defer cave_ids.deinit();
        var cave_names = std.ArrayList([]const u8).init(std.testing.allocator);
        defer cave_names.deinit();
        var edges_l = std.ArrayList(Edge).init(std.testing.allocator);
        defer edges_l.deinit();

        try cave_ids.put("start", 0);
        try cave_ids.put("end", 1);
        try cave_names.append("start");
        try cave_names.append("end");
        // 2 because 0=start 1=end
        var next_cave_id: u8 = 2;

        var lines = std.mem.tokenize(u8, input, "\r\n");
        while (lines.next()) |line| {
            var parts = std.mem.split(u8, line, "-");
            const a = parts.next().?;
            const b = parts.next().?;

            const a_id = cave_ids.get(a) orelse blk: {
                const id = next_cave_id;
                next_cave_id += 1;
                try cave_ids.put(a, id);
                try cave_names.append(a);
                break :blk id;
            };

            const b_id = cave_ids.get(b) orelse blk: {
                const id = next_cave_id;
                next_cave_id += 1;
                try cave_ids.put(b, id);
                try cave_names.append(b);
                break :blk id;
            };

            try edges_l.append(.{ .a = a_id, .b = b_id });
        }

        edges = edges_l.toOwnedSlice();
        names = cave_names.toOwnedSlice();
    }

    std.log.info("Day12 \n\tpart 1 -> {}\n\tpart 2 -> {}", .{ part1(names, edges), part2(names, edges) });
}

const Walk = struct {
    already_hit: std.DynamicBitSet,
    names: []const []const u8,
    edges: []const Edge,

    fn countPaths(self: *@This(), id: u8, revisit: bool) usize {
        if (id == 1) return 1; // id of end
        var is_set = false;
        if (self.already_hit.isSet(id)) {
            if (!revisit or id == 0) return 0;
            is_set = true;
        } else if (self.names[id][0] >= 'a') {
            self.already_hit.set(id);
        }
        defer if (!is_set) {
            self.already_hit.unset(id);
        };
        var paths: usize = 0;
        for (self.edges) |edge| {
            const n = if (edge.a == id) edge.b else if (edge.b == id) edge.a else continue;
            paths += self.countPaths(n, revisit and !is_set);
        }
        return paths;
    }
};

fn part1(names: []const []const u8, edges: []const Edge) !u64 {
    var walk = Walk{
        .edges = edges,
        .names = names,
        .already_hit = try std.DynamicBitSet.initEmpty(std.testing.allocator, names.len),
    };
    defer walk.already_hit.deinit();
    return walk.countPaths(0, false);
}

// --- Part Two ---
// After reviewing the available paths, you realize you might have time to visit a single small cave twice. Specifically, big caves can be visited any number of times, a single small cave can be visited at most twice, and the remaining small caves can be visited at most once. However, the caves named start and end can only be visited exactly once each: once you leave the start cave, you may not return to it, and once you reach the end cave, the path must end immediately.

// Now, the 36 possible paths through the first example above are:

// start,A,b,A,b,A,c,A,end
// start,A,b,A,b,A,end
// start,A,b,A,b,end
// start,A,b,A,c,A,b,A,end
// start,A,b,A,c,A,b,end
// start,A,b,A,c,A,c,A,end
// start,A,b,A,c,A,end
// start,A,b,A,end
// start,A,b,d,b,A,c,A,end
// start,A,b,d,b,A,end
// start,A,b,d,b,end
// start,A,b,end
// start,A,c,A,b,A,b,A,end
// start,A,c,A,b,A,b,end
// start,A,c,A,b,A,c,A,end
// start,A,c,A,b,A,end
// start,A,c,A,b,d,b,A,end
// start,A,c,A,b,d,b,end
// start,A,c,A,b,end
// start,A,c,A,c,A,b,A,end
// start,A,c,A,c,A,b,end
// start,A,c,A,c,A,end
// start,A,c,A,end
// start,A,end
// start,b,A,b,A,c,A,end
// start,b,A,b,A,end
// start,b,A,b,end
// start,b,A,c,A,b,A,end
// start,b,A,c,A,b,end
// start,b,A,c,A,c,A,end
// start,b,A,c,A,end
// start,b,A,end
// start,b,d,b,A,c,A,end
// start,b,d,b,A,end
// start,b,d,b,end
// start,b,end
// The slightly larger example above now has 103 paths through it, and the even larger example now has 3509 paths through it.

// Given these new rules, how many paths through this cave system are there?

fn part2(names: []const []const u8, edges: []const Edge) !u64 {
    var walk = Walk{
        .edges = edges,
        .names = names,
        .already_hit = try std.DynamicBitSet.initEmpty(std.testing.allocator, names.len),
    };
    defer walk.already_hit.deinit();
    return walk.countPaths(0, true);
}
