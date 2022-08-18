const LetStatement = @import("LetStatement.zig");

pub const Statement = union(enum) {
    Let: LetStatement,

    pub fn tokenLiteral(self: *const @This()) []const u8 {
        return switch (self) {
            .Let => |ls| ls.tokenLiteral(),
        };
    }

    pub fn deinit(self: *const @This()) void {
        switch (self) {
            .Let => |ls| ls.deinit(),
        }
    }
};
