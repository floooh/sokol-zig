// machine generated, do not edit

const builtin = @import("builtin");

// helper function to convert a C string to a Zig string slice
fn cStrToZig(c_str: [*c]const u8) [:0]const u8 {
  return @import("std").mem.span(c_str);
}
pub const LogItem = enum(i32) {
    OK,
    MALLOC_FAILED,
    ALSA_SND_PCM_OPEN_FAILED,
    ALSA_FLOAT_SAMPLES_NOT_SUPPORTED,
    ALSA_REQUESTED_BUFFER_SIZE_NOT_SUPPORTED,
    ALSA_REQUESTED_CHANNEL_COUNT_NOT_SUPPORTED,
    ALSA_SND_PCM_HW_PARAMS_SET_RATE_NEAR_FAILED,
    ALSA_SND_PCM_HW_PARAMS_FAILED,
    ALSA_PTHREAD_CREATE_FAILED,
    WASAPI_CREATE_EVENT_FAILED,
    WASAPI_CREATE_DEVICE_ENUMERATOR_FAILED,
    WASAPI_GET_DEFAULT_AUDIO_ENDPOINT_FAILED,
    WASAPI_DEVICE_ACTIVATE_FAILED,
    WASAPI_AUDIO_CLIENT_INITIALIZE_FAILED,
    WASAPI_AUDIO_CLIENT_GET_BUFFER_SIZE_FAILED,
    WASAPI_AUDIO_CLIENT_GET_SERVICE_FAILED,
    WASAPI_AUDIO_CLIENT_SET_EVENT_HANDLE_FAILED,
    WASAPI_CREATE_THREAD_FAILED,
    AAUDIO_STREAMBUILDER_OPEN_STREAM_FAILED,
    AAUDIO_PTHREAD_CREATE_FAILED,
    AAUDIO_RESTARTING_STREAM_AFTER_ERROR,
    USING_AAUDIO_BACKEND,
    AAUDIO_CREATE_STREAMBUILDER_FAILED,
    USING_SLES_BACKEND,
    SLES_CREATE_ENGINE_FAILED,
    SLES_ENGINE_GET_ENGINE_INTERFACE_FAILED,
    SLES_CREATE_OUTPUT_MIX_FAILED,
    SLES_MIXER_GET_VOLUME_INTERFACE_FAILED,
    SLES_ENGINE_CREATE_AUDIO_PLAYER_FAILED,
    SLES_PLAYER_GET_PLAY_INTERFACE_FAILED,
    SLES_PLAYER_GET_VOLUME_INTERFACE_FAILED,
    SLES_PLAYER_GET_BUFFERQUEUE_INTERFACE_FAILED,
    COREAUDIO_NEW_OUTPUT_FAILED,
    COREAUDIO_ALLOCATE_BUFFER_FAILED,
    COREAUDIO_START_FAILED,
    BACKEND_BUFFER_SIZE_ISNT_MULTIPLE_OF_PACKET_SIZE,
};
pub const Logger = extern struct {
    func: ?*const fn([*c]const u8, u32, u32, [*c]const u8, u32, [*c]const u8, ?*anyopaque) callconv(.C) void = null,
    user_data: ?*anyopaque = null,
};
pub const Allocator = extern struct {
    alloc: ?*const fn(usize, ?*anyopaque) callconv(.C) ?*anyopaque = null,
    free: ?*const fn(?*anyopaque, ?*anyopaque) callconv(.C) void = null,
    user_data: ?*anyopaque = null,
};
pub const Desc = extern struct {
    sample_rate: i32 = 0,
    num_channels: i32 = 0,
    buffer_frames: i32 = 0,
    packet_frames: i32 = 0,
    num_packets: i32 = 0,
    stream_cb: ?*const fn([*c] f32, i32, i32) callconv(.C) void = null,
    stream_userdata_cb: ?*const fn([*c] f32, i32, i32, ?*anyopaque) callconv(.C) void = null,
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
