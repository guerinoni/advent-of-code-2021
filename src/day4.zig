// --- Day 4: Giant Squid ---
// You're already almost 1.5km (almost a mile) below the surface of the ocean, already so deep that you can't see any sunlight. What you can see, however, is a giant squid that has attached itself to the outside of your submarine.

// Maybe it wants to play bingo?

// Bingo is played on a set of boards each consisting of a 5x5 grid of numbers. Numbers are chosen at random, and the chosen number is marked on all boards on which it appears. (Numbers may not appear on all boards.) If all numbers in any row or any column of a board are marked, that board wins. (Diagonals don't count.)

// The submarine has a bingo subsystem to help passengers (currently, you and the giant squid) pass the time. It automatically generates a random order in which to draw numbers and a random set of boards (your puzzle input). For example:

// 7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

// 22 13 17 11  0
//  8  2 23  4 24
// 21  9 14 16  7
//  6 10  3 18  5
//  1 12 20 15 19

//  3 15  0  2 22
//  9 18 13 17  5
// 19  8  7 25 23
// 20 11 10 24  4
// 14 21 16 12  6

// 14 21 17 24  4
// 10 16 15  9 19
// 18  8 23 26 20
// 22 11 13  6  5
//  2  0 12  3  7
// After the first five numbers are drawn (7, 4, 9, 5, and 11), there are no winners, but the boards are marked as follows (shown here adjacent to each other to save space):

// 22 13 17 11  0         3 15  0  2 22        14 21 17 24  4
//  8  2 23  4 24         9 18 13 17  5        10 16 15  9 19
// 21  9 14 16  7        19  8  7 25 23        18  8 23 26 20
//  6 10  3 18  5        20 11 10 24  4        22 11 13  6  5
//  1 12 20 15 19        14 21 16 12  6         2  0 12  3  7
// After the next six numbers are drawn (17, 23, 2, 0, 14, and 21), there are still no winners:

// 22 13 17 11  0         3 15  0  2 22        14 21 17 24  4
//  8  2 23  4 24         9 18 13 17  5        10 16 15  9 19
// 21  9 14 16  7        19  8  7 25 23        18  8 23 26 20
//  6 10  3 18  5        20 11 10 24  4        22 11 13  6  5
//  1 12 20 15 19        14 21 16 12  6         2  0 12  3  7
// Finally, 24 is drawn:

// 22 13 17 11  0         3 15  0  2 22        14 21 17 24  4
//  8  2 23  4 24         9 18 13 17  5        10 16 15  9 19
// 21  9 14 16  7        19  8  7 25 23        18  8 23 26 20
//  6 10  3 18  5        20 11 10 24  4        22 11 13  6  5
//  1 12 20 15 19        14 21 16 12  6         2  0 12  3  7
// At this point, the third board wins because it has at least one complete row or column of marked numbers (in this case, the entire top row is marked: 14 21 17 24 4).

// The score of the winning board can now be calculated. Start by finding the sum of all unmarked numbers on that board; in this case, the sum is 188. Then, multiply that sum by the number that was just called when the board won, 24, to get the final score, 188 * 24 = 4512.

// To guarantee victory against the giant squid, figure out which board will win first. What will your final score be if you choose that board?


const std = @import("std");

const input = @embedFile("../input/day4.txt");

pub fn solve() !void {
    std.log.info("Day4 \n\tpart 1 -> {}\n\tpart 2 -> {}", .{part1(), part2()});
}

