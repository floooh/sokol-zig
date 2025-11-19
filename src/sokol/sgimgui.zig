// machine generated, do not edit

//
// sokol_gfx_imgui.h -- debug-inspection UI for sokol_gfx.h using Dear ImGui
//
// Project URL: https://github.com/floooh/sokol
//
// Do this:
//     #define SOKOL_IMPL or
//     #define SOKOL_GFX_IMGUI_IMPL
//
// before you include this file in *one* C or C++ file to create the
// implementation.
//
// NOTE that the implementation can be compiled either as C++ or as C.
// When compiled as C++, sokol_gfx_imgui.h will directly call into the
// Dear ImGui C++ API. When compiled as C, sokol_gfx_imgui.h will call
// cimgui.h functions instead.
//
// Include the following file(s) before including sokol_gfx_imgui.h:
//
//     sokol_gfx.h
//
// Additionally, include the following headers before including the
// implementation:
//
// If the implementation is compiled as C++:
//     imgui.h
//
// If the implementation is compiled as C:
//     cimgui.h
//
// The sokol_gfx.h implementation must be compiled with debug trace hooks
// enabled by defining:
//
//     SOKOL_TRACE_HOOKS
//
// ...before including the sokol_gfx.h implementation.
//
// Before including the sokol_gfx_imgui.h implementation, optionally
// override the following macros:
//
//     SOKOL_ASSERT(c)     -- your own assert macro, default: assert(c)
//     SOKOL_UNREACHABLE   -- your own macro to annotate unreachable code,
//                            default: SOKOL_ASSERT(false)
//     SOKOL_GFX_IMGUI_API_DECL    - public function declaration prefix (default: extern)
//     SOKOL_GFX_IMGUI_CPREFIX     - defines the function prefix for the Dear ImGui C bindings (default: ig)
//     SOKOL_API_DECL      - same as SOKOL_GFX_IMGUI_API_DECL
//     SOKOL_API_IMPL      - public function implementation prefix (default: -)
//
// If sokol_gfx_imgui.h is compiled as a DLL, define the following before
// including the declaration or implementation:
//
// SOKOL_DLL
//
// On Windows, SOKOL_DLL will define SOKOL_GFX_IMGUI_API_DECL as __declspec(dllexport)
// or __declspec(dllimport) as needed.
//
// STEP BY STEP:
// =============
// --- create an sgimgui_t struct (which must be preserved between frames)
//     and initialize it with:
//
//         sgimgui_init(&sgimgui, &(sgimgui_desc_t){ 0 });
//
//     Note that from C++ you can't inline the desc structure initialization:
//
//         const sgimgui_desc_t desc = { };
//         sgimgui_init(&sgimgui, &desc);
//
//     Provide optional memory allocator override functions (compatible with malloc/free) like this:
//
//         sgimgui_init(&sgimgui, &(sgimgui_desc_t){
//             .allocator = {
//                 .alloc_fn = my_malloc,
//                 .free_fn = my_free,
//             }
//         });
//
// --- somewhere in the per-frame code call:
//
//         sgimgui_draw(&sgimgui)
//
//     this won't draw anything yet, since no windows are open.
//
// --- call the convenience function sgimgui_draw_menu(ctx, title)
//     to render a menu which allows to open/close the provided debug windows
//
//         sgimgui_draw_menu(&sgimgui, "sokol-gfx");
//
// --- alternative, open and close windows directly by setting the following public
//     booleans in the sgimgui_t struct:
//
//         sgimgui.caps_window.open = true;
//         sgimgui.frame_stats_window.open = true;
//         sgimgui.buffer_window.open = true;
//         sgimgui.image_window.open = true;
//         sgimgui.sampler_window.open = true;
//         sgimgui.shader_window.open = true;
//         sgimgui.pipeline_window.open = true;
//         sgimgui.view_window.open = true;
//         sgimgui.capture_window.open = true;
//         sgimgui.frame_stats_window.open = true;
//
//     ...for instance, to control the window visibility through menu items, the following code can be used:
//
//         if (ImGui::BeginMainMenuBar()) {
//             if (ImGui::BeginMenu("sokol-gfx")) {
//                 ImGui::MenuItem("Capabilities", 0, &sgimgui.caps_window.open);
//                 ImGui::MenuItem("Frame Stats", 0, &sgimgui.frame_stats_window.open);
//                 ImGui::MenuItem("Buffers", 0, &sgimgui.buffer_window.open);
//                 ImGui::MenuItem("Images", 0, &sgimgui.image_window.open);
//                 ImGui::MenuItem("Samplers", 0, &sgimgui.sampler_window.open);
//                 ImGui::MenuItem("Shaders", 0, &sgimgui.shader_window.open);
//                 ImGui::MenuItem("Pipelines", 0, &sgimgui.pipeline_window.open);
//                 ImGui::MenuItem("Views", 0, &sgimgui.view_window.open);
//                 ImGui::MenuItem("Calls", 0, &sgimgui.capture_window.open);
//                 ImGui::EndMenu();
//             }
//             ImGui::EndMainMenuBar();
//         }
//
// --- before application shutdown, call:
//
//         sgimgui_discard(&sgimgui);
//
//     ...this is not strictly necessary because the application exits
//     anyway, but not doing this may trigger memory leak detection tools.
//
// --- finally, your application needs an ImGui renderer, you can either
//     provide your own, or drop in the sokol_imgui.h utility header
//
// ALTERNATIVE DRAWING FUNCTIONS:
// ==============================
// Instead of the convenient, but all-in-one sgimgui_draw() function,
// you can also use the following granular functions which might allow
// better integration with your existing UI:
//
// The following functions only render the window *content* (so you
// can integrate the UI into you own windows):
//
//     void sgimgui_draw_buffer_window_content(sgimgui_t* ctx);
//     void sgimgui_draw_image_window_content(sgimgui_t* ctx);
//     void sgimgui_draw_sampler_window_content(sgimgui_t* ctx);
//     void sgimgui_draw_shader_window_content(sgimgui_t* ctx);
//     void sgimgui_draw_pipeline_window_content(sgimgui_t* ctx);
//     void sgimgui_draw_view_window_content(sgimgui_t* ctx);
//     void sgimgui_draw_capture_window_content(sgimgui_t* ctx);
//
// And these are the 'full window' drawing functions:
//
//     void sgimgui_draw_buffer_window(sgimgui_t* ctx);
//     void sgimgui_draw_image_window(sgimgui_t* ctx);
//     void sgimgui_draw_sampler_window(sgimgui_t* ctx);
//     void sgimgui_draw_shader_window(sgimgui_t* ctx);
//     void sgimgui_draw_pipeline_window(sgimgui_t* ctx);
//     void sgimgui_draw_view_window(sgimgui_t* ctx);
//     void sgimgui_draw_capture_window(sgimgui_t* ctx);
//
// Finer-grained drawing functions may be moved to the public API
// in the future as needed.
//
// MEMORY ALLOCATION OVERRIDE
// ==========================
// You can override the memory allocation functions at initialization time
// like this:
//
//     void* my_alloc(size_t size, void* user_data) {
//         return malloc(size);
//     }
//
//     void my_free(void* ptr, void* user_data) {
//         free(ptr);
//     }
//
//     ...
//         sgimgui_init(&(&ctx, &(sgimgui_desc_t){
//             // ...
//             .allocator = {
//                 .alloc_fn = my_alloc,
//                 .free_fn = my_free,
//                 .user_data = ...;
//             }
//         });
//     ...
//
// This only affects memory allocation calls done by sokol_gfx_imgui.h
// itself though, not any allocations in OS libraries.
//
//
// LICENSE
// =======
// zlib/libpng license
//
// Copyright (c) 2018 Andre Weissflog
//
// This software is provided 'as-is', without any express or implied warranty.
// In no event will the authors be held liable for any damages arising from the
// use of this software.
//
// Permission is granted to anyone to use this software for any purpose,
// including commercial applications, and to alter it and redistribute it
// freely, subject to the following restrictions:
//
//     1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software in a
//     product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//
//     2. Altered source versions must be plainly marked as such, and must not
//     be misrepresented as being the original software.
//
//     3. This notice may not be removed or altered from any source
//     distribution.

