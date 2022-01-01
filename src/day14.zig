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

pub fn solve() !void {
    std.log.info("Day14 \n\tpart 1 -> {}\n\tpart 2 -> {}", .{ part1(), part2() });
}

const u8x2 = std.meta.Vector(2, u8);

// "AA" => 0, "ZZ" => 26*26-1
fn hash(val: *const [2]u8) u16 {
    var pair = @as(u8x2, val.*);
    pair -= u8x2{ 'A', 'A' };
    return @as(u16, pair[0]) * 26 + pair[1];
}

// 0 => "AA", 675 => "ZZ"
fn unhash(val: u16) [2]u8 {
    return u8x2{ @truncate(u8, val / 26), @truncate(u8, val % 26) } + u8x2{ 'A', 'A' };
}

fn part1() !u64 {
    const in = comptime std.mem.trim(u8, input, &std.ascii.spaces);
    var data = std.mem.split(u8, in, "\n");
    var counts = [1]usize{0} ** (26 * 26);
    const template = data.next().?;
    for (template[0 .. template.len - 1]) |_, i|
        counts[hash(template[i .. i + 2][0..2])] += 1;
    _ = data.next().?;
    var rules = [1]u8{0} ** (26 * 26);
    while (data.next()) |line|
        rules[hash(line[0..2])] = line[6];

    var step: usize = 0;
    while (step < 10) : (step += 1) {
        var new_counts = [1]usize{0} ** (26 * 26);
        for (counts) |count, i| {
            if (count == 0) continue;
            const pair = unhash(@intCast(u16, i));
            const result = rules[i];
            const left: [2]u8 = .{ pair[0], result };
            const right: [2]u8 = .{ result, pair[1] };
            new_counts[hash(&left)] += count;
            new_counts[hash(&right)] += count;
        }

        counts = new_counts;
    }

    if (step == 10) {
        var char_counts = [1]usize{0} ** 26;
        for (counts) |entry, i| {
            const pair = unhash(@intCast(u16, i));
            char_counts[pair[0] - 'A'] += entry;
        }
        char_counts[template[template.len - 1] - 'A'] += 1;
        std.sort.sort(usize, &char_counts, {}, comptime std.sort.desc(usize));

        const max = char_counts[0];
        const min = for (char_counts) |x, i| {
            if (char_counts[i + 1] == 0) break x;
        } else unreachable;
        const answer = max - min;
        return answer;
    }

    return 0;
}

// --- Part Two ---
// The resulting polymer isn't nearly strong enough to reinforce the submarine. You'll need to run more steps of the pair insertion process; a total of 40 steps should do it.

// In the above example, the most common element is B (occurring 2192039569602 times) and the least common element is H (occurring 3849876073 times); subtracting these produces 2188189693529.

// Apply 40 steps of pair insertion to the polymer template and find the most and least common elements in the result. What do you get if you take the quantity of the most common element and subtract the quantity of the least common element?

fn part2() !u64 {
    const in = comptime std.mem.trim(u8, input, &std.ascii.spaces);
    var data = std.mem.split(u8, in, "\n");
    var counts = [1]usize{0} ** (26 * 26);
    const template = data.next().?;
    for (template[0 .. template.len - 1]) |_, i|
        counts[hash(template[i .. i + 2][0..2])] += 1;
    _ = data.next().?;
    var rules = [1]u8{0} ** (26 * 26);
    while (data.next()) |line|
        rules[hash(line[0..2])] = line[6];

    var step: usize = 0;
    while (step < 40) : (step += 1) {
        var new_counts = [1]usize{0} ** (26 * 26);
        for (counts) |count, i| {
            if (count == 0) continue;
            const pair = unhash(@intCast(u16, i));
            const result = rules[i];
            const left: [2]u8 = .{ pair[0], result };
            const right: [2]u8 = .{ result, pair[1] };
            new_counts[hash(&left)] += count;
            new_counts[hash(&right)] += count;
        }

        counts = new_counts;
    }

    if (step == 40) {
        var char_counts = [1]usize{0} ** 26;
        for (counts) |entry, i| {
            const pair = unhash(@intCast(u16, i));
            char_counts[pair[0] - 'A'] += entry;
        }
        char_counts[template[template.len - 1] - 'A'] += 1;
        std.sort.sort(usize, &char_counts, {}, comptime std.sort.desc(usize));

        const max = char_counts[0];
        const min = for (char_counts) |x, i| {
            if (char_counts[i + 1] == 0) break x;
        } else unreachable;
        const answer = max - min;
        return answer;
    }

    return 0;
}
