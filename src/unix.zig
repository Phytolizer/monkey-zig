pub const _SC_GETPW_R_SIZE_MAX: c_int = 70;
pub extern "c" fn sysconf(sc: c_int) i64;

pub extern "c" fn getuid() uid_t;

pub const uid_t = c_uint;
pub const gid_t = c_uint;
pub const passwd = extern struct {
    pw_name: [*c]u8,
    pw_passwd: [*c]u8,
    pw_uid: uid_t,
    pw_gid: gid_t,
    pw_gecos: [*c]u8,
    pw_dir: [*c]u8,
    pw_shell: [*c]u8,
};

pub extern "c" fn getpwuid_r(
    uid: uid_t,
    pwd: [*c]passwd,
    buf: [*c]u8,
    buflen: usize,
    result: [*c][*c]passwd,
) c_int;
