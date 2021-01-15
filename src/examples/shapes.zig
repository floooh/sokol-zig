//------------------------------------------------------------------------------
//  shapes.zig
//
//  Simple sokol.shape demo.
//------------------------------------------------------------------------------
const sokol  = @import("sokol");
const sg     = sokol.gfx;
const sapp   = sokol.app;
const sgapp  = sokol.app_gfx_glue;
const sdtx   = sokol.debugtext;
const sshape = sokol.shape;
const vec3   = @import("math.zig").Vec3;
const mat4   = @import("math.zig").Mat4;
const assert = @import("std").debug.assert;
const shd    = @import("shaders/shapes.glsl.zig");

const Shape = struct {
    pos: vec3 = vec3.zero(),
    draw: sshape.ElementRange = .{},
};

//const VSParams = extern struct {
//    mvp: mat4 = mat4.identity(),
//    draw_mode: f32 = 0.0,
//    pad: [12]u8 = undefined,
//};

const BOX        = 0;
const PLANE      = 1;
const SPHERE     = 2;
const CYLINDER   = 3;
const TORUS      = 4;
const NUM_SHAPES = 5;

const state = struct {
    var pass_action: sg.PassAction = .{};
    var pip:         sg.Pipeline = .{};
    var bind:        sg.Bindings = .{};
    var vs_params:   shd.VsParams = undefined;
    var shapes:      [NUM_SHAPES]Shape = undefined;
    var rx: f32 = 0.0;
    var ry: f32 = 0.0;
    const view = mat4.lookat(.{.x=0.0, .y=1.5, .z=6.0}, vec3.zero(), vec3.up());
};

export fn init() void {
    sg.setup(.{ .context = sgapp.context() });

    var sdtx_desc: sdtx.Desc = .{};
    sdtx_desc.fonts[0] = sdtx.fontOric();
    sdtx.setup(sdtx_desc);

    // pass-action for clearing to black
    state.pass_action.colors[0] = .{ .action = .CLEAR, .val = .{ 0, 0, 0, 1 }};

    // shader- and pipeline-object
    var pip_desc: sg.PipelineDesc = .{
        .shader = sg.makeShader(shd.shapesShaderDesc(sg.queryBackend())),
        .index_type = .UINT16,
        .depth_stencil = .{
            .depth_compare_func = .LESS_EQUAL,
            .depth_write_enabled = true,
        },
        .rasterizer = .{
            .cull_mode = .NONE,
        }
    };
    pip_desc.layout.buffers[0] = sshape.bufferLayoutDesc();
    pip_desc.layout.attrs[shd.ATTR_vs_position] = sshape.positionAttrDesc();
    pip_desc.layout.attrs[shd.ATTR_vs_normal]   = sshape.normalAttrDesc();
    pip_desc.layout.attrs[shd.ATTR_vs_texcoord] = sshape.texcoordAttrDesc();
    pip_desc.layout.attrs[shd.ATTR_vs_color0]   = sshape.colorAttrDesc();
    state.pip = sg.makePipeline(pip_desc);

    // shape positions
    state.shapes[BOX].pos       = .{ .x=-1, .y=1, .z=0 };
    state.shapes[PLANE].pos     = .{ .x=1, .y=1, .z=0 };
    state.shapes[SPHERE].pos    = .{ .x=-2, .y=-1, .z=0 };
    state.shapes[CYLINDER].pos  = .{ .x=2, .y=-1, .z=0 };
    state.shapes[TORUS].pos     = .{ .x=0, .y=-1, .z=0 };

    // generate shape geometries
    var vertices: [6*1024]sshape.Vertex = undefined;
    var indices:  [16*1024]u16 = undefined;
    var buf: sshape.Buffer = .{
        .vertices = .{ .buffer = sshape.asRange(vertices) },
        .indices  = .{ .buffer = sshape.asRange(indices) },
    };
    buf = sshape.buildBox(buf, .{
        .width = 1.0,
        .height = 1.0,
        .depth = 1.0,
        .tiles = 10,
        .random_colors = true,
    });
    state.shapes[BOX].draw = sshape.elementRange(buf);
    buf = sshape.buildPlane(buf, .{
        .width = 1.0,
        .depth = 1.0,
        .tiles = 10,
        .random_colors = true,
    });
    state.shapes[PLANE].draw = sshape.elementRange(buf);
    buf = sshape.buildSphere(buf, .{
        .radius = 0.75,
        .slices = 36,
        .stacks = 20,
        .random_colors = true,
    });
    state.shapes[SPHERE].draw = sshape.elementRange(buf);
    buf = sshape.buildCylinder(buf, .{
        .radius = 0.5,
        .height = 1.5,
        .slices = 36,
        .stacks = 10,
        .random_colors = true,
    });
    state.shapes[CYLINDER].draw = sshape.elementRange(buf);
    buf = sshape.buildTorus(buf, .{
        .radius = 0.5,
        .ring_radius = 0.3,
        .rings = 36,
        .sides = 18,
        .random_colors = true,
    });
    state.shapes[TORUS].draw = sshape.elementRange(buf);
    assert(buf.valid);

    // one vertex- and index-buffer for all shapes
    state.bind.vertex_buffers[0] = sg.makeBuffer(sshape.vertexBufferDesc(buf));
    state.bind.index_buffer = sg.makeBuffer(sshape.indexBufferDesc(buf));
}

