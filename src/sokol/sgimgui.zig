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
// --- call sgimgui_init() with optional allocator overrides:
//
//         sgimgui_init(&(sgimgui_desc_t){
//             .allocator = {
//                 .alloc_fn = my_malloc,
//                 .free_fn = my_free,
//             }
//         });
//
// --- somewhere in the per-frame code call:
//
//         sgimgui_draw()
//
//     this won't draw anything yet, since no windows are open.
//
// --- call the convenience function sgimgui_draw_menu(ctx, title)
//     to render a menu which allows to open/close the provided debug windows
//
//         sgimgui_draw_menu("sokol-gfx");
//
// --- alternatively the individual single menu items via:
//
//     if (ImGui::BeginMainMenuBar()) {
//         if (ImGui::BeginMenu("sokol-gfx")) {
//             sgimgui_draw_buffer_window_menu_item("Buffers");
//             sgimgui_draw_image_window_menu_item("Images");
//             sgimgui_draw_sampler_window_menu_item("Samplers");
//             sgimgui_draw_shader_window_menu_item("Shaders");
//             sgimgui_draw_pipeline_window_menu_item("Pipelines");
//             sgimgui_draw_view_window_menu_item("Views");
//             sgimgui_draw_capture_window_menu_item("Calls");
//             sgimgui_draw_capabilities_window_menu_item("Capabilities");
//             sgimgui_draw_frame_stats_window_menu_item("Frame Stats");
//             ImGui::EndMenu();
//         }
//         ImGui::EndMainMenuBar();
//     }
//
// --- before application shutdown, call:
//
//         sgimgui_discard();
//
//     ...this is not strictly necessary because the application exits
//     anyway, but not doing this may trigger memory leak detection tools.
//
// --- finally, your application needs an ImGui renderer, you can either
//     provide your own, or drop in the sokol_imgui.h utility header
//
// ALTERNATIVE DRAWING FUNCTIONS:
// ==============================
// Instead of the convenient but all-in-one sgimgui_draw() function,
// you can also use the following granular functions which might allow
// better integration with your existing UI:
//
// The following functions only render the window *content* (so you
// can integrate the UI into you own windows):
//
//     void sgimgui_draw_buffer_window_content();
//     void sgimgui_draw_image_window_content();
//     void sgimgui_draw_sampler_window_content();
//     void sgimgui_draw_shader_window_content();
//     void sgimgui_draw_pipeline_window_content();
//     void sgimgui_draw_view_window_content();
//     void sgimgui_draw_capture_window_content();
//     void sgimgui_draw_capabilities_window_content();
//     void sgimgui_draw_frame_stats_window_content();
//
// And these are the 'full window' drawing functions:
//
//     void sgimgui_draw_buffer_window("Buffers");
//     void sgimgui_draw_image_window("Images");
//     void sgimgui_draw_sampler_window("Samplers");
//     void sgimgui_draw_shader_window("Shaders");
//     void sgimgui_draw_pipeline_window("Pipelines");
//     void sgimgui_draw_view_window("Views");
//     void sgimgui_draw_capture_window("Frame Capture");
//     void sgimgui_draw_capabilities_window("Capabilities");
//     void sgimgui_draw_frame_stats_window("Frame Stats");
//
// Finer-grained drawing functions may be moved to the public API
// in the future as needed.
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
const simgui = @import("imgui.zig");

// helper function to convert a C string to a Zig string slice
fn cStrToZig(c_str: [*c]const u8) [:0]const u8 {
    return @import("std").mem.span(c_str);
}
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

extern fn sgimgui_setup([*c]const Desc) void;

pub fn setup(desc: Desc) void {
    sgimgui_setup(&desc);
}

extern fn sgimgui_shutdown() void;

pub fn shutdown() void {
    sgimgui_shutdown();
}

extern fn sgimgui_draw() void;

pub fn draw() void {
    sgimgui_draw();
}

extern fn sgimgui_draw_menu([*c]const u8) void;

pub fn drawMenu(title: [:0]const u8) void {
    sgimgui_draw_menu(@ptrCast(title));
}

extern fn sgimgui_draw_buffer_window_content() void;

pub fn drawBufferWindowContent() void {
    sgimgui_draw_buffer_window_content();
}

extern fn sgimgui_draw_image_window_content() void;

pub fn drawImageWindowContent() void {
    sgimgui_draw_image_window_content();
}

extern fn sgimgui_draw_sampler_window_content() void;

pub fn drawSamplerWindowContent() void {
    sgimgui_draw_sampler_window_content();
}

extern fn sgimgui_draw_shader_window_content() void;

pub fn drawShaderWindowContent() void {
    sgimgui_draw_shader_window_content();
}

extern fn sgimgui_draw_pipeline_window_content() void;

