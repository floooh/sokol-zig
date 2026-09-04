// machine generated, do not edit

//
// sokol_cmdbuf.h  - a software command buffer for sokol_gfx.h
//
// Project URL: https://github.com/floooh/sokol
//
// Do this:
//     #define SOKOL_IMPL or
//     #define SOKOL_CMDBUF_IMPL
// before you include this file in *one* C or C++ file to create the
// implementation.
//
// ...optionally provide the following macros to override defaults:
//
// SOKOL_ASSERT(c)     - your own assert macro (default: assert(c))
// SOKOL_CMDBUF_API_DECL   - public function declaration prefix (default: extern)
// SOKOL_API_DECL      - same as SOKOL_CMDBUF_API_DECL
// SOKOL_API_IMPL      - public function implementation prefix (default: -)
// SOKOL_UNREACHABLE() - a guard macro for unreachable code (default: assert(false))
//
// If sokol_cmdbuf.h is compiled as a DLL, define the following before
// including the declaration or implementation:
//
// SOKOL_DLL
//
// On Windows, SOKOL_DLL will define SOKOL_CMDBUF_API_DECL as __declspec(dllexport)
// or __declspec(dllimport) as needed.
//
// Include the following headers before including sokol_cmdbuf.h:
//
//     sokol_gfx.h
//
//
// FIXME docs
//
//
// LICENSE
// =======
// zlib/libpng license
//
// Copyright (c) 2026 Andre Weissflog
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
/// public constants
pub const invalid_id = 0;

/// scb_cmdbuf
///
/// A command buffer handle created with scb_make_cmdbuf().
pub const Cmdbuf = extern struct {
    id: u32 = 0,
};

/// scb_resource_state
///
/// The state of a command buffer object, obtainable via scb_query_cmdbuf_state().
/// Publicly visible values are only SCB_RESOURCESTATE_VALID
/// and SCB_RESOURCESTATE_FAILED.
pub const ResourceState = enum(i32) {
    INITIAL,
    ALLOC,
    VALID,
    FAILED,
    INVALID,
};

/// scb_cmdbuf_desc
///
/// Creation parameters of a command buffer object. Used
/// in scb_make_cmdbuf().
///
/// TODO: information on how to estimate required size
pub const CmdbufDesc = extern struct {
    size: usize = 0,
    label: [*c]const u8 = null,
};

/// scb_cmdbuf_info
///
/// Result of scb_query_cmdbuf_info.
pub const CmdbufInfo = extern struct {
    size: usize = 0,
    remaining: usize = 0,
    overflown: bool = false,
};

pub const LogItem = enum(i32) {
    OK,
    MALLOC_FAILED,
    CMDBUF_OVERFLOW,
    CMDBUF_NOT_VALID,
    SUBMIT_CMDBUF_OVERFLOWN,
    SUBMIT_INVALID_COMMAND,
};

/// scb_logger
///
/// Used in scb_desc to provide a custom logging and error reporting
/// callback to sokol_cmdbuf.h
pub const Logger = extern struct {
    func: ?*const fn ([*c]const u8, u32, u32, [*c]const u8, u32, [*c]const u8, ?*anyopaque) callconv(.c) void = null,
    user_data: ?*anyopaque = null,
};

/// scb_allocator
///
/// Used in scb_desc to provide custom memory-alloc and -free functions
/// to sokol_cmdbuf.h. If memory management should be overridden, both the
/// alloc_fn and free_fn function must be provided (e.g. it's not valid to
/// override one function but not the other).
pub const Allocator = extern struct {
    alloc_fn: ?*const fn (usize, ?*anyopaque) callconv(.c) ?*anyopaque = null,
    free_fn: ?*const fn (?*anyopaque, ?*anyopaque) callconv(.c) void = null,
    user_data: ?*anyopaque = null,
};

/// scb_desc
///
/// FIXME: docs
pub const Desc = extern struct {
    cmdbuf_pool_size: i32 = 0,
    allocator: Allocator = .{},
    logger: Logger = .{},
};

/// setup sokol-cmdbuf
extern fn scb_setup([*c]const Desc) void;

/// setup sokol-cmdbuf
pub fn setup(desc: Desc) void {
    scb_setup(&desc);
}

/// shutdown sokol-cmdbuf
extern fn scb_shutdown() void;

/// shutdown sokol-cmdbuf
pub fn shutdown() void {
    scb_shutdown();
}

/// create a cmdbuf object
extern fn scb_make_cmdbuf([*c]const CmdbufDesc) Cmdbuf;

/// create a cmdbuf object
pub fn makeCmdbuf(desc: CmdbufDesc) Cmdbuf {
    return scb_make_cmdbuf(&desc);
}

/// destroy cmdbuf object
extern fn scb_destroy_cmdbuf(Cmdbuf) void;

