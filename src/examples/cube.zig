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

const State = struct {
    rx: f32 = 0.0,
    ry: f32 = 0.0,
    pip: sg.Pipeline = .{},
    bind: sg.Bindings = .{},
    pass_action: sg.PassAction = .{},
    // the view matrix doesn't change
    view: mat4 = mat4.lookat(.{ .x=0.0, .y=1.5, .z=6.0 }, vec3.zero(), vec3.up())
};
var state: State = .{};

// a uniform block struct with a model-view-project matrix
const VsParams = packed struct {
    mvp: mat4
};

export fn init() void {
    sg.setup(.{
        .context = sgapp.context()
    });

    // cube vertex buffer
    const vertices = [_] f32 {
        -1.0, -1.0, -1.0,   1.0, 0.0, 0.0, 1.0,
         1.0, -1.0, -1.0,   1.0, 0.0, 0.0, 1.0,
         1.0,  1.0, -1.0,   1.0, 0.0, 0.0, 1.0,
        -1.0,  1.0, -1.0,   1.0, 0.0, 0.0, 1.0,

        -1.0, -1.0,  1.0,   0.0, 1.0, 0.0, 1.0,
         1.0, -1.0,  1.0,   0.0, 1.0, 0.0, 1.0,
         1.0,  1.0,  1.0,   0.0, 1.0, 0.0, 1.0,
        -1.0,  1.0,  1.0,   0.0, 1.0, 0.0, 1.0,

        -1.0, -1.0, -1.0,   0.0, 0.0, 1.0, 1.0,
        -1.0,  1.0, -1.0,   0.0, 0.0, 1.0, 1.0,
        -1.0,  1.0,  1.0,   0.0, 0.0, 1.0, 1.0,
        -1.0, -1.0,  1.0,   0.0, 0.0, 1.0, 1.0,

        1.0, -1.0, -1.0,    1.0, 0.5, 0.0, 1.0,
        1.0,  1.0, -1.0,    1.0, 0.5, 0.0, 1.0,
        1.0,  1.0,  1.0,    1.0, 0.5, 0.0, 1.0,
        1.0, -1.0,  1.0,    1.0, 0.5, 0.0, 1.0,

        -1.0, -1.0, -1.0,   0.0, 0.5, 1.0, 1.0,
        -1.0, -1.0,  1.0,   0.0, 0.5, 1.0, 1.0,
         1.0, -1.0,  1.0,   0.0, 0.5, 1.0, 1.0,
         1.0, -1.0, -1.0,   0.0, 0.5, 1.0, 1.0,

        -1.0,  1.0, -1.0,   1.0, 0.0, 0.5, 1.0,
        -1.0,  1.0,  1.0,   1.0, 0.0, 0.5, 1.0,
         1.0,  1.0,  1.0,   1.0, 0.0, 0.5, 1.0,
         1.0,  1.0, -1.0,   1.0, 0.0, 0.5, 1.0
    };
    state.bind.vertex_buffers[0] = sg.makeBuffer(.{
        .content = &vertices,
        .size = @sizeOf(@TypeOf(vertices))
    });

    // cube index buffer
    const indices = [_]u16 {
        0, 1, 2,  0, 2, 3,
        6, 5, 4,  7, 6, 4,
        8, 9, 10,  8, 10, 11,
        14, 13, 12,  15, 14, 12,
        16, 17, 18,  16, 18, 19,
        22, 21, 20,  23, 22, 20
    };
    state.bind.index_buffer = sg.makeBuffer(.{
        .type = .INDEXBUFFER,
        .content = &indices,
        .size = @sizeOf(@TypeOf(indices))
    });

    // shader and pipeline object
    const shd = sg.makeShader(shaderDesc());
    var pip_desc: sg.PipelineDesc = .{
        .shader = shd,
        .index_type = .UINT16,
        .depth_stencil = .{
            .depth_compare_func = .LESS_EQUAL,
            .depth_write_enabled = true,
        },
        .rasterizer = .{
            .cull_mode = .BACK
        }
    };
    pip_desc.layout.attrs[0].format = .FLOAT3;
    pip_desc.layout.attrs[1].format = .FLOAT4;
    state.pip = sg.makePipeline(pip_desc);

    // framebuffer clear color
    state.pass_action.colors[0] = .{ .action=.CLEAR, .val=.{ 0.25, 0.5, 0.75, 1.0 } };
}

export fn frame() void {

    state.rx += 1.0;
    state.ry += 2.0;
    const vs_params = computeVsParams(state.rx, state.ry);

    sg.beginDefaultPass(state.pass_action, sapp.width(), sapp.height());
    sg.applyPipeline(state.pip);
    sg.applyBindings(state.bind);
    sg.applyUniforms(.VS, 0, &vs_params, @sizeOf(@TypeOf(vs_params)));
    sg.draw(0, 36, 1);
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

fn computeVsParams(rx: f32, ry: f32) VsParams {
    const rxm = mat4.rotate(rx, .{ .x=1.0, .y=0.0, .z=0.0 });
    const rym = mat4.rotate(ry, .{ .x=0.0, .y=1.0, .z=0.0 });
    const model = mat4.mul(rxm, rym);
    const aspect = @intToFloat(f32, sapp.width()) / @intToFloat(f32, sapp.height());
    const proj = mat4.persp(60.0, aspect, 0.01, 10.0);
    return VsParams {
        .mvp = mat4.mul(mat4.mul(proj, state.view), model)
    };
}

// build a backend-specific ShaderDesc struct
fn shaderDesc() sg.ShaderDesc {
    var desc: sg.ShaderDesc = .{};
    switch (sg.queryBackend()) {
        .D3D11 => {
            // NOTE: there's no particular reason why the sem_index of COLOR is 1,
            // this is just testing whether semantic indices != 0 work as expected
            desc.attrs[0] = .{ .sem_name="POSITION" };
            desc.attrs[1] = .{ .sem_name="COLOR", .sem_index=1 };
            desc.vs.uniform_blocks[0].size = @sizeOf(VsParams);
            desc.vs.source =
                \\ cbuffer params: register(b0) {
                \\   float4x4 mvp;
                \\ };
                \\ struct vs_in {
                \\   float4 pos: POSITION;
                \\   float4 color: COLOR1;
                \\ };
                \\ struct vs_out {
                \\   float4 color: COLOR0;
                \\   float4 pos: SV_Position;
                \\ };
                \\ vs_out main(vs_in inp) {
                \\   vs_out outp;
                \\   outp.pos = mul(mvp, inp.pos);
                \\   outp.color = inp.color;
                \\   return outp;
                \\ }
                ;
            desc.fs.source =
                \\ float4 main(float4 color: COLOR0): SV_Target0 {
                \\   return color;
                \\ }
                ;
        },
        else => {}
    }
    return desc;
}

