// --- Day 22: Reactor Reboot ---
// 
// Operating at these extreme ocean depths has overloaded the submarine's reactor; it needs to be rebooted.
// 
// The reactor core is made up of a large 3-dimensional grid made up entirely of cubes, one cube per integer 3-dimensional coordinate (x,y,z). Each cube can be either on or off; at the start of the reboot process, they are all off. (Could it be an old model of a reactor you've seen before?)
// 
// To reboot the reactor, you just need to set all of the cubes to either on or off by following a list of reboot steps (your puzzle input). Each step specifies a cuboid (the set of all cubes that have coordinates which fall within ranges for x, y, and z) and whether to turn all of the cubes in that cuboid on or off.
// 
// For example, given these reboot steps:
// 
// on x=10..12,y=10..12,z=10..12
// on x=11..13,y=11..13,z=11..13
// off x=9..11,y=9..11,z=9..11
// on x=10..10,y=10..10,z=10..10
// 
// The first step (on x=10..12,y=10..12,z=10..12) turns on a 3x3x3 cuboid consisting of 27 cubes:
// 
//     10,10,10
//     10,10,11
//     10,10,12
//     10,11,10
//     10,11,11
//     10,11,12
//     10,12,10
//     10,12,11
//     10,12,12
//     11,10,10
//     11,10,11
//     11,10,12
//     11,11,10
//     11,11,11
//     11,11,12
//     11,12,10
//     11,12,11
//     11,12,12
//     12,10,10
//     12,10,11
//     12,10,12
//     12,11,10
//     12,11,11
//     12,11,12
//     12,12,10
//     12,12,11
//     12,12,12
// 
// The second step (on x=11..13,y=11..13,z=11..13) turns on a 3x3x3 cuboid that overlaps with the first. As a result, only 19 additional cubes turn on; the rest are already on from the previous step:
// 
//     11,11,13
//     11,12,13
//     11,13,11
//     11,13,12
//     11,13,13
//     12,11,13
//     12,12,13
//     12,13,11
//     12,13,12
//     12,13,13
//     13,11,11
//     13,11,12
//     13,11,13
//     13,12,11
//     13,12,12
//     13,12,13
//     13,13,11
//     13,13,12
//     13,13,13
// 
// The third step (off x=9..11,y=9..11,z=9..11) turns off a 3x3x3 cuboid that overlaps partially with some cubes that are on, ultimately turning off 8 cubes:
// 
//     10,10,10
//     10,10,11
//     10,11,10
//     10,11,11
//     11,10,10
//     11,10,11
//     11,11,10
//     11,11,11
// 
// The final step (on x=10..10,y=10..10,z=10..10) turns on a single cube, 10,10,10. After this last step, 39 cubes are on.
// 
// The initialization procedure only uses cubes that have x, y, and z positions of at least -50 and at most 50. For now, ignore cubes outside this region.
// 
// Here is a larger example:
// 
// on x=-20..26,y=-36..17,z=-47..7
// on x=-20..33,y=-21..23,z=-26..28
// on x=-22..28,y=-29..23,z=-38..16
// on x=-46..7,y=-6..46,z=-50..-1
// on x=-49..1,y=-3..46,z=-24..28
// on x=2..47,y=-22..22,z=-23..27
// on x=-27..23,y=-28..26,z=-21..29
// on x=-39..5,y=-6..47,z=-3..44
// on x=-30..21,y=-8..43,z=-13..34
// on x=-22..26,y=-27..20,z=-29..19
// off x=-48..-32,y=26..41,z=-47..-37
// on x=-12..35,y=6..50,z=-50..-2
// off x=-48..-32,y=-32..-16,z=-15..-5
// on x=-18..26,y=-33..15,z=-7..46
// off x=-40..-22,y=-38..-28,z=23..41
// on x=-16..35,y=-41..10,z=-47..6
// off x=-32..-23,y=11..30,z=-14..3
// on x=-49..-5,y=-3..45,z=-29..18
// off x=18..30,y=-20..-8,z=-3..13
// on x=-41..9,y=-7..43,z=-33..15
// on x=-54112..-39298,y=-85059..-49293,z=-27449..7877
// on x=967..23432,y=45373..81175,z=27513..53682
// 
// The last two steps are fully outside the initialization procedure area; all other steps are fully within it. After executing these steps in the initialization procedure region, 590784 cubes are on.
// 
// Execute the reboot steps. Afterward, considering only cubes in the region x=-50..50,y=-50..50,z=-50..50, how many cubes are on?

const std = @import("std");

const input = @embedFile("../input/day22.txt");

