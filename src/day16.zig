// --- Day 16: Packet Decoder ---
// 
// As you leave the cave and reach open waters, you receive a transmission from the Elves back on the ship.
// 
// The transmission was sent using the Buoyancy Interchange Transmission System (BITS), a method of packing numeric expressions into a binary sequence. Your submarine's computer has saved the transmission in hexadecimal (your puzzle input).
// 
// The first step of decoding the message is to convert the hexadecimal representation into binary. Each character of hexadecimal corresponds to four bits of binary data:
// 
// 0 = 0000
// 1 = 0001
// 2 = 0010
// 3 = 0011
// 4 = 0100
// 5 = 0101
// 6 = 0110
// 7 = 0111
// 8 = 1000
// 9 = 1001
// A = 1010
// B = 1011
// C = 1100
// D = 1101
// E = 1110
// F = 1111
// 
// The BITS transmission contains a single packet at its outermost layer which itself contains many other packets. The hexadecimal representation of this packet might encode a few extra 0 bits at the end; these are not part of the transmission and should be ignored.
// 
// Every packet begins with a standard header: the first three bits encode the packet version, and the next three bits encode the packet type ID. These two values are numbers; all numbers encoded in any packet are represented as binary with the most significant bit first. For example, a version encoded as the binary sequence 100 represents the number 4.
// 
// Packets with type ID 4 represent a literal value. Literal value packets encode a single binary number. To do this, the binary number is padded with leading zeroes until its length is a multiple of four bits, and then it is broken into groups of four bits. Each group is prefixed by a 1 bit except the last group, which is prefixed by a 0 bit. These groups of five bits immediately follow the packet header. For example, the hexadecimal string D2FE28 becomes:
// 
// 110100101111111000101000
// VVVTTTAAAAABBBBBCCCCC
// 
// Below each bit is a label indicating its purpose:
// 
//     The three bits labeled V (110) are the packet version, 6.
//     The three bits labeled T (100) are the packet type ID, 4, which means the packet is a literal value.
//     The five bits labeled A (10111) start with a 1 (not the last group, keep reading) and contain the first four bits of the number, 0111.
//     The five bits labeled B (11110) start with a 1 (not the last group, keep reading) and contain four more bits of the number, 1110.
//     The five bits labeled C (00101) start with a 0 (last group, end of packet) and contain the last four bits of the number, 0101.
//     The three unlabeled 0 bits at the end are extra due to the hexadecimal representation and should be ignored.
// 
// So, this packet represents a literal value with binary representation 011111100101, which is 2021 in decimal.
// 
// Every other type of packet (any packet with a type ID other than 4) represent an operator that performs some calculation on one or more sub-packets contained within. Right now, the specific operations aren't important; focus on parsing the hierarchy of sub-packets.
// 
// An operator packet contains one or more packets. To indicate which subsequent binary data represents its sub-packets, an operator packet can use one of two modes indicated by the bit immediately after the packet header; this is called the length type ID:
// 
//     If the length type ID is 0, then the next 15 bits are a number that represents the total length in bits of the sub-packets contained by this packet.
//     If the length type ID is 1, then the next 11 bits are a number that represents the number of sub-packets immediately contained by this packet.
// 
// Finally, after the length type ID bit and the 15-bit or 11-bit field, the sub-packets appear.
// 
// For example, here is an operator packet (hexadecimal string 38006F45291200) with length type ID 0 that contains two sub-packets:
// 
// 00111000000000000110111101000101001010010001001000000000
// VVVTTTILLLLLLLLLLLLLLLAAAAAAAAAAABBBBBBBBBBBBBBBB
// 
//     The three bits labeled V (001) are the packet version, 1.
//     The three bits labeled T (110) are the packet type ID, 6, which means the packet is an operator.
//     The bit labeled I (0) is the length type ID, which indicates that the length is a 15-bit number representing the number of bits in the sub-packets.
//     The 15 bits labeled L (000000000011011) contain the length of the sub-packets in bits, 27.
//     The 11 bits labeled A contain the first sub-packet, a literal value representing the number 10.
//     The 16 bits labeled B contain the second sub-packet, a literal value representing the number 20.
// 
// After reading 11 and 16 bits of sub-packet data, the total length indicated in L (27) is reached, and so parsing of this packet stops.
// 
// As another example, here is an operator packet (hexadecimal string EE00D40C823060) with length type ID 1 that contains three sub-packets:
// 
// 11101110000000001101010000001100100000100011000001100000
// VVVTTTILLLLLLLLLLLAAAAAAAAAAABBBBBBBBBBBCCCCCCCCCCC
// 
//     The three bits labeled V (111) are the packet version, 7.
//     The three bits labeled T (011) are the packet type ID, 3, which means the packet is an operator.
//     The bit labeled I (1) is the length type ID, which indicates that the length is a 11-bit number representing the number of sub-packets.
//     The 11 bits labeled L (00000000011) contain the number of sub-packets, 3.
//     The 11 bits labeled A contain the first sub-packet, a literal value representing the number 1.
//     The 11 bits labeled B contain the second sub-packet, a literal value representing the number 2.
//     The 11 bits labeled C contain the third sub-packet, a literal value representing the number 3.
// 
// After reading 3 complete sub-packets, the number of sub-packets indicated in L (3) is reached, and so parsing of this packet stops.
// 
// For now, parse the hierarchy of the packets throughout the transmission and add up all of the version numbers.
// 
// Here are a few more examples of hexadecimal-encoded transmissions:
// 
//     8A004A801A8002F478 represents an operator packet (version 4) which contains an operator packet (version 1) which contains an operator packet (version 5) which contains a literal value (version 6); this packet has a version sum of 16.
//     620080001611562C8802118E34 represents an operator packet (version 3) which contains two sub-packets; each sub-packet is an operator packet that contains two literal values. This packet has a version sum of 12.
//     C0015000016115A2E0802F182340 has the same structure as the previous example, but the outermost packet uses a different length type ID. This packet has a version sum of 23.
//     A0016C880162017C3686B18A3D4780 is an operator packet that contains an operator packet that contains an operator packet that contains five literal values; it has a version sum of 31.
// 
// Decode the structure of your hexadecimal-encoded BITS transmission; what do you get if you add up the version numbers in all packets?

