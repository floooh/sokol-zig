// machine generated, do not edit

const builtin = @import("builtin");
const sg = @import("gfx.zig");

// helper function to convert a C string to a Zig string slice
fn cStrToZig(c_str: [*c]const u8) [:0]const u8 {
  return @import("std").mem.span(c_str);
}
// helper function to convert "anything" to a Range struct
pub fn asRange(val: anytype) Range {
    const type_info = @typeInfo(@TypeOf(val));
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
        }
    }
}

pub const Range = extern struct {
    ptr: ?*const anyopaque = null,
    size: usize = 0,
};
pub const Mat4 = extern struct {
    m: [4][4]f32 = [_][4]f32{[_]f32{ 0.0 }**4}**4,
};
pub const Vertex = extern struct {
    x: f32 = 0.0,
    y: f32 = 0.0,
    z: f32 = 0.0,
    normal: u32 = 0,
    u: u16 = 0,
    v: u16 = 0,
    color: u32 = 0,
};
pub const ElementRange = extern struct {
    base_element: u32 = 0,
    num_elements: u32 = 0,
    __pad: [3]u32 = [_]u32{0} ** 3,
};
pub const SizesItem = extern struct {
    num: u32 = 0,
    size: u32 = 0,
    __pad: [3]u32 = [_]u32{0} ** 3,
};
pub const Sizes = extern struct {
    vertices: SizesItem = .{ },
    indices: SizesItem = .{ },
};
pub const BufferItem = extern struct {
    buffer: Range = .{ },
    data_size: usize = 0,
    shape_offset: usize = 0,
};
pub const Buffer = extern struct {
    valid: bool = false,
    vertices: BufferItem = .{ },
    indices: BufferItem = .{ },
};
pub const Plane = extern struct {
    width: f32 = 0.0,
    depth: f32 = 0.0,
    tiles: u16 = 0,
    color: u32 = 0,
    random_colors: bool = false,
    merge: bool = false,
    transform: Mat4 = .{ },
};
pub const Box = extern struct {
    width: f32 = 0.0,
    height: f32 = 0.0,
    depth: f32 = 0.0,
    tiles: u16 = 0,
    color: u32 = 0,
    random_colors: bool = false,
    merge: bool = false,
    transform: Mat4 = .{ },
};
pub const Sphere = extern struct {
    radius: f32 = 0.0,
    slices: u16 = 0,
    stacks: u16 = 0,
    color: u32 = 0,
    random_colors: bool = false,
    merge: bool = false,
    transform: Mat4 = .{ },
};
pub const Cylinder = extern struct {
    radius: f32 = 0.0,
    height: f32 = 0.0,
    slices: u16 = 0,
    stacks: u16 = 0,
    color: u32 = 0,
    random_colors: bool = false,
    merge: bool = false,
    transform: Mat4 = .{ },
};
pub const Torus = extern struct {
    radius: f32 = 0.0,
    ring_radius: f32 = 0.0,
    sides: u16 = 0,
    rings: u16 = 0,
    color: u32 = 0,
    random_colors: bool = false,
    merge: bool = false,
    transform: Mat4 = .{ },
};
pub extern fn sshape_build_plane([*c]const Buffer, [*c]const Plane) Buffer;
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
pub extern fn sshape_plane_sizes(u32) Sizes;
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
pub extern fn sshape_element_range([*c]const Buffer) ElementRange;
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
pub extern fn sshape_buffer_layout_desc() sg.BufferLayoutDesc;
pub fn bufferLayoutDesc() sg.BufferLayoutDesc {
    return sshape_buffer_layout_desc();
}
pub extern fn sshape_position_attr_desc() sg.VertexAttrDesc;
pub fn positionAttrDesc() sg.VertexAttrDesc {
    return sshape_position_attr_desc();
}
pub extern fn sshape_normal_attr_desc() sg.VertexAttrDesc;
pub fn normalAttrDesc() sg.VertexAttrDesc {
    return sshape_normal_attr_desc();
}
pub extern fn sshape_texcoord_attr_desc() sg.VertexAttrDesc;
pub fn texcoordAttrDesc() sg.VertexAttrDesc {
    return sshape_texcoord_attr_desc();
}
pub extern fn sshape_color_attr_desc() sg.VertexAttrDesc;
pub fn colorAttrDesc() sg.VertexAttrDesc {
    return sshape_color_attr_desc();
}
pub extern fn sshape_color_4f(f32, f32, f32, f32) u32;
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
pub extern fn sshape_mat4([*c]const f32) Mat4;
pub fn mat4(m: *const f32) Mat4 {
    return sshape_mat4(m);
}
pub extern fn sshape_mat4_transpose([*c]const f32) Mat4;
pub fn mat4Transpose(m: *const f32) Mat4 {
    return sshape_mat4_transpose(m);
}
