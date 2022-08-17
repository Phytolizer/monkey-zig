const std = @import("std");
const builtin = @import("builtin");
const win32 = if (builtin.os.tag == .windows)
    @import("zigwin32")
else
    struct {};
const system = if (builtin.os.tag != .windows)
    @import("unix.zig")
else
    struct {};
const Allocator = std.mem.Allocator;

pub fn currentUser(allocator: Allocator) ![]u8 {
    _ = allocator;
    switch (builtin.os.tag) {
        .windows => {
            var size: u32 = 0;
            _ = win32.security.authentication.identity.GetUserNameExA(.Display, null, &size);
            var result = try allocator.alloc(u8, size);
            _ = win32.security.authentication.identity.GetUserNameExA(.Display, result[0..result.len :0], &size);
            return result;
        },
        else => {
            var bufsizeI = system.sysconf(system._SC_GETPW_R_SIZE_MAX);
            const bufsize = if (bufsizeI == -1)
                16384
            else
                @intCast(usize, bufsizeI);

            var buf = try allocator.alloc(u8, bufsize);
            defer allocator.free(buf);
            const uid = system.getuid();
            var pw: system.passwd = undefined;
            var result: ?*system.passwd = undefined;
            _ = system.getpwuid_r(uid, &pw, buf.ptr, bufsize, &result);
            if (result == null) {
                return error.CannotGetUserName;
            }
            const strlen = std.mem.indexOfScalar(u8, pw.pw_name[0..bufsize], 0) orelse bufsize;
            const name = try allocator.dupe(u8, pw.pw_name[0..strlen]);
            return name;
        },
    }
}
