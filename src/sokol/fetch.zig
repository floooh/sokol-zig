// machine generated, do not edit

const builtin = @import("builtin");

// helper function to convert a C string to a Zig string slice
fn cStrToZig(c_str: [*c]const u8) [:0]const u8 {
    return @import("std").mem.span(c_str);
}
// helper function to convert "anything" to a Range struct
pub fn asRange(val: anytype) Range {
    const type_info = @typeInfo(@TypeOf(val));
    switch (type_info) {
        .Pointer => {
            switch (type_info.Pointer.size) {
                .One => return .{ .ptr = val, .size = @sizeOf(type_info.Pointer.child) },
                .Slice => return .{ .ptr = val.ptr, .size = @sizeOf(type_info.Pointer.child) * val.len },
                else => @compileError("FIXME: Pointer type!"),
            }
        },
        .Struct, .Array => {
            @compileError("Structs and arrays must be passed as pointers to asRange");
        },
        else => {
            @compileError("Cannot convert to range!");
        },
    }
}

pub const LogItem = enum(i32) {
    OK,
    MALLOC_FAILED,
    FILE_PATH_UTF8_DECODING_FAILED,
    SEND_QUEUE_FULL,
    REQUEST_CHANNEL_INDEX_TOO_BIG,
    REQUEST_PATH_IS_NULL,
    REQUEST_PATH_TOO_LONG,
    REQUEST_CALLBACK_MISSING,
    REQUEST_CHUNK_SIZE_GREATER_BUFFER_SIZE,
    REQUEST_USERDATA_PTR_IS_SET_BUT_USERDATA_SIZE_IS_NULL,
    REQUEST_USERDATA_PTR_IS_NULL_BUT_USERDATA_SIZE_IS_NOT,
    REQUEST_USERDATA_SIZE_TOO_BIG,
    CLAMPING_NUM_CHANNELS_TO_MAX_CHANNELS,
    REQUEST_POOL_EXHAUSTED,
};
pub const Logger = extern struct {
    func: ?*const fn ([*c]const u8, u32, u32, [*c]const u8, u32, [*c]const u8, ?*anyopaque) callconv(.C) void = null,
    user_data: ?*anyopaque = null,
};
pub const Range = extern struct {
    ptr: ?*const anyopaque = null,
    size: usize = 0,
};
pub const Allocator = extern struct {
    alloc_fn: ?*const fn (usize, ?*anyopaque) callconv(.C) ?*anyopaque = null,
    free_fn: ?*const fn (?*anyopaque, ?*anyopaque) callconv(.C) void = null,
    user_data: ?*anyopaque = null,
};
pub const Desc = extern struct {
    max_requests: u32 = 0,
    num_channels: u32 = 0,
    num_lanes: u32 = 0,
    allocator: Allocator = .{},
    logger: Logger = .{},
};
pub const Handle = extern struct {
    id: u32 = 0,
};
pub const Error = enum(i32) {
    NO_ERROR,
    FILE_NOT_FOUND,
    NO_BUFFER,
    BUFFER_TOO_SMALL,
    UNEXPECTED_EOF,
    INVALID_HTTP_STATUS,
    CANCELLED,
};
pub const Response = extern struct {
    handle: Handle = .{},
    dispatched: bool = false,
    fetched: bool = false,
    paused: bool = false,
    finished: bool = false,
    failed: bool = false,
    cancelled: bool = false,
    error_code: Error = .NO_ERROR,
    channel: u32 = 0,
    lane: u32 = 0,
    path: [*c]const u8 = null,
    user_data: ?*anyopaque = null,
    data_offset: u32 = 0,
    data: Range = .{},
    buffer: Range = .{},
};
pub const Request = extern struct {
    channel: u32 = 0,
    path: [*c]const u8 = null,
    callback: ?*const fn ([*c]const Response) callconv(.C) void = null,
    chunk_size: u32 = 0,
    buffer: Range = .{},
    user_data: Range = .{},
};
pub extern fn sfetch_setup([*c]const Desc) void;
pub fn setup(desc: Desc) void {
    sfetch_setup(&desc);
}
pub extern fn sfetch_shutdown() void;
pub fn shutdown() void {
    sfetch_shutdown();
}
pub extern fn sfetch_valid() bool;
pub fn valid() bool {
    return sfetch_valid();
}
pub extern fn sfetch_desc() Desc;
pub fn getDesc() Desc {
    return sfetch_desc();
}
pub extern fn sfetch_max_userdata_bytes() i32;
pub fn maxUserdataBytes() i32 {
    return sfetch_max_userdata_bytes();
}
pub extern fn sfetch_max_path() i32;
pub fn maxPath() i32 {
    return sfetch_max_path();
}
pub extern fn sfetch_send([*c]const Request) Handle;
pub fn send(request: Request) Handle {
    return sfetch_send(&request);
}
pub extern fn sfetch_handle_valid(Handle) bool;
pub fn handleValid(h: Handle) bool {
    return sfetch_handle_valid(h);
}
pub extern fn sfetch_dowork() void;
pub fn dowork() void {
    sfetch_dowork();
}
pub extern fn sfetch_bind_buffer(Handle, Range) void;
pub fn bindBuffer(h: Handle, buffer: Range) void {
    sfetch_bind_buffer(h, buffer);
}
pub extern fn sfetch_unbind_buffer(Handle) ?*anyopaque;
pub fn unbindBuffer(h: Handle) ?*anyopaque {
    return sfetch_unbind_buffer(h);
}
pub extern fn sfetch_cancel(Handle) void;
pub fn cancel(h: Handle) void {
    sfetch_cancel(h);
}
pub extern fn sfetch_pause(Handle) void;
pub fn pause(h: Handle) void {
    sfetch_pause(h);
}
pub extern fn sfetch_continue(Handle) void;
pub fn continueFetching(h: Handle) void {
    sfetch_continue(h);
}
