//------------------------------------------------------------------------------
//  blend.zig
//  Test/demonstrate blend modes.
//------------------------------------------------------------------------------
const sokol = @import("sokol");
const slog  = sokol.log;
const sg    = sokol.gfx;
const sapp  = sokol.app;
const sgapp = sokol.app_gfx_glue;
const vec3  = @import("math.zig").Vec3;
const mat4  = @import("math.zig").Mat4;
const shd   = @import("shaders/blend.glsl.zig");

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
        .context = sgapp.context(),
        .logger = .{ .func = slog.func },
    });

    state.pass_action.colors[0].action = .DONTCARE;
    state.pass_action.depth.action = .DONTCARE;
    state.pass_action.stencil.action = .DONTCARE;

    state.bind.vertex_buffers[0] = sg.makeBuffer(.{
        .data = sg.asRange(&[_]f32 {
             // pos               color
            -1.0, -1.0, 0.0,  1.0, 0.0, 0.0, 0.5,
             1.0, -1.0, 0.0,  0.0, 1.0, 0.0, 0.5,
            -1.0,  1.0, 0.0,  0.0, 0.0, 1.0, 0.5,
             1.0,  1.0, 0.0,  1.0, 1.0, 0.0, 0.5
        })
    });

    // pipeline object for rendering the background
    var pip_desc: sg.PipelineDesc = .{
        .shader = sg.makeShader(shd.bgShaderDesc(sg.queryBackend())),
        .primitive_type = .TRIANGLE_STRIP,
    };
    pip_desc.layout.buffers[0].stride = 28;
    pip_desc.layout.attrs[shd.ATTR_vs_bg_position].format = .FLOAT2;
    state.bg_pip = sg.makePipeline(pip_desc);

    // lot of pipeline objects for rendering the blended quads
    pip_desc = .{
        .shader = sg.makeShader(shd.quadShaderDesc(sg.queryBackend())),
        .primitive_type = .TRIANGLE_STRIP,
        .blend_color = .{ .r=1.0, .g=0.0, .b=0.0, .a=1.0 }
    };
    pip_desc.layout.attrs[shd.ATTR_vs_quad_position].format = .FLOAT3;
    pip_desc.layout.attrs[shd.ATTR_vs_quad_color0].format = .FLOAT4;
    pip_desc.colors[0].blend = .{
        .enabled = true,
        .src_factor_alpha = .ONE,
        .dst_factor_alpha = .ZERO,
    };
    var src: usize = 0; while (src < NUM_BLEND_FACTORS): (src += 1) {
        var dst: usize = 0; while (dst < NUM_BLEND_FACTORS): (dst += 1) {
            pip_desc.colors[0].blend.src_factor_rgb = @intToEnum(sg.BlendFactor, src + 1);
            pip_desc.colors[0].blend.dst_factor_rgb = @intToEnum(sg.BlendFactor, dst + 1);
            state.pip[src][dst] = sg.makePipeline(pip_desc);
        }
    }
}

export fn frame() void {
    const time = @floatCast(f32, sapp.frameDuration()) * 60.0;

    sg.beginDefaultPass(state.pass_action, sapp.width(), sapp.height());

    // draw background
    state.tick += 1.0 * time;
    const bg_fs_params: shd.BgFsParams = .{ .tick = state.tick };
    sg.applyPipeline(state.bg_pip);
    sg.applyBindings(state.bind);
    sg.applyUniforms(.FS, shd.SLOT_bg_fs_params, sg.asRange(&bg_fs_params));
    sg.draw(0, 4, 1);

    // draw the blended quads
    const proj = mat4.persp(90.0, sapp.widthf() / sapp.heightf(), 0.01, 100.0);
    const view = mat4.lookat(.{ .x = 0, .y = 0, .z = 25.0 }, vec3.zero(), vec3.up());
    const view_proj = mat4.mul(proj, view);

    state.r += 0.6 * time;
    var r0 = state.r;
    var src: usize = 0; while (src < NUM_BLEND_FACTORS): (src += 1) {
        var dst: usize = 0; while (dst < NUM_BLEND_FACTORS): (dst += 1) {
            // compute model-view-proj matrix
            const shift = NUM_BLEND_FACTORS / 2;
            const t: vec3 = .{
                .x = (@intToFloat(f32, dst) - shift) * 3.0,
                .y = (@intToFloat(f32, src) - shift) * 2.2,
                .z = 0.0
            };
            const model = mat4.mul(mat4.translate(t), mat4.rotate(r0, vec3.up()));
            const quad_vs_params: shd.QuadVsParams = .{
                .mvp = mat4.mul(view_proj, model)
            };
            sg.applyPipeline(state.pip[src][dst]);
            sg.applyBindings(state.bind);
            sg.applyUniforms(.VS, shd.SLOT_quad_vs_params, sg.asRange(&quad_vs_params));
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
