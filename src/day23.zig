// --- Day 23: Amphipod ---
//
// A group of amphipods notice your fancy submarine and flag you down. "With such an impressive shell," one amphipod says, "surely you can help us with a question that has stumped our best scientists."
//
// They go on to explain that a group of timid, stubborn amphipods live in a nearby burrow. Four types of amphipods live there: Amber (A), Bronze (B), Copper (C), and Desert (D). They live in a burrow that consists of a hallway and four side rooms. The side rooms are initially full of amphipods, and the hallway is initially empty.
//
// They give you a diagram of the situation (your puzzle input), including locations of each amphipod (A, B, C, or D, each of which is occupying an otherwise open space), walls (#), and open space (.).
//
// For example:
//
// #############
// #...........#
// ###B#C#B#D###
//   #A#D#C#A#
//   #########
//
// The amphipods would like a method to organize every amphipod into side rooms so that each side room contains one type of amphipod and the types are sorted A-D going left to right, like this:
//
// #############
// #...........#
// ###A#B#C#D###
//   #A#B#C#D#
//   #########
//
// Amphipods can move up, down, left, or right so long as they are moving into an unoccupied open space. Each type of amphipod requires a different amount of energy to move one step: Amber amphipods require 1 energy per step, Bronze amphipods require 10 energy, Copper amphipods require 100, and Desert ones require 1000. The amphipods would like you to find a way to organize the amphipods that requires the least total energy.
//
// However, because they are timid and stubborn, the amphipods have some extra rules:
//
//     Amphipods will never stop on the space immediately outside any room. They can move into that space so long as they immediately continue moving. (Specifically, this refers to the four open spaces in the hallway that are directly above an amphipod starting position.)
//     Amphipods will never move from the hallway into a room unless that room is their destination room and that room contains no amphipods which do not also have that room as their own destination. If an amphipod's starting room is not its destination room, it can stay in that room until it leaves the room. (For example, an Amber amphipod will not move from the hallway into the right three rooms, and will only move into the leftmost room if that room is empty or if it only contains other Amber amphipods.)
//     Once an amphipod stops moving in the hallway, it will stay in that spot until it can move into a room. (That is, once any amphipod starts moving, any other amphipods currently in the hallway are locked in place and will not move again until they can move fully into a room.)
//
// In the above example, the amphipods can be organized using a minimum of 12521 energy. One way to do this is shown below.
//
// Starting configuration:
//
// #############
// #...........#
// ###B#C#B#D###
//   #A#D#C#A#
//   #########
//
// One Bronze amphipod moves into the hallway, taking 4 steps and using 40 energy:
//
// #############
// #...B.......#
// ###B#C#.#D###
//   #A#D#C#A#
//   #########
//
// The only Copper amphipod not in its side room moves there, taking 4 steps and using 400 energy:
//
// #############
// #...B.......#
// ###B#.#C#D###
//   #A#D#C#A#
//   #########
//
// A Desert amphipod moves out of the way, taking 3 steps and using 3000 energy, and then the Bronze amphipod takes its place, taking 3 steps and using 30 energy:
//
// #############
// #.....D.....#
// ###B#.#C#D###
//   #A#B#C#A#
//   #########
//
// The leftmost Bronze amphipod moves to its room using 40 energy:
//
// #############
// #.....D.....#
// ###.#B#C#D###
//   #A#B#C#A#
//   #########
//
// Both amphipods in the rightmost room move into the hallway, using 2003 energy in total:
//
// #############
// #.....D.D.A.#
// ###.#B#C#.###
//   #A#B#C#.#
//   #########
//
// Both Desert amphipods move into the rightmost room using 7000 energy:
//
// #############
// #.........A.#
// ###.#B#C#D###
//   #A#B#C#D#
//   #########
//
// Finally, the last Amber amphipod moves into its room, using 8 energy:
//
// #############
// #...........#
// ###A#B#C#D###
//   #A#B#C#D#
//   #########
//
// What is the least energy required to organize the amphipods?

const std = @import("std");

const input = @embedFile("../input/day23.txt");

const Move = struct {
    room: usize,
    hallway: usize,
};

const Moves = struct {
    const max_size: usize = 32;
    payload: [max_size]Move,
    size: usize,

    pub fn init() @This() {
        return @This(){
            .payload = undefined,
            .size = 0,
        };
    }

    pub fn append(self: *@This(), room: usize, hallway: usize) void {
        if (self.size >= max_size) {
            unreachable;
        }
        self.payload[self.size] = Move{ .room = room, .hallway = hallway };
        self.size += 1;
    }

    pub fn moves(self: *const @This()) []const Move {
        return self.payload[0..self.size];
    }
};

pub fn solve() !void {
    std.log.info("Day23 \n\tpart 1 -> {}\n\tpart 2 -> {}", .{ part1(), part2() });
}

fn room_to_hallway(room: usize) usize {
    return 2 + (2 * (room % 4));
}
fn get_target_room(p: u8) usize {
    switch (p) {
        'A' => return 0,
        'B' => return 1,
        'C' => return 2,
        'D' => return 3,
        else => unreachable,
    }
}

