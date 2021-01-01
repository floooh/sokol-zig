//------------------------------------------------------------------------------
//  mrt.zig
//
//  Rendering with multiple-rendertargets, and reallocate render targets
//  on window resize events.
//
//  NOTE: the rotation direction will appear different on the different
//  backend 3D APIs. This is because of the different image origin conventions
//  in GL vs D3D vs Metal. We don't care about those differences in this sample
//  (using the sokol shader compiler allows to easily 'normalize' those differences.
//------------------------------------------------------------------------------
const math  = @import("std").math;
const sg    = @import("sokol").gfx;
const sapp  = @import("sokol").app;
const sgapp = @import("sokol").app_gfx_glue;
const vec2  = @import("math.zig").Vec2;
const vec3  = @import("math.zig").Vec3;
const mat4  = @import("math.zig").Mat4;

const offscreen_sample_count = 4;

const state = struct {
    const offscreen = struct {
        var pass_action: sg.PassAction = .{};
        var pass_desc: sg.PassDesc = .{};
        var pass: sg.Pass = .{};
        var pip: sg.Pipeline = .{};
        var bind: sg.Bindings = .{};
    };
    const fsq = struct {
        var pip: sg.Pipeline = .{};
        var bind: sg.Bindings = .{};
    };
    const dbg = struct {
        var pip: sg.Pipeline = .{};
        var bind: sg.Bindings = .{};
    };
    const default = struct {
        var pass_action: sg.PassAction = .{};
    };
    var rx: f32 = 0.0;
    var ry: f32 = 0.0;
    const view: mat4 = mat4.lookat(.{ .x=0.0, .y=1.5, .z=6.0 }, vec3.zero(), vec3.up());
};

const OffscreenVsParams = packed struct {
    mvp: mat4,
};

const FsqVsParams = packed struct {
    offset: vec2,
};

