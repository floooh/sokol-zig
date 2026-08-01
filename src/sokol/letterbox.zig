// machine generated, do not edit

//
// sokol_letterbox.h -- provide fixed-aspect viewport for random-aspect framebuffer
//
// Project URL: https://github.com/floooh/sokol
//
// Optionally provide the following defines with your own implementations:
//
// SOKOL_ASSERT(c)     - your own assert macro (default: assert(c))
// SOKOL_LETTERBOX_API_DECL - public function declaration prefix (default: extern)
// SOKOL_API_DECL      - same as SOKOL_LETTERBOX_API_DECL
// SOKOL_API_IMPL      - public function implementation prefix (default: -)
//
// If sokol_letterbox.h is compiled as a DLL, define the following before
// including the declaration or implementation:
//
// SOKOL_DLL
//
// WHAT
// ====
// Computes viewport parameters to render fixed-aspect content in a variable-aspect
// framebuffer (e.g. position a 16:9 frame in a randomly sized window) - commonly
// known as 'letterboxing'.
//
// Check the WASM example here:
//
//     https://floooh.github.io/sokol-html5/letterbox-sapp.html
//
// HOW
// ===
// Just call slbx_letterbox() and plug the result into sg_apply_viewport().
//
// Takes a framebuffer width/height as input and a pointer to an slbx_letterbox_desc
// struct:
//
// ```c
// int w = sapp_width();
// int h = sapp_height();
// slbx_viewport vp = slbx_letterbox(w, h, &(slbx_letterbox_desc){
//     .content_aspect_ratio = 16.0f / 9.0f,
// });
// ```
//
// ...then plug the resulting viewport parameters into `sg_apply_viewport()` (or
// a similar viewport function).
//
// ```c
// sg_apply_viewport(vp.x, vp.y, vp.width, vp.height, true);
// ```
//
// You can define a 'safe border' in pixels:
// ```c
// slbx_viewport vp = slbx_letterbox(w, h, &(slbx_letterbox_desc){
//     .content_aspect_ratio = 16.0f / 9.0f,
//     .border = {
//         .left = 10,
//         .right = 10,
//         .top = 10,
//         .bottom = 10,
//     },
// });
// ```
//
// ...and finally you can anchor the content so that it sticks to an edge
// of the framebuffer (the default behaviour is to center the content):
//
// ```c
// slbx_viewport vp = slbx_letterbox(w, h, &(slbx_letterbox_desc){
//     .content_aspect_ratio = 16.0f / 9.0f,
//     .anchor = SLBX_ANCHOR_TOP,
//     .border = {
//         .left = 10,
//         .right = 10,
//         .top = 10,
//         .bottom = 10,
//     },
// });
// ```
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

// helper function to convert a C string to a Zig string slice
fn cStrToZig(c_str: [*c]const u8) [:0]const u8 {
    return @import("std").mem.span(c_str);
}
/// Defines a 'safe border' in pixels. Used as nested struct
/// in slbx_letterbox_desc.
pub const Border = extern struct {
    left: i32 = 0,
    right: i32 = 0,
    top: i32 = 0,
    bottom: i32 = 0,
};

/// Anchor the content to a side. The default is to center the content.
/// Used in slbx_letterbox_desc.
pub const Anchor = enum(i32) {
    CENTER = 0,
    TOP,
    BOTTOM,
    LEFT,
    RIGHT,
};

/// The content letterbox description. Used as input to the
/// slbx_letterbox() function.
pub const LetterboxDesc = extern struct {
    content_aspect_ratio: f32 = 0.0,
    anchor: Anchor = .CENTER,
    border: Border = .{},
};

/// The resulting viewport. Return value of slbx_letterbox()
pub const Viewport = extern struct {
    x: i32 = 0,
    y: i32 = 0,
    width: i32 = 0,
    height: i32 = 0,
};

/// compute viewport for 'letterboxing' fixed-aspect content in a variable-aspect framebuffer
extern fn slbx_letterbox(i32, i32, [*c]const LetterboxDesc) Viewport;

/// compute viewport for 'letterboxing' fixed-aspect content in a variable-aspect framebuffer
pub fn letterbox(width: i32, height: i32, desc: LetterboxDesc) Viewport {
    return slbx_letterbox(width, height, &desc);
}

