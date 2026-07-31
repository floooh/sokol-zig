// machine generated, do not edit

//
// sokol_framebuffer.h -- pixel framebuffer for CPU rendering
//
// Project URL: https://github.com/floooh/sokol
//
// Optionally provide the following defines with your own implementations:
//
// SOKOL_ASSERT(c)     - your own assert macro (default: assert(c))
// SOKOL_FRAMEBUFFER_API_DECL - public function declaration prefix (default: extern)
// SOKOL_API_DECL      - same as SOKOL_FRAMEBUFFER_API_DECL
// SOKOL_API_IMPL      - public function implementation prefix (default: -)
//
// If sokol_framebuffer.h is compiled as a DLL, define the following before
// including the declaration or implementation:
//
// SOKOL_DLL
//
// NOTE: the implementation is written in C99 and cannot be compiled in C++ mode,
// the declaration can be used from C++ though.
//
// WHAT
// ====
// Provides old-school pixel framebuffers for CPU rendering in two pixel format:
//
// - direct RGBA8 (32 bits per pixel)
// - 8-bits per pixel indexing a 256-entry RGBA8 color palette
//
// HOW
// ===
// First initialize sokol_framebuffer.h via:
//
//     sfb_setup(&(sfb_desc){
//         .logger.func = slog_func,
//     });
//
// If you need more than 8 framebuffers at the same time, increase the
// framebuffer pool:
//
//     sfb_setup(&(sfb_desc){
//         .framebuffer_pool_size = 129,
//         .logger.func = slog_func,
//     });
//
// You can also provide a custom allocator:
//
//     sfb_setup(&(sfb_desc){
//         .framebuffer_pool_size = 129,
//         .allocator = {
//             .alloc_fn = my_malloc,
//             .free_fn = my_free,
//             .user_data = my_user_data,
//         }
//         .logger.func = slog_func,
//     });
//
// Next, create one or more framebuffers. You need to provide at least
// a width and height:
//
//     sfb_framebuffer fb = sfb_make_framebuffer(&(sfb_framebuffer_desc){
//         .width = 320,
//         .height = 256,
//     });
//
// By default this creates an RGBA8 framebuffer. To get the paletted format
// (1 byte per pixel and 256 color palette entries):
//
//     sfb_framebuffer fb = sfb_make_framebuffer(&(sfb_framebuffer_desc){
//         .width = 320,
//         .height = 256,
//         .format = SFB_FORMAT_PALETTE8,
//     });
//
// You can also provide a 'prescale factor'. This allows to balance
// pixel crispiness against bluriness. E.g. if you want your final rendered
// framebuffer to look less blurry but not quite have the harsh look
// of nearest filtering, try a prescale factor of 2:
//
//     sfb_framebuffer fb = sfb_make_framebuffer(&(sfb_framebuffer_desc){
//         .width = 320,
//         .height = 256,
//         .format = SFB_FORMAT_PALETTE8,
//         .prescale = 2,
//     });
//
// You can rotate the framebuffer by 90 degrees, this is mainly useful to
// emulate some classic arcade machines where a regular 4:3 CRT was installed
// in 'portrait mode':
//
//     sfb_framebuffer fb = sfb_make_framebuffer(&(sfb_framebuffer_desc){
//         .width = 320,
//         .height = 256,
//         .format = SFB_FORMAT_PALETTE8,
//         .prescale = 2,
//         .rotate90 = true,
//     });
//
// You can define a sub-rectangle of the framebuffer to be rendered. For instance
// to only render the upper-left quadrant of a 320x256 framebuffer:
//
//     sfb_framebuffer fb = sfb_make_framebuffer(&(sfb_framebuffer_desc){
//         .width = 512
//         .height = 512,
//         .format = SFB_FORMAT_PALETTE8,
//         .prescale = 2,
//         .rotate90 = true,
//         .cliprect = {
//             .x = 0,
//             .y = 0,
//             .width = 160,
//             .height = 128,
//         }
//     });
//
// Finally if you plan to render the framebuffer in a render pass with different
// properties than the default swapchain format, you'll need to provide
// a color- and depth-pixelformat and a sample count which matches the
// properties of the render pass:
//
//     sfb_framebuffer fb = sfb_make_framebuffer(&(sfb_framebuffer_desc){
//         .width = 320,
//         .height = 256,
//         .format = SFB_FORMAT_PALETTE8,
//         .prescale = 2,
//         .rotate90 = true,
//         .render_pass = {
//             .color_format = SG_PIXELFORMAT_...
//             .depth_format = SG_PIXELFORMAT_...
//             .sample_count = ...,
//         },
//     });
//
// The actual pixel buffer and color palette are owned by you. For a 320x256
// framebuffer with 32-bits per pixel (SFB_FORMAT_RGBA8), use an uint32_t
// buffer like this:
//
//     uint32_t pixels[256][320];
//
// For the paletted format (1 byte per pixel and a 256 entry color palette):
//
//     uint8_t pixels[256][320];
//     uint32_t palette[256];
//
// ...now 'render' into the pixel and palette buffers with the CPU.
//
// An RGBA8 pixel or palette entry split into red, green, blue, alpha like this:
//
//     |AAAAAAAA|BBBBBBBB|GGGGGGGG|RRRRRRRR|
//
// E.g. bits 24 to 31 are the alpha component, bits 16 to 23 the blue component,
// bits 8 to 15 to green component and bits 0 to 7 the red component. Or typically:
//
//     uint8_t a = 255;
//     uint8_t r = ...;
//     uint8_t g = ...;
//     uint8_t b = ...;
//     uint32 pixel = (a << 24) | (b << 16) | (g << 8) | r;
//
// Whenever the pixel buffer or color palette content changes, call sfb_update()
// outside a sokol-gfx render pass, and ONLY ONCE PER FRAME at most:
//
//     sfb_update(fb, &(sfb_update_desc){
//         .pixels = SG_RANGE(pixels),
//         .palette = SG_RANGE(palette),
//     });
//
// Of course for an RGBA8 framebuffer you'd only provide the pixels:
//
//     sfb_update(fb, &(sfb_update_desc){
//         .pixels = SG_RANGE(pixels),
//     });
//
// ...but even for a paletted framebuffer you can omit the data that doesn't
// change. E.g. when only the palette changes but not the pixel data:
//
//     sfb_update(fb, &(sfb_update_desc){
//         .palette = SG_RANGE(palette),
//     });
//
// ...or vice versa when only the pixels but not the palette entries change:
//
//     sfb_update(fb, &(sfb_update_desc){
//         .pixels = SG_RANGE(pixels),
//     });
//
// The sfb_update() function will do up to two calls to the sokol-gfx
// function sg_update_image() - once for the pixel data and once for the
// palette data (this is why the function must only be called at most
// once per frame), and then do an render pass into an internal color attachment
// texture (this is why the function must be called outside any sokol-gfx
// pass).
//
// Finally, to render your framebuffer to the display, call sfb_render()
// *inside* a sokol-gfx render pass:
//
//     sg_begin_pass(...);
//     sfb_render(fb);
//     ...
//     sg_end_pass();
//
// This will stretch the framebuffer to the whole canvas which might distort
// its aspect ratio. If you want a fixed aspect ratio consider setting a
// viewport with the help of sokol_letterbox.h.
//
// For more control over the rendering process, call sfb_render_ex() instead.
// For instance to override the default sampler with linear filtering and
// instead use a builtin sampler with nearest filtering:
//
//     sfb_render_ex(fb, &(sfb_render_desc){
//         .use_nearest_filter = true,
//     });
//
// Note though that the prescale factor provided in the sfb_make_framebuffer()
// call is a better way to tweak bluriness vs crispiness. Only use the
// nearest-filter override if you want a 100% pixelized look.
//
// The main purpose of sfb_render_ex() is to inject a more advanced shader though
// (like a CRT shader).
//
// TODO: refer to a future sokol_crt.h header.
//
// If any of the sizing properties of the framebuffer changes, call:
//
//     bool size_changed = sfb_resize(fb, &(sfb_resize_desc){
//         .width = new_width,
//         .height = new_height,
//         .prescale = new_prescale,
//         .cliprect = new_cliprect
//     });
//
// The sfb_resize() function is 'lazy', it will only destroy and recreate internal
// objects when actually needed (e.g. the size of image objects has changed). In
// that case, true is returned. When the function returns false, it was
// basically a cheap no-op.
//
// If you want to do the final rendering entirely yourself you can get handles
// to all the internally used resources of a framebuffer object via:
//
//     sfb_framebuffer_info info = sfb_query_framebuffer_info(fb);
//
// This returns handles to all internal image, view and sampler objects
// as well as image sizes and pixel formats.
//
// To query the current 'resource state' of a framebuffer:
//
//     sfb_resoure_state state = sfb_query_framebuffer_state(fb);
//
// ...this is mainly useful to check whether framebuffer creation via
// sfb_make_framebuffer() had failed.
//
// To get a copy the the sfb_framebuffer_desc struct (patched with defaults)
// of a framebuffer object:
//
//     sfb_framebuffer_desc desc = sfb_query_framebuffer_desc(fb);
//
// To destroy a framebuffer object:
//
//     sfb_destroy_framebuffer(fb);
//
// ...calling sfb_shutdown() will also destroy any remaining framebuffer
// objects:
//
//     sfb_shutdown();
//
//
// LICENSE
// =======
//
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
/// Public constants.
pub const invalid_id = 0;

