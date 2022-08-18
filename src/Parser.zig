const std = @import("std");
const ast = @import("ast.zig");

const Lexer = @import("Lexer.zig");
const Token = @import("Token.zig");

l: *Lexer,

curToken: ?Token = null,
peekToken: ?Token = null,

pub fn init(l: *Lexer) !@This() {
    var result = @This(){
        .l = l,
    };
    try result.nextToken();
    try result.nextToken();
    return result;
}

pub fn deinit(self: *@This()) void {
    if (self.curToken) |cur| {
        cur.deinit();
    }
    if (self.peekToken) |peek| {
        peek.deinit();
    }
}

fn nextToken(self: *@This()) !void {
    if (self.curToken) |old| {
        old.deinit();
    }
    self.curToken = self.peekToken;
    self.peekToken = try self.l.nextToken();
}

pub fn parseProgram(self: *@This()) !?*ast.Program {
    _ = self;
    return null;
}

test "let statements" {
    const input = @embedFile("parser/letStatementsInput.txt");
    var l = try Lexer.init(std.testing.allocator, input);
    defer l.deinit();
    var p = try init(&l);
    defer p.deinit();

    const program = try p.parseProgram();
    try std.testing.expect(program != null);
}
