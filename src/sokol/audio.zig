// machine generated, do not edit

pub const Desc = extern struct {
    sample_rate: i32 = 0,
    num_channels: i32 = 0,
    buffer_frames: i32 = 0,
    packet_frames: i32 = 0,
    num_packets: i32 = 0,
    stream_cb: ?fn([*c] f32, i32, i32) callconv(.C) void = null,
    stream_userdata_cb: ?fn([*c] f32, i32, i32, ?*c_void) callconv(.C) void = null,
    user_data: ?*c_void = null,
};
pub extern fn saudio_setup([*c]const Desc) void;
pub inline fn setup(desc: Desc) void {
    saudio_setup(&desc);
}
pub extern fn saudio_shutdown() void;
pub inline fn shutdown() void {
    saudio_shutdown();
}
pub extern fn saudio_isvalid() bool;
pub inline fn isvalid() bool {
    return saudio_isvalid();
}
pub extern fn saudio_userdata() ?*c_void;
pub inline fn userdata() ?*c_void {
    return saudio_userdata();
}
pub extern fn saudio_query_desc() Desc;
pub inline fn queryDesc() Desc {
    return saudio_query_desc();
}
pub extern fn saudio_sample_rate() i32;
pub inline fn sampleRate() i32 {
    return saudio_sample_rate();
}
pub extern fn saudio_buffer_frames() i32;
pub inline fn bufferFrames() i32 {
    return saudio_buffer_frames();
}
pub extern fn saudio_channels() i32;
pub inline fn channels() i32 {
    return saudio_channels();
}
pub extern fn saudio_expect() i32;
pub inline fn expect() i32 {
    return saudio_expect();
}
pub extern fn saudio_push([*c]const f32, i32) i32;
pub inline fn push(frames: *const f32, num_frames: i32) i32 {
    return saudio_push(frames, num_frames);
}
