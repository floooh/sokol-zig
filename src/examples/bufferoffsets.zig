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
        .data = .{
            .ptr = &vertices,
            .size = @sizeOf(@TypeOf(vertices))
        }
    });
    state.bind.index_buffer = sg.makeBuffer(.{
        .type = .INDEXBUFFER,
        .data = .{
            .ptr = &indices,
            .size = @sizeOf(@TypeOf(indices))
        }
    });

    // a shader and pipeline object
    var pip_desc: sg.PipelineDesc = .{
        .shader = sg.makeShader(shaderDesc()),
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

fn shaderDesc() sg.ShaderDesc {
    var desc: sg.ShaderDesc = .{};
    switch (sg.queryBackend()) {
        .D3D11 => {
            desc.attrs[0].sem_name = "POSITION";
            desc.attrs[1].sem_name = "COLOR";
            desc.vs.source =
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
                ;
            desc.fs.source =
                \\float4 main(float4 color: COLOR0): SV_Target0 {
                \\  return color;
                \\}
                ;
        },
        .GLCORE33 => {
            desc.vs.source =
                \\ #version 330
                \\ layout(location=0) in vec2 pos;
                \\ layout(location=1) in vec3 color0;
                \\ out vec4 color;
                \\ void main() {
                \\   gl_Position = vec4(pos, 0.5, 1.0);
                \\   color = vec4(color0, 1.0);
                \\ }
                ;
            desc.fs.source =
                \\ #version 330
                \\ in vec4 color;
                \\ out vec4 frag_color;
                \\ void main() {
                \\   frag_color = color;
                \\ }
                ;
        },
        .METAL_MACOS => {
            desc.vs.source =
                \\ #include <metal_stdlib>
                \\ using namespace metal;
                \\ struct vs_in {
                \\   float2 pos [[attribute(0)]];
                \\   float3 color [[attribute(1)]];
                \\ };
                \\ struct vs_out {
                \\   float4 pos [[position]];
                \\   float4 color;
                \\ };
                \\ vertex vs_out _main(vs_in in [[stage_in]]) {
                \\   vs_out out;
                \\   out.pos = float4(in.pos, 0.5f, 1.0f);
                \\   out.color = float4(in.color, 1.0);
                \\   return out;
                \\ }
                ;
            desc.fs.source =
                \\ #include <metal_stdlib>
                \\ using namespace metal;
                \\ fragment float4 _main(float4 color [[stage_in]]) {
                \\   return color;
                \\ }
                ;
        },
        else => {}
    }
    return desc;
}
