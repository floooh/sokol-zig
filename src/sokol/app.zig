// machine generated, do not edit

const builtin = @import("builtin");

// helper function to convert a C string to a Zig string slice
fn cStrToZig(c_str: [*c]const u8) [:0]const u8 {
  return @import("std").mem.span(c_str);
}
pub const max_touchpoints = 8;
pub const max_mousebuttons = 3;
pub const max_keycodes = 512;
pub const max_iconimages = 8;
pub const EventType = enum(i32) {
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
    FOCUSED,
    UNFOCUSED,
    SUSPENDED,
    RESUMED,
    QUIT_REQUESTED,
    CLIPBOARD_PASTED,
    FILES_DROPPED,
    NUM,
};
pub const Keycode = enum(i32) {
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
pub const AndroidTooltype = enum(i32) {
    UNKNOWN = 0,
    FINGER = 1,
    STYLUS = 2,
    MOUSE = 3,
};
pub const Touchpoint = extern struct {
    identifier: usize = 0,
    pos_x: f32 = 0.0,
    pos_y: f32 = 0.0,
    android_tooltype: AndroidTooltype = .UNKNOWN,
    changed: bool = false,
};
pub const Mousebutton = enum(i32) {
    LEFT = 0,
    RIGHT = 1,
    MIDDLE = 2,
    INVALID = 256,
};
pub const modifier_shift = 1;
pub const modifier_ctrl = 2;
pub const modifier_alt = 4;
pub const modifier_super = 8;
pub const modifier_lmb = 256;
pub const modifier_rmb = 512;
pub const modifier_mmb = 1024;
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
pub const Range = extern struct {
    ptr: ?*const anyopaque = null,
    size: usize = 0,
};
pub const ImageDesc = extern struct {
    width: i32 = 0,
    height: i32 = 0,
    pixels: Range = .{ },
};
pub const IconDesc = extern struct {
    sokol_default: bool = false,
    images: [8]ImageDesc = [_]ImageDesc{.{}} ** 8,
};
pub const Allocator = extern struct {
    alloc: ?*const fn(usize, ?*anyopaque) callconv(.C) ?*anyopaque = null,
    free: ?*const fn(?*anyopaque, ?*anyopaque) callconv(.C) void = null,
    user_data: ?*anyopaque = null,
};
pub const LogItem = enum(i32) {
    OK,
    MALLOC_FAILED,
    MACOS_INVALID_NSOPENGL_PROFILE,
    WIN32_LOAD_OPENGL32_DLL_FAILED,
    WIN32_CREATE_HELPER_WINDOW_FAILED,
    WIN32_HELPER_WINDOW_GETDC_FAILED,
    WIN32_DUMMY_CONTEXT_SET_PIXELFORMAT_FAILED,
    WIN32_CREATE_DUMMY_CONTEXT_FAILED,
    WIN32_DUMMY_CONTEXT_MAKE_CURRENT_FAILED,
    WIN32_GET_PIXELFORMAT_ATTRIB_FAILED,
    WIN32_WGL_FIND_PIXELFORMAT_FAILED,
    WIN32_WGL_DESCRIBE_PIXELFORMAT_FAILED,
    WIN32_WGL_SET_PIXELFORMAT_FAILED,
    WIN32_WGL_ARB_CREATE_CONTEXT_REQUIRED,
    WIN32_WGL_ARB_CREATE_CONTEXT_PROFILE_REQUIRED,
    WIN32_WGL_OPENGL_3_2_NOT_SUPPORTED,
    WIN32_WGL_OPENGL_PROFILE_NOT_SUPPORTED,
    WIN32_WGL_INCOMPATIBLE_DEVICE_CONTEXT,
    WIN32_WGL_CREATE_CONTEXT_ATTRIBS_FAILED_OTHER,
    WIN32_D3D11_CREATE_DEVICE_AND_SWAPCHAIN_WITH_DEBUG_FAILED,
    WIN32_D3D11_GET_IDXGIFACTORY_FAILED,
    WIN32_D3D11_GET_IDXGIADAPTER_FAILED,
    WIN32_D3D11_QUERY_INTERFACE_IDXGIDEVICE1_FAILED,
    WIN32_REGISTER_RAW_INPUT_DEVICES_FAILED_MOUSE_LOCK,
    WIN32_REGISTER_RAW_INPUT_DEVICES_FAILED_MOUSE_UNLOCK,
    WIN32_GET_RAW_INPUT_DATA_FAILED,
    LINUX_GLX_LOAD_LIBGL_FAILED,
    LINUX_GLX_LOAD_ENTRY_POINTS_FAILED,
    LINUX_GLX_EXTENSION_NOT_FOUND,
    LINUX_GLX_QUERY_VERSION_FAILED,
    LINUX_GLX_VERSION_TOO_LOW,
    LINUX_GLX_NO_GLXFBCONFIGS,
    LINUX_GLX_NO_SUITABLE_GLXFBCONFIG,
    LINUX_GLX_GET_VISUAL_FROM_FBCONFIG_FAILED,
    LINUX_GLX_REQUIRED_EXTENSIONS_MISSING,
    LINUX_GLX_CREATE_CONTEXT_FAILED,
    LINUX_GLX_CREATE_WINDOW_FAILED,
    LINUX_X11_CREATE_WINDOW_FAILED,
    LINUX_EGL_BIND_OPENGL_API_FAILED,
    LINUX_EGL_BIND_OPENGL_ES_API_FAILED,
    LINUX_EGL_GET_DISPLAY_FAILED,
    LINUX_EGL_INITIALIZE_FAILED,
    LINUX_EGL_NO_CONFIGS,
    LINUX_EGL_NO_NATIVE_VISUAL,
    LINUX_EGL_GET_VISUAL_INFO_FAILED,
    LINUX_EGL_CREATE_WINDOW_SURFACE_FAILED,
    LINUX_EGL_CREATE_CONTEXT_FAILED,
    LINUX_EGL_MAKE_CURRENT_FAILED,
    LINUX_X11_OPEN_DISPLAY_FAILED,
    LINUX_X11_QUERY_SYSTEM_DPI_FAILED,
    LINUX_X11_DROPPED_FILE_URI_WRONG_SCHEME,
    ANDROID_UNSUPPORTED_INPUT_EVENT_INPUT_CB,
    ANDROID_UNSUPPORTED_INPUT_EVENT_MAIN_CB,
    ANDROID_READ_MSG_FAILED,
    ANDROID_WRITE_MSG_FAILED,
    ANDROID_MSG_CREATE,
    ANDROID_MSG_RESUME,
    ANDROID_MSG_PAUSE,
    ANDROID_MSG_FOCUS,
    ANDROID_MSG_NO_FOCUS,
    ANDROID_MSG_SET_NATIVE_WINDOW,
    ANDROID_MSG_SET_INPUT_QUEUE,
    ANDROID_MSG_DESTROY,
    ANDROID_UNKNOWN_MSG,
    ANDROID_LOOP_THREAD_STARTED,
    ANDROID_LOOP_THREAD_DONE,
    ANDROID_NATIVE_ACTIVITY_ONSTART,
    ANDROID_NATIVE_ACTIVITY_ONRESUME,
    ANDROID_NATIVE_ACTIVITY_ONSAVEINSTANCESTATE,
    ANDROID_NATIVE_ACTIVITY_ONWINDOWFOCUSCHANGED,
    ANDROID_NATIVE_ACTIVITY_ONPAUSE,
    ANDROID_NATIVE_ACTIVITY_ONSTOP,
    ANDROID_NATIVE_ACTIVITY_ONNATIVEWINDOWCREATED,
    ANDROID_NATIVE_ACTIVITY_ONNATIVEWINDOWDESTROYED,
    ANDROID_NATIVE_ACTIVITY_ONINPUTQUEUECREATED,
    ANDROID_NATIVE_ACTIVITY_ONINPUTQUEUEDESTROYED,
    ANDROID_NATIVE_ACTIVITY_ONCONFIGURATIONCHANGED,
    ANDROID_NATIVE_ACTIVITY_ONLOWMEMORY,
    ANDROID_NATIVE_ACTIVITY_ONDESTROY,
    ANDROID_NATIVE_ACTIVITY_DONE,
    ANDROID_NATIVE_ACTIVITY_ONCREATE,
    ANDROID_CREATE_THREAD_PIPE_FAILED,
    ANDROID_NATIVE_ACTIVITY_CREATE_SUCCESS,
    IMAGE_DATA_SIZE_MISMATCH,
    DROPPED_FILE_PATH_TOO_LONG,
    CLIPBOARD_STRING_TOO_BIG,
};
pub const Logger = extern struct {
    func: ?*const fn([*c]const u8, u32, u32, [*c]const u8, u32, [*c]const u8, ?*anyopaque) callconv(.C) void = null,
    user_data: ?*anyopaque = null,
};
pub const Desc = extern struct {
    init_cb: ?*const fn() callconv(.C) void = null,
    frame_cb: ?*const fn() callconv(.C) void = null,
    cleanup_cb: ?*const fn() callconv(.C) void = null,
    event_cb: ?*const fn([*c]const Event) callconv(.C) void = null,
    user_data: ?*anyopaque = null,
    init_userdata_cb: ?*const fn(?*anyopaque) callconv(.C) void = null,
    frame_userdata_cb: ?*const fn(?*anyopaque) callconv(.C) void = null,
    cleanup_userdata_cb: ?*const fn(?*anyopaque) callconv(.C) void = null,
    event_userdata_cb: ?*const fn([*c]const Event, ?*anyopaque) callconv(.C) void = null,
    width: i32 = 0,
    height: i32 = 0,
    sample_count: i32 = 0,
    swap_interval: i32 = 0,
    high_dpi: bool = false,
    fullscreen: bool = false,
    alpha: bool = false,
    window_title: [*c]const u8 = null,
    enable_clipboard: bool = false,
    clipboard_size: i32 = 0,
    enable_dragndrop: bool = false,
    max_dropped_files: i32 = 0,
    max_dropped_file_path_length: i32 = 0,
    icon: IconDesc = .{ },
    allocator: Allocator = .{ },
    logger: Logger = .{ },
    gl_major_version: i32 = 0,
    gl_minor_version: i32 = 0,
    win32_console_utf8: bool = false,
    win32_console_create: bool = false,
    win32_console_attach: bool = false,
    html5_canvas_name: [*c]const u8 = null,
    html5_canvas_resize: bool = false,
    html5_preserve_drawing_buffer: bool = false,
    html5_premultiplied_alpha: bool = false,
    html5_ask_leave_site: bool = false,
    ios_keyboard_resizes_canvas: bool = false,
};
pub const Html5FetchError = enum(i32) {
    FETCH_ERROR_NO_ERROR,
    FETCH_ERROR_BUFFER_TOO_SMALL,
    FETCH_ERROR_OTHER,
};
pub const Html5FetchResponse = extern struct {
    succeeded: bool = false,
    error_code: Html5FetchError = .FETCH_ERROR_NO_ERROR,
    file_index: i32 = 0,
    data: Range = .{ },
    buffer: Range = .{ },
    user_data: ?*anyopaque = null,
};
pub const Html5FetchRequest = extern struct {
    dropped_file_index: i32 = 0,
    callback: ?*const fn([*c]const Html5FetchResponse) callconv(.C) void = null,
    buffer: Range = .{ },
    user_data: ?*anyopaque = null,
};
pub const MouseCursor = enum(i32) {
    DEFAULT = 0,
    ARROW,
    IBEAM,
    CROSSHAIR,
    POINTING_HAND,
    RESIZE_EW,
    RESIZE_NS,
    RESIZE_NWSE,
    RESIZE_NESW,
    RESIZE_ALL,
    NOT_ALLOWED,
    NUM,
};
pub extern fn sapp_isvalid() bool;
pub fn isvalid() bool {
    return sapp_isvalid();
}
pub extern fn sapp_width() i32;
pub fn width() i32 {
    return sapp_width();
}
pub extern fn sapp_widthf() f32;
pub fn widthf() f32 {
    return sapp_widthf();
}
pub extern fn sapp_height() i32;
pub fn height() i32 {
    return sapp_height();
}
pub extern fn sapp_heightf() f32;
pub fn heightf() f32 {
    return sapp_heightf();
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
pub extern fn sapp_set_mouse_cursor(MouseCursor) void;
pub fn setMouseCursor(cursor: MouseCursor) void {
    sapp_set_mouse_cursor(cursor);
}
pub extern fn sapp_get_mouse_cursor() MouseCursor;
pub fn getMouseCursor() MouseCursor {
    return sapp_get_mouse_cursor();
}
pub extern fn sapp_userdata() ?*anyopaque;
pub fn userdata() ?*anyopaque {
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
pub extern fn sapp_frame_duration() f64;
pub fn frameDuration() f64 {
    return sapp_frame_duration();
}
pub extern fn sapp_set_clipboard_string([*c]const u8) void;
pub fn setClipboardString(str: [:0]const u8) void {
    sapp_set_clipboard_string(@ptrCast([*c]const u8,str));
}
pub extern fn sapp_get_clipboard_string() [*c]const u8;
pub fn getClipboardString() [:0]const u8 {
    return cStrToZig(sapp_get_clipboard_string());
}
pub extern fn sapp_set_window_title([*c]const u8) void;
pub fn setWindowTitle(str: [:0]const u8) void {
    sapp_set_window_title(@ptrCast([*c]const u8,str));
}
pub extern fn sapp_set_icon([*c]const IconDesc) void;
pub fn setIcon(icon_desc: IconDesc) void {
    sapp_set_icon(&icon_desc);
}
pub extern fn sapp_get_num_dropped_files() i32;
pub fn getNumDroppedFiles() i32 {
    return sapp_get_num_dropped_files();
}
pub extern fn sapp_get_dropped_file_path(i32) [*c]const u8;
pub fn getDroppedFilePath(index: i32) [:0]const u8 {
    return cStrToZig(sapp_get_dropped_file_path(index));
}
pub extern fn sapp_run([*c]const Desc) void;
pub fn run(desc: Desc) void {
    sapp_run(&desc);
}
pub extern fn sapp_egl_get_display() ?*const anyopaque;
pub fn eglGetDisplay() ?*const anyopaque {
    return sapp_egl_get_display();
}
pub extern fn sapp_egl_get_context() ?*const anyopaque;
pub fn eglGetContext() ?*const anyopaque {
    return sapp_egl_get_context();
}
pub extern fn sapp_html5_ask_leave_site(bool) void;
pub fn html5AskLeaveSite(ask: bool) void {
    sapp_html5_ask_leave_site(ask);
}
pub extern fn sapp_html5_get_dropped_file_size(i32) u32;
pub fn html5GetDroppedFileSize(index: i32) u32 {
    return sapp_html5_get_dropped_file_size(index);
}
pub extern fn sapp_html5_fetch_dropped_file([*c]const Html5FetchRequest) void;
pub fn html5FetchDroppedFile(request: Html5FetchRequest) void {
    sapp_html5_fetch_dropped_file(&request);
}
pub extern fn sapp_metal_get_device() ?*const anyopaque;
pub fn metalGetDevice() ?*const anyopaque {
    return sapp_metal_get_device();
}
pub extern fn sapp_metal_get_renderpass_descriptor() ?*const anyopaque;
pub fn metalGetRenderpassDescriptor() ?*const anyopaque {
    return sapp_metal_get_renderpass_descriptor();
}
pub extern fn sapp_metal_get_drawable() ?*const anyopaque;
pub fn metalGetDrawable() ?*const anyopaque {
    return sapp_metal_get_drawable();
}
pub extern fn sapp_macos_get_window() ?*const anyopaque;
pub fn macosGetWindow() ?*const anyopaque {
    return sapp_macos_get_window();
}
pub extern fn sapp_ios_get_window() ?*const anyopaque;
pub fn iosGetWindow() ?*const anyopaque {
    return sapp_ios_get_window();
}
pub extern fn sapp_d3d11_get_device() ?*const anyopaque;
pub fn d3d11GetDevice() ?*const anyopaque {
    return sapp_d3d11_get_device();
}
pub extern fn sapp_d3d11_get_device_context() ?*const anyopaque;
pub fn d3d11GetDeviceContext() ?*const anyopaque {
    return sapp_d3d11_get_device_context();
}
pub extern fn sapp_d3d11_get_swap_chain() ?*const anyopaque;
pub fn d3d11GetSwapChain() ?*const anyopaque {
    return sapp_d3d11_get_swap_chain();
}
pub extern fn sapp_d3d11_get_render_target_view() ?*const anyopaque;
pub fn d3d11GetRenderTargetView() ?*const anyopaque {
    return sapp_d3d11_get_render_target_view();
}
pub extern fn sapp_d3d11_get_depth_stencil_view() ?*const anyopaque;
pub fn d3d11GetDepthStencilView() ?*const anyopaque {
    return sapp_d3d11_get_depth_stencil_view();
}
pub extern fn sapp_win32_get_hwnd() ?*const anyopaque;
pub fn win32GetHwnd() ?*const anyopaque {
    return sapp_win32_get_hwnd();
}
pub extern fn sapp_wgpu_get_device() ?*const anyopaque;
pub fn wgpuGetDevice() ?*const anyopaque {
    return sapp_wgpu_get_device();
}
pub extern fn sapp_wgpu_get_render_view() ?*const anyopaque;
pub fn wgpuGetRenderView() ?*const anyopaque {
    return sapp_wgpu_get_render_view();
}
pub extern fn sapp_wgpu_get_resolve_view() ?*const anyopaque;
pub fn wgpuGetResolveView() ?*const anyopaque {
    return sapp_wgpu_get_resolve_view();
}
pub extern fn sapp_wgpu_get_depth_stencil_view() ?*const anyopaque;
pub fn wgpuGetDepthStencilView() ?*const anyopaque {
    return sapp_wgpu_get_depth_stencil_view();
}
pub extern fn sapp_android_get_native_activity() ?*const anyopaque;
pub fn androidGetNativeActivity() ?*const anyopaque {
    return sapp_android_get_native_activity();
}
