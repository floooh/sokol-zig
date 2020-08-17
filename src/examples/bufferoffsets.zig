//------------------------------------------------------------------------------
//  bufferoffsets.zig
//
//  Render separate geometries in vertex- and index-buffers with
//  buffer offsets.
//------------------------------------------------------------------------------
const sg = @import("sokol").gfx;
const sapp = @import("sokol").app;
const sgapp = @import("sokol").app_gfx_glue;

const State = struct {
    pass_action: sg.PassAction = .{},
    pip: sg.Pipeline = .{},
    bind: sg.Bindings = .{},
};
var state: State = .{};

const Vertex = packed struct {
    x: f32, y: f32,
    r: f32, g: f32, b: f32
};

export fn init() void {
    sg.setup(.{
        .context = sgapp.context()
    });

    // clear to a blue-ish color
    state.pass_action.colors[0] = .{ .action = .CLEAR, .val = .{ 0.5, 0.5, 1.0, 1.0 } };

    // a 2D triangle and quad in 1 vertex buffer and 1 index buffer
    const vertices = [_]Vertex {
        // triangle vertices
        .{ .x= 0.0,  .y= 0.55,  .r=1.0, .g=0.0, .b=0.0 },
        .{ .x= 0.25, .y= 0.05,  .r=0.0, .g=1.0, .b=0.0 },
        .{ .x=-0.25, .y= 0.05,  .r=0.0, .g=0.0, .b=1.0 },

        // quad vertices
        .{ .x=-0.25, .y=-0.05,  .r=0.0, .g=0.0, .b=1.0 },
        .{ .x= 0.25, .y=-0.05,  .r=0.0, .g=1.0, .b=0.0 },
        .{ .x= 0.25, .y=-0.55,  .r=1.0, .g=0.0, .b=0.0 },
        .{ .x=-0.25, .y=-0.55,  .r=1.0, .g=1.0, .b=0.0 }
    };
    const indices = [_]u16 {
        // triangle indices
        0, 1, 2,
        // quad indices
        0, 1, 2, 0, 2, 3
    };
    state.bind.vertex_buffers[0] = sg.makeBuffer(.{
        .content = &vertices,
        .size = sg.sizeOf(vertices)
    });
    state.bind.index_buffer = sg.makeBuffer(.{
        .type = .INDEXBUFFER,
        .content = &indices,
        .size = sg.sizeOf(indices)
    });

    // a shader and pipeline object
    var shd_desc: sg.ShaderDesc = .{};
    shd_desc.attrs[0].sem_name = "POSITION";
    shd_desc.attrs[1].sem_name = "COLOR";
    shd_desc.vs.source = vs_source();
    shd_desc.fs.source = fs_source();

    var pip_desc: sg.PipelineDesc = .{
        .shader = sg.makeShader(shd_desc),
        .index_type = .UINT16
    };
    pip_desc.layout.attrs[0].format = .FLOAT2;
    pip_desc.layout.attrs[1].format = .FLOAT3;
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
        .window_title = "bufferoffsets.zig"
    });
}

fn vs_source() [*c]const u8 {
    return switch (sg.queryBackend()) {
        .D3D11 =>
            \\struct vs_in {
            \\  float2 pos: POSITION;
            \\  float3 color: COLOR0;
            \\};
            \\struct vs_out {
            \\  float4 color: COLOR0;
            \\  float4 pos: SV_Position;
            \\};
            \\vs_out main(vs_in inp) {
            \\  vs_out outp;
            \\  outp.pos = float4(inp.pos, 0.5, 1.0);
            \\  outp.color = float4(inp.color, 1.0);
            \\  return outp;
            \\}
            ,
        else => "FIXME"
    };
}

fn fs_source() [*c]const u8 {
    return switch (sg.queryBackend()) {
        .D3D11 =>
            \\float4 main(float4 color: COLOR0): SV_Target0 {
            \\  return color;
            \\}
            ,
        else => "FIXME"
    };
}
