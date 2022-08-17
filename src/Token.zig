const std = @import("std");

const Allocator = std.mem.Allocator;

pub const Kind = enum {
    Illegal,
    Eof,

    Ident,
    Int,

    Assign,
    Plus,
    Minus,
    Bang,
    Asterisk,
    Slash,

    Lt,
    Gt,

    Comma,
    Semicolon,

    LParen,
    RParen,
    LBrace,
    RBrace,

    Function,
    Let,

    pub fn toString(self: Kind) []const u8 {
        return switch (self) {
            .Illegal => "ILLEGAL",
            .Eof => "EOF",
            .Ident => "IDENT",
            .Int => "INT",
            .Assign => "=",
            .Plus => "+",
            .Minus => "-",
            .Bang => "!",
            .Asterisk => "*",
            .Slash => "/",
            .Lt => "<",
            .Gt => ">",
            .Comma => ",",
            .Semicolon => ";",
            .LParen => "(",
            .RParen => ")",
            .LBrace => "{",
            .RBrace => "}",
            .Function => "FUNCTION",
            .Let => "LET",
        };
    }
};

allocator: Allocator,
kind: Kind,
literal: []u8,

const Self = @This();

pub fn init(allocator: Allocator, kind: Kind, literal: []const u8) !Self {
    return Self{
        .allocator = allocator,
        .kind = kind,
        .literal = try allocator.dupe(u8, literal),
    };
}

pub fn deinit(self: *const Self) void {
    self.allocator.free(self.literal);
}
