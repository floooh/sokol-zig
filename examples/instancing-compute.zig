//------------------------------------------------------------------------------
//  instancing-compute.zig
//
//  Like instancing.zig, but update particle positions via compute shader.
//------------------------------------------------------------------------------
const sokol = @import("sokol");
const slog = sokol.log;
const sg = sokol.gfx;
const sapp = sokol.app;
const sglue = sokol.glue;
const vec3 = @import("math.zig").Vec3;
const mat4 = @import("math.zig").Mat4;
const shd = @import("shaders/instancing-compute.glsl.zig");

const max_particles: usize = 512 * 1024;
const num_particles_emitted_per_frame: usize = 10;

const state = struct {
    var num_particles: usize = 0;
    var ry: f32 = 0.0;
    const compute = struct {
        var pip: sg.Pipeline = .{};
        var bind: sg.Bindings = .{};
    };
    const display = struct {
        var pip: sg.Pipeline = .{};
        var bind: sg.Bindings = .{};
        var pass_action: sg.PassAction = .{};
        const view: mat4 = mat4.lookat(.{ .x = 0, .y = 1.5, .z = 12.0 }, vec3.zero(), vec3.up());
    };
};

export fn init() void {
    sg.setup(.{
        .environment = sglue.environment(),
        .logger = .{ .func = slog.func },
    });

    // if compute shaders not supported, clear to red color and early out
    if (!sg.queryFeatures().compute) {
        state.display.pass_action.colors[0] = .{
            .load_action = .CLEAR,
            .clear_value = .{ .r = 1, .g = 0, .b = 0, .a = 1 },
        };
        return;
    }

    // regular clear color
    state.display.pass_action.colors[0] = .{
        .load_action = .CLEAR,
        .clear_value = .{ .r = 0, .g = 0.1, .b = 0.2, .a = 1 },
    };

    // a buffer and storage-buffer-view for the partcle state
    const sbuf = sg.makeBuffer(.{
        .usage = .{
            .vertex_buffer = true,
            .storage_buffer = true,
        },
        .size = max_particles * @sizeOf(shd.Particle),
        .label = "particle-buffer",
    });
    const sbuf_view = sg.makeView(.{ .storage_buffer = .{ .buffer = sbuf } });
    state.compute.bind.views[shd.VIEW_cs_ssbo] = sbuf_view;
    state.display.bind.views[shd.VIEW_vs_ssbo] = sbuf_view;

    // a compute shader and pipeline object for updating the particle state
    state.compute.pip = sg.makePipeline(.{
        .compute = true,
        .shader = sg.makeShader(shd.updateShaderDesc(sg.queryBackend())),
        .label = "update-pipeline",
    });

    // vertex and index buffer for particle geometry
    const r = 0.05;
    state.display.bind.vertex_buffers[0] = sg.makeBuffer(.{
        .data = sg.asRange(&[_]f32{
            0.0, -r,  0.0, 1.0, 0.0, 0.0, 1.0,
            r,   0.0, r,   0.0, 1.0, 0.0, 1.0,
            r,   0.0, -r,  0.0, 0.0, 1.0, 1.0,
            -r,  0.0, -r,  1.0, 1.0, 0.0, 1.0,
            -r,  0.0, r,   0.0, 1.0, 1.0, 1.0,
            0.0, r,   0.0, 1.0, 0.0, 1.0, 1.0,
        }),
        .label = "geometry-vbuf",
    });
    state.display.bind.index_buffer = sg.makeBuffer(.{
        .usage = .{ .index_buffer = true },
        .data = sg.asRange(&[_]u16{
            2, 1, 0, 3, 2, 0,
            4, 3, 0, 1, 4, 0,
            5, 1, 2, 5, 2, 3,
            5, 3, 4, 5, 4, 1,
        }),
        .label = "geometry-ibuf",
    });

    // shader and pipeline for rendering the particles, this uses
    // the compute-updated storage buffer to provide the particle positions
    state.display.pip = sg.makePipeline(.{
        .shader = sg.makeShader(shd.displayShaderDesc(sg.queryBackend())),
        .layout = brk: {
            var layout: sg.VertexLayoutState = .{};
            layout.attrs[0] = .{ .format = .FLOAT3 };
            layout.attrs[1] = .{ .format = .FLOAT4 };
            break :brk layout;
        },
        .index_type = .UINT16,
        .depth = .{
            .compare = .LESS_EQUAL,
            .write_enabled = true,
        },
        .cull_mode = .BACK,
        .label = "render-pipeline",
    });

    // one-time init of particle velocities via a compute shader
    const pip = sg.makePipeline(.{
        .compute = true,
        .shader = sg.makeShader(shd.initShaderDesc(sg.queryBackend())),
    });
    sg.beginPass(.{ .compute = true });
    sg.applyPipeline(pip);
    sg.applyBindings(state.compute.bind);
    sg.dispatch(max_particles / 64, 1, 1);
    sg.endPass();
    sg.destroyPipeline(pip);
}

export fn frame() void {
    if (!sg.queryFeatures().compute) {
        drawFallback();
        return;
    }

    state.num_particles += num_particles_emitted_per_frame;
    if (state.num_particles > max_particles) {
        state.num_particles = max_particles;
    }
    const dt: f32 = @floatCast(sapp.frameDuration());

    // compute pass to update particle positions
    const cs_params: shd.CsParams = .{
        .dt = dt,
        .num_particles = @intCast(state.num_particles),
    };
    sg.beginPass(.{ .compute = true, .label = "compute-pass" });
    sg.applyPipeline(state.compute.pip);
    sg.applyBindings(state.compute.bind);
    sg.applyUniforms(shd.UB_cs_params, sg.asRange(&cs_params));
    sg.dispatch(@intCast((state.num_particles + 63) / 64), 1, 1);
    sg.endPass();

    // render pass to render the particles via instancing, with the
    // instance positions coming from the storage buffer
    state.ry += 60.0 * dt;
    const vs_params = computeVsParams(1.0, state.ry);
    sg.beginPass(.{
        .action = state.display.pass_action,
        .swapchain = sglue.swapchain(),
        .label = "render-pass",
    });
    sg.applyPipeline(state.display.pip);
    sg.applyBindings(state.display.bind);
    sg.applyUniforms(shd.UB_vs_params, sg.asRange(&vs_params));
    sg.draw(0, 24, @intCast(state.num_particles));
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
        .icon = .{ .sokol_default = true },
        .window_title = "instancing-compute.zig",
        .logger = .{ .func = slog.func },
    });
}

fn computeVsParams(rx: f32, ry: f32) shd.VsParams {
    const rxm = mat4.rotate(rx, .{ .x = 1.0, .y = 0.0, .z = 0.0 });
    const rym = mat4.rotate(ry, .{ .x = 0.0, .y = 1.0, .z = 0.0 });
    const model = mat4.mul(rxm, rym);
    const aspect = sapp.widthf() / sapp.heightf();
    const proj = mat4.persp(60.0, aspect, 0.01, 50.0);
    return shd.VsParams{ .mvp = mat4.mul(mat4.mul(proj, state.display.view), model) };
}

fn drawFallback() void {
    sg.beginPass(.{ .action = state.display.pass_action, .swapchain = sglue.swapchain(), .label = "render-pass" });
    sg.endPass();
    sg.commit();
}