const builtin = @import("builtin");
const sg = @import("gfx.zig");

// helper function to convert a C string to a Zig string slice
fn cStrToZig(c_str: [*c]const u8) [:0]const u8 {
    return @import("std").mem.span(c_str);
}
pub const Str = extern struct {
    buf: [96]u8 = [_]u8{0} ** 96,
};

pub const Buffer = extern struct {
    res_id: sg.Buffer = .{},
    label: Str = .{},
    desc: sg.BufferDesc = .{},
};

pub const Image = extern struct {
    res_id: sg.Image = .{},
    ui_scale: f32 = 0.0,
    label: Str = .{},
    desc: sg.ImageDesc = .{},
};

pub const Sampler = extern struct {
    res_id: sg.Sampler = .{},
    label: Str = .{},
    desc: sg.SamplerDesc = .{},
};

pub const Shader = extern struct {
    res_id: sg.Shader = .{},
    label: Str = .{},
    vs_entry: Str = .{},
    vs_d3d11_target: Str = .{},
    fs_entry: Str = .{},
    fs_d3d11_target: Str = .{},
    glsl_texture_sampler_name: [32]Str = [_]Str{.{}} ** 32,
    glsl_uniform_name: [8][16]Str = [_][16]Str{[_]Str{.{}} ** 16} ** 8,
    attr_glsl_name: [16]Str = [_]Str{.{}} ** 16,
    attr_hlsl_sem_name: [16]Str = [_]Str{.{}} ** 16,
    desc: sg.ShaderDesc = .{},
};