export fn frame() void {
    // help text
    sdtx.canvas(sapp.widthf() * 0.5, sapp.heightf() * 0.5);
    sdtx.pos(0.5, 0.5);
    sdtx.puts("press key to switch draw mode:\n\n");
    sdtx.puts("  1: vertex normals\n");
    sdtx.puts("  2: texture coords\n");
    sdtx.puts("  3: vertex colors\n");

    // view-project matrix
    const proj = mat4.persp(60.0, sapp.widthf()/sapp.heightf(), 0.01, 10.0);
    const view_proj = mat4.mul(proj, state.view);

    // model-rotation matrix
    state.rx += 1.0;
    state.ry += 1.0;
    const rxm = mat4.rotate(state.rx, .{ .x=1, .y=0, .z=0 });
    const rym = mat4.rotate(state.ry, .{ .x=0, .y=1, .z=0 });
    const rm  = mat4.mul(rxm, rym);

    // render shapes...
    sg.beginDefaultPass(state.pass_action, sapp.width(), sapp.height());
    sg.applyPipeline(state.pip);
    sg.applyBindings(state.bind);
    for (state.shapes) |shape| {
        // per-shape model-view-projection matrix
        const model = mat4.mul(mat4.translate(shape.pos), rm);
        state.vs_params.mvp = mat4.mul(view_proj, model);
        sg.applyUniforms(.VS, shd.SLOT_vs_params, sg.asRange(state.vs_params));
        sg.draw(shape.draw.base_element, shape.draw.num_elements, 1);
    }
    sdtx.draw();
    sg.endPass();
    sg.commit();
}

export fn input(event: ?*const sapp.Event) void {
    const ev = event.?;
    if (ev.type == .KEY_DOWN) {
        state.vs_params.draw_mode = switch (ev.key_code) {
            ._1 => 0.0,
            ._2 => 1.0,
            ._3 => 2.0,
            else => state.vs_params.draw_mode
        };
    }
}

export fn cleanup() void {
    sdtx.shutdown();
    sg.shutdown();
}

pub fn main() void {
    sapp.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .event_cb = input,
        .cleanup_cb = cleanup,
        .width = 800,
        .height = 600,
        .sample_count = 4,
        .window_title = "shapes.zig"
    });
}