const Map = struct {
    cubes: std.ArrayList(Cube),

    const Self = @This();

    fn init() Self { return .{ .cubes = std.ArrayList(Cube).init(std.testing.allocator) }; }

    fn deinit(self: *Self) void { self.cubes.deinit(); }

    fn count(self: *Self) i32 {
        var sum: i32 = 0;
        for (self.cubes.items) |s| {
            sum += s.count();
        }
        return sum;
    }

    fn on(self: *Self, s: Cube) !void {
        var i: usize = 0;
        while (i < self.cubes.items.len) {
            const item = self.cubes.items[i];
            if (item.overlap(s)) {
                if (item.contains(s)) return;
                if (s.contains(item)) {
                    _ = self.cubes.swapRemove(i);
                    continue;
                }
                var parts = try Cubes.init(0);
                split(&parts, item, s);
                try self.cubes.replaceRange(i, 1, parts.slice());
                i += parts.len;
            } else {
                i += 1;
            }
        }
        try self.cubes.append(s);
    }

    fn off(self: *Self, s: Cube) !void {
        var i: usize = 0;
        while (i < self.cubes.items.len) {
            const item = self.cubes.items[i];
            if (item.overlap(s)) {
                if (s.contains(item)) {
                    _ = self.cubes.swapRemove(i);
                    continue;
                }
                var parts = try Cubes.init(0);
                split(&parts, item, s);
                try self.cubes.replaceRange(i, 1, parts.slice());
                i += parts.len;
            } else {
                i += 1;
            }
        }
    }
};

pub fn solve() !void {
    std.log.info("Day22 \n\tpart 1 -> {}\n\tpart 2 -> {}", .{ part1(), part2() });
}

const Cube = struct {
    x_min: i32,
    x_max: i32,
    y_min: i32,
    y_max: i32,
    z_min: i32,
    z_max: i32,

    const Self = @This();

    fn count(self: Self) i32 {
        return (self.x_max - self.x_min + 1) *
            (self.y_max - self.y_min + 1) *
            (self.z_max - self.z_min + 1);
    }

    fn contains(self: Self, other: Self) bool {
        return (self.x_min <= other.x_min and other.x_max <= self.x_max) and
            (self.y_min <= other.y_min and other.y_max <= self.y_max) and
            (self.z_min <= other.z_min and other.z_max <= self.z_max);
    }

    fn overlap(self: Self, other: Self) bool {
        return (self.x_min <= other.x_max and other.x_min <= self.x_max) and
            (self.y_min <= other.y_max and other.y_min <= self.y_max) and
            (self.z_min <= other.z_max and other.z_min <= self.z_max);
    }
};

const Cubes = std.BoundedArray(Cube, 6);

fn split(result: *Cubes, a: Cube, b: Cube) void {
    var remain = a;
    if (remain.x_min < b.x_min) {
        var chunk = remain;
        chunk.x_max = b.x_min - 1;
        result.appendAssumeCapacity(chunk);
        remain.x_min = b.x_min;
    }

    if (remain.x_max > b.x_max) {
        var chunk = remain;
        chunk.x_min = b.x_max + 1;
        result.appendAssumeCapacity(chunk);
        remain.x_max = b.x_max;
    }

    if (remain.y_min < b.y_min) {
        var chunk = remain;
        chunk.y_max = b.y_min - 1;
        result.appendAssumeCapacity(chunk);
        remain.y_min = b.y_min;
    }

    if (remain.y_max > b.y_max) {
        var chunk = remain;
        chunk.y_min = b.y_max + 1;
        result.appendAssumeCapacity(chunk);
        remain.y_max = b.y_max;
    }

    if (remain.z_min < b.z_min) {
        var chunk = remain;
        chunk.z_max = b.z_min - 1;
        result.appendAssumeCapacity(chunk);
        remain.z_min = b.z_min;
    }

    if (remain.z_max > b.z_max) {
        var chunk = remain;
        chunk.z_min = b.z_max + 1;
        result.appendAssumeCapacity(chunk);
        remain.z_max = b.z_max;
    }
}

fn part1() !i32 {
    var it = std.mem.tokenize(u8, input, "\n\r");
    var map = Map.init();
    defer map.deinit();
    var ret : i32 = 0;
    while (it.next()) | item | {
        var parts = std.mem.tokenize(u8, item, " ,");
        const on = parts.next().?[1] == 'n';

        var xparts = std.mem.tokenize(u8, parts.next().?[2..], ".");
        const x_min = try std.fmt.parseInt(i32, xparts.next().?, 10);
        const x_max = try std.fmt.parseInt(i32, xparts.next().?, 10);

        var yparts = std.mem.tokenize(u8, parts.next().?[2..], ".");
        const y_min = try std.fmt.parseInt(i32, yparts.next().?, 10);
        const y_max = try std.fmt.parseInt(i32, yparts.next().?, 10);

        var zparts = std.mem.tokenize(u8, parts.next().?[2..], ".");
        const z_min = try std.fmt.parseInt(i32, zparts.next().?, 10);
        const z_max = try std.fmt.parseInt(i32, zparts.next().?, 10);

        if ((x_min < -50 or x_max > 50 or y_min < -50 or y_max > 50 or z_min < -50 or z_max > 50) and ret == 0) ret = map.count();

        if (on) {
            try map.on(.{ .x_min = x_min, .x_max = x_max, .y_min = y_min, .y_max = y_max, .z_min = z_min, .z_max = z_max });
        } else {
            try map.off(.{ .x_min = x_min, .x_max = x_max, .y_min = y_min, .y_max = y_max, .z_min = z_min, .z_max = z_max });
        }
    }

    return ret;
}

fn part2() !u64 {
    return 0;
}