pub const Pipeline = extern struct {
    res_id: sg.Pipeline = .{},
    label: Str = .{},
    desc: sg.PipelineDesc = .{},
};

pub const View = extern struct {
    res_id: sg.View = .{},
    ui_scale: f32 = 0.0,
    label: Str = .{},
    desc: sg.ViewDesc = .{},
};

pub const BufferWindow = extern struct {
    open: bool = false,
    sel_buf: sg.Buffer = .{},
    num_slots: i32 = 0,
    slots: *Buffer = undefined,
};

pub const ImageWindow = extern struct {
    open: bool = false,
    sel_img: sg.Image = .{},
    num_slots: i32 = 0,
    slots: *Image = undefined,
};

pub const SamplerWindow = extern struct {
    open: bool = false,
    sel_smp: sg.Sampler = .{},
    num_slots: i32 = 0,
    slots: *Sampler = undefined,
};

pub const ShaderWindow = extern struct {
    open: bool = false,
    sel_shd: sg.Shader = .{},
    num_slots: i32 = 0,
    slots: *Shader = undefined,
};

pub const PipelineWindow = extern struct {
    open: bool = false,
    sel_pip: sg.Pipeline = .{},
    num_slots: i32 = 0,
    slots: *Pipeline = undefined,
};

pub const ViewWindow = extern struct {
    open: bool = false,
    sel_view: sg.View = .{},
    num_slots: i32 = 0,
    slots: *View = undefined,
};

pub const Cmd = enum(i32) {
    INVALID,
    RESET_STATE_CACHE,
    MAKE_BUFFER,
    MAKE_IMAGE,
    MAKE_SAMPLER,
    MAKE_SHADER,
    MAKE_PIPELINE,
    MAKE_VIEW,
    DESTROY_BUFFER,
    DESTROY_IMAGE,
    DESTROY_SAMPLER,
    DESTROY_SHADER,
    DESTROY_PIPELINE,
    DESTROY_VIEW,
    UPDATE_BUFFER,
    UPDATE_IMAGE,
    APPEND_BUFFER,
    BEGIN_PASS,
    APPLY_VIEWPORT,
    APPLY_SCISSOR_RECT,
    APPLY_PIPELINE,
    APPLY_BINDINGS,
    APPLY_UNIFORMS,
    DRAW,
    DRAW_EX,
    DISPATCH,
    END_PASS,
    COMMIT,
    ALLOC_BUFFER,
    ALLOC_IMAGE,
    ALLOC_SAMPLER,
    ALLOC_SHADER,
    ALLOC_PIPELINE,
    ALLOC_VIEW,
    DEALLOC_BUFFER,
    DEALLOC_IMAGE,
    DEALLOC_SAMPLER,
    DEALLOC_SHADER,
    DEALLOC_PIPELINE,
    DEALLOC_VIEW,
    INIT_BUFFER,
    INIT_IMAGE,
    INIT_SAMPLER,
    INIT_SHADER,
    INIT_PIPELINE,
    INIT_VIEW,
    UNINIT_BUFFER,
    UNINIT_IMAGE,
    UNINIT_SAMPLER,
    UNINIT_SHADER,
    UNINIT_PIPELINE,
    UNINIT_VIEW,
    FAIL_BUFFER,
    FAIL_IMAGE,
    FAIL_SAMPLER,
    FAIL_SHADER,
    FAIL_PIPELINE,
    FAIL_VIEW,
    PUSH_DEBUG_GROUP,
    POP_DEBUG_GROUP,
};

