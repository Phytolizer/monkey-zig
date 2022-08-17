const std = @import("std");

const Allocator = std.mem.Allocator;
const Token = @import("Token.zig");

const Self = @This();

allocator: Allocator,
input: []const u8,
position: usize = 0,
readPosition: usize = 0,
ch: u8 = 0,

pub fn init(allocator: Allocator, input: []const u8) Self {
    var result = Self{
        .allocator = allocator,
        .input = input,
    };
    result.readChar();
    return result;
}

fn readChar(self: *Self) void {
    if (self.readPosition >= self.input.len) {
        self.ch = 0;
    } else {
        self.ch = self.input[self.readPosition];
    }
    self.position = self.readPosition;
    self.readPosition += 1;
}

pub fn nextToken(self: *Self) !Token {
    var tok: Token = undefined;

    switch (self.ch) {
        '=' => {
            tok = try Token.init(self.allocator, .Assign, &.{self.ch});
        },
        ';' => {
            tok = try Token.init(self.allocator, .Semicolon, &.{self.ch});
        },
        '(' => {
            tok = try Token.init(self.allocator, .LParen, &.{self.ch});
        },
        ')' => {
            tok = try Token.init(self.allocator, .RParen, &.{self.ch});
        },
        ',' => {
            tok = try Token.init(self.allocator, .Comma, &.{self.ch});
        },
        '+' => {
            tok = try Token.init(self.allocator, .Plus, &.{self.ch});
        },
        '{' => {
            tok = try Token.init(self.allocator, .LBrace, &.{self.ch});
        },
        '}' => {
            tok = try Token.init(self.allocator, .RBrace, &.{self.ch});
        },
        0 => {
            tok = try Token.init(self.allocator, .Eof, "");
        },
        else => unreachable,
    }

    self.readChar();
    return tok;
}

test "nextToken" {
    const input = "=+(){},;";
    const Test = struct {
        expectedKind: Token.Kind,
        expectedLiteral: []const u8,

        const Test = @This();
        pub fn init(expectedKind: Token.Kind, expectedLiteral: []const u8) Test {
            return Test{
                .expectedKind = expectedKind,
                .expectedLiteral = expectedLiteral,
            };
        }
    };
    const tests = [_]Test{
        Test.init(.Assign, "="),
        Test.init(.Plus, "+"),
        Test.init(.LParen, "("),
        Test.init(.RParen, ")"),
        Test.init(.LBrace, "{"),
        Test.init(.RBrace, "}"),
        Test.init(.Comma, ","),
        Test.init(.Semicolon, ";"),
        Test.init(.Eof, ""),
    };

    var l = Self.init(std.testing.allocator, input);

    for (tests) |tt| {
        const tok = try l.nextToken();
        defer tok.deinit();
        try std.testing.expectEqual(tok.kind, tt.expectedKind);
        try std.testing.expectEqualStrings(tok.literal, tt.expectedLiteral);
    }
}
