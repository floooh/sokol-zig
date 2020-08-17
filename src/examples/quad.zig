//------------------------------------------------------------------------------
//  quad.zig
//
//  Simple 2D rendering with vertex- and index-buffer.
//------------------------------------------------------------------------------
const sg = @import("sokol").gfx;
const sapp = @import("sokol").app;
const sgapp = @import("sokol").app_gfx_glue;

const State = struct {
    bind: sg.Bindings = .{},
    pip: sg.Pipeline = .{},
    pass_action: sg.PassAction = .{}
};
var state: State = .{};

export fn init() void {
    sg.setup(.{
        .context = sgapp.context()
    });

    // a vertex buffer
    const vertices = [_]f32 {
        // positions         colors
        -0.5,  0.5, 0.5,     1.0, 0.0, 0.0, 1.0,
         0.5,  0.5, 0.5,     0.0, 1.0, 0.0, 1.0,
         0.5, -0.5, 0.5,     0.0, 0.0, 1.0, 1.0,
        -0.5, -0.5, 0.5,     1.0, 1.0, 0.0, 1.0
    };
    state.bind.vertex_buffers[0] = sg.makeBuffer(.{
        .content = &vertices,
        .size = sg.sizeOf(vertices)
    });

    // an index buffer
    const indices = [_] u16 { 0, 1, 2,  0, 2, 3 };
    state.bind.index_buffer = sg.makeBuffer(.{
        .type = .INDEXBUFFER,
        .content = &indices,
        .size = sg.sizeOf(indices)
    });

    // a shader and pipeline state object
    var shd_desc: sg.ShaderDesc = .{};
    shd_desc.attrs[0].sem_name = "POS";
    shd_desc.attrs[1].sem_name = "COLOR";
    shd_desc.vs.source = vs_source();
    shd_desc.fs.source = fs_source();

    var pip_desc: sg.PipelineDesc = .{
        .index_type = .UINT16,
        .shader = sg.makeShader(shd_desc)
    };
    pip_desc.layout.attrs[0].format = .FLOAT3;
    pip_desc.layout.attrs[1].format = .FLOAT4;
    state.pip = sg.makePipeline(pip_desc);

    // clear to black
    state.pass_action.colors[0] = .{ .action=.CLEAR, .val=.{ 0.0, 0.0, 0.0, 0.0} };
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
        .window_title = "quad.zig"
    });
}

fn vs_source() [*c]const u8 {
    return switch (sg.queryBackend()) {
        .D3D11 =>
            \\struct vs_in {
            \\  float4 pos: POS;
            \\  float4 color: COLOR;
            \\};
            \\struct vs_out {
            \\  float4 color: COLOR0;
            \\  float4 pos: SV_Position;
            \\};
            \\vs_out main(vs_in inp) {
            \\  vs_out outp;
            \\  outp.pos = inp.pos;
            \\  outp.color = inp.color;
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