pub fn drawPipelineWindowContent() void {
    sgimgui_draw_pipeline_window_content();
}

extern fn sgimgui_draw_view_window_content() void;

pub fn drawViewWindowContent() void {
    sgimgui_draw_view_window_content();
}

extern fn sgimgui_draw_capture_window_content() void;

pub fn drawCaptureWindowContent() void {
    sgimgui_draw_capture_window_content();
}

extern fn sgimgui_draw_capabilities_window_content() void;

pub fn drawCapabilitiesWindowContent() void {
    sgimgui_draw_capabilities_window_content();
}

extern fn sgimgui_draw_frame_stats_window_content() void;

pub fn drawFrameStatsWindowContent() void {
    sgimgui_draw_frame_stats_window_content();
}

extern fn sgimgui_draw_buffer_window([*c]const u8) void;

pub fn drawBufferWindow(title: [:0]const u8) void {
    sgimgui_draw_buffer_window(@ptrCast(title));
}

extern fn sgimgui_draw_image_window([*c]const u8) void;

pub fn drawImageWindow(title: [:0]const u8) void {
    sgimgui_draw_image_window(@ptrCast(title));
}

extern fn sgimgui_draw_sampler_window([*c]const u8) void;

pub fn drawSamplerWindow(title: [:0]const u8) void {
    sgimgui_draw_sampler_window(@ptrCast(title));
}

extern fn sgimgui_draw_shader_window([*c]const u8) void;

pub fn drawShaderWindow(title: [:0]const u8) void {
    sgimgui_draw_shader_window(@ptrCast(title));
}

extern fn sgimgui_draw_pipeline_window([*c]const u8) void;

pub fn drawPipelineWindow(title: [:0]const u8) void {
    sgimgui_draw_pipeline_window(@ptrCast(title));
}

extern fn sgimgui_draw_view_window([*c]const u8) void;

pub fn drawViewWindow(title: [:0]const u8) void {
    sgimgui_draw_view_window(@ptrCast(title));
}

extern fn sgimgui_draw_capture_window([*c]const u8) void;

pub fn drawCaptureWindow(title: [:0]const u8) void {
    sgimgui_draw_capture_window(@ptrCast(title));
}

extern fn sgimgui_draw_capabilities_window([*c]const u8) void;

pub fn drawCapabilitiesWindow(title: [:0]const u8) void {
    sgimgui_draw_capabilities_window(@ptrCast(title));
}

extern fn sgimgui_draw_frame_stats_window([*c]const u8) void;

pub fn drawFrameStatsWindow(title: [:0]const u8) void {
    sgimgui_draw_frame_stats_window(@ptrCast(title));
}

extern fn sgimgui_draw_buffer_menu_item([*c]const u8) void;

pub fn drawBufferMenuItem(label: [:0]const u8) void {
    sgimgui_draw_buffer_menu_item(@ptrCast(label));
}

extern fn sgimgui_draw_image_menu_item([*c]const u8) void;

pub fn drawImageMenuItem(label: [:0]const u8) void {
    sgimgui_draw_image_menu_item(@ptrCast(label));
}

extern fn sgimgui_draw_sampler_menu_item([*c]const u8) void;

pub fn drawSamplerMenuItem(label: [:0]const u8) void {
    sgimgui_draw_sampler_menu_item(@ptrCast(label));
}

extern fn sgimgui_draw_shader_menu_item([*c]const u8) void;

pub fn drawShaderMenuItem(label: [:0]const u8) void {
    sgimgui_draw_shader_menu_item(@ptrCast(label));
}

extern fn sgimgui_draw_pipeline_menu_item([*c]const u8) void;

pub fn drawPipelineMenuItem(label: [:0]const u8) void {
    sgimgui_draw_pipeline_menu_item(@ptrCast(label));
}

extern fn sgimgui_draw_view_menu_item([*c]const u8) void;

pub fn drawViewMenuItem(label: [:0]const u8) void {
    sgimgui_draw_view_menu_item(@ptrCast(label));
}

extern fn sgimgui_draw_capture_menu_item([*c]const u8) void;

pub fn drawCaptureMenuItem(label: [:0]const u8) void {
    sgimgui_draw_capture_menu_item(@ptrCast(label));
}

extern fn sgimgui_draw_capabilities_menu_item([*c]const u8) void;

pub fn drawCapabilitiesMenuItem(label: [:0]const u8) void {
    sgimgui_draw_capabilities_menu_item(@ptrCast(label));
}

extern fn sgimgui_draw_frame_stats_menu_item([*c]const u8) void;

pub fn drawFrameStatsMenuItem(label: [:0]const u8) void {
    sgimgui_draw_frame_stats_menu_item(@ptrCast(label));
}

