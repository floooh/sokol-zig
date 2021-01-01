//------------------------------------------------------------------------------
//  offscreen.zig
//
//  Render to an offscreen rendertarget texture, and use this texture
//  for rendering to the display.
//------------------------------------------------------------------------------
const sg = @import("sokol").gfx;
const sapp = @import("sokol").app;
const sgapp = @import("sokol").app_gfx_glue;
const vec3 = @import("math.zig").Vec3;
const mat4 = @import("math.zig").Mat4;

const offscreen_sample_count = 4;

const state = struct {
    const offscreen = struct {
        var pass_action: sg.PassAction = .{};
        var pass: sg.Pass = .{};
        var pip: sg.Pipeline = .{};
        var bind: sg.Bindings = .{};
    };
    const default = struct {
        var pass_action: sg.PassAction = .{};
        var pip: sg.Pipeline = .{};
        var bind: sg.Bindings = .{};
    };
    var rx: f32 = 0.0;
    var ry: f32 = 0.0;
    // the view matrix doesn't change
    const view: mat4 = mat4.lookat(.{ .x=0.0, .y=1.5, .z=6.0 }, vec3.zero(), vec3.up());
};

// a uniform block struct with a model-view-projection matrix
const VsParams = packed struct {
    mvp: mat4
};

export fn init() void {
    sg.setup(.{
        .context = sgapp.context()
    });

    // default pass action: clear to blue-ish
    state.default.pass_action.colors[0] = .{ .action = .CLEAR, .val = .{ 0.0, 0.25, 1.0, 1.0 } };

    // offscreen pass action: clear to black
    state.offscreen.pass_action.colors[0] = .{ .action = .CLEAR };

    // a render pass with one color- and one depth-attachment image
    var img_desc: sg.ImageDesc = .{
        .render_target = true,
        .width = 256,
        .height = 256,
        .pixel_format = .RGBA8,
        .min_filter = .LINEAR,
        .mag_filter = .LINEAR,
        .sample_count = offscreen_sample_count
    };
    const color_img = sg.makeImage(img_desc);
    img_desc.pixel_format = .DEPTH;
    const depth_img = sg.makeImage(img_desc);

    var pass_desc: sg.PassDesc = .{};
    pass_desc.color_attachments[0].image = color_img;
    pass_desc.depth_stencil_attachment.image = depth_img;
    state.offscreen.pass = sg.makePass(pass_desc);

    // cube vertices with positions, colors and tex coords
    const vertices = [_]f32 {
        // pos               color                   uvs
        -1.0, -1.0, -1.0,    1.0, 0.5, 0.5, 1.0,     0.0, 0.0,
         1.0, -1.0, -1.0,    1.0, 0.5, 0.5, 1.0,     1.0, 0.0,
         1.0,  1.0, -1.0,    1.0, 0.5, 0.5, 1.0,     1.0, 1.0,
        -1.0,  1.0, -1.0,    1.0, 0.5, 0.5, 1.0,     0.0, 1.0,

        -1.0, -1.0,  1.0,    0.5, 1.0, 0.5, 1.0,     0.0, 0.0,
         1.0, -1.0,  1.0,    0.5, 1.0, 0.5, 1.0,     1.0, 0.0,
         1.0,  1.0,  1.0,    0.5, 1.0, 0.5, 1.0,     1.0, 1.0,
        -1.0,  1.0,  1.0,    0.5, 1.0, 0.5, 1.0,     0.0, 1.0,

        -1.0, -1.0, -1.0,    0.5, 0.5, 1.0, 1.0,     0.0, 0.0,
        -1.0,  1.0, -1.0,    0.5, 0.5, 1.0, 1.0,     1.0, 0.0,
        -1.0,  1.0,  1.0,    0.5, 0.5, 1.0, 1.0,     1.0, 1.0,
        -1.0, -1.0,  1.0,    0.5, 0.5, 1.0, 1.0,     0.0, 1.0,

         1.0, -1.0, -1.0,    1.0, 0.5, 0.0, 1.0,     0.0, 0.0,
         1.0,  1.0, -1.0,    1.0, 0.5, 0.0, 1.0,     1.0, 0.0,
         1.0,  1.0,  1.0,    1.0, 0.5, 0.0, 1.0,     1.0, 1.0,
         1.0, -1.0,  1.0,    1.0, 0.5, 0.0, 1.0,     0.0, 1.0,

        -1.0, -1.0, -1.0,    0.0, 0.5, 1.0, 1.0,     0.0, 0.0,
        -1.0, -1.0,  1.0,    0.0, 0.5, 1.0, 1.0,     1.0, 0.0,
         1.0, -1.0,  1.0,    0.0, 0.5, 1.0, 1.0,     1.0, 1.0,
         1.0, -1.0, -1.0,    0.0, 0.5, 1.0, 1.0,     0.0, 1.0,

        -1.0,  1.0, -1.0,    1.0, 0.0, 0.5, 1.0,     0.0, 0.0,
        -1.0,  1.0,  1.0,    1.0, 0.0, 0.5, 1.0,     1.0, 0.0,
         1.0,  1.0,  1.0,    1.0, 0.0, 0.5, 1.0,     1.0, 1.0,
         1.0,  1.0, -1.0,    1.0, 0.0, 0.5, 1.0,     0.0, 1.0
    };
    const vbuf = sg.makeBuffer(.{
        .type = .VERTEXBUFFER,
        .content = &vertices,
        .size = @sizeOf(@TypeOf(vertices))
    });

    // cube indices
    const indices = [_]u16 {
        0, 1, 2,  0, 2, 3,
        6, 5, 4,  7, 6, 4,
        8, 9, 10,  8, 10, 11,
        14, 13, 12,  15, 14, 12,
        16, 17, 18,  16, 18, 19,
        22, 21, 20,  23, 22, 20
    };
    const ibuf = sg.makeBuffer(.{
        .type = .INDEXBUFFER,
        .content = &indices,
        .size = @sizeOf(@TypeOf(indices))
    });

    // shader and pipeline object for offscreen rendering
    var offscreen_pip_desc: sg.PipelineDesc = .{
        .shader = sg.makeShader(offscreenShaderDesc()),
        .index_type = .UINT16,
        .depth_stencil = .{
            .depth_compare_func = .LESS_EQUAL,
            .depth_write_enabled = true,
        },
        .blend = .{
            .color_format = .RGBA8,
            .depth_format = .DEPTH
        },
        .rasterizer = .{
            .cull_mode = .BACK,
            .sample_count = offscreen_sample_count
        }
    };
    offscreen_pip_desc.layout.buffers[0].stride = 36;       // need to provide vertex stride because texcoords are skipped
    offscreen_pip_desc.layout.attrs[0].format = .FLOAT3;    // position vertex component
    offscreen_pip_desc.layout.attrs[1].format = .FLOAT4;    // color vertex component
    state.offscreen.pip = sg.makePipeline(offscreen_pip_desc);

    // shader and pipeline object for the default render pass
    var default_pip_desc: sg.PipelineDesc = .{
        .shader = sg.makeShader(defaultShaderDesc()),
        .index_type = .UINT16,
        .depth_stencil = .{
            .depth_compare_func = .LESS_EQUAL,
            .depth_write_enabled = true,
        },
        .rasterizer = .{
            .cull_mode = .BACK
        }
    };
    default_pip_desc.layout.attrs[0].format = .FLOAT3;      // position vertex component
    default_pip_desc.layout.attrs[1].format = .FLOAT4;      // color vertex component
    default_pip_desc.layout.attrs[2].format = .FLOAT2;      // texcoord vertex component
    state.default.pip = sg.makePipeline(default_pip_desc);

    // resource bindings to render a non-textured cube (into the offscreen render target)
    state.offscreen.bind.vertex_buffers[0] = vbuf;
    state.offscreen.bind.index_buffer = ibuf;

    // resource bindings to render a textured cube, using the offscreen render target as texture
    state.default.bind.vertex_buffers[0] = vbuf;
    state.default.bind.index_buffer = ibuf;
    state.default.bind.fs_images[0] = color_img;
}