/// sfb_framebuffer
///
/// A framebuffer handle, created with sfb_make_framebuffer(), destroyed
/// with sfb_destroy_framebuffer()
pub const Framebuffer = extern struct {
    id: u32 = 0,
};

/// sfb_resource_state
///
/// The state of a framebuffer object, obtainable via sfg_query_framebuffer_state().
/// Publicly visible values are only SFB_RESOURCESTATE_VALID
/// and SFB_RESOURCESTATE_FAILED.
pub const ResourceState = enum(i32) {
    INITIAL,
    ALLOC,
    VALID,
    FAILED,
    INVALID,
};

/// sfb_format
///
/// The framebuffer pixel format. Either RGBA8 direct color where each
/// pixel is an uint32_t, or paletted format with uint8_t pixels as
/// index into a 256 entry color palette.
pub const Format = enum(i32) {
    DEFAULT = 0,
    RGBA8,
    PALETTE8,
};

/// sfb_rect
///
/// Used as clipping rectangle in struct sfb_framebuffer_desc
/// and sfb_resize_desc.
pub const Rect = extern struct {
    x: i32 = 0,
    y: i32 = 0,
    width: i32 = 0,
    height: i32 = 0,
};

/// sfb_render_pass_desc
///
/// Describes render pass properties in an sfb_framebuffer_desc (color-
/// and depth-pixel-format, sample count). This is used to create the
/// sg_pipeline objects applied in the render functions. When rendering
/// to a default swapchain all the values can remain at default (zero).
pub const RenderPassDesc = extern struct {
    color_format: sg.PixelFormat = .DEFAULT,
    depth_format: sg.PixelFormat = .DEFAULT,
    sample_count: i32 = 0,
};

