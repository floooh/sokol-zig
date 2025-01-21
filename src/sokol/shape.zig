// machine generated, do not edit

//
// sokol_shape.h -- create simple primitive shapes for sokol_gfx.h
//
// Project URL: https://github.com/floooh/sokol
//
// Do this:
//     #define SOKOL_IMPL or
//     #define SOKOL_SHAPE_IMPL
// before you include this file in *one* C or C++ file to create the
// implementation.
//
// Include the following headers before including sokol_shape.h:
//
//     sokol_gfx.h
//
// ...optionally provide the following macros to override defaults:
//
// SOKOL_ASSERT(c)     - your own assert macro (default: assert(c))
// SOKOL_SHAPE_API_DECL- public function declaration prefix (default: extern)
// SOKOL_API_DECL      - same as SOKOL_SHAPE_API_DECL
// SOKOL_API_IMPL      - public function implementation prefix (default: -)
//
// If sokol_shape.h is compiled as a DLL, define the following before
// including the declaration or implementation:
//
// SOKOL_DLL
//
// On Windows, SOKOL_DLL will define SOKOL_SHAPE_API_DECL as __declspec(dllexport)
// or __declspec(dllimport) as needed.
//
// FEATURE OVERVIEW
// ================
// sokol_shape.h creates vertices and indices for simple shapes and
// builds structs which can be plugged into sokol-gfx resource
// creation functions:
//
// The following shape types are supported:
//
//     - plane
//     - cube
//     - sphere (with poles, not geodesic)
//     - cylinder
//     - torus (donut)
//
// Generated vertices look like this:
//
//     typedef struct sshape_vertex_t {
//         float x, y, z;
//         uint32_t normal;        // packed normal as BYTE4N
//         uint16_t u, v;          // packed uv coords as USHORT2N
//         uint32_t color;         // packed color as UBYTE4N (r,g,b,a);
//     } sshape_vertex_t;
//
// Indices are generally 16-bits wide (SG_INDEXTYPE_UINT16) and the indices
// are written as triangle-lists (SG_PRIMITIVETYPE_TRIANGLES).
//
// EXAMPLES:
// =========
//
// Create multiple shapes into the same vertex- and index-buffer and
// render with separate draw calls:
//
// https://github.com/floooh/sokol-samples/blob/master/sapp/shapes-sapp.c
//
// Same as the above, but pre-transform shapes and merge them into a single
// shape that's rendered with a single draw call.
//
// https://github.com/floooh/sokol-samples/blob/master/sapp/shapes-transform-sapp.c
//
// STEP-BY-STEP:
// =============
//
// Setup an sshape_buffer_t struct with pointers to memory buffers where
// generated vertices and indices will be written to:
//
// ```c
// sshape_vertex_t vertices[512];
// uint16_t indices[4096];
//
// sshape_buffer_t buf = {
//     .vertices = {
//         .buffer = SSHAPE_RANGE(vertices),
//     },
//     .indices = {
//         .buffer = SSHAPE_RANGE(indices),
//     }
// };
// ```
//
// To find out how big those memory buffers must be (in case you want
// to allocate dynamically) call the following functions:
//
// ```c
// sshape_sizes_t sshape_plane_sizes(uint32_t tiles);
// sshape_sizes_t sshape_box_sizes(uint32_t tiles);
// sshape_sizes_t sshape_sphere_sizes(uint32_t slices, uint32_t stacks);
// sshape_sizes_t sshape_cylinder_sizes(uint32_t slices, uint32_t stacks);
// sshape_sizes_t sshape_torus_sizes(uint32_t sides, uint32_t rings);
// ```
//
// The returned sshape_sizes_t struct contains vertex- and index-counts
// as well as the equivalent buffer sizes in bytes. For instance:
//
// ```c
// sshape_sizes_t sizes = sshape_sphere_sizes(36, 12);
// uint32_t num_vertices = sizes.vertices.num;
// uint32_t num_indices = sizes.indices.num;
// uint32_t vertex_buffer_size = sizes.vertices.size;
// uint32_t index_buffer_size = sizes.indices.size;
// ```
//
// With the sshape_buffer_t struct that was setup earlier, call any
// of the shape-builder functions:
//
// ```c
// sshape_buffer_t sshape_build_plane(const sshape_buffer_t* buf, const sshape_plane_t* params);
// sshape_buffer_t sshape_build_box(const sshape_buffer_t* buf, const sshape_box_t* params);
// sshape_buffer_t sshape_build_sphere(const sshape_buffer_t* buf, const sshape_sphere_t* params);
// sshape_buffer_t sshape_build_cylinder(const sshape_buffer_t* buf, const sshape_cylinder_t* params);
// sshape_buffer_t sshape_build_torus(const sshape_buffer_t* buf, const sshape_torus_t* params);
// ```
//
// Note how the sshape_buffer_t struct is both an input value and the
// return value. This can be used to append multiple shapes into the
// same vertex- and index-buffers (more on this later).
//
// The second argument is a struct which holds creation parameters.
//
// For instance to build a sphere with radius 2, 36 "cake slices" and 12 stacks:
//
// ```c
// sshape_buffer_t buf = ...;
// buf = sshape_build_sphere(&buf, &(sshape_sphere_t){
//     .radius = 2.0f,
//     .slices = 36,
//     .stacks = 12,
// });
// ```
//
// If the provided buffers are big enough to hold all generated vertices and
// indices, the "valid" field in the result will be true:
//
// ```c
// assert(buf.valid);
// ```
//
// The shape creation parameters have "useful defaults", refer to the
// actual C struct declarations below to look up those defaults.
//
// You can also provide additional creation parameters, like a common vertex
// color, a debug-helper to randomize colors, tell the shape builder function
// to merge the new shape with the previous shape into the same draw-element-range,
// or a 4x4 transform matrix to move, rotate and scale the generated vertices:
//
// ```c
// sshape_buffer_t buf = ...;
// buf = sshape_build_sphere(&buf, &(sshape_sphere_t){
//     .radius = 2.0f,
//     .slices = 36,
//     .stacks = 12,
//     // merge with previous shape into a single element-range
//     .merge = true,
//     // set vertex color to red+opaque
//     .color = sshape_color_4f(1.0f, 0.0f, 0.0f, 1.0f),
//     // set position to y = 2.0
//     .transform = {
//         .m = {
//             { 1.0f, 0.0f, 0.0f, 0.0f },
//             { 0.0f, 1.0f, 0.0f, 0.0f },
//             { 0.0f, 0.0f, 1.0f, 0.0f },
//             { 0.0f, 2.0f, 0.0f, 1.0f },
//         }
//     }
// });
// assert(buf.valid);
// ```
//
// The following helper functions can be used to build a packed
// color value or to convert from external matrix types:
//
// ```c
// uint32_t sshape_color_4f(float r, float g, float b, float a);
// uint32_t sshape_color_3f(float r, float g, float b);
// uint32_t sshape_color_4b(uint8_t r, uint8_t g, uint8_t b, uint8_t a);
// uint32_t sshape_color_3b(uint8_t r, uint8_t g, uint8_t b);
// sshape_mat4_t sshape_mat4(const float m[16]);
// sshape_mat4_t sshape_mat4_transpose(const float m[16]);
// ```
//
// After the shape builder function has been called, the following functions
// are used to extract the build result for plugging into sokol_gfx.h:
//
// ```c
// sshape_element_range_t sshape_element_range(const sshape_buffer_t* buf);
// sg_buffer_desc sshape_vertex_buffer_desc(const sshape_buffer_t* buf);
// sg_buffer_desc sshape_index_buffer_desc(const sshape_buffer_t* buf);
// sg_vertex_buffer_layout_state sshape_vertex_buffer_layout_state(void);
// sg_vertex_attr_state sshape_position_vertex_attr_state(void);
// sg_vertex_attr_state sshape_normal_vertex_attr_state(void);
// sg_vertex_attr_state sshape_texcoord_vertex_attr_state(void);
// sg_vertex_attr_state sshape_color_vertex_attr_state(void);
// ```
//
// The sshape_element_range_t struct contains the base-index and number of
// indices which can be plugged into the sg_draw() call:
//
// ```c
// sshape_element_range_t elms = sshape_element_range(&buf);
// ...
// sg_draw(elms.base_element, elms.num_elements, 1);
// ```
//
// To create sokol-gfx vertex- and index-buffers from the generated
// shape data:
//
// ```c
// // create sokol-gfx vertex buffer
// sg_buffer_desc vbuf_desc = sshape_vertex_buffer_desc(&buf);
// sg_buffer vbuf = sg_make_buffer(&vbuf_desc);
//
// // create sokol-gfx index buffer
// sg_buffer_desc ibuf_desc = sshape_index_buffer_desc(&buf);
// sg_buffer ibuf = sg_make_buffer(&ibuf_desc);
// ```
//
// The remaining functions are used to populate the vertex-layout item
// in sg_pipeline_desc, note that these functions don't depend on the
// created geometry, they always return the same result:
//
// ```c
// sg_pipeline pip = sg_make_pipeline(&(sg_pipeline_desc){
//     .layout = {
//         .buffers[0] = sshape_vertex_buffer_layout_state(),
//         .attrs = {
//             [0] = sshape_position_vertex_attr_state(),
//             [1] = ssape_normal_vertex_attr_state(),
//             [2] = sshape_texcoord_vertex_attr_state(),
//             [3] = sshape_color_vertex_attr_state()
//         }
//     },
//     ...
// });
// ```
//
// Note that you don't have to use all generated vertex attributes in the
// pipeline's vertex layout, the sg_vertex_buffer_layout_state struct returned
// by sshape_vertex_buffer_layout_state() contains the correct vertex stride
// to skip vertex components.
//
// WRITING MULTIPLE SHAPES INTO THE SAME BUFFER
// ============================================
// You can merge multiple shapes into the same vertex- and
// index-buffers and either render them as a single shape, or
// in separate draw calls.
//
// To build a single shape made of two cubes which can be rendered
// in a single draw-call:
//
// ```
// sshape_vertex_t vertices[128];
// uint16_t indices[16];
//
// sshape_buffer_t buf = {
//     .vertices.buffer = SSHAPE_RANGE(vertices),
//     .indices.buffer  = SSHAPE_RANGE(indices)
// };
//
// // first cube at pos x=-2.0 (with default size of 1x1x1)
// buf = sshape_build_cube(&buf, &(sshape_box_t){
//     .transform = {
//         .m = {
//             { 1.0f, 0.0f, 0.0f, 0.0f },
//             { 0.0f, 1.0f, 0.0f, 0.0f },
//             { 0.0f, 0.0f, 1.0f, 0.0f },
//             {-2.0f, 0.0f, 0.0f, 1.0f },
//         }
//     }
// });
// // ...and append another cube at pos pos=+1.0
// // NOTE the .merge = true, this tells the shape builder
// // function to not advance the current shape start offset
// buf = sshape_build_cube(&buf, &(sshape_box_t){
//     .merge = true,
//     .transform = {
//         .m = {
//             { 1.0f, 0.0f, 0.0f, 0.0f },
//             { 0.0f, 1.0f, 0.0f, 0.0f },
//             { 0.0f, 0.0f, 1.0f, 0.0f },
//             {-2.0f, 0.0f, 0.0f, 1.0f },
//         }
//     }
// });
// assert(buf.valid);
//
// // skipping buffer- and pipeline-creation...
//
// sshape_element_range_t elms = sshape_element_range(&buf);
// sg_draw(elms.base_element, elms.num_elements, 1);
// ```
//
// To render the two cubes in separate draw-calls, the element-ranges used
// in the sg_draw() calls must be captured right after calling the
// builder-functions:
//
// ```c
// sshape_vertex_t vertices[128];
// uint16_t indices[16];
// sshape_buffer_t buf = {
//     .vertices.buffer = SSHAPE_RANGE(vertices),
//     .indices.buffer = SSHAPE_RANGE(indices)
// };
//
// // build a red cube...
// buf = sshape_build_cube(&buf, &(sshape_box_t){
//     .color = sshape_color_3b(255, 0, 0)
// });
// sshape_element_range_t red_cube = sshape_element_range(&buf);
//
// // append a green cube to the same vertex-/index-buffer:
// buf = sshape_build_cube(&bud, &sshape_box_t){
//     .color = sshape_color_3b(0, 255, 0);
// });
// sshape_element_range_t green_cube = sshape_element_range(&buf);
//
// // skipping buffer- and pipeline-creation...
//
// sg_draw(red_cube.base_element, red_cube.num_elements, 1);
// sg_draw(green_cube.base_element, green_cube.num_elements, 1);
// ```
//
// ...that's about all :)
//
// LICENSE
// =======
// zlib/libpng license
//
// Copyright (c) 2020 Andre Weissflog
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
// helper function to convert "anything" to a Range struct
pub fn asRange(val: anytype) Range {
    const type_info = @typeInfo(@TypeOf(val));
    // FIXME: naming convention change between 0.13 and 0.14-dev
    if (@hasField(@TypeOf(type_info), "Pointer")) {
        switch (type_info) {
            .Pointer => {
                switch (type_info.Pointer.size) {
                    .One => return .{ .ptr = val, .size = @sizeOf(type_info.Pointer.child) },
                    .Slice => return .{ .ptr = val.ptr, .size = @sizeOf(type_info.Pointer.child) * val.len },
                    else => @compileError("FIXME: Pointer type!"),
                }
            },
            .Struct, .Array => {
                @compileError("Structs and arrays must be passed as pointers to asRange");
            },
            else => {
                @compileError("Cannot convert to range!");
            },
        }
    } else {
        switch (type_info) {
            .pointer => {
                switch (type_info.pointer.size) {
                    .one => return .{ .ptr = val, .size = @sizeOf(type_info.pointer.child) },
                    .slice => return .{ .ptr = val.ptr, .size = @sizeOf(type_info.pointer.child) * val.len },
                    else => @compileError("FIXME: Pointer type!"),
                }
            },
            .@"struct", .array => {
                @compileError("Structs and arrays must be passed as pointers to asRange");
            },
            else => {
                @compileError("Cannot convert to range!");
            },
        }
    }
}