export fn init() void {
    sg.setup(.{
        .context = sgapp.context()
    });

    // setup pass action for default render pass
    state.default.pass_action.colors[0] = .{ .action = .DONTCARE };
    state.default.pass_action.depth     = .{ .action = .DONTCARE };
    state.default.pass_action.stencil   = .{ .action = .DONTCARE };

    // set pass action for offscreen render pass
    state.offscreen.pass_action.colors[0] = .{ .action = .CLEAR, .val = .{ 0.25, 0.0, 0.0, 1.0 } };
    state.offscreen.pass_action.colors[1] = .{ .action = .CLEAR, .val = .{ 0.0, 0.25, 0.0, 1.0 } };
    state.offscreen.pass_action.colors[2] = .{ .action = .CLEAR, .val = .{ 0.0, 0.0, 0.25, 1.0 } };

    // setup the offscreen render pass and render target images,
    // this will also be called when the window resizes
    createOffscreenPass(sapp.width(), sapp.height());

    // create vertex buffer for a cube
    const cube_vertices = [_]f32 {
        // positions        brightness
        -1.0, -1.0, -1.0,   1.0,
         1.0, -1.0, -1.0,   1.0,
         1.0,  1.0, -1.0,   1.0,
        -1.0,  1.0, -1.0,   1.0,

        -1.0, -1.0,  1.0,   0.8,
         1.0, -1.0,  1.0,   0.8,
         1.0,  1.0,  1.0,   0.8,
        -1.0,  1.0,  1.0,   0.8,

        -1.0, -1.0, -1.0,   0.6,
        -1.0,  1.0, -1.0,   0.6,
        -1.0,  1.0,  1.0,   0.6,
        -1.0, -1.0,  1.0,   0.6,

         1.0, -1.0, -1.0,   0.4,
         1.0,  1.0, -1.0,   0.4,
         1.0,  1.0,  1.0,   0.4,
         1.0, -1.0,  1.0,   0.4,

        -1.0, -1.0, -1.0,   0.5,
        -1.0, -1.0,  1.0,   0.5,
         1.0, -1.0,  1.0,   0.5,
         1.0, -1.0, -1.0,   0.5,

        -1.0,  1.0, -1.0,   0.7,
        -1.0,  1.0,  1.0,   0.7,
         1.0,  1.0,  1.0,   0.7,
         1.0,  1.0, -1.0,   0.7
    };
    const cube_vbuf = sg.makeBuffer(.{
        .content = &cube_vertices,
        .size = @sizeOf(@TypeOf(cube_vertices))
    });

    // index buffer for a cube
    const cube_indices = [_]u16 {
        0, 1, 2,  0, 2, 3,
        6, 5, 4,  7, 6, 4,
        8, 9, 10,  8, 10, 11,
        14, 13, 12,  15, 14, 12,
        16, 17, 18,  16, 18, 19,
        22, 21, 20,  23, 22, 20
    };
    const cube_ibuf = sg.makeBuffer(.{
        .type = .INDEXBUFFER,
        .content = &cube_indices,
        .size = @sizeOf(@TypeOf(cube_indices))
    });

    // resource bindings for offscreen rendering
    state.offscreen.bind.vertex_buffers[0] = cube_vbuf;
    state.offscreen.bind.index_buffer = cube_ibuf;

    // shader and pipeline state object for rendering cube into MRT render targets
    var offscreen_pip_desc: sg.PipelineDesc = .{
        .shader = sg.makeShader(offscreenShaderDesc()),
        .index_type = .UINT16,
        .depth_stencil = .{
            .depth_compare_func = .LESS_EQUAL,
            .depth_write_enabled = true,
        },
        .blend = .{
            .color_attachment_count = 3,
            .depth_format = .DEPTH,
        },
        .rasterizer = .{
            .cull_mode = .BACK,
            .sample_count = offscreen_sample_count
        }
    };
    offscreen_pip_desc.layout.attrs[0].format = .FLOAT3;
    offscreen_pip_desc.layout.attrs[1].format = .FLOAT;
    state.offscreen.pip = sg.makePipeline(offscreen_pip_desc);

    // a vertex buffer to render a fullscreen quad
    const quad_vertices = [_]f32 { 0.0, 0.0,  1.0, 0.0,  0.0, 1.0,  1.0, 1.0 };
    const quad_vbuf = sg.makeBuffer(.{
        .content = &quad_vertices,
        .size = @sizeOf(@TypeOf(quad_vertices))
    });

    // shader and pipeline object to render a fullscreen quad which composes
    // the 3 offscreen render targets into the default framebuffer
    var fsq_pip_desc: sg.PipelineDesc = .{
        .shader = sg.makeShader(fsqShaderDesc()),
        .primitive_type = .TRIANGLE_STRIP,
    };
    fsq_pip_desc.layout.attrs[0].format = .FLOAT2;
    state.fsq.pip = sg.makePipeline(fsq_pip_desc);

    // resource bindings to render the fullscreen quad (composed from the
    // offscreen render target textures
    state.fsq.bind.vertex_buffers[0] = quad_vbuf;
    inline for (.{0, 1, 2}) |i| {
        state.fsq.bind.fs_images[i] = state.offscreen.pass_desc.color_attachments[i].image;
    }

    // shader, pipeline and resource bindings to render debug visualization quads
    var dbg_pip_desc: sg.PipelineDesc = .{
        .shader = sg.makeShader(dbgShaderDesc()),
        .primitive_type = .TRIANGLE_STRIP,
    };
    dbg_pip_desc.layout.attrs[0].format = .FLOAT2;
    state.dbg.pip = sg.makePipeline(dbg_pip_desc);

    // resource bindings to render the debug visualization
    // (the required images will be filled in during rendering)
    state.dbg.bind.vertex_buffers[0] = quad_vbuf;
}

