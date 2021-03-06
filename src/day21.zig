// --- Day 21: Dirac Dice ---
//
// There's not much to do as you slowly descend to the bottom of the ocean. The submarine computer challenges you to a nice game of Dirac Dice.
//
// This game consists of a single die, two pawns, and a game board with a circular track containing ten spaces marked 1 through 10 clockwise. Each player's starting space is chosen randomly (your puzzle input). Player 1 goes first.
//
// Players take turns moving. On each player's turn, the player rolls the die three times and adds up the results. Then, the player moves their pawn that many times forward around the track (that is, moving clockwise on spaces in order of increasing value, wrapping back around to 1 after 10). So, if a player is on space 7 and they roll 2, 2, and 1, they would move forward 5 times, to spaces 8, 9, 10, 1, and finally stopping on 2.
//
// After each player moves, they increase their score by the value of the space their pawn stopped on. Players' scores start at 0. So, if the first player starts on space 7 and rolls a total of 5, they would stop on space 2 and add 2 to their score (for a total score of 2). The game immediately ends as a win for any player whose score reaches at least 1000.
//
// Since the first game is a practice game, the submarine opens a compartment labeled deterministic dice and a 100-sided die falls out. This die always rolls 1 first, then 2, then 3, and so on up to 100, after which it starts over at 1 again. Play using this die.
//
// For example, given these starting positions:
//
// Player 1 starting position: 4
// Player 2 starting position: 8
//
// This is how the game would go:
//
//     Player 1 rolls 1+2+3 and moves to space 10 for a total score of 10.
//     Player 2 rolls 4+5+6 and moves to space 3 for a total score of 3.
//     Player 1 rolls 7+8+9 and moves to space 4 for a total score of 14.
//     Player 2 rolls 10+11+12 and moves to space 6 for a total score of 9.
//     Player 1 rolls 13+14+15 and moves to space 6 for a total score of 20.
//     Player 2 rolls 16+17+18 and moves to space 7 for a total score of 16.
//     Player 1 rolls 19+20+21 and moves to space 6 for a total score of 26.
//     Player 2 rolls 22+23+24 and moves to space 6 for a total score of 22.
//
// ...after many turns...
//
//     Player 2 rolls 82+83+84 and moves to space 6 for a total score of 742.
//     Player 1 rolls 85+86+87 and moves to space 4 for a total score of 990.
//     Player 2 rolls 88+89+90 and moves to space 3 for a total score of 745.
//     Player 1 rolls 91+92+93 and moves to space 10 for a final score, 1000.
//
// Since player 1 has at least 1000 points, player 1 wins and the game ends. At this point, the losing player had 745 points and the die had been rolled a total of 993 times; 745 * 993 = 739785.
//
// Play a practice game using the deterministic 100-sided die. The moment either player wins, what do you get if you multiply the score of the losing player by the number of times the die was rolled during the game?

const std = @import("std");

const input = @embedFile("../input/day21.txt");

pub fn solve() !void {
    var iterator = std.mem.tokenize(u8, input, " \r\n");
    var discard = iterator.next().?;
    discard = iterator.next().?;
    discard = iterator.next().?;
    discard = iterator.next().?;
    var p1 = try std.fmt.parseInt(u8, iterator.next().?, 10);
    discard = iterator.next().?;
    discard = iterator.next().?;
    discard = iterator.next().?;
    discard = iterator.next().?;
    var p2 = try std.fmt.parseInt(u8, iterator.next().?, 10);
    var player1: Player = .{ .pos = p1 };
    var player2: Player = .{ .pos = p2 };
    std.log.info("Day21 \n\tpart 1 -> {}\n\tpart 2 -> {}", .{ part1(player1, player2), part2(player1, player2) });
}

const Player = struct {
    score: usize = 0,
    pos: usize,

    fn update(self: *@This(), steps: [3]usize) void {
        self.pos = (self.pos + steps[0] + steps[1] + steps[2] - 1) % 10 + 1;
        self.score += self.pos;
    }
};

fn part1(player1: Player, player2: Player) !u64 {
    var p1 = player1;
    var p2 = player2;
    var step: usize = 1;
    while (true) {
        p1.update([_]usize{ step, step + 1, step + 2 });
        step += 3;
        if (p1.score >= 1000)
            return p2.score * (step - 1);
        p2.update([_]usize{ step, step + 1, step + 2 });
        step += 3;
        if (p2.score >= 1000)
            return p1.score * (step - 1);
    }

    return 0;
}

// --- Part Two ---
//
// Now that you're warmed up, it's time to play the real game.
//
// A second compartment opens, this time labeled Dirac dice. Out of it falls a single three-sided die.
//
// As you experiment with the die, you feel a little strange. An informational brochure in the compartment explains that this is a quantum die: when you roll it, the universe splits into multiple copies, one copy for each possible outcome of the die. In this case, rolling the die always splits the universe into three copies: one where the outcome of the roll was 1, one where it was 2, and one where it was 3.
//
// The game is played the same as before, although to prevent things from getting too far out of hand, the game now ends when either player's score reaches at least 21.
//
// Using the same starting positions as in the example above, player 1 wins in 444356092776315 universes, while player 2 merely wins in 341960390180808 universes.
//
// Using your given starting positions, determine every possible outcome. Find the player that wins in more universes; in how many universes does that player win?

const Players = struct {
    a: Player,
    b: Player,
};

fn count(a: Player, b: Player, combs: *const [27][3]usize, memo: *std.AutoHashMap(Players, Results)) Results {
    if (a.score >= 21) return .{ .a = 1, .b = 0 };
    if (b.score >= 21) return .{ .a = 0, .b = 1 };

    if (memo.get(.{ .a = a, .b = b })) |counts| return counts;

    var a_count: usize = 0;
    var b_count: usize = 0;
    for (combs) |comb| {
        var player = a;
        player.update(comb);

        const counts = count(b, player, combs, memo);
        a_count += counts.b;
        b_count += counts.a;
    }

    const result: Results = .{ .a = a_count, .b = b_count };
    memo.put(.{ .a = a, .b = b }, result) catch unreachable;
    return result;
}

const Results = struct {
    a: usize,
    b: usize,
};

fn part2(player1: Player, player2: Player) !u64 {
    var memo = std.AutoHashMap(Players, Results).init(std.testing.allocator);
    defer memo.deinit();
    var combs: [27][3]usize = undefined;
    var i: usize = 0;
    for ([3]usize{ 1, 2, 3 }) |a| {
        for ([3]usize{ 1, 2, 3 }) |b| {
            for ([3]usize{ 1, 2, 3 }) |c| {
                combs[i] = .{ a, b, c };
                i += 1;
            }
        }
    }
    const ret = count(player1, player2, &combs, &memo);
    return std.math.max(ret.a, ret.b);
}