fn shaderDesc() sg.ShaderDesc {
    var desc: sg.ShaderDesc = .{};
    desc.vs.uniform_blocks[0].size = @sizeOf(VSParams);
    switch (sg.queryBackend()) {
        // shader code is copied output from sokol-shdc!
        .METAL_MACOS => {
            desc.vs.source =
                \\ #include <metal_stdlib>
                \\ using namespace metal;
                \\ struct vs_params {
                \\     float4x4 mvp;
                \\     float draw_mode;
                \\ };
                \\ struct vs_in {
                \\     float4 position [[attribute(0)]];
                \\     float3 normal [[attribute(1)]];
                \\     float2 texcoord [[attribute(2)]];
                \\     float4 color0 [[attribute(3)]];
                \\ };
                \\ struct vs_out {
                \\     float4 color [[user(locn0)]];
                \\     float4 position [[position]];
                \\ };
                \\ vertex vs_out _main(vs_in in [[stage_in]], constant vs_params& params [[buffer(0)]]) {
                \\     vs_out out = {};
                \\     out.position = params.mvp * in.position;
                \\     if (params.draw_mode == 0.0) {
                \\         out.color = float4((in.normal + float3(1.0)) * 0.5, 1.0);
                \\     }
                \\     else if (params.draw_mode == 1.0) {
                \\         out.color = float4(in.texcoord, 0.0, 1.0);
                \\     }
                \\     else {
                \\         out.color = in.color0;
                \\     }
                \\     return out;
                \\ }
                ;
            desc.fs.source =
                \\ #include <metal_stdlib>
                \\ using namespace metal;
                \\ struct fs_out {
                \\     float4 frag_color [[color(0)]];
                \\ };
                \\ struct fs_in {
                \\     float4 color [[user(locn0)]];
                \\ };
                \\ fragment fs_out _main(fs_in in [[stage_in]]) {
                \\     fs_out out = {};
                \\     out.frag_color = in.color;
                \\     return out;
                \\ }
                ;
        },
        .GLCORE33 => {
            desc.vs.uniform_blocks[0].uniforms[0].name = "vs_params";
            desc.vs.uniform_blocks[0].uniforms[0].type = .FLOAT4;
            desc.vs.uniform_blocks[0].uniforms[0].array_count = 5;
            desc.vs.source =
                \\ #version 330
                \\ uniform vec4 vs_params[5];
                \\ layout(location = 0) in vec4 position;
                \\ out vec4 color;
                \\ layout(location = 1) in vec3 normal;
                \\ layout(location = 2) in vec2 texcoord;
                \\ layout(location = 3) in vec4 color0;
                \\ void main() {
                \\     gl_Position = mat4(vs_params[0], vs_params[1], vs_params[2], vs_params[3]) * position;
                \\     if (vs_params[4].x == 0.0) {
                \\         color = vec4((normal + vec3(1.0)) * 0.5, 1.0);
                \\     }
                \\     else {
                \\         if (vs_params[4].x == 1.0) {
                \\             color = vec4(texcoord, 0.0, 1.0);
                \\         }
                \\         else {
                \\             color = color0;
                \\         }
                \\     }
                \\ }
                ;
            desc.fs.source =
                \\ #version 330
                \\ layout(location = 0) out vec4 frag_color;
                \\ in vec4 color;
                \\ void main() {
                \\     frag_color = color;
                \\ }
                ;
        },
        .D3D11 => {
            desc.attrs[0] = .{ .sem_name="POSITION" };
            desc.attrs[1] = .{ .sem_name="NORMAL" };
            desc.attrs[2] = .{ .sem_name="TEXCOORD" };
            desc.attrs[3] = .{ .sem_name="COLOR" };
            desc.vs.source =
                \\ cbuffer params: register(b0) {
                \\   float4x4 mvp;
                \\   float draw_mode;
                \\ };
                \\ struct vs_in {
                \\   float4 pos: POSITION;
                \\   float3 normal: NORMAL;
                \\   float2 texcoord: TEXCOORD;
                \\   float4 color: COLOR;
                \\ };
                \\ struct vs_out {
                \\   float4 color: COLOR0;
                \\   float4 pos: SV_Position;
                \\ };
                \\ vs_out main(vs_in inp) {
                \\   vs_out outp;
                \\   outp.pos = mul(mvp, inp.pos);
                \\   if (draw_mode == 0.0) {
                \\     outp.color = float4((inp.normal + 1.0) * 0.5, 1.0);
                \\   }
                \\   else if (draw_mode == 1.0) {
                \\     outp.color = float4(inp.texcoord, 0.0, 1.0);
                \\   }
                \\   else {
                \\     outp.color = inp.color;
                \\   }
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
