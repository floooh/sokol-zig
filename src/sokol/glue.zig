// machine generated, do not edit

//
// sokol_glue.h -- glue helper functions for sokol headers
//
// Project URL: https://github.com/floooh/sokol
//
// Do this:
//     #define SOKOL_IMPL or
//     #define SOKOL_GLUE_IMPL
// before you include this file in *one* C or C++ file to create the
// implementation.
//
// ...optionally provide the following macros to override defaults:
//
// SOKOL_ASSERT(c)     - your own assert macro (default: assert(c))
// SOKOL_GLUE_API_DECL - public function declaration prefix (default: extern)
// SOKOL_API_DECL      - same as SOKOL_GLUE_API_DECL
// SOKOL_API_IMPL      - public function implementation prefix (default: -)
//
// If sokol_glue.h is compiled as a DLL, define the following before
// including the declaration or implementation:
//
// SOKOL_DLL
//
// On Windows, SOKOL_DLL will define SOKOL_GLUE_API_DECL as __declspec(dllexport)
// or __declspec(dllimport) as needed.
//
// OVERVIEW
// ========
// sokol_glue.h provides glue helper functions between sokol_gfx.h and sokol_app.h,
// so that sokol_gfx.h doesn't need to depend on sokol_app.h but can be
// used with different window system glue libraries.
//
// PROVIDED FUNCTIONS
// ==================
//
// sg_environment sglue_environment(void)
//
//     Returns an sg_environment struct initialized by calling sokol_app.h
//     functions. Use this in the sg_setup() call like this:
//
//     sg_setup(&(sg_desc){
//         .environment = sglue_environment(),
//         ...
//     });
//
// sg_swapchain sglue_swapchain(void)
//
//     Returns an sg_swapchain struct initialized by calling sokol_app.h
//     functions. Use this in sg_begin_pass() for a 'swapchain pass' like
//     this:
//
//     sg_begin_pass(&(sg_pass){ .swapchain = sglue_swapchain(), ... });
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
extern fn sglue_environment() sg.Environment;

pub fn environment() sg.Environment {
    return sglue_environment();
}

extern fn sglue_swapchain() sg.Swapchain;

pub fn swapchain() sg.Swapchain {
    return sglue_swapchain();
}