/// sfb_framebuffer_desc
///
/// Creation parameters for a framebuffer object. Passed into
/// sfb_make_framebuffer().
pub const FramebufferDesc = extern struct {
    width: i32 = 0,
    height: i32 = 0,
    prescale: i32 = 0,
    format: Format = .DEFAULT,
    cliprect: Rect = .{},
    rotate90: bool = false,
    render_pass: RenderPassDesc = .{},
};

/// sfb_resize_desc
///
/// Parameters for sfb_resize(). Needs to be called before sfb_update() in a
/// frame if with potentially new framebuffer size parameters or clipping
/// rectangle. Note that the sfb_resize() function can be called even when no
/// resizing needs to happen, in that case the function will be a silent no-op
/// and return false. When the function returns true this means that internal
/// image objects had been recreated and need to be repopulated again via
/// sfb_update()
///
/// Resizing is slightly cheaper than destroying and creating the frambuffer
/// because only image objects needs to be re-created, but no pipeline objects.
pub const ResizeDesc = extern struct {
    width: i32 = 0,
    height: i32 = 0,
    prescale: i32 = 0,
    cliprect: Rect = .{},
};

/// sfb_update_desc
///
/// Passed into sfb_update() to update the pixel-date and/or color-palette-data
/// The sfb_update() function should only be called when any of the above
/// actually changes, at most once per frame, and outside any sokol-gfx pass.
pub const UpdateDesc = extern struct {
    pixels: sg.Range = .{},
    palette: sg.Range = .{},
};

/// sfb_render_overrides
///
/// Passed into sfb_render_ex() to override the default shader. Mainly
/// useful to inject custom shaders (like CRT shaders).
///
/// TODO: add more details once sokol_crt.h is ready.
pub const RenderDesc = extern struct {
    use_nearest_filter: bool = false,
    pip: sg.Pipeline = .{},
    views: [32]sg.View = @splat(.{}),
    samplers: [12]sg.Sampler = @splat(.{}),
    uniforms: [8]sg.Range = @splat(.{}),
};

/// sfb_texture_info
///
/// Nested struct in sfb_framebuffer_info to describe the properties of
/// an internal image/view pair.
pub const TextureInfo = extern struct {
    width: i32 = 0,
    height: i32 = 0,
    pixel_format: sg.PixelFormat = .DEFAULT,
    image: sg.Image = .{},
    tex_view: sg.View = .{},
};

/// sfb_framebuffer_info
///
/// Result of sfb_query_framebuffer_info(), returns handles to the internally
/// managed images, texture views and samplers, image sizes and pixel formats.
/// This is mostly useful when completely replacing the sfb_render[_ex]()
/// functions with a complete custom implementation (like a CRT shader which
/// requires multiple render passes).
pub const FramebufferInfo = extern struct {
    update: TextureInfo = .{},
    offscreen: TextureInfo = .{},
    palette: TextureInfo = .{},
    nearest_sampler: sg.Sampler = .{},
    linear_sampler: sg.Sampler = .{},
};

