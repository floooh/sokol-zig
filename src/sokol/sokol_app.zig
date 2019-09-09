const std = @import("std");
const assert = std.debug.assert;
const panic = std.debug.panic;
const c = @cImport({
    @cInclude("sokol_app.h");
});

pub const SokolApp = struct {

const State = struct {
    init_cb: ?fn() void,
    frame_cb: ?fn() void,
    cleanup_cb: ?fn() void,
};
var state: State = undefined;

extern fn fwd_init() void {
    if (state.init_cb) |init_cb| {
        init_cb();
    }
}

extern fn fwd_frame() void {
    if (state.frame_cb) |frame_cb| {
        frame_cb();
    }
}

extern fn fwd_cleanup() void {
    if (state.cleanup_cb) |cleanup_cb| {
        cleanup_cb();
    }
}

fn cstrdup(str: []const u8) ![]const u8 {
    return std.cstr.addNullByte(state.allocator, str);
}

pub const Desc = struct {
    init_cb: ?fn() void = null,
    frame_cb: ?fn() void = null,
    cleanup_cb: ?fn() void = null,
    width: i32 = 0,
    height: i32 = 0,
    sample_count: i32 = 0,
    swap_interval: i32 = 0,
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

pub fn run(desc: Desc) anyerror!void {
    state = State {
        .init_cb = desc.init_cb,
        .frame_cb = desc.frame_cb,
        .cleanup_cb = desc.cleanup_cb,
    };

    const sapp_desc = c.sapp_desc{
        .init_cb = fwd_init,
        .frame_cb = fwd_frame,
        .cleanup_cb = fwd_cleanup,
        .event_cb = null,
        .fail_cb = null,
        .user_data = null,
        .init_userdata_cb = null,
        .frame_userdata_cb = null,
        .cleanup_userdata_cb = null,
        .event_userdata_cb = null,
        .fail_userdata_cb = null,
        .width = desc.width,
        .height = desc.height,
        .sample_count = desc.sample_count,
        .swap_interval = desc.swap_interval,
        .high_dpi = desc.high_dpi,
        .fullscreen = desc.fullscreen,
        .alpha = desc.alpha,
        .window_title = desc.window_title,
        .user_cursor = desc.user_cursor,
        .html5_canvas_name = desc.html5_canvas_name,
        .html5_canvas_resize = desc.html5_canvas_resize,
        .html5_preserve_drawing_buffer = desc.html5_preserve_drawing_buffer,
        .html5_premultiplied_alpha = desc.html5_premultiplied_alpha,
        .ios_keyboard_resizes_canvas = desc.ios_keyboard_resizes_canvas,
        .gl_force_gles2 = desc.gl_force_gles2
    };
    _ = c.sapp_run(&sapp_desc);
}

pub extern fn metal_get_device() ?*const c_void {
    return c.sapp_metal_get_device();
}
pub extern fn metal_get_renderpass_descriptor() ?*const c_void {
    return c.sapp_metal_get_renderpass_descriptor();
}
pub extern fn metal_get_drawable() ?*const c_void {
    return c.sapp_metal_get_drawable();
}

pub fn width() c_int {
    return c.sapp_width();
}

pub fn height() c_int {
    return c.sapp_height();
}

}; // sokol-app