pub const ArgsMakeBuffer = extern struct {
    result: sg.Buffer = .{},
};

pub const ArgsMakeImage = extern struct {
    result: sg.Image = .{},
};

pub const ArgsMakeSampler = extern struct {
    result: sg.Sampler = .{},
};

pub const ArgsMakeShader = extern struct {
    result: sg.Shader = .{},
};

pub const ArgsMakePipeline = extern struct {
    result: sg.Pipeline = .{},
};

pub const ArgsMakeView = extern struct {
    result: sg.View = .{},
};

pub const ArgsDestroyBuffer = extern struct {
    buffer: sg.Buffer = .{},
};

pub const ArgsDestroyImage = extern struct {
    image: sg.Image = .{},
};

pub const ArgsDestroySampler = extern struct {
    sampler: sg.Sampler = .{},
};

pub const ArgsDestroyShader = extern struct {
    shader: sg.Shader = .{},
};

pub const ArgsDestroyPipeline = extern struct {
    pipeline: sg.Pipeline = .{},
};

pub const ArgsDestroyView = extern struct {
    view: sg.View = .{},
};

pub const ArgsUpdateBuffer = extern struct {
    buffer: sg.Buffer = .{},
    data_size: usize = 0,
};

pub const ArgsUpdateImage = extern struct {
    image: sg.Image = .{},
};

pub const ArgsAppendBuffer = extern struct {
    buffer: sg.Buffer = .{},
    data_size: usize = 0,
    result: i32 = 0,
};

pub const ArgsBeginPass = extern struct {
    pass: sg.Pass = .{},
};

pub const ArgsApplyViewport = extern struct {
    x: i32 = 0,
    y: i32 = 0,
    width: i32 = 0,
    height: i32 = 0,
    origin_top_left: bool = false,
};

pub const ArgsApplyScissorRect = extern struct {
    x: i32 = 0,
    y: i32 = 0,
    width: i32 = 0,
    height: i32 = 0,
    origin_top_left: bool = false,
};

pub const ArgsApplyPipeline = extern struct {
    pipeline: sg.Pipeline = .{},
};

pub const ArgsApplyBindings = extern struct {
    bindings: sg.Bindings = .{},
};

pub const ArgsApplyUniforms = extern struct {
    ub_slot: i32 = 0,
    data_size: usize = 0,
    pipeline: sg.Pipeline = .{},
    ubuf_pos: usize = 0,
};

pub const ArgsDraw = extern struct {
    base_element: i32 = 0,
    num_elements: i32 = 0,
    num_instances: i32 = 0,
};

pub const ArgsDrawEx = extern struct {
    base_element: i32 = 0,
    num_elements: i32 = 0,
    num_instances: i32 = 0,
    base_vertex: i32 = 0,
    base_instance: i32 = 0,
};

pub const ArgsDispatch = extern struct {
    num_groups_x: i32 = 0,
    num_groups_y: i32 = 0,
    num_groups_z: i32 = 0,
};

pub const ArgsAllocBuffer = extern struct {
    result: sg.Buffer = .{},
};

pub const ArgsAllocImage = extern struct {
    result: sg.Image = .{},
};

pub const ArgsAllocSampler = extern struct {
    result: sg.Sampler = .{},
};

pub const ArgsAllocShader = extern struct {
    result: sg.Shader = .{},
};

pub const ArgsAllocPipeline = extern struct {
    result: sg.Pipeline = .{},
};

pub const ArgsAllocView = extern struct {
    result: sg.View = .{},
};

