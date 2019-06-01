const std = @import("std");
const assert = std.debug.assert;
const panic = std.debug.panic;
const c = @cImport(@cInclude("sokol_app.h"));

pub const Desc = struct {
    init_cb: ?fn() void = null,
    frame_cb: ?fn() void = null,
    cleanup_cb: ?fn() void = null,
    event_cb: ?fn([*c]const c.sapp_event) void = null,
    fail_cb: ?fn([*c]const u8) void = null,
    user_data: ?*c_void = null,
    init_userdata_cb: ?fn(?*c_void) void = null,
    frame_userdata_cb: ?fn(?*c_void) void = null,
    cleanup_userdata_cb: ?fn(?*c_void) void = null,
    event_userdata_cb: ?fn([*c]const c.sapp_event, ?*c_void) void = null,
    fail_userdata_cb: ?fn([*c]const u8, ?*c_void) void = null,
    width: c_int = 0,
    height: c_int = 0,
    sample_count: c_int = 0,
    swap_interval: c_int = 0,
    high_dpi: bool = false,
    fullscreen: bool = false,
    alpha: bool = false,
    window_title: [*c]const u8 = null,
    user_cursor: bool = false,
    html5_canvas_name: [*c]const u8 = null,
    html5_canvas_resize: bool = false,
    html5_preserve_drawing_buffer: bool = false,
    html5_premultiplied_alpha: bool = false,
    ios_keyboard_resizes_canvas: bool = false,
    gl_force_gles2: bool = false
};

pub fn run(desc: *const Desc) void {
    assert(@sizeOf(Desc) == @sizeOf(c.sapp_desc));
    if (0 != c.sapp_run(@ptrCast(*const c.sapp_desc, desc))) {
        panic("sapp_run failed");
    }
}