export fn frame() void {

    state.rx += 1.0;
    state.ry += 2.0;

    // compute shader uniform data
    const offscreen_params: OffscreenVsParams = .{
        .mvp = computeMVP(state.rx, state.ry)
    };
    const fsq_params: FsqVsParams = .{
        .offset = .{ .x = math.sin(state.rx * 0.01) * 0.1, .y = math.cos(state.ry * 0.01) * 0.1 }
    };

    // render cube into MRT offscreen render targets
    sg.beginPass(state.offscreen.pass, state.offscreen.pass_action);
    sg.applyPipeline(state.offscreen.pip);
    sg.applyBindings(state.offscreen.bind);
    sg.applyUniforms(.VS, 0, &offscreen_params, @sizeOf(@TypeOf(offscreen_params)));
    sg.draw(0, 36, 1);
    sg.endPass();

    // render fullscreen quad with the composed offscreen-render images,
    // 3 a small debug view quads at the bottom of the screen
    sg.beginDefaultPass(state.default.pass_action, sapp.width(), sapp.height());
    sg.applyPipeline(state.fsq.pip);
    sg.applyBindings(state.fsq.bind);
    sg.applyUniforms(.VS, 0, &fsq_params, @sizeOf(@TypeOf(fsq_params)));
    sg.draw(0, 4, 1);
    sg.applyPipeline(state.dbg.pip);
    inline for (.{0, 1, 2 }) |i| {
        sg.applyViewport(i * 100, 0, 100, 100, false);
        state.dbg.bind.fs_images[0] = state.offscreen.pass_desc.color_attachments[i].image;
        sg.applyBindings(state.dbg.bind);
        sg.draw(0, 4, 1);
    }
    sg.endPass();
    sg.commit();
}

export fn cleanup() void {
    sg.shutdown();
}

export fn event(ev: [*c]const sapp.Event) void {
    if (ev.*.type == .RESIZED) {
        createOffscreenPass(ev.*.framebuffer_width, ev.*.framebuffer_height);
    }
}

pub fn main() void {
    sapp.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = event,
        .width = 800,
        .height = 600,
        .sample_count = 4,
        .window_title = "mrt.zig"
    });
}

// compute model-view-projection matrix
fn computeMVP(rx: f32, ry: f32) mat4 {
    const rxm = mat4.rotate(rx, .{ .x=1.0, .y=0.0, .z=0.0 });
    const rym = mat4.rotate(ry, .{ .x=0.0, .y=1.0, .z=0.0 });
    const model = mat4.mul(rxm, rym);
    const aspect = @intToFloat(f32, sapp.width()) / @intToFloat(f32, sapp.height());
    const proj = mat4.persp(60.0, aspect, 0.01, 10.0);
    return mat4.mul(mat4.mul(proj, state.view), model);
}

// helper function to create or re-create render target images and pass object for offscreen rendering
fn createOffscreenPass(width: i32, height: i32) void {
    // destroy previous resources (can be called with invalid ids)
    sg.destroyPass(state.offscreen.pass);
    for (state.offscreen.pass_desc.color_attachments) |att| {
        sg.destroyImage(att.image);
    }
    sg.destroyImage(state.offscreen.pass_desc.depth_stencil_attachment.image);

    // create offscreen render target images and pass
    const color_img_desc: sg.ImageDesc = .{
        .render_target = true,
        .width = width,
        .height = height,
        .min_filter = .LINEAR,
        .mag_filter = .LINEAR,
        .wrap_u = .CLAMP_TO_EDGE,
        .wrap_v = .CLAMP_TO_EDGE,
        .sample_count = offscreen_sample_count,
    };
    var depth_img_desc = color_img_desc;
    depth_img_desc.pixel_format = .DEPTH;

    inline for (.{ 0, 1, 2 }) |i| {
        state.offscreen.pass_desc.color_attachments[i].image = sg.makeImage(color_img_desc);
    }
    state.offscreen.pass_desc.depth_stencil_attachment.image = sg.makeImage(depth_img_desc);
    state.offscreen.pass = sg.makePass(state.offscreen.pass_desc);

    // update the fullscreen-quad texture bindings
    inline for (.{ 0, 1, 2 }) |i| {
        state.fsq.bind.fs_images[i] = state.offscreen.pass_desc.color_attachments[i].image;
    }
}

