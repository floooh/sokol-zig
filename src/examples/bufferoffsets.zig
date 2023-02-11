//------------------------------------------------------------------------------
//  bufferoffsets.zig
//
//  Render separate geometries in vertex- and index-buffers with
//  buffer offsets.
//------------------------------------------------------------------------------
const sokol = @import("sokol");
const slog  = sokol.log;
const sg    = sokol.gfx;
const sapp  = sokol.app;
const sgapp = sokol.app_gfx_glue;
const shd   = @import("shaders/bufferoffsets.glsl.zig");

const state = struct {
    var pass_action: sg.PassAction = .{};
    var pip: sg.Pipeline = .{};
    var bind: sg.Bindings = .{};
};

const Vertex = extern struct {
    x: f32, y: f32,
    r: f32, g: f32, b: f32
};

export fn init() void {
    sg.setup(.{
        .context = sgapp.context(),
        .logger = .{ .func = slog.func },
    });

    // clear to a blue-ish color
    state.pass_action.colors[0] = .{ .action = .CLEAR, .value = .{ .r=0.5, .g=0.5, .b=1, .a=1 } };

    // a 2D triangle and quad in 1 vertex buffer and 1 index buffer
    state.bind.vertex_buffers[0] = sg.makeBuffer(.{
        .data = sg.asRange(&[_]Vertex{
            // triangle vertices
            .{ .x= 0.0,  .y= 0.55,  .r=1.0, .g=0.0, .b=0.0 },
            .{ .x= 0.25, .y= 0.05,  .r=0.0, .g=1.0, .b=0.0 },
            .{ .x=-0.25, .y= 0.05,  .r=0.0, .g=0.0, .b=1.0 },

            // quad vertices
            .{ .x=-0.25, .y=-0.05,  .r=0.0, .g=0.0, .b=1.0 },
            .{ .x= 0.25, .y=-0.05,  .r=0.0, .g=1.0, .b=0.0 },
            .{ .x= 0.25, .y=-0.55,  .r=1.0, .g=0.0, .b=0.0 },
            .{ .x=-0.25, .y=-0.55,  .r=1.0, .g=1.0, .b=0.0 }
        })
    });
    state.bind.index_buffer = sg.makeBuffer(.{
        .type = .INDEXBUFFER,
        .data = sg.asRange(&[_]u16{
            // triangle indices
            0, 1, 2,
            // quad indices
            0, 1, 2, 0, 2, 3
        })
    });

    // a shader and pipeline object
    var pip_desc: sg.PipelineDesc = .{
        .shader = sg.makeShader(shd.bufferoffsetsShaderDesc(sg.queryBackend())),
        .index_type = .UINT16
    };
    pip_desc.layout.attrs[shd.ATTR_vs_position].format = .FLOAT2;
    pip_desc.layout.attrs[shd.ATTR_vs_color0].format = .FLOAT3;
    state.pip = sg.makePipeline(pip_desc);
}

export fn frame() void {
    sg.beginDefaultPass(state.pass_action, sapp.width(), sapp.height());
    sg.applyPipeline(state.pip);

    // render the triangle
    state.bind.vertex_buffer_offsets[0] = 0;
    state.bind.index_buffer_offset = 0;
    sg.applyBindings(state.bind);
    sg.draw(0, 3, 1);

    // render the quad
    state.bind.vertex_buffer_offsets[0] = 3 * @sizeOf(Vertex);
    state.bind.index_buffer_offset = 3 * @sizeOf(u16);
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
        .width = 800,
        .height = 600,
        .icon = .{ .sokol_default = true },
        .window_title = "bufferoffsets.zig",
        .logger = .{ .func = slog.func },
    });
}
