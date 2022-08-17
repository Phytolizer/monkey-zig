const c = @cImport({
    @cInclude("unistd.h");
    @cInclude("sys/types.h");
    @cInclude("pwd.h");
});
pub const _SC_GETPW_R_SIZE_MAX = c._SC_GETPW_R_SIZE_MAX;
pub const sysconf = c.sysconf;

pub const getuid = c.getuid;

pub const uid_t = c.uid_t;
pub const gid_t = c.gid_t;
pub const passwd = c.passwd;
pub const getpwuid_r = c.getpwuid_r;