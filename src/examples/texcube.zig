//------------------------------------------------------------------------------
//  texcube.zig
//
//  Texture creation, rendering with texture, packed vertex components.
//------------------------------------------------------------------------------
const sg    = @import("sokol").gfx;
const sapp  = @import("sokol").app;
const sgapp = @import("sokol").app_gfx_glue;
const vec3  = @import("math.zig").Vec3;
const mat4  = @import("math.zig").Mat4;

const state = struct {
    var rx: f32 = 0.0;
    var ry: f32 = 0.0;
    var pass_action: sg.PassAction = .{};
    var pip: sg.Pipeline = .{};
    var bind: sg.Bindings = .{};
    const view: mat4 = mat4.lookat(.{ .x=0.0, .y=1.5, .z=6.0 }, vec3.zero(), vec3.up());
};

// a uniform block struct with a model-view-projection matrix
const VsParams = packed struct {
    mvp: mat4
};

// a vertex struct with position, color and uv-coords
const Vertex = packed struct {
    x: f32, y: f32, z: f32,
    color: u32,
    u: i16, v: i16
};

export fn init() void {
    sg.setup(.{
        .context = sgapp.context()
    });

    // Cube vertex buffer with packed vertex formats for color and texture coords.
    // Note that a vertex format which must be portable across all
    // backends must only use the normalized integer formats
    // (BYTE4N, UBYTE4N, SHORT2N, SHORT4N), which can be converted
    // to floating point formats in the vertex shader inputs.
    // The reason is that D3D11 cannot convert from non-normalized
    // formats to floating point inputs (only to integer inputs),
    // and WebGL2 / GLES2 don't support integer vertex shader inputs.
    const vertices = [_]Vertex {
        // pos                         color              texcoords
        .{ .x=-1.0, .y=-1.0, .z=-1.0,  .color=0xFF0000FF, .u=    0, .v=    0 },
        .{ .x= 1.0, .y=-1.0, .z=-1.0,  .color=0xFF0000FF, .u=32767, .v=    0 },
        .{ .x= 1.0, .y= 1.0, .z=-1.0,  .color=0xFF0000FF, .u=32767, .v=32767 },
        .{ .x=-1.0, .y= 1.0, .z=-1.0,  .color=0xFF0000FF, .u=    0, .v=32767 },

        .{ .x=-1.0, .y=-1.0, .z= 1.0,  .color=0xFF00FF00, .u=    0, .v=    0 },
        .{ .x= 1.0, .y=-1.0, .z= 1.0,  .color=0xFF00FF00, .u=32767, .v=    0 },
        .{ .x= 1.0, .y= 1.0, .z= 1.0,  .color=0xFF00FF00, .u=32767, .v=32767 },
        .{ .x=-1.0, .y= 1.0, .z= 1.0,  .color=0xFF00FF00, .u=    0, .v=32767 },

        .{ .x=-1.0, .y=-1.0, .z=-1.0,  .color=0xFFFF0000, .u=    0, .v=    0 },
        .{ .x=-1.0, .y= 1.0, .z=-1.0,  .color=0xFFFF0000, .u=32767, .v=    0 },
        .{ .x=-1.0, .y= 1.0, .z= 1.0,  .color=0xFFFF0000, .u=32767, .v=32767 },
        .{ .x=-1.0, .y=-1.0, .z= 1.0,  .color=0xFFFF0000, .u=    0, .v=32767 },

        .{ .x= 1.0, .y=-1.0, .z=-1.0,  .color=0xFFFF007F, .u=    0, .v=    0 },
        .{ .x= 1.0, .y= 1.0, .z=-1.0,  .color=0xFFFF007F, .u=32767, .v=    0 },
        .{ .x= 1.0, .y= 1.0, .z= 1.0,  .color=0xFFFF007F, .u=32767, .v=32767 },
        .{ .x= 1.0, .y=-1.0, .z= 1.0,  .color=0xFFFF007F, .u=    0, .v=32767 },

        .{ .x=-1.0, .y=-1.0, .z=-1.0,  .color=0xFFFF7F00, .u=    0, .v=    0 },
        .{ .x=-1.0, .y=-1.0, .z= 1.0,  .color=0xFFFF7F00, .u=32767, .v=    0 },
        .{ .x= 1.0, .y=-1.0, .z= 1.0,  .color=0xFFFF7F00, .u=32767, .v=32767 },
        .{ .x= 1.0, .y=-1.0, .z=-1.0,  .color=0xFFFF7F00, .u=    0, .v=32767 },

        .{ .x=-1.0, .y= 1.0, .z=-1.0,  .color=0xFF007FFF, .u=    0, .v=    0 },
        .{ .x=-1.0, .y= 1.0, .z= 1.0,  .color=0xFF007FFF, .u=32767, .v=    0 },
        .{ .x= 1.0, .y= 1.0, .z= 1.0,  .color=0xFF007FFF, .u=32767, .v=32767 },
        .{ .x= 1.0, .y= 1.0, .z=-1.0,  .color=0xFF007FFF, .u=    0, .v=32767 },
    };
    state.bind.vertex_buffers[0] = sg.makeBuffer(.{
        .data = sg.asRange(vertices)
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
        .data = sg.asRange(indices)
    });

    // create a small checker-board texture
    const pixels = [4*4]u32 {
        0xFFFFFFFF, 0xFF000000, 0xFFFFFFFF, 0xFF000000,
        0xFF000000, 0xFFFFFFFF, 0xFF000000, 0xFFFFFFFF,
        0xFFFFFFFF, 0xFF000000, 0xFFFFFFFF, 0xFF000000,
        0xFF000000, 0xFFFFFFFF, 0xFF000000, 0xFFFFFFFF,
    };
    var img_desc: sg.ImageDesc = .{
        .width = 4,
        .height = 4,
    };
    img_desc.data.subimage[0][0] = sg.asRange(pixels);
    state.bind.fs_images[0] = sg.makeImage(img_desc);

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
    pip_desc.layout.attrs[1].format = .UBYTE4N;
    pip_desc.layout.attrs[2].format = .SHORT2N;
    state.pip = sg.makePipeline(pip_desc);

    // pass action for clearing the frame buffer
    state.pass_action.colors[0] = .{ .action = .CLEAR, .val = .{ 0.25, 0.5, 0.75, 1.0 } };
}

