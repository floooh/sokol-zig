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

const num_mrts = 3;
const offscreen_sample_count = 1;

const state = struct {
    const images = struct {
        var color: [num_mrts]sg.Image = @splat(.{});
        var resolve: [num_mrts]sg.Image = @splat(.{});
        var depth: sg.Image = .{};
    };
    const offscreen = struct {
        var pip: sg.Pipeline = .{};
        var bind: sg.Bindings = .{};
        var pass: sg.Pass = .{};
    };
    const display = struct {
        var pip: sg.Pipeline = .{};
        var bind: sg.Bindings = .{};
        var pass_action: sg.PassAction = .{};
    };
    const dbg = struct {
        var pip: sg.Pipeline = .{};
        var bind: sg.Bindings = .{};
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

    // setup the offscreen render pass resources, this will also be called when the window resizes
    recreateOffscreenAttachments(sapp.width(), sapp.height());

    // setup pass action for default render pass
    state.display.pass_action.colors[0] = .{ .load_action = .DONTCARE };
    state.display.pass_action.depth = .{ .load_action = .DONTCARE };
    state.display.pass_action.stencil = .{ .load_action = .DONTCARE };

    // set pass action for offscreen render pass
    for (0..num_mrts) |i| {
        state.offscreen.pass.action.colors[i] = .{
            .load_action = .CLEAR,
            .clear_value = switch (i) {
                0 => .{ .r = 0.25, .g = 0, .b = 0, .a = 1 },
                1 => .{ .r = 0, .g = 0.25, .b = 0, .a = 1 },
                else => .{ .r = 0, .g = 0, .b = 0.25, .a = 1 },
            },
        };
    }

    // create vertex buffer for a cube
    state.offscreen.bind.vertex_buffers[0] = sg.makeBuffer(.{
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
    state.offscreen.bind.index_buffer = sg.makeBuffer(.{
        .usage = .{ .index_buffer = true },
        .data = sg.asRange(&[_]u16{
            0,  1,  2,  0,  2,  3,
            6,  5,  4,  7,  6,  4,
            8,  9,  10, 8,  10, 11,
            14, 13, 12, 15, 14, 12,
            16, 17, 18, 16, 18, 19,
            22, 21, 20, 23, 22, 20,
        }),
    });

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
    state.display.bind.vertex_buffers[0] = quad_vbuf;
    state.dbg.bind.vertex_buffers[0] = quad_vbuf;

    // shader and pipeline object to render a fullscreen quad which composes
    // the 3 offscreen render targets into the default framebuffer
    state.display.pip = sg.makePipeline(.{
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
    state.display.bind.samplers[shd.SMP_smp] = smp;
    state.dbg.bind.samplers[shd.SMP_smp] = smp;

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
    sg.beginPass(state.offscreen.pass);
    sg.applyPipeline(state.offscreen.pip);
    sg.applyBindings(state.offscreen.bind);
    sg.applyUniforms(shd.UB_offscreen_params, sg.asRange(&offscreen_params));
    sg.draw(0, 36, 1);
    sg.endPass();

    // render fullscreen quad with the composed offscreen-render images,
    // 3 a small debug view quads at the bottom of the screen
    sg.beginPass(.{ .action = state.display.pass_action, .swapchain = sglue.swapchain() });
    sg.applyPipeline(state.display.pip);
    sg.applyBindings(state.display.bind);
    sg.applyUniforms(shd.UB_fsq_params, sg.asRange(&fsq_params));
    sg.draw(0, 4, 1);
    sg.applyPipeline(state.dbg.pip);
    inline for (0..num_mrts) |i| {
        sg.applyViewport(i * 100, 0, 100, 100, false);
        state.dbg.bind.views[shd.VIEW_tex] = state.display.bind.views[i];
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
        recreateOffscreenAttachments(ev.*.framebuffer_width, ev.*.framebuffer_height);
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

// helper function to create or re-create attachment resources
fn recreateOffscreenAttachments(width: i32, height: i32) void {
    // destroy and re-create create color, resolve and depth-stencil attachment images and views
    // (NOTE: calling destroy funcs on invalid handles is fine)
    for (0..num_mrts) |i| {
        // color attachment images and views
        sg.destroyImage(state.images.color[i]);
        state.images.color[i] = sg.makeImage(.{
            .usage = .{ .color_attachment = true },
            .width = width,
            .height = height,
            .sample_count = offscreen_sample_count,
        });
        sg.destroyView(state.offscreen.pass.attachments.colors[i]);
        state.offscreen.pass.attachments.colors[i] = sg.makeView(.{
            .color_attachment = .{ .image = state.images.color[i] },
        });

        // resolve attachment images and views
        sg.destroyImage(state.images.resolve[i]);
        state.images.resolve[i] = sg.makeImage(.{
            .usage = .{ .resolve_attachment = true },
            .width = width,
            .height = height,
            .sample_count = 1,
        });
        sg.destroyView(state.offscreen.pass.attachments.resolves[i]);
        state.offscreen.pass.attachments.resolves[i] = sg.makeView(.{
            .resolve_attachment = .{ .image = state.images.resolve[i] },
        });

        // the resolve images are also sampled as textures, so need texture views
        sg.destroyView(state.display.bind.views[i]);
        state.display.bind.views[i] = sg.makeView(.{
            .texture = .{ .image = state.images.resolve[i] },
        });
    }

    // depth-stencil attachment image and view
    sg.destroyImage(state.images.depth);
    state.images.depth = sg.makeImage(.{
        .usage = .{ .depth_stencil_attachment = true },
        .width = width,
        .height = height,
        .sample_count = offscreen_sample_count,
        .pixel_format = .DEPTH,
    });
    sg.destroyView(state.offscreen.pass.attachments.depth_stencil);
    state.offscreen.pass.attachments.depth_stencil = sg.makeView(.{
        .depth_stencil_attachment = .{ .image = state.images.depth },
    });
}
