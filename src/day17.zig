// --- Day 17: Trick Shot ---
// 
// You finally decode the Elves' message. HI, the message says. You continue searching for the sleigh keys.
// 
// Ahead of you is what appears to be a large ocean trench. Could the keys have fallen into it? You'd better send a probe to investigate.
// 
// The probe launcher on your submarine can fire the probe with any integer velocity in the x (forward) and y (upward, or downward if negative) directions. For example, an initial x,y velocity like 0,10 would fire the probe straight up, while an initial velocity like 10,-1 would fire the probe forward at a slight downward angle.
// 
// The probe's x,y position starts at 0,0. Then, it will follow some trajectory by moving in steps. On each step, these changes occur in the following order:
// 
//     The probe's x position increases by its x velocity.
//     The probe's y position increases by its y velocity.
//     Due to drag, the probe's x velocity changes by 1 toward the value 0; that is, it decreases by 1 if it is greater than 0, increases by 1 if it is less than 0, or does not change if it is already 0.
//     Due to gravity, the probe's y velocity decreases by 1.
// 
// For the probe to successfully make it into the trench, the probe must be on some trajectory that causes it to be within a target area after any step. The submarine computer has already calculated this target area (your puzzle input). For example:
// 
// target area: x=20..30, y=-10..-5
// 
// This target area means that you need to find initial x,y velocity values such that after any step, the probe's x position is at least 20 and at most 30, and the probe's y position is at least -10 and at most -5.
// 
// Given this target area, one initial velocity that causes the probe to be within the target area after any step is 7,2:
// 
// .............#....#............
// .......#..............#........
// ...............................
// S........................#.....
// ...............................
// ...............................
// ...........................#...
// ...............................
// ....................TTTTTTTTTTT
// ....................TTTTTTTTTTT
// ....................TTTTTTTT#TT
// ....................TTTTTTTTTTT
// ....................TTTTTTTTTTT
// ....................TTTTTTTTTTT
// 
// In this diagram, S is the probe's initial position, 0,0. The x coordinate increases to the right, and the y coordinate increases upward. In the bottom right, positions that are within the target area are shown as T. After each step (until the target area is reached), the position of the probe is marked with #. (The bottom-right # is both a position the probe reaches and a position in the target area.)
// 
// Another initial velocity that causes the probe to be within the target area after any step is 6,3:
// 
// ...............#..#............
// ...........#........#..........
// ...............................
// ......#..............#.........
// ...............................
// ...............................
// S....................#.........
// ...............................
// ...............................
// ...............................
// .....................#.........
// ....................TTTTTTTTTTT
// ....................TTTTTTTTTTT
// ....................TTTTTTTTTTT
// ....................TTTTTTTTTTT
// ....................T#TTTTTTTTT
// ....................TTTTTTTTTTT
// 
// Another one is 9,0:
// 
// S........#.....................
// .................#.............
// ...............................
// ........................#......
// ...............................
// ....................TTTTTTTTTTT
// ....................TTTTTTTTTT#
// ....................TTTTTTTTTTT
// ....................TTTTTTTTTTT
// ....................TTTTTTTTTTT
// ....................TTTTTTTTTTT
// 
// One initial velocity that doesn't cause the probe to be within the target area after any step is 17,-4:
// 
// S..............................................................
// ...............................................................
// ...............................................................
// ...............................................................
// .................#.............................................
// ....................TTTTTTTTTTT................................
// ....................TTTTTTTTTTT................................
// ....................TTTTTTTTTTT................................
// ....................TTTTTTTTTTT................................
// ....................TTTTTTTTTTT..#.............................
// ....................TTTTTTTTTTT................................
// ...............................................................
// ...............................................................
// ...............................................................
// ...............................................................
// ................................................#..............
// ...............................................................
// ...............................................................
// ...............................................................
// ...............................................................
// ...............................................................
// ...............................................................
// ..............................................................#
// 
// The probe appears to pass through the target area, but is never within it after any step. Instead, it continues down and to the right - only the first few steps are shown.
// 
// If you're going to fire a highly scientific probe out of a super cool probe launcher, you might as well do it with style. How high can you make the probe go while still reaching the target area?
// 
// In the above example, using an initial velocity of 6,9 is the best you can do, causing the probe to reach a maximum y position of 45. (Any higher initial y velocity causes the probe to overshoot the target area entirely.)
// 
// Find the initial velocity that causes the probe to reach the highest y position and still eventually be within the target area after any step. What is the highest y position it reaches on this trajectory?

const std = @import("std");

const input = @embedFile("../input/day17.txt");

const Target = struct {
    x_min: i32,
    x_max: i32,
    y_min: i32,
    y_max: i32,
};

pub fn solve() !void {
    var it = std.mem.split(u8, std.mem.trim(u8, input, "\n"), ": ");
    _ = it.next().?;

    it = std.mem.split(u8, it.next().?, ", ");
    var x_it = std.mem.split(u8, it.next().?[2..], "..");
    var y_it = std.mem.split(u8, it.next().?[2..], "..");

    var target = Target {
        .x_min = try std.fmt.parseInt(i32, x_it.next().?, 10),
        .x_max = try std.fmt.parseInt(i32, x_it.next().?, 10),
        .y_min = try std.fmt.parseInt(i32, y_it.next().?, 10),
        .y_max = try std.fmt.parseInt(i32, y_it.next().?, 10),
    };

    _ = target;

    std.log.info("Day17 \n\tpart 1 -> {}\n\tpart 2 -> {}", .{ part1(target), part2() });
}

const Probe = struct {
    x: i32,
    y: i32,
    vel_x: i32,
    vel_y: i32,

    max: i32 = std.math.minInt(i32),
    x_at_max: i32 = 0,

    fn sim(self: *@This(), target: Target) ?i32 {
        if (self.y > self.max) {
            self.max = self.y;
            self.x_at_max = self.x;
        }

        while (true) {
            self.x += self.vel_x;
            self.y += self.vel_y;

            if (self.y > self.max) {
                self.max = self.y;
                self.x_at_max = self.x;
            }

            if (self.x >= target.x_min and self.x <= target.x_max and
                self.y >= target.y_min and self.y <= target.y_max) {
                return self.max;
            }

            if (self.x >= target.x_max or self.y <= target.y_min) return null;

            if (self.vel_x != 0) self.vel_x += if (self.vel_x < 0) @as(i32, 1) else @as(i32, -1);
            self.vel_y -= 1;
        }
    }
};

fn part1(target: Target) !i32 {
 var x: i32 = 1;
    var y: i32 = -100;
    var max_y: i32 = std.math.minInt(i32);
    var valid = std.ArrayList(Probe).init(std.testing.allocator);

    while (true) {
        var probe = Probe { .x = 0, .y = 0, .vel_x = x, .vel_y = y };
        if (probe.sim(target)) |max| {
            if (max > max_y) max_y = max;

            try valid.append(probe);
        }

        x += 1;
        if (x > target.x_max) {
            x = 1;
            y += 1;
        }

        if (probe.x_at_max > target.x_max and y > 1000) break;
    }

    return max_y;
}

fn part2() !u32 {
    return 0;
}
