//------------------------------------------------------------------------------
//  offscreen.zig
//
//  Render to an offscreen rendertarget texture, and use this texture
//  for rendering to the display.
//------------------------------------------------------------------------------
const sokol  = @import("sokol");
const slog   = sokol.log;
const sg     = sokol.gfx;
const sapp   = sokol.app;
const sgapp  = sokol.app_gfx_glue;
const sshape = sokol.shape;
const vec3   = @import("math.zig").Vec3;
const mat4   = @import("math.zig").Mat4;
const shd    = @import("shaders/offscreen.glsl.zig");

const offscreen_sample_count = 1;

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
    var donut: sshape.ElementRange = .{};
    var sphere: sshape.ElementRange = .{};
    var rx: f32 = 0.0;
    var ry: f32 = 0.0;
};

export fn init() void {
    sg.setup(.{
        .context = sgapp.context(),
        .logger = .{ .func = slog.func },
    });

    // default pass action: clear to blue-ish
    state.default.pass_action.colors[0] = .{ .load_action = .CLEAR, .clear_value = .{ .r=0.25, .g=0.45, .b=0.65, .a=1.0 } };

    // offscreen pass action: clear to black
    state.offscreen.pass_action.colors[0] = .{ .load_action = .CLEAR, .clear_value = .{ .r=0.25, .g=0.25, .b=0.25, .a=1.0 } };

    // a render pass with one color- and one depth-attachment image
    var img_desc: sg.ImageDesc = .{
        .render_target = true,
        .width = 256,
        .height = 256,
        .pixel_format = .RGBA8,
        .min_filter = .LINEAR,
        .mag_filter = .LINEAR,
        .wrap_u = .REPEAT,
        .wrap_v = .REPEAT,
        .sample_count = offscreen_sample_count
    };
    const color_img = sg.makeImage(img_desc);
    img_desc.pixel_format = .DEPTH;
    const depth_img = sg.makeImage(img_desc);

    var pass_desc: sg.PassDesc = .{};
    pass_desc.color_attachments[0].image = color_img;
    pass_desc.depth_stencil_attachment.image = depth_img;
    state.offscreen.pass = sg.makePass(pass_desc);

    // a donut shape which is rendered into the offscreen render target, and
    // a sphere shape which is rendered into the default framebuffer
    var vertices: [4000]sshape.Vertex = undefined;
    var indices: [24000]u16 = undefined;
    var buf: sshape.Buffer = .{
        .vertices = .{ .buffer = sshape.asRange(&vertices) },
        .indices  = .{ .buffer = sshape.asRange(&indices) },
    };
    buf = sshape.buildTorus(buf, .{
        .radius = 0.5,
        .ring_radius = 0.3,
        .sides = 20,
        .rings = 36
    });
    state.donut = sshape.elementRange(buf);
    buf = sshape.buildSphere(buf, .{
        .radius = 0.5,
        .slices = 72,
        .stacks = 40,
    });
    state.sphere = sshape.elementRange(buf);

    const vbuf = sg.makeBuffer(sshape.vertexBufferDesc(buf));
    const ibuf = sg.makeBuffer(sshape.indexBufferDesc(buf));

    // shader and pipeline object for offscreen rendering
    var offscreen_pip_desc: sg.PipelineDesc = .{
        .shader = sg.makeShader(shd.offscreenShaderDesc(sg.queryBackend())),
        .index_type = .UINT16,
        .cull_mode = .BACK,
        .sample_count = offscreen_sample_count,
        .depth = .{
            .pixel_format = .DEPTH,
            .compare = .LESS_EQUAL,
            .write_enabled = true,
        },
    };
    offscreen_pip_desc.colors[0].pixel_format = .RGBA8;
    offscreen_pip_desc.layout.buffers[0] = sshape.bufferLayoutDesc();
    offscreen_pip_desc.layout.attrs[shd.ATTR_vs_offscreen_position] = sshape.positionAttrDesc();
    offscreen_pip_desc.layout.attrs[shd.ATTR_vs_offscreen_normal] = sshape.normalAttrDesc();
    state.offscreen.pip = sg.makePipeline(offscreen_pip_desc);

    // shader and pipeline object for the default render pass
    var default_pip_desc: sg.PipelineDesc = .{
        .shader = sg.makeShader(shd.defaultShaderDesc(sg.queryBackend())),
        .index_type = .UINT16,
        .cull_mode = .BACK,
        .depth = .{
            .compare = .LESS_EQUAL,
            .write_enabled = true,
        },
    };
    default_pip_desc.layout.buffers[0] = sshape.bufferLayoutDesc();
    default_pip_desc.layout.attrs[shd.ATTR_vs_default_position] = sshape.positionAttrDesc();
    default_pip_desc.layout.attrs[shd.ATTR_vs_default_normal] = sshape.normalAttrDesc();
    default_pip_desc.layout.attrs[shd.ATTR_vs_default_texcoord0] = sshape.texcoordAttrDesc();
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

    const dt = @floatCast(f32, sapp.frameDuration()) * 60.0;
    state.rx += 1 * dt;
    state.ry += 2 * dt;
    const aspect = sapp.widthf() / sapp.heightf();

    // the offscreen pass, rendering a rotating untextured donut into a render target image
    sg.beginPass(state.offscreen.pass, state.offscreen.pass_action);
    sg.applyPipeline(state.offscreen.pip);
    sg.applyBindings(state.offscreen.bind);
    sg.applyUniforms(.VS, 0, sg.asRange(&computeVsParams(state.rx, state.ry, 1.0, 2.5)));
    sg.draw(state.donut.base_element, state.donut.num_elements, 1);
    sg.endPass();

    // and the display pass, rendering a rotating textured sphere, using the previously
    // rendered offscreen render target as texture
    sg.beginDefaultPass(state.default.pass_action, sapp.width(), sapp.height());
    sg.applyPipeline(state.default.pip);
    sg.applyBindings(state.default.bind);
    sg.applyUniforms(.VS, 0, sg.asRange(&computeVsParams(-state.rx*0.25, state.ry*0.25, aspect, 2)));
    sg.draw(state.sphere.base_element, state.sphere.num_elements, 1);
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
        .icon = .{ .sokol_default = true },
        .window_title = "offscreen.zig",
        .logger = .{ .func = slog.func },
    });
}

fn computeVsParams(rx: f32, ry: f32, aspect: f32, eye_dist: f32) shd.VsParams {
    const proj = mat4.persp(45, aspect, 0.01, 10);
    const view = mat4.lookat(.{ .x=0, .y=0, .z=eye_dist}, vec3.zero(), vec3.up());
    const view_proj = mat4.mul(proj, view);
    const rxm = mat4.rotate(rx, .{ .x=1, .y=0, .z=0 });
    const rym = mat4.rotate(ry, .{ .x=0, .y=1, .z=0 });
    const model = mat4.mul(rxm, rym);
    return shd.VsParams {
        .mvp = mat4.mul(view_proj, model)
    };
}
