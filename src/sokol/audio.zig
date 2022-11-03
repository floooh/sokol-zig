// machine generated, do not edit

const builtin = @import("builtin");
const meta = @import("std").meta;

// helper function to convert a C string to a Zig string slice
fn cStrToZig(c_str: [*c]const u8) [:0]const u8 {
  return @import("std").mem.span(c_str);
}
pub const Allocator = extern struct {
    alloc: ?meta.FnPtr(fn(usize, ?*anyopaque) callconv(.C) ?*anyopaque) = null,
    free: ?meta.FnPtr(fn(?*anyopaque, ?*anyopaque) callconv(.C) void) = null,
    user_data: ?*anyopaque = null,
};
pub const Logger = extern struct {
    log_cb: ?meta.FnPtr(fn([*c]const u8, ?*anyopaque) callconv(.C) void) = null,
    user_data: ?*anyopaque = null,
};
pub const Logger = extern struct {
    log_cb: ?fn([*c]const u8, ?*anyopaque) callconv(.C) void = null,
    user_data: ?*anyopaque = null,
};
pub const Desc = extern struct {
    sample_rate: i32 = 0,
    num_channels: i32 = 0,
    buffer_frames: i32 = 0,
    packet_frames: i32 = 0,
    num_packets: i32 = 0,
    stream_cb: ?meta.FnPtr(fn([*c] f32, i32, i32) callconv(.C) void) = null,
    stream_userdata_cb: ?meta.FnPtr(fn([*c] f32, i32, i32, ?*anyopaque) callconv(.C) void) = null,
    user_data: ?*anyopaque = null,
    allocator: Allocator = .{ },
    logger: Logger = .{ },
};
pub extern fn saudio_setup([*c]const Desc) void;
pub fn setup(desc: Desc) void {
    saudio_setup(&desc);
}
pub extern fn saudio_shutdown() void;
pub fn shutdown() void {
    saudio_shutdown();
}
pub extern fn saudio_isvalid() bool;
pub fn isvalid() bool {
    return saudio_isvalid();
}
pub extern fn saudio_userdata() ?*anyopaque;
pub fn userdata() ?*anyopaque {
    return saudio_userdata();
}
pub extern fn saudio_query_desc() Desc;
pub fn queryDesc() Desc {
    return saudio_query_desc();
}
pub extern fn saudio_sample_rate() i32;
pub fn sampleRate() i32 {
    return saudio_sample_rate();
}
pub extern fn saudio_buffer_frames() i32;
pub fn bufferFrames() i32 {
    return saudio_buffer_frames();
}
pub extern fn saudio_channels() i32;
pub fn channels() i32 {
    return saudio_channels();
}
pub extern fn saudio_suspended() bool;
pub fn suspended() bool {
    return saudio_suspended();
}
pub extern fn saudio_expect() i32;
pub fn expect() i32 {
    return saudio_expect();
}
pub extern fn saudio_push([*c]const f32, i32) i32;
pub fn push(frames: *const f32, num_frames: i32) i32 {
    return saudio_push(frames, num_frames);
}
