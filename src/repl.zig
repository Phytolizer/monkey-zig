const std = @import("std");

const Lexer = @import("Lexer.zig");

const prompt = ">> ";

pub fn start(comptime Reader: type, reader: Reader, comptime Writer: type, writer: Writer) !void {
    const gpAllocator = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpAllocator.backing_allocator;
    var scanner = std.io.bufferedReader(reader);
    const scannerReader = scanner.reader();

    while (true) {
        try writer.writeAll(prompt);
        const scanned = (try scannerReader.readUntilDelimiterOrEofAlloc(allocator, '\n', 256)) orelse {
            try writer.writeAll("\n");
            return;
        };
        defer allocator.free(scanned);

        var l = try Lexer.init(allocator, scanned);
        defer l.deinit();

        while (true) {
            const token = try l.nextToken();
            defer token.deinit();
            if (token.kind == .Eof) {
                break;
            }
            try writer.print("{any}\n", .{token});
        }
    }
}
