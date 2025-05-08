//------------------------------------------------------------------------------
//  vertexpull.zig
//
//  Pull vertices from a storage buffer instead of using fixed-function
//  vertex input.
//------------------------------------------------------------------------------
const sokol = @import("sokol");
const slog = sokol.log;
const sg = sokol.gfx;
const sapp = sokol.app;
const sglue = sokol.glue;
const vec3 = @import("math.zig").Vec3;
const mat4 = @import("math.zig").Mat4;
const shd = @import("shaders/vertexpull.glsl.zig");

const state = struct {
    var rx: f32 = 0.0;
    var ry: f32 = 0.0;
    var pip: sg.Pipeline = .{};
    var bind: sg.Bindings = .{};
    var pass_action: sg.PassAction = .{};
    const view: mat4 = mat4.lookat(.{ .x = 0.0, .y = 1.5, .z = 6.0 }, vec3.zero(), vec3.up());
};

export fn init() void {
    sg.setup(.{
        .environment = sglue.environment(),
        .logger = .{ .func = slog.func },
    });

    // if storage buffers are not supported on the current backend, just render a red screen
    if (!sg.queryFeatures().compute) {
        state.pass_action.colors[0] = .{
            .load_action = .CLEAR,
            .clear_value = .{ .r = 1, .g = 0, .b = 0, .a = 1 },
        };
        return;
    }

    // otherwise set regular clear color
    state.pass_action.colors[0] = .{
        .load_action = .CLEAR,
        .clear_value = .{ .r = 0.75, .g = 0.5, .b = 0.25, .a = 1 },
    };

    // a storage buffer with the cube vertex data
    state.bind.storage_buffers[shd.SBUF_ssbo] = sg.makeBuffer(.{
        .usage = .{ .storage_buffer = true },
        .data = sg.asRange(&[_]shd.SbVertex{
            // zig fmt: off
            .{ .pos = .{ -1.0, -1.0, -1.0 }, .color = .{ 1.0, 0.0, 0.0, 1.0 } },
            .{ .pos = .{  1.0, -1.0, -1.0 }, .color = .{ 1.0, 0.0, 0.0, 1.0 } },
            .{ .pos = .{  1.0,  1.0, -1.0 }, .color = .{ 1.0, 0.0, 0.0, 1.0 } },
            .{ .pos = .{ -1.0,  1.0, -1.0 }, .color = .{ 1.0, 0.0, 0.0, 1.0 } },
            .{ .pos = .{ -1.0, -1.0,  1.0 }, .color = .{ 0.0, 1.0, 0.0, 1.0 } },
            .{ .pos = .{  1.0, -1.0,  1.0 }, .color = .{ 0.0, 1.0, 0.0, 1.0 } },
            .{ .pos = .{  1.0,  1.0,  1.0 }, .color = .{ 0.0, 1.0, 0.0, 1.0 } },
            .{ .pos = .{ -1.0,  1.0,  1.0 }, .color = .{ 0.0, 1.0, 0.0, 1.0 } },
            .{ .pos = .{ -1.0, -1.0, -1.0 }, .color = .{ 0.0, 0.0, 1.0, 1.0 } },
            .{ .pos = .{ -1.0,  1.0, -1.0 }, .color = .{ 0.0, 0.0, 1.0, 1.0 } },
            .{ .pos = .{ -1.0,  1.0,  1.0 }, .color = .{ 0.0, 0.0, 1.0, 1.0 } },
            .{ .pos = .{ -1.0, -1.0,  1.0 }, .color = .{ 0.0, 0.0, 1.0, 1.0 } },
            .{ .pos = .{  1.0, -1.0, -1.0 }, .color = .{ 1.0, 0.5, 0.0, 1.0 } },
            .{ .pos = .{  1.0,  1.0, -1.0 }, .color = .{ 1.0, 0.5, 0.0, 1.0 } },
            .{ .pos = .{  1.0,  1.0,  1.0 }, .color = .{ 1.0, 0.5, 0.0, 1.0 } },
            .{ .pos = .{  1.0, -1.0,  1.0 }, .color = .{ 1.0, 0.5, 0.0, 1.0 } },
            .{ .pos = .{ -1.0, -1.0, -1.0 }, .color = .{ 0.0, 0.5, 1.0, 1.0 } },
            .{ .pos = .{ -1.0, -1.0,  1.0 }, .color = .{ 0.0, 0.5, 1.0, 1.0 } },
            .{ .pos = .{  1.0, -1.0,  1.0 }, .color = .{ 0.0, 0.5, 1.0, 1.0 } },
            .{ .pos = .{  1.0, -1.0, -1.0 }, .color = .{ 0.0, 0.5, 1.0, 1.0 } },
            .{ .pos = .{ -1.0,  1.0, -1.0 }, .color = .{ 1.0, 0.0, 0.5, 1.0 } },
            .{ .pos = .{ -1.0,  1.0,  1.0 }, .color = .{ 1.0, 0.0, 0.5, 1.0 } },
            .{ .pos = .{  1.0,  1.0,  1.0 }, .color = .{ 1.0, 0.0, 0.5, 1.0 } },
            .{ .pos = .{  1.0,  1.0, -1.0 }, .color = .{ 1.0, 0.0, 0.5, 1.0 } },
            // zig fmt: on
        }),
        .label = "vertices",
    });

    // a regular index buffer
    state.bind.index_buffer = sg.makeBuffer(.{
        .usage = .{ .index_buffer = true },
        .data = sg.asRange(&[_]u16{
            0,  1,  2,  0,  2,  3,
            6,  5,  4,  7,  6,  4,
            8,  9,  10, 8,  10, 11,
            14, 13, 12, 15, 14, 12,
            16, 17, 18, 16, 18, 19,
            22, 21, 20, 23, 22, 20,
        }),
        .label = "indices",
    });

    // shader and pipeline object, note that the pipeline desc doesn't have a vertex layout
    state.pip = sg.makePipeline(.{
        .shader = sg.makeShader(shd.vertexpullShaderDesc(sg.queryBackend())),
        .index_type = .UINT16,
        .depth = .{
            .compare = .LESS_EQUAL,
            .write_enabled = true,
        },
        .cull_mode = .BACK,
        .label = "pipeline",
    });
}

export fn frame() void {
    const dt: f32 = @floatCast(sapp.frameDuration() * 60);
    state.rx += 1.0 * dt;
    state.ry += 2.0 * dt;
    const vs_params = computeVsParams(state.rx, state.ry);

    sg.beginPass(.{ .action = state.pass_action, .swapchain = sglue.swapchain() });
    if (sg.queryFeatures().compute) {
        sg.applyPipeline(state.pip);
        sg.applyBindings(state.bind);
        sg.applyUniforms(shd.UB_vs_params, sg.asRange(&vs_params));
        sg.draw(0, 36, 1);
    }
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
        .sample_count = 4,
        .icon = .{ .sokol_default = true },
        .window_title = "vertexpull.zig",
        .logger = .{ .func = slog.func },
    });
}

fn computeVsParams(rx: f32, ry: f32) shd.VsParams {
    const rxm = mat4.rotate(rx, .{ .x = 1.0, .y = 0.0, .z = 0.0 });
    const rym = mat4.rotate(ry, .{ .x = 0.0, .y = 1.0, .z = 0.0 });
    const model = mat4.mul(rxm, rym);
    const aspect = sapp.widthf() / sapp.heightf();
    const proj = mat4.persp(60.0, aspect, 0.01, 10.0);
    return shd.VsParams{ .mvp = mat4.mul(mat4.mul(proj, state.view), model) };
}