pub const ArgsDeallocBuffer = extern struct {
    buffer: sg.Buffer = .{},
};

pub const ArgsDeallocImage = extern struct {
    image: sg.Image = .{},
};

pub const ArgsDeallocSampler = extern struct {
    sampler: sg.Sampler = .{},
};

pub const ArgsDeallocShader = extern struct {
    shader: sg.Shader = .{},
};

pub const ArgsDeallocPipeline = extern struct {
    pipeline: sg.Pipeline = .{},
};

pub const ArgsDeallocView = extern struct {
    view: sg.View = .{},
};

pub const ArgsInitBuffer = extern struct {
    buffer: sg.Buffer = .{},
};

pub const ArgsInitImage = extern struct {
    image: sg.Image = .{},
};

pub const ArgsInitSampler = extern struct {
    sampler: sg.Sampler = .{},
};

pub const ArgsInitShader = extern struct {
    shader: sg.Shader = .{},
};

pub const ArgsInitPipeline = extern struct {
    pipeline: sg.Pipeline = .{},
};

pub const ArgsInitView = extern struct {
    view: sg.View = .{},
};

pub const ArgsUninitBuffer = extern struct {
    buffer: sg.Buffer = .{},
};

pub const ArgsUninitImage = extern struct {
    image: sg.Image = .{},
};

pub const ArgsUninitSampler = extern struct {
    sampler: sg.Sampler = .{},
};

pub const ArgsUninitShader = extern struct {
    shader: sg.Shader = .{},
};

pub const ArgsUninitPipeline = extern struct {
    pipeline: sg.Pipeline = .{},
};

pub const ArgsUninitView = extern struct {
    view: sg.View = .{},
};

pub const ArgsFailBuffer = extern struct {
    buffer: sg.Buffer = .{},
};

pub const ArgsFailImage = extern struct {
    image: sg.Image = .{},
};

pub const ArgsFailSampler = extern struct {
    sampler: sg.Sampler = .{},
};

pub const ArgsFailShader = extern struct {
    shader: sg.Shader = .{},
};

pub const ArgsFailPipeline = extern struct {
    pipeline: sg.Pipeline = .{},
};

pub const ArgsFailView = extern struct {
    view: sg.View = .{},
};

pub const ArgsPushDebugGroup = extern struct {
    name: Str = .{},
};

pub const Args = extern struct {
    make_buffer: ArgsMakeBuffer = .{},
    make_image: ArgsMakeImage = .{},
    make_sampler: ArgsMakeSampler = .{},
    make_shader: ArgsMakeShader = .{},
    make_pipeline: ArgsMakePipeline = .{},
    make_view: ArgsMakeView = .{},
    destroy_buffer: ArgsDestroyBuffer = .{},
    destroy_image: ArgsDestroyImage = .{},
    destroy_sampler: ArgsDestroySampler = .{},
    destroy_shader: ArgsDestroyShader = .{},
    destroy_pipeline: ArgsDestroyPipeline = .{},
    destroy_view: ArgsDestroyView = .{},
    update_buffer: ArgsUpdateBuffer = .{},
    update_image: ArgsUpdateImage = .{},
    append_buffer: ArgsAppendBuffer = .{},
    begin_pass: ArgsBeginPass = .{},
    apply_viewport: ArgsApplyViewport = .{},
    apply_scissor_rect: ArgsApplyScissorRect = .{},
    apply_pipeline: ArgsApplyPipeline = .{},
    apply_bindings: ArgsApplyBindings = .{},
    apply_uniforms: ArgsApplyUniforms = .{},
    draw: ArgsDraw = .{},
    draw_ex: ArgsDrawEx = .{},
    dispatch: ArgsDispatch = .{},
    alloc_buffer: ArgsAllocBuffer = .{},
    alloc_image: ArgsAllocImage = .{},
    alloc_sampler: ArgsAllocSampler = .{},
    alloc_shader: ArgsAllocShader = .{},
    alloc_pipeline: ArgsAllocPipeline = .{},
    alloc_view: ArgsAllocView = .{},
    dealloc_buffer: ArgsDeallocBuffer = .{},
    dealloc_image: ArgsDeallocImage = .{},
    dealloc_sampler: ArgsDeallocSampler = .{},
    dealloc_shader: ArgsDeallocShader = .{},
    dealloc_pipeline: ArgsDeallocPipeline = .{},
    dealloc_view: ArgsDeallocView = .{},
    init_buffer: ArgsInitBuffer = .{},
    init_image: ArgsInitImage = .{},
    init_sampler: ArgsInitSampler = .{},
    init_shader: ArgsInitShader = .{},
    init_pipeline: ArgsInitPipeline = .{},
    init_view: ArgsInitView = .{},
    uninit_buffer: ArgsUninitBuffer = .{},
    uninit_image: ArgsUninitImage = .{},
    uninit_sampler: ArgsUninitSampler = .{},
    uninit_shader: ArgsUninitShader = .{},
    uninit_pipeline: ArgsUninitPipeline = .{},
    uninit_view: ArgsUninitView = .{},
    fail_buffer: ArgsFailBuffer = .{},
    fail_image: ArgsFailImage = .{},
    fail_sampler: ArgsFailSampler = .{},
    fail_shader: ArgsFailShader = .{},
    fail_pipeline: ArgsFailPipeline = .{},
    fail_view: ArgsFailView = .{},
    push_debug_group: ArgsPushDebugGroup = .{},
};

