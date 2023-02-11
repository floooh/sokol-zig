//------------------------------------------------------------------------------
//  quad.zig
//
//  Simple 2D rendering with vertex- and index-buffer.
//------------------------------------------------------------------------------
const sokol = @import("sokol");
const slog  = sokol.log;
const sg    = sokol.gfx;
const sapp  = sokol.app;
const sgapp = sokol.app_gfx_glue;
const shd   = @import("shaders/quad.glsl.zig");

const state = struct {
    var bind: sg.Bindings = .{};
    var pip: sg.Pipeline = .{};
    var pass_action: sg.PassAction = .{};
};

export fn init() void {
    sg.setup(.{
        .context = sgapp.context(),
        .logger = .{ .func = slog.func },
    });

    // a vertex buffer
    state.bind.vertex_buffers[0] = sg.makeBuffer(.{
        .data = sg.asRange(&[_]f32{
            // positions      colors
            -0.5,  0.5, 0.5,  1.0, 0.0, 0.0, 1.0,
             0.5,  0.5, 0.5,  0.0, 1.0, 0.0, 1.0,
             0.5, -0.5, 0.5,  0.0, 0.0, 1.0, 1.0,
            -0.5, -0.5, 0.5,  1.0, 1.0, 0.0, 1.0
        })
    });

    // an index buffer
    state.bind.index_buffer = sg.makeBuffer(.{
        .type = .INDEXBUFFER,
        .data = sg.asRange(&[_]u16{ 0, 1, 2, 0, 2, 3 })
    });

    // a shader and pipeline state object
    var pip_desc: sg.PipelineDesc = .{
        .index_type = .UINT16,
        .shader = sg.makeShader(shd.quadShaderDesc(sg.queryBackend())),
    };
    pip_desc.layout.attrs[shd.ATTR_vs_position].format = .FLOAT3;
    pip_desc.layout.attrs[shd.ATTR_vs_color0].format = .FLOAT4;
    state.pip = sg.makePipeline(pip_desc);

    // clear to black
    state.pass_action.colors[0] = .{ .action=.CLEAR, .value=.{ .r=0, .g=0, .b=0, .a=1 } };
}

export fn frame() void {
    sg.beginDefaultPass(state.pass_action, sapp.width(), sapp.height());
    sg.applyPipeline(state.pip);
    sg.applyBindings(state.bind);
    sg.draw(0, 6, 1);
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
        .width = 640,
        .height = 480,
        .icon = .{ .sokol_default = true },
        .window_title = "quad.zig",
        .logger = .{ .func = slog.func },
    });
}
