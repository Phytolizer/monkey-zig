const std = @import("std");

const Token = @import("../Token.zig");
const Allocator = std.mem.Allocator;

allocator: Allocator,
token: Token,
value: []u8,

pub fn deinit(self: *const @This()) void {
    self.allocator.free(self.value);
    self.token.deinit();
}

pub fn tokenLiteral(self: *const @This()) []const u8 {
    return self.token.literal;
}