/// sshape_range is a pointer-size-pair struct used to pass memory
/// blobs into sokol-shape. When initialized from a value type
/// (array or struct), use the SSHAPE_RANGE() macro to build
/// an sshape_range struct.
pub const Range = extern struct {
    ptr: ?*const anyopaque = null,
    size: usize = 0,
};

/// a 4x4 matrix wrapper struct
pub const Mat4 = extern struct {
    m: [4][4]f32 = [_][4]f32{[_]f32{0.0} ** 4} ** 4,
};

/// vertex layout of the generated geometry
pub const Vertex = extern struct {
    x: f32 = 0.0,
    y: f32 = 0.0,
    z: f32 = 0.0,
    normal: u32 = 0,
    u: u16 = 0,
    v: u16 = 0,
    color: u32 = 0,
};

/// a range of draw-elements (sg_draw(int base_element, int num_element, ...))
pub const ElementRange = extern struct {
    base_element: u32 = 0,
    num_elements: u32 = 0,
};

/// number of elements and byte size of build actions
pub const SizesItem = extern struct {
    num: u32 = 0,
    size: u32 = 0,
};

pub const Sizes = extern struct {
    vertices: SizesItem = .{},
    indices: SizesItem = .{},
};

/// in/out struct to keep track of mesh-build state
pub const BufferItem = extern struct {
    buffer: Range = .{},
    data_size: usize = 0,
    shape_offset: usize = 0,
};