pub const CaptureItem = extern struct {
    cmd: Cmd = .INVALID,
    color: u32 = 0,
    args: Args = .{},
};

pub const CaptureBucket = extern struct {
    ubuf_size: usize = 0,
    ubuf_pos: usize = 0,
    ubuf: *u8 = undefined,
    num_items: i32 = 0,
    items: [4096]CaptureItem = [_]CaptureItem{.{}} ** 4096,
};

/// double-buffered call-capture buckets, one bucket is currently recorded,
///   the previous bucket is displayed
pub const CaptureWindow = extern struct {
    open: bool = false,
    bucket_index: i32 = 0,
    sel_item: i32 = 0,
    bucket: [2]CaptureBucket = [_]CaptureBucket{.{}} ** 2,
};

pub const CapsWindow = extern struct {
    open: bool = false,
};

pub const FrameStatsWindow = extern struct {
    open: bool = false,
    disable_sokol_imgui_stats: bool = false,
    in_sokol_imgui: bool = false,
    stats: sg.FrameStats = .{},
};

/// sgimgui_allocator_t
///
/// Used in sgimgui_desc_t to provide custom memory-alloc and -free functions
/// to sokol_gfx_imgui.h. If memory management should be overridden, both the
/// alloc and free function must be provided (e.g. it's not valid to
/// override one function but not the other).
pub const Allocator = extern struct {
    alloc_fn: ?*const fn (usize, ?*anyopaque) callconv(.c) ?*anyopaque = null,
    free_fn: ?*const fn (?*anyopaque, ?*anyopaque) callconv(.c) void = null,
    user_data: ?*anyopaque = null,
};

/// sgimgui_desc_t
///
/// Initialization options for sgimgui_init().
pub const Desc = extern struct {
    allocator: Allocator = .{},
};

pub const ImguiDebug = extern struct {
    init_tag: u32 = 0,
    desc: Desc = .{},
    buffer_window: BufferWindow = .{},
    image_window: ImageWindow = .{},
    sampler_window: SamplerWindow = .{},
    shader_window: ShaderWindow = .{},
    pipeline_window: PipelineWindow = .{},
    view_window: ViewWindow = .{},
    capture_window: CaptureWindow = .{},
    caps_window: CapsWindow = .{},
    frame_stats_window: FrameStatsWindow = .{},
    cur_pipeline: sg.Pipeline = .{},
    hooks: sg.TraceHooks = .{},
};

extern fn sgimgui_init(*ImguiDebug, [*c]const Desc) void;

pub fn init(ctx: *ImguiDebug, desc: Desc) void {
    sgimgui_init(ctx, &desc);
}

extern fn sgimgui_discard(*ImguiDebug) void;

pub fn discard(ctx: *ImguiDebug) void {
    sgimgui_discard(ctx);
}

extern fn sgimgui_draw(*ImguiDebug) void;

pub fn draw(ctx: *ImguiDebug) void {
    sgimgui_draw(ctx);
}