export fn frame() void {

    state.rx += 1.0;
    state.ry += 2.0;
    const vs_params = computeVsParams(state.rx, state.ry);

    // the offscreen pass, rendering a rotating untextured cube into a render target image
    sg.beginPass(state.offscreen.pass, state.offscreen.pass_action);
    sg.applyPipeline(state.offscreen.pip);
    sg.applyBindings(state.offscreen.bind);
    sg.applyUniforms(.VS, 0, &vs_params, @sizeOf(@TypeOf(vs_params)));
    sg.draw(0, 36, 1);
    sg.endPass();

    // and the display pass, rendering a rotating textured cube, using the previously
    // rendered offscreen render target as texture
    sg.beginDefaultPass(state.default.pass_action, sapp.width(), sapp.height());
    sg.applyPipeline(state.default.pip);
    sg.applyBindings(state.default.bind);
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
        .sample_count = 4,
        .width = 800,
        .height = 600,
        .window_title = "offscreen.zig"
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

fn offscreenShaderDesc() sg.ShaderDesc {
    var desc: sg.ShaderDesc = .{};
    desc.vs.uniform_blocks[0].size = @sizeOf(VsParams);
    switch (sg.queryBackend()) {
        .D3D11 => {
            desc.attrs[0].sem_name = "POSITION";
            desc.attrs[1].sem_name = "COLOR";
            desc.vs.source =
                \\cbuffer params: register(b0) {
                \\  float4x4 mvp;
                \\};
                \\struct vs_in {
                \\  float4 pos: POSITION;
                \\  float4 color: COLOR0;
                \\};
                \\struct vs_out {
                \\  float4 color: COLOR0;
                \\  float4 pos: SV_Position;
                \\};
                \\vs_out main(vs_in inp) {
                \\  vs_out outp;
                \\  outp.pos = mul(mvp, inp.pos);
                \\  outp.color = inp.color;
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
            desc.vs.uniform_blocks[0].uniforms[0] = .{ .name="mvp", .type=.MAT4 };
            desc.vs.source =
                \\ #version 330
                \\ uniform mat4 mvp;
                \\ layout(location=0) in vec4 position;
                \\ layout(location=1) in vec4 color0;
                \\ out vec4 color;
                \\ void main() {
                \\   gl_Position = mvp * position;
                \\   color = color0;
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
                \\ struct params_t {
                \\   float4x4 mvp;
                \\ };
                \\ struct vs_in {
                \\   float4 position [[attribute(0)]];
                \\   float4 color [[attribute(1)]];
                \\ };
                \\ struct vs_out {
                \\   float4 pos [[position]];
                \\   float4 color;
                \\ };
                \\ vertex vs_out _main(vs_in in [[stage_in]], constant params_t& params [[buffer(0)]]) {
                \\   vs_out out;
                \\   out.pos = params.mvp * in.position;
                \\   out.color = in.color;
                \\   return out;
                \\ }
                ;
            desc.fs.source =
                \\ #include <metal_stdlib>
                \\ using namespace metal;
                \\ fragment float4 _main(float4 color [[stage_in]]) {
                \\   return color;
                \\ };
                ;
        },
        else => {}
    }
    return desc;
}

fn defaultShaderDesc() sg.ShaderDesc {
    var desc: sg.ShaderDesc = .{};
    desc.vs.uniform_blocks[0].size = @sizeOf(VsParams);
    switch (sg.queryBackend()) {
        .D3D11 => {
            desc.attrs[0].sem_name = "POSITION";
            desc.attrs[1].sem_name = "COLOR";
            desc.attrs[2].sem_name = "TEXCOORD";
            desc.fs.images[0].type = ._2D;
            desc.vs.source =
                \\cbuffer params: register(b0) {
                \\  float4x4 mvp;
                \\};
                \\struct vs_in {
                \\  float4 pos: POSITION;
                \\  float4 color: COLOR0;
                \\  float2 uv: TEXCOORD0;
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
                \\  outp.uv = inp.uv;
                \\  return outp;
                \\}
            ;
            desc.fs.source =
                \\Texture2D<float4> tex: register(t0);
                \\sampler smp: register(s0);
                \\float4 main(float4 color: COLOR0, float2 uv: TEXCOORD0): SV_Target0 {
                \\  return tex.Sample(smp, uv) + color * 0.5;
                \\}
            ;
        },
        .GLCORE33 => {
            desc.vs.uniform_blocks[0].uniforms[0] = .{ .name="mvp", .type=.MAT4 };
            desc.fs.images[0] = .{ .name="tex", .type=._2D };
            desc.vs.source =
                \\ #version 330
                \\ uniform mat4 mvp;
                \\ layout(location=0) in vec4 position;
                \\ layout(location=1) in vec4 color0;
                \\ layout(location=2) in vec2 texcoord0;
                \\ out vec4 color;
                \\ out vec2 uv;
                \\ void main() {
                \\   gl_Position = mvp * position;
                \\   color = color0;
                \\   uv = texcoord0;
                \\ }
                ;
            desc.fs.source =
                \\ #version 330
                \\ uniform sampler2D tex;
                \\ in vec4 color;
                \\ in vec2 uv;
                \\ out vec4 frag_color;
                \\ void main() {
                \\   frag_color = texture(tex, uv) + color * 0.5;
                \\ }
                ;
        },
        .METAL_MACOS => {
            desc.fs.images[0].type = ._2D;
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
                \\ vertex vs_out _main(vs_in in [[stage_in]], constant params_t& params [[buffer(0)]]) {
                \\   vs_out out;
                \\   out.pos = params.mvp * in.position;
                \\   out.color = in.color;
                \\   out.uv = in.uv;
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
                \\ fragment float4 _main(fs_in in [[stage_in]], texture2d<float> tex [[texture(0)]], sampler smp [[sampler(0)]]) {
                \\   return float4(tex.sample(smp, in.uv).xyz + in.color.xyz * 0.5, 1.0);
                \\ };
                ;
        },
        else => {}
    }
    return desc;
}
