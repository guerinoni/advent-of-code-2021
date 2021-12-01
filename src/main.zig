const std = @import("std");
const day1 = @import("day1.zig");

pub fn main() u8 {
    std.log.info("Welcome to Advent of Code 2021", .{});

    day1.solve();

    return 0;
}
