// --- Day 14: Extended Polymerization ---
// The incredible pressures at this depth are starting to put a strain on your submarine. The submarine has polymerization equipment that would produce suitable materials to reinforce the submarine, and the nearby volcanically-active caves should even have the necessary input elements in sufficient quantities.

// The submarine manual contains instructions for finding the optimal polymer formula; specifically, it offers a polymer template and a list of pair insertion rules (your puzzle input). You just need to work out what polymer would result after repeating the pair insertion process a few times.

// For example:

// NNCB

// CH -> B
// HH -> N
// CB -> H
// NH -> C
// HB -> C
// HC -> B
// HN -> C
// NN -> C
// BH -> H
// NC -> B
// NB -> B
// BN -> B
// BB -> N
// BC -> B
// CC -> N
// CN -> C
// The first line is the polymer template - this is the starting point of the process.

// The following section defines the pair insertion rules. A rule like AB -> C means that when elements A and B are immediately adjacent, element C should be inserted between them. These insertions all happen simultaneously.

// So, starting with the polymer template NNCB, the first step simultaneously considers all three pairs:

// The first pair (NN) matches the rule NN -> C, so element C is inserted between the first N and the second N.
// The second pair (NC) matches the rule NC -> B, so element B is inserted between the N and the C.
// The third pair (CB) matches the rule CB -> H, so element H is inserted between the C and the B.
// Note that these pairs overlap: the second element of one pair is the first element of the next pair. Also, because all pairs are considered simultaneously, inserted elements are not considered to be part of a pair until the next step.

// After the first step of this process, the polymer becomes NCNBCHB.

// Here are the results of a few steps using the above rules:

// Template:     NNCB
// After step 1: NCNBCHB
// After step 2: NBCCNBBBCBHCB
// After step 3: NBBBCNCCNBBNBNBBCHBHHBCHB
// After step 4: NBBNBNBBCCNBCNCCNBBNBBNBBBNBBNBBCBHCBHHNHCBBCBHCB
// This polymer grows quickly. After step 5, it has length 97; After step 10, it has length 3073. After step 10, B occurs 1749 times, C occurs 298 times, H occurs 161 times, and N occurs 865 times; taking the quantity of the most common element (B, 1749) and subtracting the quantity of the least common element (H, 161) produces 1749 - 161 = 1588.

// Apply 10 steps of pair insertion to the polymer template and find the most and least common elements in the result. What do you get if you take the quantity of the most common element and subtract the quantity of the least common element?

const std = @import("std");

const input = @embedFile("../input/day14.txt");

const Rule = struct {
    pair: []const u8,
    insert: u8,
};

pub fn solve() !void {
    var list = std.ArrayList([]const u8).init(std.testing.allocator);
    defer list.deinit();
    var lines = std.mem.split(input, "\n");
    while (lines.next()) | line | {
        try list.append(line);
    }

    var rulesStr = list.toOwnedSlice();
    var polymer = std.ArrayList(u8).init(std.testing.allocator);
    defer polymer.deinit();

    const template = rulesStr[0];
    for (template) | c | {
        try polymer.append(c);
    }

    var rules = std.ArrayList(Rule).init(std.testing.allocator);
    defer rules.deinit();
    for (rulesStr[2..]) | line | {
        var split = std.mem.split(line, " -> ");
        var p = split.next().?;
        var i = split.next().?[0];
        var r = Rule { .pair = p, .insert = i };
        try rules.append(r);
    }

    std.log.info("Day14 \n\tpart 1 -> {}\n\tpart 2 -> {}", .{part1(&polymer, &rules), part2()});
}

fn part1(polymer: *std.ArrayList(u8), rules: *std.ArrayList(Rule)) !u64 {
    var step: usize = 0;
    while (step < 10) : (step += 1) {
        var build = std.ArrayList(u8).init(std.testing.allocator);
        defer build.deinit();

        var it: usize = 0;
        while (it < polymer.items.len - 1) : (it += 1) {
            try build.append(polymer.items[it]);
            for (rules.items) | rule | {
                if (std.mem.eql(u8, rule.pair, polymer.items[it .. it + 2])) {
                    try build.append(rule.insert);
                }
            }
        }
        
        try build.append(polymer.items[polymer.items.len - 1]);
        polymer.clearAndFree();
        for (build.items) |c| {
            try polymer.append(c);
        }
    }

    var counts = [_]?usize{null} ** 26;
    var min: usize = std.math.maxInt(usize);
    var max: usize = 0;
    for (polymer.items) | c | {
        if (counts[c - 'A']) |*count| {
            count.* += 1;
        } else counts[c - 'A'] = 1;
    }
    
    for (counts) |c| {
        if (c) |*count| {
            if (count.* < min) min = count.*;
            if (count.* > max) max = count.*;
        }
    }

    return max-min;
}

fn part2() !u64 {
    return 0;
}