// helper functions to build backend-specific ShaderDesc structs
fn offscreenShaderDesc() sg.ShaderDesc {
    var desc: sg.ShaderDesc = .{};
    desc.vs.uniform_blocks[0].size = @sizeOf(OffscreenVsParams);
    switch (sg.queryBackend()) {
        .D3D11 => {
            desc.attrs[0].sem_name = "POSITION";
            desc.attrs[1].sem_name = "BRIGHT";
            desc.vs.source =
                \\ cbuffer params: register(b0) {
                \\   float4x4 mvp;
                \\ };
                \\ struct vs_in {
                \\   float4 pos: POSITION;
                \\   float bright: BRIGHT;
                \\ };
                \\ struct vs_out {
                \\   float bright: BRIGHT;
                \\   float4 pos: SV_Position;
                \\ };
                \\ vs_out main(vs_in inp) {
                \\   vs_out outp;
                \\   outp.pos = mul(mvp, inp.pos);
                \\   outp.bright = inp.bright;
                \\   return outp;
                \\ }
            ;
            desc.fs.source =
                \\ struct fs_out {
                \\   float4 c0: SV_Target0;
                \\   float4 c1: SV_Target1;
                \\   float4 c2: SV_Target2;
                \\ };
                \\ fs_out main(float b: BRIGHT) {
                \\   fs_out outp;
                \\   outp.c0 = float4(b, 0.0, 0.0, 1.0);
                \\   outp.c1 = float4(0.0, b, 0.0, 1.0);
                \\   outp.c2 = float4(0.0, 0.0, b, 1.0);
                \\   return outp;
                \\ }
            ;
        },
        .GLCORE33 => {
            desc.vs.uniform_blocks[0].uniforms[0] = .{ .name="mvp", .type=.MAT4 };
            desc.vs.source =
                \\ #version 330
                \\ uniform mat4 mvp;
                \\ layout(location=0) in vec4 position;
                \\ layout(location=1) in float bright0;
                \\ out float bright;
                \\ void main() {
                \\   gl_Position = mvp * position;
                \\   bright = bright0;
                \\ }
                ;
            desc.fs.source =
                \\ #version 330
                \\ in float bright;
                \\ layout(location=0) out vec4 frag_color_0;
                \\ layout(location=1) out vec4 frag_color_1;
                \\ layout(location=2) out vec4 frag_color_2;
                \\ void main() {
                \\   frag_color_0 = vec4(bright, 0.0, 0.0, 1.0);
                \\   frag_color_1 = vec4(0.0, bright, 0.0, 1.0);
                \\   frag_color_2 = vec4(0.0, 0.0, bright, 1.0);
                \\ }
                ;
        },
        .METAL_MACOS => {
            desc.vs.source =
                \\#include <metal_stdlib>
                \\using namespace metal;
                \\struct params_t {
                \\  float4x4 mvp;
                \\};
                \\struct vs_in {
                \\  float4 pos [[attribute(0)]];
                \\  float bright [[attribute(1)]];
                \\};
                \\struct vs_out {
                \\  float4 pos [[position]];
                \\  float bright;
                \\};
                \\vertex vs_out _main(vs_in in [[stage_in]], constant params_t& params [[buffer(0)]]) {
                \\  vs_out out;
                \\  out.pos = params.mvp * in.pos;
                \\  out.bright = in.bright;
                \\  return out;
                \\}
                ;
            desc.fs.source =
                \\ #include <metal_stdlib>
                \\ using namespace metal;
                \\ struct fs_out {
                \\   float4 color0 [[color(0)]];
                \\   float4 color1 [[color(1)]];
                \\   float4 color2 [[color(2)]];
                \\ };
                \\ fragment fs_out _main(float bright [[stage_in]]) {
                \\   fs_out out;
                \\   out.color0 = float4(bright, 0.0, 0.0, 1.0);
                \\   out.color1 = float4(0.0, bright, 0.0, 1.0);
                \\   out.color2 = float4(0.0, 0.0, bright, 1.0);
                \\   return out;
                \\ }
                ;
        },
        else => { }
    }
    return desc;
}