fn part1() !u32 {
    var lines = std.mem.split(u8, input, "\n\n");

    var bingo_nums = std.ArrayList(u8).init(std.testing.allocator);
    var bingo_line = std.mem.tokenize(u8, lines.next().?, ",");

    while (bingo_line.next()) | line | {
        try bingo_nums.append(try std.fmt.parseInt(u8, line, 10));
    }

    var bingo_boards = std.ArrayList([5 * 5]u8).init(std.testing.allocator);
    var board_tallys = std.ArrayList([5 + 5]u8).init(std.testing.allocator);
    var board_totals = std.ArrayList(u32).init(std.testing.allocator);
    var board_finished = std.ArrayList(bool).init(std.testing.allocator);

    while (lines.next()) | line | {
        var board_nums = std.mem.tokenize(u8, line, " \n");
        var board: [25]u8 = undefined;
        for (board) |*num| {
            num.* = try std.fmt.parseInt(u8, board_nums.next().?, 10);
        }
        try bingo_boards.append(board);
        try board_tallys.append([_]u8{0} ** (5 + 5));
        try board_totals.append(0);
        try board_finished.append(false);
    }

    var ret: u32 = 0;
    var boards_finished: u32 = 0;
    stop_bingo: for (bingo_nums.items) | bingo_num | {
        for (bingo_boards.items) | board, i | {
            if (board_finished.items[i]) {
                continue;
            }

            for (board) | board_num, num_i | {
                if (board_num == bingo_num) {
                    board_totals.items[i] += bingo_num;
                    board_tallys.items[i][num_i / 5] += 1;
                    board_tallys.items[i][5 + num_i % 5] += 1;
                    if (board_tallys.items[i][num_i / 5] == 5 or
                        board_tallys.items[i][5 + num_i % 5] == 5) {
                        boards_finished += 1;
                        board_finished.items[i] = true;
                        if (boards_finished == 1) {
                            ret = calculateBoardSum(board, board_totals.items[i]) * bingo_num;
                        }
                        
                        if (boards_finished == board_finished.items.len) {
                            break :stop_bingo;
                        }
                        break;
                    }
                }
            }
        }
    }

    return ret;
}

fn calculateBoardSum(board: [25]u8, board_total: u32) u32 {
    const sum = blk: {
        var acc: u32 = 0;
        for (board) | num | {
            acc += num;
        }
        acc -= board_total;
        break :blk acc;
    };
    return sum;
}

// --- Part Two ---
// On the other hand, it might be wise to try a different strategy: let the giant squid win.

// You aren't sure how many bingo boards a giant squid could play at once, so rather than waste time counting its arms, the safe thing to do is to figure out which board will win last and choose that one. That way, no matter which boards it picks, it will win for sure.

// In the above example, the second board is the last to win, which happens after 13 is eventually called and its middle column is completely marked. If you were to keep playing until this point, the second board would have a sum of unmarked numbers equal to 148 for a final score of 148 * 13 = 1924.

// Figure out which board will win last. Once it wins, what would its final score be?

fn part2() !u32 {
    var lines = std.mem.split(u8, input, "\n\n");

    var bingo_nums = std.ArrayList(u8).init(std.testing.allocator);
    var bingo_line = std.mem.tokenize(u8, lines.next().?, ",");

    while (bingo_line.next()) | line | {
        try bingo_nums.append(try std.fmt.parseInt(u8, line, 10));
    }

    var bingo_boards = std.ArrayList([5 * 5]u8).init(std.testing.allocator);
    var board_tallys = std.ArrayList([5 + 5]u8).init(std.testing.allocator);
    var board_totals = std.ArrayList(u32).init(std.testing.allocator);
    var board_finished = std.ArrayList(bool).init(std.testing.allocator);

    while (lines.next()) | line | {
        var board_nums = std.mem.tokenize(u8, line, " \n");
        var board: [25]u8 = undefined;
        for (board) |*num| {
            num.* = try std.fmt.parseInt(u8, board_nums.next().?, 10);
        }
        try bingo_boards.append(board);
        try board_tallys.append([_]u8{0} ** (5 + 5));
        try board_totals.append(0);
        try board_finished.append(false);
    }

    var ret: u32 = 0;
    var boards_finished: u32 = 0;
    stop_bingo: for (bingo_nums.items) |bingo_num| {
        for (bingo_boards.items) |board, i| {
            if (board_finished.items[i]) {
                continue;
            }

            for (board) |board_num, num_i| {
                if (board_num == bingo_num) {
                    board_totals.items[i] += bingo_num;
                    board_tallys.items[i][num_i / 5] += 1;
                    board_tallys.items[i][5 + num_i % 5] += 1;
                    if (board_tallys.items[i][num_i / 5] == 5 or
                        board_tallys.items[i][5 + num_i % 5] == 5) {
                        boards_finished += 1;
                        board_finished.items[i] = true;
                        if (boards_finished == board_finished.items.len) {
                            ret = calculateBoardSum(board, board_totals.items[i]) * bingo_num;
                            break :stop_bingo;
                        }
                        break;
                    }
                }
            }
        }
    }

    return ret;
}