extern fn sgimgui_draw_menu(*ImguiDebug, [*c]const u8) void;

pub fn drawMenu(ctx: *ImguiDebug, title: [:0]const u8) void {
    sgimgui_draw_menu(ctx, @ptrCast(title));
}

extern fn sgimgui_draw_buffer_window_content(*ImguiDebug) void;

pub fn drawBufferWindowContent(ctx: *ImguiDebug) void {
    sgimgui_draw_buffer_window_content(ctx);
}

extern fn sgimgui_draw_image_window_content(*ImguiDebug) void;

pub fn drawImageWindowContent(ctx: *ImguiDebug) void {
    sgimgui_draw_image_window_content(ctx);
}

extern fn sgimgui_draw_sampler_window_content(*ImguiDebug) void;

pub fn drawSamplerWindowContent(ctx: *ImguiDebug) void {
    sgimgui_draw_sampler_window_content(ctx);
}

extern fn sgimgui_draw_shader_window_content(*ImguiDebug) void;

pub fn drawShaderWindowContent(ctx: *ImguiDebug) void {
    sgimgui_draw_shader_window_content(ctx);
}

extern fn sgimgui_draw_pipeline_window_content(*ImguiDebug) void;

pub fn drawPipelineWindowContent(ctx: *ImguiDebug) void {
    sgimgui_draw_pipeline_window_content(ctx);
}

extern fn sgimgui_draw_view_window_content(*ImguiDebug) void;

pub fn drawViewWindowContent(ctx: *ImguiDebug) void {
    sgimgui_draw_view_window_content(ctx);
}

extern fn sgimgui_draw_capture_window_content(*ImguiDebug) void;

pub fn drawCaptureWindowContent(ctx: *ImguiDebug) void {
    sgimgui_draw_capture_window_content(ctx);
}

extern fn sgimgui_draw_capabilities_window_content(*ImguiDebug) void;

pub fn drawCapabilitiesWindowContent(ctx: *ImguiDebug) void {
    sgimgui_draw_capabilities_window_content(ctx);
}

extern fn sgimgui_draw_frame_stats_window_content(*ImguiDebug) void;

pub fn drawFrameStatsWindowContent(ctx: *ImguiDebug) void {
    sgimgui_draw_frame_stats_window_content(ctx);
}

extern fn sgimgui_draw_buffer_window(*ImguiDebug) void;

pub fn drawBufferWindow(ctx: *ImguiDebug) void {
    sgimgui_draw_buffer_window(ctx);
}

extern fn sgimgui_draw_image_window(*ImguiDebug) void;

pub fn drawImageWindow(ctx: *ImguiDebug) void {
    sgimgui_draw_image_window(ctx);
}

extern fn sgimgui_draw_sampler_window(*ImguiDebug) void;

pub fn drawSamplerWindow(ctx: *ImguiDebug) void {
    sgimgui_draw_sampler_window(ctx);
}

extern fn sgimgui_draw_shader_window(*ImguiDebug) void;

pub fn drawShaderWindow(ctx: *ImguiDebug) void {
    sgimgui_draw_shader_window(ctx);
}

extern fn sgimgui_draw_pipeline_window(*ImguiDebug) void;

pub fn drawPipelineWindow(ctx: *ImguiDebug) void {
    sgimgui_draw_pipeline_window(ctx);
}

extern fn sgimgui_draw_view_window(*ImguiDebug) void;

pub fn drawViewWindow(ctx: *ImguiDebug) void {
    sgimgui_draw_view_window(ctx);
}

extern fn sgimgui_draw_capture_window(*ImguiDebug) void;

pub fn drawCaptureWindow(ctx: *ImguiDebug) void {
    sgimgui_draw_capture_window(ctx);
}

extern fn sgimgui_draw_capabilities_window(*ImguiDebug) void;

pub fn drawCapabilitiesWindow(ctx: *ImguiDebug) void {
    sgimgui_draw_capabilities_window(ctx);
}

extern fn sgimgui_draw_frame_stats_window(*ImguiDebug) void;

pub fn drawFrameStatsWindow(ctx: *ImguiDebug) void {
    sgimgui_draw_frame_stats_window(ctx);
}

