const Statement = @import("statement.zig").Statement;
const Expression = @import("expression.zig").Expression;
const Program = @import("Program.zig");

pub const Node = union(enum) {
    Statement: Statement,
    Expression: Expression,
    Program: Program,
};
