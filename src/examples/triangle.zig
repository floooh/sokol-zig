//------------------------------------------------------------------------------
//  triangle.zig
//
//  Vertex buffer, shader, pipeline state object.
//------------------------------------------------------------------------------
const sokol = @import("sokol");
const sg = sokol.gfx;
const sapp = sokol.app;
const sgapp = sokol.app_gfx_glue;

const State = struct {
    bind: sg.Bindings = .{},
    pip: sg.Pipeline = .{},
};
var state: State = .{};

fn init() callconv(.C) void {
    sg.setup(.{
        .context = sgapp.context()
    });

    // create vertex buffer with triangle vertices
    const vertices = [_]f32 {
        // positions         colors
         0.0,  0.5, 0.5,     1.0, 0.0, 0.0, 1.0,
         0.5, -0.5, 0.5,     0.0, 1.0, 0.0, 1.0,
        -0.5, -0.5, 0.5,     0.0, 0.0, 1.0, 1.0
    };
    state.bind.vertex_buffers[0] = sg.makeBuffer(.{
        .content = &vertices,
        .size = sg.sizeOf(vertices)
    });

    // create a shader and pipeline object
    const shd = sg.makeShader(sg.ShaderDesc.init(.{
        .attrs = .{
            .{ .sem_name="POS" },
            .{ .sem_name="COLOR" }
        },
        // FIXME: hardwired HLSL source
        .vs = .{
            .source =
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
        },
        .fs = .{
            .source =
                \\float4 main(float4 color: COLOR0): SV_Target0 {
                \\  return color;
                \\}
        }
    }));
    state.pip = sg.makePipeline(sg.PipelineDesc.init(.{
        .layout = .{
            .attrs = .{
                .{ .format = .FLOAT3 }, // vertex position
                .{ .format = .FLOAT4 }, // vertex color
            }
        },
        .shader = shd
    }));
}

fn frame() callconv(.C) void {
    // default pass-action clears to grey
    sg.beginDefaultPass(.{}, sapp.width(), sapp.height());
    sg.applyPipeline(state.pip);
    sg.applyBindings(state.bind);
    sg.draw(0, 3, 1);
    sg.endPass();
    sg.commit();
}

fn cleanup() callconv(.C) void {
    sg.shutdown();
}

pub fn main() void {
    sapp.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .width = 640,
        .height = 480,
        .window_title = "triangle.zig"
    });
}
