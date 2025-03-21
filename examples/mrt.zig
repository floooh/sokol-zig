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
const math = @import("std").math;
const sokol = @import("sokol");
const slog = sokol.log;
const sg = sokol.gfx;
const sapp = sokol.app;
const sglue = sokol.glue;
const vec2 = @import("math.zig").Vec2;
const vec3 = @import("math.zig").Vec3;
const mat4 = @import("math.zig").Mat4;
const shd = @import("shaders/mrt.glsl.zig");

const offscreen_sample_count = 1;

const state = struct {
    const offscreen = struct {
        var pass_action: sg.PassAction = .{};
        var attachments_desc: sg.AttachmentsDesc = .{};
        var attachments: sg.Attachments = .{};
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
    const view: mat4 = mat4.lookat(.{ .x = 0.0, .y = 1.5, .z = 6.0 }, vec3.zero(), vec3.up());
};

export fn init() void {
    sg.setup(.{
        .environment = sglue.environment(),
        .logger = .{ .func = slog.func },
    });

    // setup pass action for default render pass
    state.default.pass_action.colors[0] = .{ .load_action = .DONTCARE };
    state.default.pass_action.depth = .{ .load_action = .DONTCARE };
    state.default.pass_action.stencil = .{ .load_action = .DONTCARE };

    // set pass action for offscreen render pass
    state.offscreen.pass_action.colors[0] = .{
        .load_action = .CLEAR,
        .clear_value = .{ .r = 0.25, .g = 0, .b = 0, .a = 1 },
    };
    state.offscreen.pass_action.colors[1] = .{
        .load_action = .CLEAR,
        .clear_value = .{ .r = 0, .g = 0.25, .b = 0, .a = 1 },
    };
    state.offscreen.pass_action.colors[2] = .{
        .load_action = .CLEAR,
        .clear_value = .{ .r = 0, .g = 0, .b = 0.25, .a = 1 },
    };

    // setup the offscreen render pass resources this will also be called when the window resizes
    createOffscreenAttachments(sapp.width(), sapp.height());

    // create vertex buffer for a cube
    const cube_vbuf = sg.makeBuffer(.{
        .data = sg.asRange(&[_]f32{
            // positions        brightness
            -1.0, -1.0, -1.0, 1.0,
            1.0,  -1.0, -1.0, 1.0,
            1.0,  1.0,  -1.0, 1.0,
            -1.0, 1.0,  -1.0, 1.0,

            -1.0, -1.0, 1.0,  0.8,
            1.0,  -1.0, 1.0,  0.8,
            1.0,  1.0,  1.0,  0.8,
            -1.0, 1.0,  1.0,  0.8,

            -1.0, -1.0, -1.0, 0.6,
            -1.0, 1.0,  -1.0, 0.6,
            -1.0, 1.0,  1.0,  0.6,
            -1.0, -1.0, 1.0,  0.6,

            1.0,  -1.0, -1.0, 0.4,
            1.0,  1.0,  -1.0, 0.4,
            1.0,  1.0,  1.0,  0.4,
            1.0,  -1.0, 1.0,  0.4,

            -1.0, -1.0, -1.0, 0.5,
            -1.0, -1.0, 1.0,  0.5,
            1.0,  -1.0, 1.0,  0.5,
            1.0,  -1.0, -1.0, 0.5,

            -1.0, 1.0,  -1.0, 0.7,
            -1.0, 1.0,  1.0,  0.7,
            1.0,  1.0,  1.0,  0.7,
            1.0,  1.0,  -1.0, 0.7,
        }),
    });

    // index buffer for a cube
    const cube_ibuf = sg.makeBuffer(.{
        .type = .INDEXBUFFER,
        .data = sg.asRange(&[_]u16{
            0,  1,  2,  0,  2,  3,
            6,  5,  4,  7,  6,  4,
            8,  9,  10, 8,  10, 11,
            14, 13, 12, 15, 14, 12,
            16, 17, 18, 16, 18, 19,
            22, 21, 20, 23, 22, 20,
        }),
    });

    // resource bindings for offscreen rendering
    state.offscreen.bind.vertex_buffers[0] = cube_vbuf;
    state.offscreen.bind.index_buffer = cube_ibuf;

    // shader and pipeline state object for rendering cube into MRT render targets
    state.offscreen.pip = sg.makePipeline(.{
        .shader = sg.makeShader(shd.offscreenShaderDesc(sg.queryBackend())),
        .layout = init: {
            var l = sg.VertexLayoutState{};
            l.attrs[shd.ATTR_offscreen_pos].format = .FLOAT3;
            l.attrs[shd.ATTR_offscreen_bright0].format = .FLOAT;
            break :init l;
        },
        .index_type = .UINT16,
        .cull_mode = .BACK,
        .sample_count = offscreen_sample_count,
        .depth = .{
            .pixel_format = .DEPTH,
            .compare = .LESS_EQUAL,
            .write_enabled = true,
        },
        .color_count = 3,
    });

    // a vertex buffer to render a fullscreen quad
    const quad_vbuf = sg.makeBuffer(.{
        .data = sg.asRange(&[_]f32{ 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 1.0 }),
    });

    // shader and pipeline object to render a fullscreen quad which composes
    // the 3 offscreen render targets into the default framebuffer
    state.fsq.pip = sg.makePipeline(.{
        .shader = sg.makeShader(shd.fsqShaderDesc(sg.queryBackend())),
        .layout = init: {
            var l = sg.VertexLayoutState{};
            l.attrs[shd.ATTR_fsq_pos].format = .FLOAT2;
            break :init l;
        },
        .primitive_type = .TRIANGLE_STRIP,
    });

    // a sampler to sample the offscreen render target as texture
    const smp = sg.makeSampler(.{
        .min_filter = .LINEAR,
        .mag_filter = .LINEAR,
        .wrap_u = .CLAMP_TO_EDGE,
        .wrap_v = .CLAMP_TO_EDGE,
    });

    // resource bindings to render the fullscreen quad (composed from the
    // offscreen render target textures
    state.fsq.bind.vertex_buffers[0] = quad_vbuf;
    for (0..2) |i| {
        state.fsq.bind.images[i] = state.offscreen.attachments_desc.colors[i].image;
    }
    state.fsq.bind.samplers[shd.SMP_smp] = smp;

    // shader, pipeline and resource bindings to render debug visualization quads
    state.dbg.pip = sg.makePipeline(.{
        .shader = sg.makeShader(shd.dbgShaderDesc(sg.queryBackend())),
        .layout = init: {
            var l = sg.VertexLayoutState{};
            l.attrs[shd.ATTR_dbg_pos].format = .FLOAT2;
            break :init l;
        },
        .primitive_type = .TRIANGLE_STRIP,
    });

    // resource bindings to render the debug visualization
    // (the required images will be filled in during rendering)
    state.dbg.bind.vertex_buffers[0] = quad_vbuf;
    state.dbg.bind.samplers[shd.SMP_smp] = smp;
}

export fn frame() void {
    const dt: f32 = @floatCast(sapp.frameDuration() * 60.0);
    state.rx += 1.0 * dt;
    state.ry += 2.0 * dt;

    // compute shader uniform data
    const offscreen_params: shd.OffscreenParams = .{ .mvp = computeMVP(state.rx, state.ry) };
    const fsq_params: shd.FsqParams = .{
        .offset = .{
            .x = math.sin(state.rx * 0.01) * 0.1,
            .y = math.cos(state.ry * 0.01) * 0.1,
        },
    };

    // render cube into MRT offscreen render targets
    sg.beginPass(.{ .action = state.offscreen.pass_action, .attachments = state.offscreen.attachments });
    sg.applyPipeline(state.offscreen.pip);
    sg.applyBindings(state.offscreen.bind);
    sg.applyUniforms(shd.UB_offscreen_params, sg.asRange(&offscreen_params));
    sg.draw(0, 36, 1);
    sg.endPass();

    // render fullscreen quad with the composed offscreen-render images,
    // 3 a small debug view quads at the bottom of the screen
    sg.beginPass(.{ .action = state.default.pass_action, .swapchain = sglue.swapchain() });
    sg.applyPipeline(state.fsq.pip);
    sg.applyBindings(state.fsq.bind);
    sg.applyUniforms(shd.UB_fsq_params, sg.asRange(&fsq_params));
    sg.draw(0, 4, 1);
    sg.applyPipeline(state.dbg.pip);
    inline for (0..3) |i| {
        sg.applyViewport(i * 100, 0, 100, 100, false);
        state.dbg.bind.images[shd.IMG_tex] = state.offscreen.attachments_desc.colors[i].image;
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
        createOffscreenAttachments(ev.*.framebuffer_width, ev.*.framebuffer_height);
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
        .icon = .{ .sokol_default = true },
        .window_title = "mrt.zig",
        .logger = .{ .func = slog.func },
    });
}