fn fsqShaderDesc() sg.ShaderDesc {
    var desc: sg.ShaderDesc = .{};
    desc.vs.uniform_blocks[0].size = @sizeOf(FsqVsParams);
    switch (sg.queryBackend()) {
        .D3D11 => {
            desc.attrs[0].sem_name = "POSITION";
            inline for (.{ 0, 1, 2 }) |i| {
                desc.fs.images[i].type = ._2D;
            }
            desc.vs.source =
                \\ cbuffer params {
                \\   float2 offset;
                \\ };
                \\ struct vs_in {
                \\   float2 pos: POSITION;
                \\ };
                \\ struct vs_out {
                \\   float2 uv0: TEXCOORD0;
                \\   float2 uv1: TEXCOORD1;
                \\   float2 uv2: TEXCOORD2;
                \\   float4 pos: SV_Position;
                \\ };
                \\ vs_out main(vs_in inp) {
                \\   vs_out outp;
                \\   outp.pos = float4(inp.pos*2.0-1.0, 0.5, 1.0);
                \\   outp.uv0 = inp.pos + float2(offset.x, 0.0);
                \\   outp.uv1 = inp.pos + float2(0.0, offset.y);
                \\   outp.uv2 = inp.pos;
                \\   return outp;
                \\ }
                ;
            desc.fs.source =
                \\ Texture2D<float4> tex0: register(t0);
                \\ Texture2D<float4> tex1: register(t1);
                \\ Texture2D<float4> tex2: register(t2);
                \\ sampler smp0: register(s0);
                \\ sampler smp1: register(s1);
                \\ sampler smp2: register(s2);
                \\ struct fs_in {
                \\   float2 uv0: TEXCOORD0;
                \\   float2 uv1: TEXCOORD1;
                \\   float2 uv2: TEXCOORD2;
                \\ };
                \\ float4 main(fs_in inp): SV_Target0 {
                \\   float3 c0 = tex0.Sample(smp0, inp.uv0).xyz;
                \\   float3 c1 = tex1.Sample(smp1, inp.uv1).xyz;
                \\   float3 c2 = tex2.Sample(smp2, inp.uv2).xyz;
                \\   float4 c = float4(c0 + c1 + c2, 1.0);
                \\   return c;
                \\ }
                ;
        },
        .GLCORE33 => {
            desc.vs.uniform_blocks[0].uniforms[0] = .{ .name="offset", .type=.FLOAT2 };
            desc.fs.images[0] = .{ .name="tex0", .type=._2D };
            desc.fs.images[1] = .{ .name="tex1", .type=._2D };
            desc.fs.images[2] = .{ .name="tex2", .type=._2D };
            desc.vs.source =
                \\ #version 330
                \\ uniform vec2 offset;
                \\ layout(location=0) in vec2 pos;
                \\ out vec2 uv0;
                \\ out vec2 uv1;
                \\ out vec2 uv2;
                \\ void main() {
                \\   gl_Position = vec4(pos*2.0-1.0, 0.5, 1.0);
                \\   uv0 = pos + vec2(offset.x, 0.0);
                \\   uv1 = pos + vec2(0.0, offset.y);
                \\   uv2 = pos;
                \\ }
                ;
            desc.fs.source =
                \\ #version 330
                \\ uniform sampler2D tex0;
                \\ uniform sampler2D tex1;
                \\ uniform sampler2D tex2;
                \\ in vec2 uv0;
                \\ in vec2 uv1;
                \\ in vec2 uv2;
                \\ out vec4 frag_color;
                \\ void main() {
                \\   vec3 c0 = texture(tex0, uv0).xyz;
                \\   vec3 c1 = texture(tex1, uv1).xyz;
                \\   vec3 c2 = texture(tex2, uv2).xyz;
                \\   frag_color = vec4(c0 + c1 + c2, 1.0);
                \\ }
                ;
        },
        .METAL_MACOS => {
            inline for (.{ 0, 1, 2 }) |i| {
                desc.fs.images[i].type = ._2D;
            }
            desc.vs.source =
                \\ #include <metal_stdlib>
                \\ using namespace metal;
                \\ struct params_t {
                \\   float2 offset;
                \\ };
                \\ struct vs_in {
                \\   float2 pos [[attribute(0)]];
                \\ };
                \\ struct vs_out {
                \\   float4 pos [[position]];
                \\   float2 uv0;
                \\   float2 uv1;
                \\   float2 uv2;
                \\ };
                \\ vertex vs_out _main(vs_in in [[stage_in]], constant params_t& params [[buffer(0)]]) {
                \\   vs_out out;
                \\   out.pos = float4(in.pos*2.0-1.0, 0.5, 1.0);
                \\   out.uv0 = in.pos + float2(params.offset.x, 0.0);
                \\   out.uv1 = in.pos + float2(0.0, params.offset.y);
                \\   out.uv2 = in.pos;
                \\   return out;
                \\ }
                ;
            desc.fs.source =
                \\ #include <metal_stdlib>
                \\ using namespace metal;
                \\ struct fs_in {
                \\   float2 uv0;
                \\   float2 uv1;
                \\   float2 uv2;
                \\ };
                \\ fragment float4 _main(fs_in in [[stage_in]],
                \\   texture2d<float> tex0 [[texture(0)]], sampler smp0 [[sampler(0)]],
                \\   texture2d<float> tex1 [[texture(1)]], sampler smp1 [[sampler(1)]],
                \\   texture2d<float> tex2 [[texture(2)]], sampler smp2 [[sampler(2)]])
                \\ {
                \\   float3 c0 = tex0.sample(smp0, in.uv0).xyz;
                \\   float3 c1 = tex1.sample(smp1, in.uv1).xyz;
                \\   float3 c2 = tex2.sample(smp2, in.uv2).xyz;
                \\   return float4(c0 + c1 + c2, 1.0);
                \\ }
                ;
        },
        else => {}
    }
    return desc;
}