pub const Buffer = extern struct {
    valid: bool = false,
    vertices: BufferItem = .{},
    indices: BufferItem = .{},
};

/// creation parameters for the different shape types
pub const Plane = extern struct {
    width: f32 = 0.0,
    depth: f32 = 0.0,
    tiles: u16 = 0,
    color: u32 = 0,
    random_colors: bool = false,
    merge: bool = false,
    transform: Mat4 = .{},
};

pub const Box = extern struct {
    width: f32 = 0.0,
    height: f32 = 0.0,
    depth: f32 = 0.0,
    tiles: u16 = 0,
    color: u32 = 0,
    random_colors: bool = false,
    merge: bool = false,
    transform: Mat4 = .{},
};

pub const Sphere = extern struct {
    radius: f32 = 0.0,
    slices: u16 = 0,
    stacks: u16 = 0,
    color: u32 = 0,
    random_colors: bool = false,
    merge: bool = false,
    transform: Mat4 = .{},
};

pub const Cylinder = extern struct {
    radius: f32 = 0.0,
    height: f32 = 0.0,
    slices: u16 = 0,
    stacks: u16 = 0,
    color: u32 = 0,
    random_colors: bool = false,
    merge: bool = false,
    transform: Mat4 = .{},
};

pub const Torus = extern struct {
    radius: f32 = 0.0,
    ring_radius: f32 = 0.0,
    sides: u16 = 0,
    rings: u16 = 0,
    color: u32 = 0,
    random_colors: bool = false,
    merge: bool = false,
    transform: Mat4 = .{},
};

