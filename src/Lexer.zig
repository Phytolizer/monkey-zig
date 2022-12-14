const std = @import("std");

const Allocator = std.mem.Allocator;
const Token = @import("Token.zig");

const Self = @This();
const Keywords = std.StringHashMap(Token.Kind);

allocator: Allocator,
keywords: Keywords,
input: []const u8,
position: usize = 0,
readPosition: usize = 0,
ch: u8 = 0,

pub fn init(allocator: Allocator, input: []const u8) !Self {
    var result = Self{
        .allocator = allocator,
        .keywords = Keywords.init(allocator),
        .input = input,
    };
    try result.fillKeywords();
    result.readChar();
    return result;
}

fn fillKeywords(self: *Self) !void {
    try self.keywords.put("fn", .Function);
    try self.keywords.put("let", .Let);
    try self.keywords.put("true", .True);
    try self.keywords.put("false", .False);
    try self.keywords.put("if", .If);
    try self.keywords.put("else", .Else);
    try self.keywords.put("return", .Return);
}

pub fn deinit(self: *Self) void {
    self.keywords.deinit();
}

fn peekChar(self: *const Self) u8 {
    return if (self.readPosition >= self.input.len)
        0
    else
        self.input[self.readPosition];
}

fn readChar(self: *Self) void {
    self.ch = self.peekChar();
    self.position = self.readPosition;
    self.readPosition += 1;
}

fn isLetter(ch: u8) bool {
    return (ch >= 'a' and ch <= 'z') or (ch >= 'A' and ch <= 'Z') or ch == '_';
}

fn isDigit(ch: u8) bool {
    return ch >= '0' and ch <= '9';
}

fn readIdentifier(self: *Self) []const u8 {
    const position = self.position;
    while (isLetter(self.ch)) {
        self.readChar();
    }
    return self.input[position..self.position];
}

fn readNumber(self: *Self) []const u8 {
    const position = self.position;
    while (isDigit(self.ch)) {
        self.readChar();
    }
    return self.input[position..self.position];
}

fn skipWhitespace(self: *Self) void {
    while (self.ch == ' ' or self.ch == '\t' or self.ch == '\n' or self.ch == '\r') {
        self.readChar();
    }
}

