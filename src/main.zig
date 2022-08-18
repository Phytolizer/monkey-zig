const std = @import("std");
const currentUser = @import("user.zig").currentUser;
const repl = @import("repl.zig");

pub fn main() !void {
    const gpAllocator = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpAllocator.backing_allocator;
    const user = try currentUser(allocator);
    defer allocator.free(user);
    std.debug.print("Hello {s}! This is the Monkey programming language!\n", .{user});
    std.debug.print("Feel free to type in commands\n", .{});
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    try repl.start(@TypeOf(stdin), stdin, @TypeOf(stdout), stdout);
}

test {
    _ = @import("Lexer.zig");
    _ = @import("Parser.zig");
}
