const Identifier = @import("Identifier.zig");

pub const Expression = union(enum) {
    Identifier: Identifier,

    pub fn tokenLiteral(self: *const @This()) []const u8 {
        return switch (self) {
            .Identifier => |id| id.tokenLiteral(),
        };
    }

    pub fn deinit(self: *const @This()) void {
        switch (self) {
            .Identifier => |id| id.deinit(),
        }
    }
};