pub fn nextToken(self: *Self) !Token {
    var tok: Token = undefined;
    tok.allocator = self.allocator;

    self.skipWhitespace();

    switch (self.ch) {
        '=' => {
            if (self.peekChar() == '=') {
                const ch = self.ch;
                self.readChar();
                tok = try Token.init(self.allocator, .Eq, &.{ ch, self.ch });
            } else {
                tok = try Token.init(self.allocator, .Assign, &.{self.ch});
            }
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
        '-' => {
            tok = try Token.init(self.allocator, .Minus, &.{self.ch});
        },
        '!' => {
            if (self.peekChar() == '=') {
                const ch = self.ch;
                self.readChar();
                tok = try Token.init(self.allocator, .NotEq, &.{ ch, self.ch });
            } else {
                tok = try Token.init(self.allocator, .Bang, &.{self.ch});
            }
        },
        '*' => {
            tok = try Token.init(self.allocator, .Asterisk, &.{self.ch});
        },
        '/' => {
            tok = try Token.init(self.allocator, .Slash, &.{self.ch});
        },
        '<' => {
            tok = try Token.init(self.allocator, .Lt, &.{self.ch});
        },
        '>' => {
            tok = try Token.init(self.allocator, .Gt, &.{self.ch});
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
        else => {
            if (isLetter(self.ch)) {
                tok.literal = try self.allocator.dupe(u8, self.readIdentifier());
                tok.kind = self.keywords.get(tok.literal) orelse .Ident;
                return tok;
            } else if (isDigit(self.ch)) {
                tok.kind = .Int;
                tok.literal = try self.allocator.dupe(u8, self.readNumber());
                return tok;
            } else {
                tok = try Token.init(self.allocator, .Illegal, &.{self.ch});
            }
        },
    }

    self.readChar();
    return tok;
}

test "nextToken" {
    const input = @embedFile("lexer/nextTokenInput.txt");
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

        pub fn testToken(tt: *const Test, tok: Token) !void {
            try std.testing.expectEqual(tt.expectedKind, tok.kind);
            try std.testing.expectEqualStrings(tt.expectedLiteral, tok.literal);
        }
    };
    const tests = [_]Test{
        Test.init(.Let, "let"),
        Test.init(.Ident, "five"),
        Test.init(.Assign, "="),
        Test.init(.Int, "5"),
        Test.init(.Semicolon, ";"),
        Test.init(.Let, "let"),
        Test.init(.Ident, "ten"),
        Test.init(.Assign, "="),
        Test.init(.Int, "10"),
        Test.init(.Semicolon, ";"),
        Test.init(.Let, "let"),
        Test.init(.Ident, "add"),
        Test.init(.Assign, "="),
        Test.init(.Function, "fn"),
        Test.init(.LParen, "("),
        Test.init(.Ident, "x"),
        Test.init(.Comma, ","),
        Test.init(.Ident, "y"),
        Test.init(.RParen, ")"),
        Test.init(.LBrace, "{"),
        Test.init(.Ident, "x"),
        Test.init(.Plus, "+"),
        Test.init(.Ident, "y"),
        Test.init(.Semicolon, ";"),
        Test.init(.RBrace, "}"),
        Test.init(.Semicolon, ";"),
        Test.init(.Let, "let"),
        Test.init(.Ident, "result"),
        Test.init(.Assign, "="),
        Test.init(.Ident, "add"),
        Test.init(.LParen, "("),
        Test.init(.Ident, "five"),
        Test.init(.Comma, ","),
        Test.init(.Ident, "ten"),
        Test.init(.RParen, ")"),
        Test.init(.Semicolon, ";"),
        Test.init(.Bang, "!"),
        Test.init(.Minus, "-"),
        Test.init(.Slash, "/"),
        Test.init(.Asterisk, "*"),
        Test.init(.Int, "5"),
        Test.init(.Semicolon, ";"),
        Test.init(.Int, "5"),
        Test.init(.Lt, "<"),
        Test.init(.Int, "10"),
        Test.init(.Gt, ">"),
        Test.init(.Int, "5"),
        Test.init(.Semicolon, ";"),
        Test.init(.If, "if"),
        Test.init(.LParen, "("),
        Test.init(.Int, "5"),
        Test.init(.Lt, "<"),
        Test.init(.Int, "10"),
        Test.init(.RParen, ")"),
        Test.init(.LBrace, "{"),
        Test.init(.Return, "return"),
        Test.init(.True, "true"),
        Test.init(.Semicolon, ";"),
        Test.init(.RBrace, "}"),
        Test.init(.Else, "else"),
        Test.init(.LBrace, "{"),
        Test.init(.Return, "return"),
        Test.init(.False, "false"),
        Test.init(.Semicolon, ";"),
        Test.init(.RBrace, "}"),
        Test.init(.Int, "10"),
        Test.init(.Eq, "=="),
        Test.init(.Int, "10"),
        Test.init(.Semicolon, ";"),
        Test.init(.Int, "10"),
        Test.init(.NotEq, "!="),
        Test.init(.Int, "9"),
        Test.init(.Semicolon, ";"),
        Test.init(.Eof, ""),
    };

    var l = try Self.init(std.testing.allocator, input);
    defer l.deinit();

    for (tests) |tt| {
        const tok = try l.nextToken();
        defer tok.deinit();
        tt.testToken(tok) catch {
            std.debug.print("Expected '{s}' ({s}), got '{s}' ({s})\n", .{
                tt.expectedLiteral,
                tt.expectedKind.toString(),
                tok.literal,
                tok.kind.toString(),
            });
            return error.TokenMismatch;
        };
    }
}