const Burrow = struct {
    rooms: [16]u8,
    hallway: [11]u8,
    room_size: usize,

    pub fn init(data: []const u8) @This() {
        var iterator = std.mem.tokenize(u8, data, "#\r\n. ");

        var self = @This(){
            .rooms = [_]u8{'.'} ** 16,
            .hallway = [_]u8{'.'} ** 11,
            .room_size = 8,
        };

        for (self.rooms[0..8]) |*room| {
            room.* = iterator.next().?[0];
        }

        return self;
    }

    fn is_legal_move(self: *const @This(), room: usize, hallway: usize) bool {
        if (hallway >= 2 and hallway <= 8 and (hallway % 2) == 0) {
            return false;
        }

        const in_room = self.rooms[room] != '.';
        if (in_room and get_target_room(self.rooms[room]) == (room % 4)) {
            if (room >= (self.room_size - 4)) {
                return false;
            }

            var check = room;
            while (check < (self.room_size - 4)) : (check += 4) {
                if (get_target_room(self.rooms[check + 4]) == (check % 4)) {
                    return false;
                }
            }
        } else if (self.hallway[hallway] != '.') {
            const target = get_target_room(self.hallway[hallway]);
            var index: usize = 0;
            while (index < self.room_size) : (index += 4) {
                const value = self.rooms[target + index];
                if (value == '.') {
                    continue;
                } else if (value != self.hallway[hallway]) {
                    return false;
                }
            }
        }

        const hall = room_to_hallway(room);
        var low = std.math.min(hall, hallway);
        var high = std.math.max(hall, hallway) + 1;
        if (!in_room) {
            if (low == hallway) {
                low += 1;
            } else {
                high -= 1;
            }
        }

        for (self.hallway[low..high]) |v| {
            if (v != '.') {
                return false;
            }
        }

        return true;
    }

    fn possibleMoves(self: *const @This()) Moves {
        var moves = Moves.init();
        {
            var index: usize = 0;
            while (index < self.room_size) : (index += 4) {
                for (self.rooms[index..(index + 4)]) |r, ri| {
                    if (index >= 4 and self.rooms[index - 4 + ri] != '.') {
                        continue;
                    }

                    if (r == 'A' or r == 'B' or r == 'C' or r == 'D') {
                        for (self.hallway) |_, hi| {
                            if (self.is_legal_move(ri + index, hi)) {
                                moves.append(ri + index, hi);
                            }
                        }
                    }
                }
            }
        }

        for (self.hallway) |h, hi| {
            if (h == 'A' or h == 'B' or h == 'C' or h == 'D') {
                var ri = get_target_room(h);
                var offset: usize = 0;
                if (self.rooms[ri] == '.' and self.is_legal_move(ri, hi)) {
                    var index: usize = 4;
                    while (index < self.room_size) : (index += 4) {
                        if (self.rooms[ri + index] == '.') {
                            offset += 4;
                        }
                    }

                    moves.append(ri + offset, hi);
                }
            }
        }

        return moves;
    }

    fn get_cost_of_move(self: *const @This(), move: Move) usize {
        var numMoves: usize = (move.room / 4) + 1;
        const hall = room_to_hallway(move.room);
        numMoves += std.math.max(hall, move.hallway) - std.math.min(hall, move.hallway);
        const room = self.rooms[move.room];
        const hallway = self.hallway[move.hallway];
        const p = if (room == '.') hallway else room;
        switch (p) {
            'A' => return numMoves * 1,
            'B' => return numMoves * 10,
            'C' => return numMoves * 100,
            'D' => return numMoves * 1000,
            else => unreachable,
        }
    }

    fn is_finished(self: *const @This()) bool {
        for (self.rooms[0..self.room_size]) |r, ri| {
            switch (ri % 4) {
                0 => if (r != 'A') return false,
                1 => if (r != 'B') return false,
                2 => if (r != 'C') return false,
                3 => if (r != 'D') return false,
                else => unreachable,
            }
        }

        return true;
    }

    const Potential = struct {
        burrow: Burrow,
        cost: usize,

        pub fn init(burrow: Burrow, cost: usize) @This() {
            return @This(){
                .burrow = burrow,
                .cost = cost,
            };
        }
    };

    fn calculate_cost(self: *const @This()) !usize {
        var search = std.ArrayList(Potential).init(std.testing.allocator);
        var reducer = std.AutoHashMap(Burrow, usize).init(std.testing.allocator);
        try search.append(Potential.init(self.*, 0));
        var result: ?usize = null;
        while (search.items.len != 0) {
            const pop = search.swapRemove(0);

            var seenAlready = reducer.get(pop.burrow);

            if (seenAlready == null) {
                try reducer.put(pop.burrow, pop.cost);
            } else {
                if (seenAlready.? <= pop.cost) {
                    continue;
                }

                try reducer.put(pop.burrow, pop.cost);
            }

            if (result != null) {
                if (result.? <= pop.cost) {
                    continue;
                }
            }

            const searchResult = try pop.burrow.search_cost(pop.cost, &search);
            if (searchResult != null) {
                if (result == null) {
                    result = searchResult.?;
                } else {
                    result = std.math.min(result.?, searchResult.?);
                }
            }
        }

        return result.?;
    }

    fn search_cost(self: *const @This(), inputCost: usize, search: *std.ArrayList(Potential)) !?usize {
        const moves = self.possibleMoves();
        var m: usize = 0;

        while (m < moves.size) : (m += 1) {
            const move = moves.payload[m];
            var new_self = self.*;
            const myget_cost_of_move = self.get_cost_of_move(move);
            const move_to_room = new_self.rooms[move.room] == '.';

            if (move_to_room) {
                new_self.rooms[move.room] = new_self.hallway[move.hallway];
                new_self.hallway[move.hallway] = '.';
            } else {
                new_self.hallway[move.hallway] = new_self.rooms[move.room];
                new_self.rooms[move.room] = '.';
            }

            const total = inputCost + myget_cost_of_move;
            if (new_self.is_finished()) {
                return total;
            }

            try search.append(Potential.init(new_self, total));
        }

        return null;
    }
};

fn part1() !usize {
    var burrow = Burrow.init(input);
    return try burrow.calculate_cost();
}

fn part2() !usize {
    return 0;
}