export fn frame() void {

    state.rx += 1.0;
    state.ry += 2.0;
    const vs_params = computeVsParams(state.rx, state.ry);

    sg.beginDefaultPass(state.pass_action, sapp.width(), sapp.height());
    sg.applyPipeline(state.pip);
    sg.applyBindings(state.bind);
    sg.applyUniforms(.VS, 0, sg.asRange(vs_params));
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
        .sample_count = 4,
        .window_title = "texcube.zig"
    });
}

fn computeVsParams(rx: f32, ry: f32) VsParams {
    const rxm = mat4.rotate(rx, .{ .x=1.0, .y=0.0, .z=0.0 });
    const rym = mat4.rotate(ry, .{ .x=0.0, .y=1.0, .z=0.0 });
    const model = mat4.mul(rxm, rym);
    const aspect = sapp.widthf() / sapp.heightf();
    const proj = mat4.persp(60.0, aspect, 0.01, 10.0);
    return VsParams {
        .mvp = mat4.mul(mat4.mul(proj, state.view), model)
    };
}

// build a backend-specific ShaderDesc struct
fn shaderDesc() sg.ShaderDesc {
    var desc: sg.ShaderDesc = .{};
    desc.vs.uniform_blocks[0].size = @sizeOf(VsParams);
    desc.fs.images[0].type = ._2D;
    switch (sg.queryBackend()) {
        .D3D11 => {
            desc.attrs[0].sem_name = "POSITION";
            desc.attrs[1].sem_name = "COLOR";
            desc.attrs[2].sem_name = "TEXCOORD";
            desc.vs.source =
                \\cbuffer params: register(b0) {
                \\  float4x4 mvp;
                \\};
                \\struct vs_in {
                \\  float4 pos: POSITION;
                \\  float4 color: COLOR;
                \\  float2 uv: TEXCOORD;
                \\};
                \\struct vs_out {
                \\  float4 color: COLOR0;
                \\  float2 uv: TEXCOORD0;
                \\  float4 pos: SV_Position;
                \\};
                \\vs_out main(vs_in inp) {
                \\  vs_out outp;
                \\  outp.pos = mul(mvp, inp.pos);
                \\  outp.color = inp.color;
                \\  outp.uv = inp.uv * 5.0;
                \\  return outp;
                \\};
                ;
            desc.fs.source =
                \\Texture2D<float4> tex: register(t0);
                \\sampler smp: register(s0);
                \\float4 main(float4 color: COLOR0, float2 uv: TEXCOORD0): SV_Target0 {
                \\  return tex.Sample(smp, uv) * color;
                \\}
                ;
        },
        .GLCORE33 => {
            desc.vs.uniform_blocks[0].uniforms[0] = .{ .name="mvp", .type=.MAT4 };
            desc.fs.images[0].name = "tex";
            desc.vs.source =
                \\ #version 330
                \\ uniform mat4 mvp;
                \\ layout(location = 0) in vec4 position;
                \\ layout(location = 1) in vec4 color0;
                \\ layout(location = 2) in vec2 texcoord0;
                \\ out vec4 color;
                \\ out vec2 uv;
                \\ void main() {
                \\   gl_Position = mvp * position;
                \\   color = color0;
                \\   uv = texcoord0 * 5.0;
                \\ }
                ;
            desc.fs.source =
                \\ #version 330
                \\ uniform sampler2D tex;
                \\ in vec4 color;
                \\ in vec2 uv;
                \\ out vec4 frag_color;
                \\ void main() {
                \\   frag_color = texture(tex, uv) * color;
                \\ }
                ;
        },
        .METAL_MACOS => {
            desc.vs.entry = "vs_main";
            desc.fs.entry = "fs_main";
            desc.vs.source =
                \\ #include <metal_stdlib>
                \\ using namespace metal;
                \\ struct params_t {
                \\   float4x4 mvp;
                \\ };
                \\ struct vs_in {
                \\   float4 position [[attribute(0)]];
                \\   float4 color [[attribute(1)]];
                \\   float2 uv [[attribute(2)]];
                \\ };
                \\ struct vs_out {
                \\   float4 pos [[position]];
                \\   float4 color;
                \\   float2 uv;
                \\ };
                \\ vertex vs_out vs_main(vs_in in [[stage_in]], constant params_t& params [[buffer(0)]]) {
                \\   vs_out out;
                \\   out.pos = params.mvp * in.position;
                \\   out.color = in.color;
                \\   out.uv = in.uv * 5.0;
                \\   return out;
                \\ }
                ;
            desc.fs.source =
                \\ #include <metal_stdlib>
                \\ using namespace metal;
                \\ struct fs_in {
                \\   float4 color;
                \\   float2 uv;
                \\ };
                \\ fragment float4 fs_main(fs_in in [[stage_in]],
                \\   texture2d<float> tex [[texture(0)]],
                \\   sampler smp [[sampler(0)]])
                \\ {
                \\   return float4(tex.sample(smp, in.uv).xyz, 1.0) * in.color;
                \\ };
                ;
        },
        else => {}
    }
    return desc;
}




