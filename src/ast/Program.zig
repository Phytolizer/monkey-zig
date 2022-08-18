const Statement = @import("statement.zig").Statement;

statements: []*Statement,

pub fn tokenLiteral(self: *const @This()) []const u8 {
    return if (self.statements.len == 0)
        ""
    else
        self.statements[0].value.tokenLiteral();
}
