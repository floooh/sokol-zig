//------------------------------------------------------------------------------
//  blend.zig
//  Test/demonstrate blend modes.
//------------------------------------------------------------------------------
const std = @import("std");
const sokol = @import("sokol");
const slog = sokol.log;
const sg = sokol.gfx;
const sapp = sokol.app;
const sglue = sokol.glue;
const vec3 = @import("math.zig").Vec3;
const mat4 = @import("math.zig").Mat4;
const shd = @import("shaders/blend.glsl.zig");

const NUM_BLEND_FACTORS = 15;

const state = struct {
    var pass_action: sg.PassAction = .{};
    var bind: sg.Bindings = .{};
    var pip: [NUM_BLEND_FACTORS][NUM_BLEND_FACTORS]sg.Pipeline = undefined;
    var bg_pip: sg.Pipeline = .{};
    var r: f32 = 0;
    var tick: f32 = 0;
};

export fn init() void {
    sg.setup(.{
        .pipeline_pool_size = NUM_BLEND_FACTORS * NUM_BLEND_FACTORS + 1,
        .environment = sglue.environment(),
        .logger = .{ .func = slog.func },
    });

    state.pass_action.colors[0].load_action = .DONTCARE;
    state.pass_action.depth.load_action = .DONTCARE;
    state.pass_action.stencil.load_action = .DONTCARE;

    state.bind.vertex_buffers[0] = sg.makeBuffer(.{
        .data = sg.asRange(&[_]f32{
            // pos           color
            -1.0, -1.0, 0.0, 1.0, 0.0, 0.0, 0.5,
            1.0,  -1.0, 0.0, 0.0, 1.0, 0.0, 0.5,
            -1.0, 1.0,  0.0, 0.0, 0.0, 1.0, 0.5,
            1.0,  1.0,  0.0, 1.0, 1.0, 0.0, 0.5,
        }),
    });

    // pipeline object for rendering the background
    state.bg_pip = sg.makePipeline(.{
        .shader = sg.makeShader(shd.bgShaderDesc(sg.queryBackend())),
        .layout = init: {
            var l = sg.VertexLayoutState{};
            l.buffers[0].stride = 28;
            l.attrs[shd.ATTR_bg_position].format = .FLOAT2;
            break :init l;
        },
        .primitive_type = .TRIANGLE_STRIP,
    });

    // lot of pipeline objects for rendering the blended quads
    const shader = sg.makeShader(shd.quadShaderDesc(sg.queryBackend()));
    for (0..NUM_BLEND_FACTORS) |src| {
        for (0..NUM_BLEND_FACTORS) |dst| {
            state.pip[src][dst] = sg.makePipeline(.{
                .layout = init: {
                    var l = sg.VertexLayoutState{};
                    l.attrs[shd.ATTR_quad_position].format = .FLOAT3;
                    l.attrs[shd.ATTR_quad_color0].format = .FLOAT4;
                    break :init l;
                },
                .shader = shader,
                .primitive_type = .TRIANGLE_STRIP,
                .blend_color = .{ .r = 1.0, .g = 0.0, .b = 0.0, .a = 1.0 },
                .colors = init: {
                    var c = [_]sg.ColorTargetState{.{}} ** 4;
                    c[0] = .{
                        .blend = .{
                            .enabled = true,
                            .src_factor_rgb = @enumFromInt(src + 1),
                            .dst_factor_rgb = @enumFromInt(dst + 1),
                            .src_factor_alpha = .ONE,
                            .dst_factor_alpha = .ZERO,
                        },
                    };
                    break :init c;
                },
            });
        }
    }
}

export fn frame() void {
    const time: f32 = @floatCast(sapp.frameDuration() * 60.0);

    sg.beginPass(.{ .action = state.pass_action, .swapchain = sglue.swapchain() });

    // draw background
    state.tick += 1.0 * time;
    const bg_fs_params: shd.BgFsParams = .{ .tick = state.tick };
    sg.applyPipeline(state.bg_pip);
    sg.applyBindings(state.bind);
    sg.applyUniforms(shd.UB_bg_fs_params, sg.asRange(&bg_fs_params));
    sg.draw(0, 4, 1);

    // draw the blended quads
    const proj = mat4.persp(90.0, sapp.widthf() / sapp.heightf(), 0.01, 100.0);
    const view = mat4.lookat(.{ .x = 0, .y = 0, .z = 25.0 }, vec3.zero(), vec3.up());
    const view_proj = mat4.mul(proj, view);

    state.r += 0.6 * time;
    var r0 = state.r;
    for (0..NUM_BLEND_FACTORS) |src| {
        for (0..NUM_BLEND_FACTORS) |dst| {
            // compute model-view-proj matrix
            const shift = NUM_BLEND_FACTORS / 2;
            const t: vec3 = .{
                .x = (@as(f32, @floatFromInt(dst)) - shift) * 3.0,
                .y = (@as(f32, @floatFromInt(src)) - shift) * 2.2,
                .z = 0.0,
            };
            const model = mat4.mul(mat4.translate(t), mat4.rotate(r0, vec3.up()));
            const quad_vs_params: shd.QuadVsParams = .{
                .mvp = mat4.mul(view_proj, model),
            };
            sg.applyPipeline(state.pip[src][dst]);
            sg.applyBindings(state.bind);
            sg.applyUniforms(shd.UB_quad_vs_params, sg.asRange(&quad_vs_params));
            sg.draw(0, 4, 1);
            r0 += 0.6;
        }
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
        .window_title = "blend.zig",
        .icon = .{ .sokol_default = true },
        .logger = .{ .func = slog.func },
    });
}
