//------------------------------------------------------------------------------
//  cube.zig
//
//  Shader with uniform data.
//------------------------------------------------------------------------------
const sg = @import("sokol").gfx;
const sapp = @import("sokol").app;
const sgapp = @import("sokol").app_gfx_glue;
const vec3 = @import("math.zig").Vec3;
const mat4 = @import("math.zig").Mat4;

const warn = @import("std").debug.warn;

export fn init() void {
    sg.setup(.{
        .context = sgapp.context()
    });

    const m = mat4.persp(60.0, 1.33333337, 0.01, 10.0);
    warn("{}", .{ m.m[0][0] });
}

export fn frame() void {
    sg.beginDefaultPass(.{}, sapp.width(), sapp.height());
    sg.endPass();
    sg.commit();
}

export fn cleanup() void {
    sg.shutdown();
}

pub fn main() void {
    sapp.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .width = 800,
        .height = 600,
        .window_title = "cube.zig"
    });
}
