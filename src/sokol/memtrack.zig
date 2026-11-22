// machine generated, do not edit

//
// sokol_memtrack.h -- memory allocation wrapper to track memory usage
//                     of sokol libraries
//
// Project URL: https://github.com/floooh/sokol
//
// Optionally provide the following defines with your own implementations:
//
// SOKOL_MEMTRACK_API_DECL - public function declaration prefix (default: extern)
// SOKOL_API_DECL      - same as SOKOL_MEMTRACK_API_DECL
// SOKOL_API_IMPL      - public function implementation prefix (default: -)
//
// If sokol_memtrack.h is compiled as a DLL, define the following before
// including the declaration or implementation:
//
// SOKOL_DLL
//
// USAGE
// =====
// Just plug the malloc/free wrapper functions into the desc.allocator
// struct provided by most sokol header setup functions:
//
//     sg_setup(&(sg_desc){
//         //...
//         .allocator = {
//             .alloc_fn = smemtrack_alloc,
//             .free_fn = smemtrack_free,
//         }
//     });
//
// Then call smemtrack_info() to get information about current number
// of allocations and overall allocation size:
//
//     const smemtrack_info_t info = smemtrack_info();
//     const int num_allocs = info.num_allocs;
//     const int num_bytes = info.num_bytes;
//
// Note the sokol_memtrack.h can only track allocations issued by
// the sokol headers, not allocations that happen under the hood
// in system libraries.
//
// LICENSE
// =======
//
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

// helper function to convert a C string to a Zig string slice
fn cStrToZig(c_str: [*c]const u8) [:0]const u8 {
    return @import("std").mem.span(c_str);
}
pub const Info = extern struct {
    num_allocs: i32 = 0,
    num_bytes: i32 = 0,
};

extern fn smemtrack_info() Info;

pub fn info() Info {
    return smemtrack_info();
}

extern fn smemtrack_alloc(usize, ?*anyopaque) ?*anyopaque;

pub const alloc = smemtrack_alloc;
extern fn smemtrack_free(?*anyopaque, ?*anyopaque) void;

pub const free = smemtrack_free;