/// sfb_allocator
///
/// Used in sfb_desc to provide custom memory-alloc and -free functions
/// to sokol_framebuffer.h. If memory management should be overridden, both the
/// alloc and free function must be provided (e.g. it's not valid to
/// override one function but not the other).
pub const Allocator = extern struct {
    alloc_fn: ?*const fn (usize, ?*anyopaque) callconv(.c) ?*anyopaque = null,
    free_fn: ?*const fn (?*anyopaque, ?*anyopaque) callconv(.c) void = null,
    user_data: ?*anyopaque = null,
};

/// sfb_logger
///
/// Used in sfb_desc to provide a custom logging and error reporting
/// callback to sokol_framebuffer.h.
pub const Logger = extern struct {
    func: ?*const fn ([*c]const u8, u32, u32, [*c]const u8, u32, [*c]const u8, ?*anyopaque) callconv(.c) void = null,
    user_data: ?*anyopaque = null,
};

/// Initialization parameters passed into sfb_setup(). You should at least
/// provide a logging function, otherwise you won't see any error logging.
pub const Desc = extern struct {
    framebuffer_pool_size: i32 = 0,
    allocator: Allocator = .{},
    logger: Logger = .{},
};

/// setup sokol-framebuffer
extern fn sfb_setup([*c]const Desc) void;

/// setup sokol-framebuffer
pub fn setup(desc: Desc) void {
    sfb_setup(&desc);
}

/// shutdown sokol-framebuffer
extern fn sfb_shutdown() void;

/// shutdown sokol-framebuffer
pub fn shutdown() void {
    sfb_shutdown();
}

/// create a framebuffer object
extern fn sfb_make_framebuffer([*c]const FramebufferDesc) Framebuffer;

/// create a framebuffer object
pub fn makeFramebuffer(desc: FramebufferDesc) Framebuffer {
    return sfb_make_framebuffer(&desc);
}

/// destroy framebuffer object
extern fn sfb_destroy_framebuffer(Framebuffer) void;

/// destroy framebuffer object
pub fn destroyFramebuffer(fb: Framebuffer) void {
    sfb_destroy_framebuffer(fb);
}

/// resize internal images (no-op if resize isn't needed), return true when images had to be re-created
extern fn sfb_resize(Framebuffer, [*c]const ResizeDesc) bool;

/// resize internal images (no-op if resize isn't needed), return true when images had to be re-created
pub fn resize(fb: Framebuffer, desc: ResizeDesc) bool {
    return sfb_resize(fb, &desc);
}

/// update framebuffer and/or color palette content (must be called outside any sokol-gfx pass)
extern fn sfb_update(Framebuffer, [*c]const UpdateDesc) void;

/// update framebuffer and/or color palette content (must be called outside any sokol-gfx pass)
pub fn update(fb: Framebuffer, desc: UpdateDesc) void {
    sfb_update(fb, &desc);
}

/// draw framebuffer content with default shader (must be called inside a sokol-gfx render pass)
extern fn sfb_render(Framebuffer) void;

/// draw framebuffer content with default shader (must be called inside a sokol-gfx render pass)
pub fn render(fb: Framebuffer) void {
    sfb_render(fb);
}

/// draw framebuffer content with injected shader (must be called inside a sokol-gfx render pass)
extern fn sfb_render_ex(Framebuffer, [*c]const RenderDesc) void;

/// draw framebuffer content with injected shader (must be called inside a sokol-gfx render pass)
pub fn renderEx(fb: Framebuffer, desc: RenderDesc) void {
    sfb_render_ex(fb, &desc);
}

/// query framebuffer resource state (valid or failed)
extern fn sfb_query_framebuffer_state(Framebuffer) ResourceState;

/// query framebuffer resource state (valid or failed)
pub fn queryFramebufferState(fb: Framebuffer) ResourceState {
    return sfb_query_framebuffer_state(fb);
}

/// query current framebuffer properties
extern fn sfb_query_framebuffer_info(Framebuffer) FramebufferInfo;

/// query current framebuffer properties
pub fn queryFramebufferInfo(fb: Framebuffer) FramebufferInfo {
    return sfb_query_framebuffer_info(fb);
}

/// query the framebuffer desc, with default values patched in
extern fn sfb_query_framebuffer_desc(Framebuffer) FramebufferDesc;

/// query the framebuffer desc, with default values patched in
pub fn queryFramebufferDesc(fb: Framebuffer) FramebufferDesc {
    return sfb_query_framebuffer_desc(fb);
}

