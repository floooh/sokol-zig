const std = @import("std");

export fn sokol_zig_log(s: [*:0]const u8) callconv(.C) void {
    std.log.info("{s}", .{s});
}

export fn sokol_zig_assert(c: c_uint, s: [*:0]const u8) callconv(.C) void {
    if (c == 0) {
        std.log.err("Assertion: {s}", .{s});
        @panic(s[0..std.mem.len(s)]);
    }
}
