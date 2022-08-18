const Token = @import("../Token.zig");
const Identifier = @import("Identifier.zig");
const Expression = @import("expression.zig").Expression;

token: Token,
name: *Identifier,
value: *Expression,

pub fn deinit(self: *const @This()) void {
    self.token.deinit();
    self.name.deinit();
    self.value.deinit();
}

pub fn tokenLiteral(self: *const @This()) []const u8 {
    return self.token.literal;
}