fn dbgShaderDesc() sg.ShaderDesc {
    var desc: sg.ShaderDesc = .{};
    switch (sg.queryBackend()) {
        .D3D11 => {
            desc.attrs[0].sem_name = "POSITION";
            desc.fs.images[0].type = ._2D;
            desc.vs.source =
                \\struct vs_in {
                \\  float2 pos: POSITION;
                \\};
                \\struct vs_out {
                \\  float2 uv: TEXCOORD0;
                \\  float4 pos: SV_Position;
                \\};
                \\vs_out main(vs_in inp) {
                \\  vs_out outp;
                \\  outp.pos = float4(inp.pos*2.0-1.0, 0.5, 1.0);
                \\  outp.uv = inp.pos;
                \\  return outp;
                \\}
                ;
            desc.fs.source =
                \\ texture2D<float4> tex: register(t0);
                \\ sampler smp: register(s0);
                \\ float4 main(float2 uv: TEXCOORD0): SV_Target0 {
                \\   return float4(tex.Sample(smp, uv).xyz, 1.0);
                \\ }
                ;
        },
        .GLCORE33 => {
            desc.fs.images[0] = .{ .name="tex", .type=._2D };
            desc.vs.source =
                \\ #version 330
                \\ layout(location=0) in vec2 pos;
                \\ out vec2 uv;
                \\ void main() {
                \\   gl_Position = vec4(pos*2.0-1.0, 0.5, 1.0);
                \\   uv = pos;
                \\ }
                ;
            desc.fs.source =
                \\ #version 330
                \\ uniform sampler2D tex;
                \\ in vec2 uv;
                \\ out vec4 frag_color;
                \\ void main() {
                \\   frag_color = vec4(texture(tex,uv).xyz, 1.0);
                \\ }
                ;
        },
        .METAL_MACOS => {
            desc.fs.images[0].type = ._2D;
            desc.vs.source =
                \\ #include <metal_stdlib>
                \\ using namespace metal;
                \\ struct vs_in {
                \\   float2 pos [[attribute(0)]];
                \\ };
                \\ struct vs_out {
                \\   float4 pos [[position]];
                \\   float2 uv;
                \\ };
                \\ vertex vs_out _main(vs_in in [[stage_in]]) {
                \\   vs_out out;
                \\   out.pos = float4(in.pos*2.0-1.0, 0.5, 1.0);
                \\   out.uv = in.pos;
                \\   return out;
                \\ }
                ;
            desc.fs.source =
                \\ #include <metal_stdlib>
                \\ using namespace metal;
                \\ fragment float4 _main(float2 uv [[stage_in]], texture2d<float> tex [[texture(0)]], sampler smp [[sampler(0)]]) {
                \\   return float4(tex.sample(smp, uv).xyz, 1.0);
                \\ }
                ;
        },
        else => {}
    }
    return desc;
}