/// destroy cmdbuf object
pub fn destroyCmdbuf(cb: Cmdbuf) void {
    scb_destroy_cmdbuf(cb);
}

/// submit command buffer to sokol-gfx and rewind the command buffer (call inside a sokol-gfx pass)
extern fn scb_submit(Cmdbuf) void;

/// submit command buffer to sokol-gfx and rewind the command buffer (call inside a sokol-gfx pass)
pub fn submit(cb: Cmdbuf) void {
    scb_submit(cb);
}

/// record apply-viewport command (integer variant)
extern fn scb_apply_viewport(Cmdbuf, i32, i32, i32, i32, bool) void;

/// record apply-viewport command (integer variant)
pub fn applyViewport(cb: Cmdbuf, x: i32, y: i32, width: i32, height: i32, origin_top_left: bool) void {
    scb_apply_viewport(cb, x, y, width, height, origin_top_left);
}

/// record apply-viewport command (float variant)
extern fn scb_apply_viewportf(Cmdbuf, f32, f32, f32, f32, bool) void;

/// record apply-viewport command (float variant)
pub fn applyViewportf(cb: Cmdbuf, x: f32, y: f32, width: f32, height: f32, origin_top_left: bool) void {
    scb_apply_viewportf(cb, x, y, width, height, origin_top_left);
}

/// record apply-scissor-rect command (integer variant)
extern fn scb_apply_scissor_rect(Cmdbuf, i32, i32, i32, i32, bool) void;

/// record apply-scissor-rect command (integer variant)
pub fn applyScissorRect(cb: Cmdbuf, x: i32, y: i32, width: i32, height: i32, origin_top_left: bool) void {
    scb_apply_scissor_rect(cb, x, y, width, height, origin_top_left);
}

/// record apply-scissor-rect command (float variant)
extern fn scb_apply_scissor_rectf(Cmdbuf, f32, f32, f32, f32, bool) void;

/// record apply-scissor-rect command (float variant)
pub fn applyScissorRectf(cb: Cmdbuf, x: f32, y: f32, width: f32, height: f32, origin_top_left: bool) void {
    scb_apply_scissor_rectf(cb, x, y, width, height, origin_top_left);
}

/// record apply pipeline command
extern fn scb_apply_pipeline(Cmdbuf, sg.Pipeline) void;

/// record apply pipeline command
pub fn applyPipeline(cb: Cmdbuf, pip: sg.Pipeline) void {
    scb_apply_pipeline(cb, pip);
}

/// record apply bindings command
extern fn scb_apply_bindings(Cmdbuf, [*c]const sg.Bindings) void;

/// record apply bindings command
pub fn applyBindings(cb: Cmdbuf, bindings: sg.Bindings) void {
    scb_apply_bindings(cb, &bindings);
}

/// record apply uniforms command
extern fn scb_apply_uniforms(Cmdbuf, i32, [*c]const sg.Range) void;

/// record apply uniforms command
pub fn applyUniforms(cb: Cmdbuf, ub_slot: i32, data: sg.Range) void {
    scb_apply_uniforms(cb, ub_slot, &data);
}

/// record draw command
extern fn scb_draw(Cmdbuf, i32, i32, i32) void;

/// record draw command
pub fn draw(cb: Cmdbuf, base_element: i32, num_elements: i32, num_instances: i32) void {
    scb_draw(cb, base_element, num_elements, num_instances);
}

/// record draw-ex command
extern fn scb_draw_ex(Cmdbuf, i32, i32, i32, i32, i32) void;

/// record draw-ex command
pub fn drawEx(cb: Cmdbuf, base_element: i32, num_elements: i32, num_instances: i32, base_vertex: i32, base_instance: i32) void {
    scb_draw_ex(cb, base_element, num_elements, num_instances, base_vertex, base_instance);
}

/// record dispatch command
extern fn scb_dispatch(Cmdbuf, i32, i32, i32) void;

/// record dispatch command
pub fn dispatch(cb: Cmdbuf, num_groups_x: i32, num_groups_y: i32, num_groups_z: i32) void {
    scb_dispatch(cb, num_groups_x, num_groups_y, num_groups_z);
}

/// query command buffer resource state (valid or failed)
extern fn scb_query_cmdbuf_state(Cmdbuf) ResourceState;

/// query command buffer resource state (valid or failed)
pub fn queryCmdbufState(cb: Cmdbuf) ResourceState {
    return scb_query_cmdbuf_state(cb);
}

/// query current command buffer properties
extern fn scb_query_cmdbuf_info(Cmdbuf) CmdbufInfo;

/// query current command buffer properties
pub fn queryCmdbufInfo(cb: Cmdbuf) CmdbufInfo {
    return scb_query_cmdbuf_info(cb);
}