const std = @import("std");

const input = @embedFile("../input/day16.txt");

pub fn solve() !void {
    var buf: [input.len / 2]u8 = undefined;
    var bytes = try std.fmt.hexToBytes(&buf, std.mem.trim(u8, input, "\n"));
    std.log.info("Day16 \n\tpart 1 -> {}\n\tpart 2 -> {}", .{ part1(bytes), part2() });
}

const BitReader = struct {
    bytes: []u8,
    byte: u8,
    byte_index: usize = 0,
    index: usize = 0,
    eof: bool = false,

    const ReadError = error{
        EndOfFile,
    };

    fn next_bit(self: *@This()) @This().ReadError!u1  {
        if (self.eof) return @This().ReadError.EndOfFile;
        var bit: u1 = @intCast(u1, self.byte & 0b0000_0001);
        self.byte >>= 1;

        if (self.index % 8 == 7) {
            self.byte_index += 1;
            if (self.byte_index == self.bytes.len) {
                self.eof = true;
                return bit;
            }

            self.byte = @bitReverse(u8, self.bytes[self.byte_index]);
        }

        self.index += 1;
        return bit;
    }

    fn read(self: *@This(), comptime Int: type) @This().ReadError!Int {
        const int_info = @typeInfo(Int).Int;
        if (int_info.signedness == .signed) @compileError("Only accepts unsigned integers");
        if (int_info.bits == 1) return try self.next_bit();
        var value: Int = 0;
        var i: usize = 0;
        while (i < int_info.bits) : (i += 1) {
            value = value * 2 + try self.next_bit();
        }

        return value;
    }
};

const Packet = struct {
    version: usize = 0,
    id: u8 = 0,
    val: usize = 0,
};

fn parse(br: *BitReader) BitReader.ReadError!Packet {
    var pkt: Packet = .{};
    pkt.version = try br.read(u3);
    pkt.id = try br.read(u3);
    switch (pkt.id) {
        0b100 => {
            var more = true;
            while (more) {
                more = (try br.read(u1)) == 1;
                pkt.val = (pkt.val * (1 << 4)) + try br.read(u4);
            }
        },
        else => {
            var len_id = try br.read(u1);
            var num = switch (len_id) {
                0 => try br.read(u15),
                1 => try br.read(u11),
            };

            if (pkt.id == 1) pkt.val = 1;
            if (pkt.id == 2) pkt.val = std.math.maxInt(usize);
            if (pkt.id == 3) pkt.val = std.math.minInt(usize);

            switch (len_id) {
                0 => {
                    var end = br.index + num;
                    while (br.index < end) {
                        var p = try parse(br);
                        switch (pkt.id) {
                            0 => pkt.val += p.val,
                            1 => pkt.val *= p.val,
                            2 => if (p.val < pkt.val) {
                                pkt.val = p.val;
                            },
                            3 => if (p.val > pkt.val) {
                                pkt.val = p.val;
                            },
                            5 => {
                                var p2 = try parse(br);
                                pkt.version += p2.version;
                                if (p.val > p2.val) {
                                    pkt.val = 1;
                                } else pkt.val = 0;
                            },
                            6 => {
                                var p2 = try parse(br);
                                pkt.version += p2.version;
                                if (p.val < p2.val) {
                                    pkt.val = 1;
                                } else pkt.val = 0;
                            },
                            7 => {
                                var p2 = try parse(br);
                                pkt.version += p2.version;
                                if (p.val == p2.val) {
                                    pkt.val = 1;
                                } else pkt.val = 0;
                            },
                            else => unreachable,
                        }
                        pkt.version += p.version;
                    }
                },
                1 => {
                    var i: usize = 0;
                    while (i < num) : (i += 1) {
                        var p = try parse(br);
                        switch (pkt.id) {
                            0 => pkt.val += p.val,
                            1 => pkt.val *= p.val,
                            2 => if (p.val < pkt.val) {
                                pkt.val = p.val;
                            },
                            3 => if (p.val > pkt.val) {
                                pkt.val = p.val;
                            },
                            5 => {
                                var p2 = try parse(br);
                                pkt.version += p2.version;
                                if (p.val > p2.val) {
                                    pkt.val = 1;
                                } else pkt.val = 0;
                                i += 1;
                            },
                            6 => {
                                var p2 = try parse(br);
                                pkt.version += p2.version;
                                if (p.val < p2.val) {
                                    pkt.val = 1;
                                } else pkt.val = 0;
                                i += 1;
                            },
                            7 => {
                                var p2 = try parse(br);
                                pkt.version += p2.version;
                                if (p.val == p2.val) {
                                    pkt.val = 1;
                                } else pkt.val = 0;
                                i += 1;
                            },
                            else => unreachable,
                        }
                        pkt.version += p.version;
                    }
                },
            }
        },
    }

    return pkt;
}

fn part1(bytes: []u8) !u64 {
    var br = BitReader { .bytes = bytes, .byte = @bitReverse(u8, bytes[0]), .byte_index = 0, .index = 0, .eof = false };
    var p = try parse(&br);
    return p.version;
}

fn part2() !u64 {
    return 0;
}
