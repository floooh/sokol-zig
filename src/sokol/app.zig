// machine generated, do not edit

//--- helper functions ---
pub fn sizeOf(comptime v: anytype) comptime_int {
    return @sizeOf(@TypeOf(v));
}
//--- API declarations ---
pub const max_touchpoints = 8;
pub const max_mousebuttons = 3;
pub const max_keycodes = 512;
pub const EventType = extern enum(i32) {
    INVALID,
    KEY_DOWN,
    KEY_UP,
    CHAR,
    MOUSE_DOWN,
    MOUSE_UP,
    MOUSE_SCROLL,
    MOUSE_MOVE,
    MOUSE_ENTER,
    MOUSE_LEAVE,
    TOUCHES_BEGAN,
    TOUCHES_MOVED,
    TOUCHES_ENDED,
    TOUCHES_CANCELLED,
    RESIZED,
    ICONIFIED,
    RESTORED,
    SUSPENDED,
    RESUMED,
    UPDATE_CURSOR,
    QUIT_REQUESTED,
    CLIPBOARD_PASTED,
    NUM,
};
pub const Keycode = extern enum(i32) {
    INVALID = 0,
    SPACE = 32,
    APOSTROPHE = 39,
    COMMA = 44,
    MINUS = 45,
    PERIOD = 46,
    SLASH = 47,
    _0 = 48,
    _1 = 49,
    _2 = 50,
    _3 = 51,
    _4 = 52,
    _5 = 53,
    _6 = 54,
    _7 = 55,
    _8 = 56,
    _9 = 57,
    SEMICOLON = 59,
    EQUAL = 61,
    A = 65,
    B = 66,
    C = 67,
    D = 68,
    E = 69,
    F = 70,
    G = 71,
    H = 72,
    I = 73,
    J = 74,
    K = 75,
    L = 76,
    M = 77,
    N = 78,
    O = 79,
    P = 80,
    Q = 81,
    R = 82,
    S = 83,
    T = 84,
    U = 85,
    V = 86,
    W = 87,
    X = 88,
    Y = 89,
    Z = 90,
    LEFT_BRACKET = 91,
    BACKSLASH = 92,
    RIGHT_BRACKET = 93,
    GRAVE_ACCENT = 96,
    WORLD_1 = 161,
    WORLD_2 = 162,
    ESCAPE = 256,
    ENTER = 257,
    TAB = 258,
    BACKSPACE = 259,
    INSERT = 260,
    DELETE = 261,
    RIGHT = 262,
    LEFT = 263,
    DOWN = 264,
    UP = 265,
    PAGE_UP = 266,
    PAGE_DOWN = 267,
    HOME = 268,
    END = 269,
    CAPS_LOCK = 280,
    SCROLL_LOCK = 281,
    NUM_LOCK = 282,
    PRINT_SCREEN = 283,
    PAUSE = 284,
    F1 = 290,
    F2 = 291,
    F3 = 292,
    F4 = 293,
    F5 = 294,
    F6 = 295,
    F7 = 296,
    F8 = 297,
    F9 = 298,
    F10 = 299,
    F11 = 300,
    F12 = 301,
    F13 = 302,
    F14 = 303,
    F15 = 304,
    F16 = 305,
    F17 = 306,
    F18 = 307,
    F19 = 308,
    F20 = 309,
    F21 = 310,
    F22 = 311,
    F23 = 312,
    F24 = 313,
    F25 = 314,
    KP_0 = 320,
    KP_1 = 321,
    KP_2 = 322,
    KP_3 = 323,
    KP_4 = 324,
    KP_5 = 325,
    KP_6 = 326,
    KP_7 = 327,
    KP_8 = 328,
    KP_9 = 329,
    KP_DECIMAL = 330,
    KP_DIVIDE = 331,
    KP_MULTIPLY = 332,
    KP_SUBTRACT = 333,
    KP_ADD = 334,
    KP_ENTER = 335,
    KP_EQUAL = 336,
    LEFT_SHIFT = 340,
    LEFT_CONTROL = 341,
    LEFT_ALT = 342,
    LEFT_SUPER = 343,
    RIGHT_SHIFT = 344,
    RIGHT_CONTROL = 345,
    RIGHT_ALT = 346,
    RIGHT_SUPER = 347,
    MENU = 348,
};
pub const Touchpoint = extern struct {
//  identifier: uintptr_t;
    pos_x: f32 = 0.0,
    pos_y: f32 = 0.0,
    changed: bool = false,
};
pub const Mousebutton = extern enum(i32) {
    LEFT = 0,
    RIGHT = 1,
    MIDDLE = 2,
    INVALID = 256,
};
pub const modifier_shift = 1;
pub const modifier_ctrl = 2;
pub const modifier_alt = 4;
pub const modifier_super = 8;
pub const Event = extern struct {
    frame_count: u64 = 0,
    type: EventType = .INVALID,
    key_code: Keycode = .INVALID,
    char_code: u32 = 0,
    key_repeat: bool = false,
    modifiers: u32 = 0,
    mouse_button: Mousebutton = .LEFT,
    mouse_x: f32 = 0.0,
    mouse_y: f32 = 0.0,
    mouse_dx: f32 = 0.0,
    mouse_dy: f32 = 0.0,
    scroll_x: f32 = 0.0,
    scroll_y: f32 = 0.0,
    num_touches: i32 = 0,
    touches: [8]Touchpoint = [_]Touchpoint{.{}} ** 8,
    window_width: i32 = 0,
    window_height: i32 = 0,
    framebuffer_width: i32 = 0,
    framebuffer_height: i32 = 0,
};
pub const Desc = extern struct {
    init_cb: ?fn() callconv(.C) void = null,
    frame_cb: ?fn() callconv(.C) void = null,
    cleanup_cb: ?fn() callconv(.C) void = null,
    event_cb: ?fn([*c]const Event) callconv(.C) void = null,
    fail_cb: ?fn([*c]const u8) callconv(.C) void = null,
    user_data: ?*c_void = null,
    init_userdata_cb: ?fn(?*c_void) callconv(.C) void = null,
    frame_userdata_cb: ?fn(?*c_void) callconv(.C) void = null,
    cleanup_userdata_cb: ?fn(?*c_void) callconv(.C) void = null,
    event_userdata_cb: ?fn([*c]const Event, ?*c_void) callconv(.C) void = null,
    fail_userdata_cb: ?fn([*c]const u8, ?*c_void) callconv(.C) void = null,
    width: i32 = 0,
    height: i32 = 0,
    sample_count: i32 = 0,
    swap_interval: i32 = 0,
    high_dpi: bool = false,
    fullscreen: bool = false,
    alpha: bool = false,
    window_title: [*c]const u8 = null,
    user_cursor: bool = false,
    enable_clipboard: bool = false,
    clipboard_size: i32 = 0,
    html5_canvas_name: [*c]const u8 = null,
    html5_canvas_resize: bool = false,
    html5_preserve_drawing_buffer: bool = false,
    html5_premultiplied_alpha: bool = false,
    html5_ask_leave_site: bool = false,
    ios_keyboard_resizes_canvas: bool = false,
    gl_force_gles2: bool = false,
};
pub extern fn sapp_isvalid() bool;
pub fn isvalid() bool {
    return sapp_isvalid();
}
pub extern fn sapp_width() i32;
pub fn width() i32 {
    return sapp_width();
}
pub extern fn sapp_height() i32;
pub fn height() i32 {
    return sapp_height();
}
pub extern fn sapp_color_format() i32;
pub fn colorFormat() i32 {
    return sapp_color_format();
}
pub extern fn sapp_depth_format() i32;
pub fn depthFormat() i32 {
    return sapp_depth_format();
}
pub extern fn sapp_sample_count() i32;
pub fn sampleCount() i32 {
    return sapp_sample_count();
}
pub extern fn sapp_high_dpi() bool;
pub fn highDpi() bool {
    return sapp_high_dpi();
}
pub extern fn sapp_dpi_scale() f32;
pub fn dpiScale() f32 {
    return sapp_dpi_scale();
}
pub extern fn sapp_show_keyboard(bool) void;
pub fn showKeyboard(show: bool) void {
    sapp_show_keyboard(show);
}
pub extern fn sapp_keyboard_shown() bool;
pub fn keyboardShown() bool {
    return sapp_keyboard_shown();
}
pub extern fn sapp_is_fullscreen() bool;
pub fn isFullscreen() bool {
    return sapp_is_fullscreen();
}
pub extern fn sapp_toggle_fullscreen() void;
pub fn toggleFullscreen() void {
    sapp_toggle_fullscreen();
}
pub extern fn sapp_show_mouse(bool) void;
pub fn showMouse(show: bool) void {
    sapp_show_mouse(show);
}
pub extern fn sapp_mouse_shown() bool;
pub fn mouseShown() bool {
    return sapp_mouse_shown();
}
pub extern fn sapp_lock_mouse(bool) void;
pub fn lockMouse(lock: bool) void {
    sapp_lock_mouse(lock);
}
pub extern fn sapp_mouse_locked() bool;
pub fn mouseLocked() bool {
    return sapp_mouse_locked();
}
pub extern fn sapp_userdata() ?*c_void;
pub fn userdata() ?*c_void {
    return sapp_userdata();
}
pub extern fn sapp_query_desc() Desc;
pub fn queryDesc() Desc {
    return sapp_query_desc();
}
pub extern fn sapp_request_quit() void;
pub fn requestQuit() void {
    sapp_request_quit();
}
pub extern fn sapp_cancel_quit() void;
pub fn cancelQuit() void {
    sapp_cancel_quit();
}
pub extern fn sapp_quit() void;
pub fn quit() void {
    sapp_quit();
}
pub extern fn sapp_consume_event() void;
pub fn consumeEvent() void {
    sapp_consume_event();
}
pub extern fn sapp_frame_count() u64;
pub fn frameCount() u64 {
    return sapp_frame_count();
}
pub extern fn sapp_set_clipboard_string([*c]const u8) void;
pub fn setClipboardString(str: []const u8) void {
    sapp_set_clipboard_string(str);
}
pub extern fn sapp_get_clipboard_string() [*c]const u8;
pub fn getClipboardString() []const u8 {
    return sapp_get_clipboard_string();
}
pub extern fn sapp_run([*c]const Desc) void;
pub fn run(desc: Desc) void {
    sapp_run(&desc);
}
pub extern fn sapp_gles2() bool;
pub fn gles2() bool {
    return sapp_gles2();
}
pub extern fn sapp_html5_ask_leave_site(bool) void;
pub fn html5AskLeaveSite(ask: bool) void {
    sapp_html5_ask_leave_site(ask);
}
pub extern fn sapp_metal_get_device() ?*const c_void;
pub fn metalGetDevice() ?*const c_void {
    return sapp_metal_get_device();
}
pub extern fn sapp_metal_get_renderpass_descriptor() ?*const c_void;
pub fn metalGetRenderpassDescriptor() ?*const c_void {
    return sapp_metal_get_renderpass_descriptor();
}
pub extern fn sapp_metal_get_drawable() ?*const c_void;
pub fn metalGetDrawable() ?*const c_void {
    return sapp_metal_get_drawable();
}
pub extern fn sapp_macos_get_window() ?*const c_void;
pub fn macosGetWindow() ?*const c_void {
    return sapp_macos_get_window();
}
pub extern fn sapp_ios_get_window() ?*const c_void;
pub fn iosGetWindow() ?*const c_void {
    return sapp_ios_get_window();
}
pub extern fn sapp_d3d11_get_device() ?*const c_void;
pub fn d3d11GetDevice() ?*const c_void {
    return sapp_d3d11_get_device();
}
pub extern fn sapp_d3d11_get_device_context() ?*const c_void;
pub fn d3d11GetDeviceContext() ?*const c_void {
    return sapp_d3d11_get_device_context();
}
pub extern fn sapp_d3d11_get_render_target_view() ?*const c_void;
pub fn d3d11GetRenderTargetView() ?*const c_void {
    return sapp_d3d11_get_render_target_view();
}
pub extern fn sapp_d3d11_get_depth_stencil_view() ?*const c_void;
pub fn d3d11GetDepthStencilView() ?*const c_void {
    return sapp_d3d11_get_depth_stencil_view();
}
pub extern fn sapp_win32_get_hwnd() ?*const c_void;
pub fn win32GetHwnd() ?*const c_void {
    return sapp_win32_get_hwnd();
}
pub extern fn sapp_wgpu_get_device() ?*const c_void;
pub fn wgpuGetDevice() ?*const c_void {
    return sapp_wgpu_get_device();
}
pub extern fn sapp_wgpu_get_render_view() ?*const c_void;
pub fn wgpuGetRenderView() ?*const c_void {
    return sapp_wgpu_get_render_view();
}
pub extern fn sapp_wgpu_get_resolve_view() ?*const c_void;
pub fn wgpuGetResolveView() ?*const c_void {
    return sapp_wgpu_get_resolve_view();
}
pub extern fn sapp_wgpu_get_depth_stencil_view() ?*const c_void;
pub fn wgpuGetDepthStencilView() ?*const c_void {
    return sapp_wgpu_get_depth_stencil_view();
}
pub extern fn sapp_android_get_native_activity() ?*const c_void;
pub fn androidGetNativeActivity() ?*const c_void {
    return sapp_android_get_native_activity();
}