// compute model-view-projection matrix
fn computeMVP(rx: f32, ry: f32) mat4 {
    const rxm = mat4.rotate(rx, .{ .x = 1.0, .y = 0.0, .z = 0.0 });
    const rym = mat4.rotate(ry, .{ .x = 0.0, .y = 1.0, .z = 0.0 });
    const model = mat4.mul(rxm, rym);
    const aspect = sapp.widthf() / sapp.heightf();
    const proj = mat4.persp(60.0, aspect, 0.01, 10.0);
    return mat4.mul(mat4.mul(proj, state.view), model);
}

// helper function to create or re-create render target images and pass object for offscreen rendering
fn createOffscreenAttachments(width: i32, height: i32) void {
    // destroy previous resources (can be called with invalid ids)
    sg.destroyAttachments(state.offscreen.attachments);
    for (state.offscreen.attachments_desc.colors) |att| {
        sg.destroyImage(att.image);
    }
    sg.destroyImage(state.offscreen.attachments_desc.depth_stencil.image);

    // create offscreen render target images and pass
    const color_img_desc: sg.ImageDesc = .{
        .render_target = true,
        .width = width,
        .height = height,
        .sample_count = offscreen_sample_count,
    };
    var depth_img_desc = color_img_desc;
    depth_img_desc.pixel_format = .DEPTH;

    for (0..3) |i| {
        state.offscreen.attachments_desc.colors[i].image = sg.makeImage(color_img_desc);
    }
    state.offscreen.attachments_desc.depth_stencil.image = sg.makeImage(depth_img_desc);
    state.offscreen.attachments = sg.makeAttachments(state.offscreen.attachments_desc);

    // update the fullscreen-quad texture bindings
    for (0..3) |i| {
        state.fsq.bind.images[i] = state.offscreen.attachments_desc.colors[i].image;
    }
}
