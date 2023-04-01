// machine generated, do not edit

const builtin = @import("builtin");
const sg = @import("gfx.zig");

// helper function to convert a C string to a Zig string slice
fn cStrToZig(c_str: [*c]const u8) [:0]const u8 {
  return @import("std").mem.span(c_str);
}
pub const LogItem = enum(i32) {
    OK,
    MALLOC_FAILED,
    MAKE_PIPELINE_FAILED,
    PIPELINE_POOL_EXHAUSTED,
    ADD_COMMIT_LISTENER_FAILED,
    CONTEXT_POOL_EXHAUSTED,
    CANNOT_DESTROY_DEFAULT_CONTEXT,
};
pub const Logger = extern struct {
    func: ?*const fn([*c]const u8, u32, u32, [*c]const u8, u32, [*c]const u8, ?*anyopaque) callconv(.C) void = null,
    user_data: ?*anyopaque = null,
};
pub const Pipeline = extern struct {
    id: u32 = 0,
};
pub const Context = extern struct {
    id: u32 = 0,
};
pub const Error = enum(i32) {
    NO_ERROR = 0,
    VERTICES_FULL,
    UNIFORMS_FULL,
    COMMANDS_FULL,
    STACK_OVERFLOW,
    STACK_UNDERFLOW,
    NO_CONTEXT,
};
pub const ContextDesc = extern struct {
    max_vertices: i32 = 0,
    max_commands: i32 = 0,
    color_format: sg.PixelFormat = .DEFAULT,
    depth_format: sg.PixelFormat = .DEFAULT,
    sample_count: i32 = 0,
};
pub const Allocator = extern struct {
    alloc: ?*const fn(usize, ?*anyopaque) callconv(.C) ?*anyopaque = null,
    free: ?*const fn(?*anyopaque, ?*anyopaque) callconv(.C) void = null,
    user_data: ?*anyopaque = null,
};
pub const Desc = extern struct {
    max_vertices: i32 = 0,
    max_commands: i32 = 0,
    context_pool_size: i32 = 0,
    pipeline_pool_size: i32 = 0,
    color_format: sg.PixelFormat = .DEFAULT,
    depth_format: sg.PixelFormat = .DEFAULT,
    sample_count: i32 = 0,
    face_winding: sg.FaceWinding = .DEFAULT,
    allocator: Allocator = .{ },
    logger: Logger = .{ },
};
pub extern fn sgl_setup([*c]const Desc) void;
pub fn setup(desc: Desc) void {
    sgl_setup(&desc);
}
pub extern fn sgl_shutdown() void;
pub fn shutdown() void {
    sgl_shutdown();
}
pub extern fn sgl_rad(f32) f32;
pub fn asRadians(deg: f32) f32 {
    return sgl_rad(deg);
}
pub extern fn sgl_deg(f32) f32;
pub fn asDegrees(rad: f32) f32 {
    return sgl_deg(rad);
}
pub extern fn sgl_error() Error;
pub fn getError() Error {
    return sgl_error();
}
pub extern fn sgl_context_error(Context) Error;
pub fn contextError(ctx: Context) Error {
    return sgl_context_error(ctx);
}
pub extern fn sgl_make_context([*c]const ContextDesc) Context;
pub fn makeContext(desc: ContextDesc) Context {
    return sgl_make_context(&desc);
}
pub extern fn sgl_destroy_context(Context) void;
pub fn destroyContext(ctx: Context) void {
    sgl_destroy_context(ctx);
}
pub extern fn sgl_set_context(Context) void;
pub fn setContext(ctx: Context) void {
    sgl_set_context(ctx);
}
pub extern fn sgl_get_context() Context;
pub fn getContext() Context {
    return sgl_get_context();
}
pub extern fn sgl_default_context() Context;
pub fn defaultContext() Context {
    return sgl_default_context();
}
pub extern fn sgl_draw() void;
pub fn draw() void {
    sgl_draw();
}
pub extern fn sgl_context_draw(Context) void;
pub fn contextDraw(ctx: Context) void {
    sgl_context_draw(ctx);
}
pub extern fn sgl_draw_layer(i32) void;
pub fn drawLayer(layer_id: i32) void {
    sgl_draw_layer(layer_id);
}
pub extern fn sgl_context_draw_layer(Context, i32) void;
pub fn contextDrawLayer(ctx: Context, layer_id: i32) void {
    sgl_context_draw_layer(ctx, layer_id);
}
pub extern fn sgl_make_pipeline([*c]const sg.PipelineDesc) Pipeline;
pub fn makePipeline(desc: sg.PipelineDesc) Pipeline {
    return sgl_make_pipeline(&desc);
}
pub extern fn sgl_context_make_pipeline(Context, [*c]const sg.PipelineDesc) Pipeline;
pub fn contextMakePipeline(ctx: Context, desc: sg.PipelineDesc) Pipeline {
    return sgl_context_make_pipeline(ctx, &desc);
}
pub extern fn sgl_destroy_pipeline(Pipeline) void;
pub fn destroyPipeline(pip: Pipeline) void {
    sgl_destroy_pipeline(pip);
}
pub extern fn sgl_defaults() void;
pub fn defaults() void {
    sgl_defaults();
}
pub extern fn sgl_viewport(i32, i32, i32, i32, bool) void;
pub fn viewport(x: i32, y: i32, w: i32, h: i32, origin_top_left: bool) void {
    sgl_viewport(x, y, w, h, origin_top_left);
}
pub extern fn sgl_viewportf(f32, f32, f32, f32, bool) void;
pub fn viewportf(x: f32, y: f32, w: f32, h: f32, origin_top_left: bool) void {
    sgl_viewportf(x, y, w, h, origin_top_left);
}
pub extern fn sgl_scissor_rect(i32, i32, i32, i32, bool) void;
pub fn scissorRect(x: i32, y: i32, w: i32, h: i32, origin_top_left: bool) void {
    sgl_scissor_rect(x, y, w, h, origin_top_left);
}
pub extern fn sgl_scissor_rectf(f32, f32, f32, f32, bool) void;
pub fn scissorRectf(x: f32, y: f32, w: f32, h: f32, origin_top_left: bool) void {
    sgl_scissor_rectf(x, y, w, h, origin_top_left);
}
pub extern fn sgl_enable_texture() void;
pub fn enableTexture() void {
    sgl_enable_texture();
}
pub extern fn sgl_disable_texture() void;
pub fn disableTexture() void {
    sgl_disable_texture();
}
pub extern fn sgl_texture(sg.Image) void;
pub fn texture(img: sg.Image) void {
    sgl_texture(img);
}
pub extern fn sgl_layer(i32) void;
pub fn layer(layer_id: i32) void {
    sgl_layer(layer_id);
}
pub extern fn sgl_load_default_pipeline() void;
pub fn loadDefaultPipeline() void {
    sgl_load_default_pipeline();
}
pub extern fn sgl_load_pipeline(Pipeline) void;
pub fn loadPipeline(pip: Pipeline) void {
    sgl_load_pipeline(pip);
}
pub extern fn sgl_push_pipeline() void;
pub fn pushPipeline() void {
    sgl_push_pipeline();
}
pub extern fn sgl_pop_pipeline() void;
pub fn popPipeline() void {
    sgl_pop_pipeline();
}
pub extern fn sgl_matrix_mode_modelview() void;
pub fn matrixModeModelview() void {
    sgl_matrix_mode_modelview();
}
pub extern fn sgl_matrix_mode_projection() void;
pub fn matrixModeProjection() void {
    sgl_matrix_mode_projection();
}
pub extern fn sgl_matrix_mode_texture() void;
pub fn matrixModeTexture() void {
    sgl_matrix_mode_texture();
}
pub extern fn sgl_load_identity() void;
pub fn loadIdentity() void {
    sgl_load_identity();
}
pub extern fn sgl_load_matrix([*c]const f32) void;
pub fn loadMatrix(m: *const f32) void {
    sgl_load_matrix(m);
}
pub extern fn sgl_load_transpose_matrix([*c]const f32) void;
pub fn loadTransposeMatrix(m: *const f32) void {
    sgl_load_transpose_matrix(m);
}
pub extern fn sgl_mult_matrix([*c]const f32) void;
pub fn multMatrix(m: *const f32) void {
    sgl_mult_matrix(m);
}
pub extern fn sgl_mult_transpose_matrix([*c]const f32) void;
pub fn multTransposeMatrix(m: *const f32) void {
    sgl_mult_transpose_matrix(m);
}
pub extern fn sgl_rotate(f32, f32, f32, f32) void;
pub fn rotate(angle_rad: f32, x: f32, y: f32, z: f32) void {
    sgl_rotate(angle_rad, x, y, z);
}
pub extern fn sgl_scale(f32, f32, f32) void;
pub fn scale(x: f32, y: f32, z: f32) void {
    sgl_scale(x, y, z);
}
pub extern fn sgl_translate(f32, f32, f32) void;
pub fn translate(x: f32, y: f32, z: f32) void {
    sgl_translate(x, y, z);
}
pub extern fn sgl_frustum(f32, f32, f32, f32, f32, f32) void;
pub fn frustum(l: f32, r: f32, b: f32, t: f32, n: f32, f: f32) void {
    sgl_frustum(l, r, b, t, n, f);
}
pub extern fn sgl_ortho(f32, f32, f32, f32, f32, f32) void;
pub fn ortho(l: f32, r: f32, b: f32, t: f32, n: f32, f: f32) void {
    sgl_ortho(l, r, b, t, n, f);
}
pub extern fn sgl_perspective(f32, f32, f32, f32) void;
pub fn perspective(fov_y: f32, aspect: f32, z_near: f32, z_far: f32) void {
    sgl_perspective(fov_y, aspect, z_near, z_far);
}
pub extern fn sgl_lookat(f32, f32, f32, f32, f32, f32, f32, f32, f32) void;
pub fn lookat(eye_x: f32, eye_y: f32, eye_z: f32, center_x: f32, center_y: f32, center_z: f32, up_x: f32, up_y: f32, up_z: f32) void {
    sgl_lookat(eye_x, eye_y, eye_z, center_x, center_y, center_z, up_x, up_y, up_z);
}
pub extern fn sgl_push_matrix() void;
pub fn pushMatrix() void {
    sgl_push_matrix();
}
pub extern fn sgl_pop_matrix() void;
pub fn popMatrix() void {
    sgl_pop_matrix();
}
pub extern fn sgl_t2f(f32, f32) void;
pub fn t2f(u: f32, v: f32) void {
    sgl_t2f(u, v);
}
pub extern fn sgl_c3f(f32, f32, f32) void;
pub fn c3f(r: f32, g: f32, b: f32) void {
    sgl_c3f(r, g, b);
}
pub extern fn sgl_c4f(f32, f32, f32, f32) void;
pub fn c4f(r: f32, g: f32, b: f32, a: f32) void {
    sgl_c4f(r, g, b, a);
}
pub extern fn sgl_c3b(u8, u8, u8) void;
pub fn c3b(r: u8, g: u8, b: u8) void {
    sgl_c3b(r, g, b);
}
pub extern fn sgl_c4b(u8, u8, u8, u8) void;
pub fn c4b(r: u8, g: u8, b: u8, a: u8) void {
    sgl_c4b(r, g, b, a);
}
pub extern fn sgl_c1i(u32) void;
pub fn c1i(rgba: u32) void {
    sgl_c1i(rgba);
}
pub extern fn sgl_point_size(f32) void;
pub fn pointSize(s: f32) void {
    sgl_point_size(s);
}
pub extern fn sgl_begin_points() void;
pub fn beginPoints() void {
    sgl_begin_points();
}
pub extern fn sgl_begin_lines() void;
pub fn beginLines() void {
    sgl_begin_lines();
}
pub extern fn sgl_begin_line_strip() void;
pub fn beginLineStrip() void {
    sgl_begin_line_strip();
}
pub extern fn sgl_begin_triangles() void;
pub fn beginTriangles() void {
    sgl_begin_triangles();
}
pub extern fn sgl_begin_triangle_strip() void;
pub fn beginTriangleStrip() void {
    sgl_begin_triangle_strip();
}
pub extern fn sgl_begin_quads() void;
pub fn beginQuads() void {
    sgl_begin_quads();
}
pub extern fn sgl_v2f(f32, f32) void;
pub fn v2f(x: f32, y: f32) void {
    sgl_v2f(x, y);
}
pub extern fn sgl_v3f(f32, f32, f32) void;
pub fn v3f(x: f32, y: f32, z: f32) void {
    sgl_v3f(x, y, z);
}
pub extern fn sgl_v2f_t2f(f32, f32, f32, f32) void;
pub fn v2fT2f(x: f32, y: f32, u: f32, v: f32) void {
    sgl_v2f_t2f(x, y, u, v);
}
pub extern fn sgl_v3f_t2f(f32, f32, f32, f32, f32) void;
pub fn v3fT2f(x: f32, y: f32, z: f32, u: f32, v: f32) void {
    sgl_v3f_t2f(x, y, z, u, v);
}
pub extern fn sgl_v2f_c3f(f32, f32, f32, f32, f32) void;
pub fn v2fC3f(x: f32, y: f32, r: f32, g: f32, b: f32) void {
    sgl_v2f_c3f(x, y, r, g, b);
}
pub extern fn sgl_v2f_c3b(f32, f32, u8, u8, u8) void;
pub fn v2fC3b(x: f32, y: f32, r: u8, g: u8, b: u8) void {
    sgl_v2f_c3b(x, y, r, g, b);
}
pub extern fn sgl_v2f_c4f(f32, f32, f32, f32, f32, f32) void;
pub fn v2fC4f(x: f32, y: f32, r: f32, g: f32, b: f32, a: f32) void {
    sgl_v2f_c4f(x, y, r, g, b, a);
}
pub extern fn sgl_v2f_c4b(f32, f32, u8, u8, u8, u8) void;
pub fn v2fC4b(x: f32, y: f32, r: u8, g: u8, b: u8, a: u8) void {
    sgl_v2f_c4b(x, y, r, g, b, a);
}
pub extern fn sgl_v2f_c1i(f32, f32, u32) void;
pub fn v2fC1i(x: f32, y: f32, rgba: u32) void {
    sgl_v2f_c1i(x, y, rgba);
}
pub extern fn sgl_v3f_c3f(f32, f32, f32, f32, f32, f32) void;
pub fn v3fC3f(x: f32, y: f32, z: f32, r: f32, g: f32, b: f32) void {
    sgl_v3f_c3f(x, y, z, r, g, b);
}
pub extern fn sgl_v3f_c3b(f32, f32, f32, u8, u8, u8) void;
pub fn v3fC3b(x: f32, y: f32, z: f32, r: u8, g: u8, b: u8) void {
    sgl_v3f_c3b(x, y, z, r, g, b);
}
pub extern fn sgl_v3f_c4f(f32, f32, f32, f32, f32, f32, f32) void;
pub fn v3fC4f(x: f32, y: f32, z: f32, r: f32, g: f32, b: f32, a: f32) void {
    sgl_v3f_c4f(x, y, z, r, g, b, a);
}
pub extern fn sgl_v3f_c4b(f32, f32, f32, u8, u8, u8, u8) void;
pub fn v3fC4b(x: f32, y: f32, z: f32, r: u8, g: u8, b: u8, a: u8) void {
    sgl_v3f_c4b(x, y, z, r, g, b, a);
}
pub extern fn sgl_v3f_c1i(f32, f32, f32, u32) void;
pub fn v3fC1i(x: f32, y: f32, z: f32, rgba: u32) void {
    sgl_v3f_c1i(x, y, z, rgba);
}
pub extern fn sgl_v2f_t2f_c3f(f32, f32, f32, f32, f32, f32, f32) void;
pub fn v2fT2fC3f(x: f32, y: f32, u: f32, v: f32, r: f32, g: f32, b: f32) void {
    sgl_v2f_t2f_c3f(x, y, u, v, r, g, b);
}
pub extern fn sgl_v2f_t2f_c3b(f32, f32, f32, f32, u8, u8, u8) void;
pub fn v2fT2fC3b(x: f32, y: f32, u: f32, v: f32, r: u8, g: u8, b: u8) void {
    sgl_v2f_t2f_c3b(x, y, u, v, r, g, b);
}
pub extern fn sgl_v2f_t2f_c4f(f32, f32, f32, f32, f32, f32, f32, f32) void;
pub fn v2fT2fC4f(x: f32, y: f32, u: f32, v: f32, r: f32, g: f32, b: f32, a: f32) void {
    sgl_v2f_t2f_c4f(x, y, u, v, r, g, b, a);
}
pub extern fn sgl_v2f_t2f_c4b(f32, f32, f32, f32, u8, u8, u8, u8) void;
pub fn v2fT2fC4b(x: f32, y: f32, u: f32, v: f32, r: u8, g: u8, b: u8, a: u8) void {
    sgl_v2f_t2f_c4b(x, y, u, v, r, g, b, a);
}
pub extern fn sgl_v2f_t2f_c1i(f32, f32, f32, f32, u32) void;
pub fn v2fT2fC1i(x: f32, y: f32, u: f32, v: f32, rgba: u32) void {
    sgl_v2f_t2f_c1i(x, y, u, v, rgba);
}
pub extern fn sgl_v3f_t2f_c3f(f32, f32, f32, f32, f32, f32, f32, f32) void;
pub fn v3fT2fC3f(x: f32, y: f32, z: f32, u: f32, v: f32, r: f32, g: f32, b: f32) void {
    sgl_v3f_t2f_c3f(x, y, z, u, v, r, g, b);
}
pub extern fn sgl_v3f_t2f_c3b(f32, f32, f32, f32, f32, u8, u8, u8) void;
pub fn v3fT2fC3b(x: f32, y: f32, z: f32, u: f32, v: f32, r: u8, g: u8, b: u8) void {
    sgl_v3f_t2f_c3b(x, y, z, u, v, r, g, b);
}
pub extern fn sgl_v3f_t2f_c4f(f32, f32, f32, f32, f32, f32, f32, f32, f32) void;
pub fn v3fT2fC4f(x: f32, y: f32, z: f32, u: f32, v: f32, r: f32, g: f32, b: f32, a: f32) void {
    sgl_v3f_t2f_c4f(x, y, z, u, v, r, g, b, a);
}
pub extern fn sgl_v3f_t2f_c4b(f32, f32, f32, f32, f32, u8, u8, u8, u8) void;
pub fn v3fT2fC4b(x: f32, y: f32, z: f32, u: f32, v: f32, r: u8, g: u8, b: u8, a: u8) void {
    sgl_v3f_t2f_c4b(x, y, z, u, v, r, g, b, a);
}
pub extern fn sgl_v3f_t2f_c1i(f32, f32, f32, f32, f32, u32) void;
pub fn v3fT2fC1i(x: f32, y: f32, z: f32, u: f32, v: f32, rgba: u32) void {
    sgl_v3f_t2f_c1i(x, y, z, u, v, rgba);
}
pub extern fn sgl_end() void;
pub fn end() void {
    sgl_end();
}