/// shape builder functions
pub extern fn sshape_build_plane([*c]const Buffer, [*c]const Plane) Buffer;

/// shape builder functions
pub fn buildPlane(buf: Buffer, params: Plane) Buffer {
    return sshape_build_plane(&buf, &params);
}

pub extern fn sshape_build_box([*c]const Buffer, [*c]const Box) Buffer;

pub fn buildBox(buf: Buffer, params: Box) Buffer {
    return sshape_build_box(&buf, &params);
}

pub extern fn sshape_build_sphere([*c]const Buffer, [*c]const Sphere) Buffer;

pub fn buildSphere(buf: Buffer, params: Sphere) Buffer {
    return sshape_build_sphere(&buf, &params);
}

pub extern fn sshape_build_cylinder([*c]const Buffer, [*c]const Cylinder) Buffer;

pub fn buildCylinder(buf: Buffer, params: Cylinder) Buffer {
    return sshape_build_cylinder(&buf, &params);
}

pub extern fn sshape_build_torus([*c]const Buffer, [*c]const Torus) Buffer;

pub fn buildTorus(buf: Buffer, params: Torus) Buffer {
    return sshape_build_torus(&buf, &params);
}

/// query required vertex- and index-buffer sizes in bytes
pub extern fn sshape_plane_sizes(u32) Sizes;

