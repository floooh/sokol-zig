//------------------------------------------------------------------------------
//  shapes.zig
//
//  Simple sokol.shape demo.
//------------------------------------------------------------------------------
const sokol  = @import("sokol");
const slog   = sokol.log;
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

const NUM_SHAPES = 5;

const state = struct {
    var pass_action: sg.PassAction = .{};
    var pip:         sg.Pipeline = .{};
    var bind:        sg.Bindings = .{};
    var vs_params:   shd.VsParams = undefined;
    var shapes:      [NUM_SHAPES]Shape = .{
        .{ .pos = .{ .x=-1, .y=1,  .z=0 } },
        .{ .pos = .{ .x=1,  .y=1,  .z=0 } },
        .{ .pos = .{ .x=-2, .y=-1, .z=0 } },
        .{ .pos = .{ .x=2,  .y=-1, .z=0 } },
        .{ .pos = .{ .x=0,  .y=-1, .z=0 } },
    };
    var rx: f32 = 0.0;
    var ry: f32 = 0.0;
    const view = mat4.lookat(.{.x=0.0, .y=1.5, .z=6.0}, vec3.zero(), vec3.up());
};

export fn init() void {
    sg.setup(.{
        .context = sgapp.context(),
        .logger = .{ .func = slog.func },
    });

    var sdtx_desc: sdtx.Desc = .{
        .logger = .{ .func = slog.func },
    };
    sdtx_desc.fonts[0] = sdtx.fontOric();
    sdtx.setup(sdtx_desc);

    // pass-action for clearing to black
    state.pass_action.colors[0] = .{ .action = .CLEAR, .value = .{ .r=0, .g=0, .b=0, .a=1 }};

    // shader- and pipeline-object
    var pip_desc: sg.PipelineDesc = .{
        .shader = sg.makeShader(shd.shapesShaderDesc(sg.queryBackend())),
        .index_type = .UINT16,
        .cull_mode = .NONE,
        .depth = .{
            .compare = .LESS_EQUAL,
            .write_enabled = true,
        },
    };
    pip_desc.layout.buffers[0] = sshape.bufferLayoutDesc();
    pip_desc.layout.attrs[shd.ATTR_vs_position] = sshape.positionAttrDesc();
    pip_desc.layout.attrs[shd.ATTR_vs_normal]   = sshape.normalAttrDesc();
    pip_desc.layout.attrs[shd.ATTR_vs_texcoord] = sshape.texcoordAttrDesc();
    pip_desc.layout.attrs[shd.ATTR_vs_color0]   = sshape.colorAttrDesc();
    state.pip = sg.makePipeline(pip_desc);

    // generate shape geometries
    var vertices: [6*1024]sshape.Vertex = undefined;
    var indices:  [16*1024]u16 = undefined;
    var buf: sshape.Buffer = .{
        .vertices = .{ .buffer = sshape.asRange(&vertices) },
        .indices  = .{ .buffer = sshape.asRange(&indices) },
    };
    buf = sshape.buildBox(buf, .{ .width=1.0, .height=1.0, .depth=1.0, .tiles=10, .random_colors=true });
    state.shapes[0].draw = sshape.elementRange(buf);
    buf = sshape.buildPlane(buf, .{ .width=1.0, .depth=1.0, .tiles=10, .random_colors=true });
    state.shapes[1].draw = sshape.elementRange(buf);
    buf = sshape.buildSphere(buf, .{ .radius=0.75, .slices=36, .stacks=20, .random_colors=true });
    state.shapes[2].draw = sshape.elementRange(buf);
    buf = sshape.buildCylinder(buf, .{ .radius=0.5, .height=1.5, .slices=36, .stacks=10, .random_colors=true });
    state.shapes[3].draw = sshape.elementRange(buf);
    buf = sshape.buildTorus(buf, .{ .radius=0.5, .ring_radius=0.3, .rings=36, .sides=18, .random_colors=true });
    state.shapes[4].draw = sshape.elementRange(buf);
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
    const dt = @floatCast(f32, sapp.frameDuration()) * 60.0;
    state.rx += 1.0 * dt;
    state.ry += 1.0 * dt;
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
        sg.applyUniforms(.VS, shd.SLOT_vs_params, sg.asRange(&state.vs_params));
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
        .icon = .{ .sokol_default = true },
        .window_title = "shapes.zig",
        .logger = .{ .func = slog.func },
    });
}
