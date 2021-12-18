const std = @import("std");
const day1 = @import("day1.zig");
const day2 = @import("day2.zig");
const day3 = @import("day3.zig");
const day4 = @import("day4.zig");
const day5 = @import("day5.zig");
const day6 = @import("day6.zig");
const day7 = @import("day7.zig");
const day8 = @import("day8.zig");
const day9 = @import("day9.zig");
const day10 = @import("day10.zig");
const day11 = @import("day11.zig");
const day12 = @import("day12.zig");
const day13 = @import("day13.zig");

pub fn main() !void {
    std.log.info("Welcome to Advent of Code 2021", .{});

    try day1.solve();
    try day2.solve();
    try day3.solve();
    try day4.solve();
    try day5.solve();
    try day6.solve();
    try day7.solve();
    try day8.solve();
    try day9.solve();
    try day10.solve();
    try day11.solve();
    try day12.solve();
    try day13.solve();
}