/// query required vertex- and index-buffer sizes in bytes
pub fn planeSizes(tiles: u32) Sizes {
    return sshape_plane_sizes(tiles);
}

pub extern fn sshape_box_sizes(u32) Sizes;

pub fn boxSizes(tiles: u32) Sizes {
    return sshape_box_sizes(tiles);
}

pub extern fn sshape_sphere_sizes(u32, u32) Sizes;

pub fn sphereSizes(slices: u32, stacks: u32) Sizes {
    return sshape_sphere_sizes(slices, stacks);
}

pub extern fn sshape_cylinder_sizes(u32, u32) Sizes;

pub fn cylinderSizes(slices: u32, stacks: u32) Sizes {
    return sshape_cylinder_sizes(slices, stacks);
}

pub extern fn sshape_torus_sizes(u32, u32) Sizes;

pub fn torusSizes(sides: u32, rings: u32) Sizes {
    return sshape_torus_sizes(sides, rings);
}

/// extract sokol-gfx desc structs and primitive ranges from build state
pub extern fn sshape_element_range([*c]const Buffer) ElementRange;

/// extract sokol-gfx desc structs and primitive ranges from build state
pub fn elementRange(buf: Buffer) ElementRange {
    return sshape_element_range(&buf);
}

pub extern fn sshape_vertex_buffer_desc([*c]const Buffer) sg.BufferDesc;

pub fn vertexBufferDesc(buf: Buffer) sg.BufferDesc {
    return sshape_vertex_buffer_desc(&buf);
}

pub extern fn sshape_index_buffer_desc([*c]const Buffer) sg.BufferDesc;

pub fn indexBufferDesc(buf: Buffer) sg.BufferDesc {
    return sshape_index_buffer_desc(&buf);
}

pub extern fn sshape_vertex_buffer_layout_state() sg.VertexBufferLayoutState;

pub fn vertexBufferLayoutState() sg.VertexBufferLayoutState {
    return sshape_vertex_buffer_layout_state();
}

pub extern fn sshape_position_vertex_attr_state() sg.VertexAttrState;

pub fn positionVertexAttrState() sg.VertexAttrState {
    return sshape_position_vertex_attr_state();
}

pub extern fn sshape_normal_vertex_attr_state() sg.VertexAttrState;

pub fn normalVertexAttrState() sg.VertexAttrState {
    return sshape_normal_vertex_attr_state();
}

pub extern fn sshape_texcoord_vertex_attr_state() sg.VertexAttrState;

pub fn texcoordVertexAttrState() sg.VertexAttrState {
    return sshape_texcoord_vertex_attr_state();
}

pub extern fn sshape_color_vertex_attr_state() sg.VertexAttrState;

pub fn colorVertexAttrState() sg.VertexAttrState {
    return sshape_color_vertex_attr_state();
}

/// helper functions to build packed color value from floats or bytes
pub extern fn sshape_color_4f(f32, f32, f32, f32) u32;

/// helper functions to build packed color value from floats or bytes
pub fn color4f(r: f32, g: f32, b: f32, a: f32) u32 {
    return sshape_color_4f(r, g, b, a);
}

pub extern fn sshape_color_3f(f32, f32, f32) u32;

pub fn color3f(r: f32, g: f32, b: f32) u32 {
    return sshape_color_3f(r, g, b);
}

pub extern fn sshape_color_4b(u8, u8, u8, u8) u32;

pub fn color4b(r: u8, g: u8, b: u8, a: u8) u32 {
    return sshape_color_4b(r, g, b, a);
}

pub extern fn sshape_color_3b(u8, u8, u8) u32;

pub fn color3b(r: u8, g: u8, b: u8) u32 {
    return sshape_color_3b(r, g, b);
}

/// adapter function for filling matrix struct from generic float[16] array
pub extern fn sshape_mat4([*c]const f32) Mat4;

/// adapter function for filling matrix struct from generic float[16] array
pub fn mat4(m: *const f32) Mat4 {
    return sshape_mat4(m);
}

pub extern fn sshape_mat4_transpose([*c]const f32) Mat4;

pub fn mat4Transpose(m: *const f32) Mat4 {
    return sshape_mat4_transpose(m);
}

