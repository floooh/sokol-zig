// machine generated, do not edit

const builtin = @import("builtin");
const sg = @import("gfx.zig");
const sapp = @import("app.zig");

// helper function to convert a C string to a Zig string slice
fn cStrToZig(c_str: [*c]const u8) [:0]const u8 {
    return @import("std").mem.span(c_str);
}
pub const invalid_id = 0;
pub const Image = extern struct {
    id: u32 = 0,
};
pub const ImageDesc = extern struct {
    image: sg.Image = .{},
    sampler: sg.Sampler = .{},
};
pub const LogItem = enum(i32) {
    OK,
    MALLOC_FAILED,
    IMAGE_POOL_EXHAUSTED,
};
pub const Allocator = extern struct {
    alloc_fn: ?*const fn (usize, ?*anyopaque) callconv(.C) ?*anyopaque = null,
    free_fn: ?*const fn (?*anyopaque, ?*anyopaque) callconv(.C) void = null,
    user_data: ?*anyopaque = null,
};
pub const Logger = extern struct {
    func: ?*const fn ([*c]const u8, u32, u32, [*c]const u8, u32, [*c]const u8, ?*anyopaque) callconv(.C) void = null,
    user_data: ?*anyopaque = null,
};
pub const Desc = extern struct {
    max_vertices: i32 = 0,
    image_pool_size: i32 = 0,
    color_format: sg.PixelFormat = .DEFAULT,
    depth_format: sg.PixelFormat = .DEFAULT,
    sample_count: i32 = 0,
    ini_filename: [*c]const u8 = null,
    no_default_font: bool = false,
    disable_paste_override: bool = false,
    disable_set_mouse_cursor: bool = false,
    disable_windows_resize_from_edges: bool = false,
    write_alpha_channel: bool = false,
    allocator: Allocator = .{},
    logger: Logger = .{},
};
pub const FrameDesc = extern struct {
    width: i32 = 0,
    height: i32 = 0,
    delta_time: f64 = 0.0,
    dpi_scale: f32 = 0.0,
};
pub const FontTexDesc = extern struct {
    min_filter: sg.Filter = .DEFAULT,
    mag_filter: sg.Filter = .DEFAULT,
};
pub extern fn simgui_setup([*c]const Desc) void;
pub fn setup(desc: Desc) void {
    simgui_setup(&desc);
}
pub extern fn simgui_new_frame([*c]const FrameDesc) void;
pub fn newFrame(desc: FrameDesc) void {
    simgui_new_frame(&desc);
}
pub extern fn simgui_render() void;
pub fn render() void {
    simgui_render();
}
pub extern fn simgui_make_image([*c]const ImageDesc) Image;
pub fn makeImage(desc: ImageDesc) Image {
    return simgui_make_image(&desc);
}
pub extern fn simgui_destroy_image(Image) void;
pub fn destroyImage(img: Image) void {
    simgui_destroy_image(img);
}
pub extern fn simgui_query_image_desc(Image) ImageDesc;
pub fn queryImageDesc(img: Image) ImageDesc {
    return simgui_query_image_desc(img);
}
pub extern fn simgui_imtextureid(Image) ?*anyopaque;
pub fn imtextureid(img: Image) ?*anyopaque {
    return simgui_imtextureid(img);
}
pub extern fn simgui_image_from_imtextureid(?*anyopaque) Image;
pub fn imageFromImtextureid(im_texture_id: ?*anyopaque) Image {
    return simgui_image_from_imtextureid(im_texture_id);
}
pub extern fn simgui_add_focus_event(bool) void;
pub fn addFocusEvent(focus: bool) void {
    simgui_add_focus_event(focus);
}
pub extern fn simgui_add_mouse_pos_event(f32, f32) void;
pub fn addMousePosEvent(x: f32, y: f32) void {
    simgui_add_mouse_pos_event(x, y);
}
pub extern fn simgui_add_touch_pos_event(f32, f32) void;
pub fn addTouchPosEvent(x: f32, y: f32) void {
    simgui_add_touch_pos_event(x, y);
}
pub extern fn simgui_add_mouse_button_event(i32, bool) void;
pub fn addMouseButtonEvent(mouse_button: i32, down: bool) void {
    simgui_add_mouse_button_event(mouse_button, down);
}
pub extern fn simgui_add_mouse_wheel_event(f32, f32) void;
pub fn addMouseWheelEvent(wheel_x: f32, wheel_y: f32) void {
    simgui_add_mouse_wheel_event(wheel_x, wheel_y);
}
pub extern fn simgui_add_key_event(i32, bool) void;
pub fn addKeyEvent(imgui_key: i32, down: bool) void {
    simgui_add_key_event(imgui_key, down);
}
pub extern fn simgui_add_input_character(u32) void;
pub fn addInputCharacter(c: u32) void {
    simgui_add_input_character(c);
}
pub extern fn simgui_add_input_characters_utf8([*c]const u8) void;
pub fn addInputCharactersUtf8(c: [:0]const u8) void {
    simgui_add_input_characters_utf8(@ptrCast(c));
}
pub extern fn simgui_add_touch_button_event(i32, bool) void;
pub fn addTouchButtonEvent(mouse_button: i32, down: bool) void {
    simgui_add_touch_button_event(mouse_button, down);
}
pub extern fn simgui_handle_event([*c]const sapp.Event) bool;
pub fn handleEvent(ev: sapp.Event) bool {
    return simgui_handle_event(&ev);
}
pub extern fn simgui_map_keycode(sapp.Keycode) i32;
pub fn mapKeycode(keycode: sapp.Keycode) i32 {
    return simgui_map_keycode(keycode);
}
pub extern fn simgui_shutdown() void;
pub fn shutdown() void {
    simgui_shutdown();
}
pub extern fn simgui_create_fonts_texture([*c]const FontTexDesc) void;
pub fn createFontsTexture(desc: FontTexDesc) void {
    simgui_create_fonts_texture(&desc);
}
pub extern fn simgui_destroy_fonts_texture() void;
pub fn destroyFontsTexture() void {
    simgui_destroy_fonts_texture();
}
