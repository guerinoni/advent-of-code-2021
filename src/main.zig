const std = @import("std");
const day1 = @import("day1.zig");
const day2 = @import("day2.zig");
const day3 = @import("day3.zig");

pub fn main() !void {
    std.log.info("Welcome to Advent of Code 2021", .{});

    try day1.solve();
    try day2.solve();
    try day3.solve();
}