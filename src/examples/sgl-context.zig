//------------------------------------------------------------------------------
//  sgl-context.zig
//
//  Demonstrates how to render into different render passes with sokol-gl.
//  using contexts.
//------------------------------------------------------------------------------
const sokol = @import("sokol");
const slog  = sokol.log;
const sg    = sokol.gfx;
const sapp  = sokol.app;
const sgapp = sokol.app_gfx_glue;
const sgl   = sokol.gl;
const math  = @import("std").math;

const state = struct {
    const offscreen = struct {
        var pass_action: sg.PassAction = .{};
        var pass: sg.Pass = .{};
        var img: sg.Image = .{};
        var sgl_ctx: sgl.Context = .{};
    };
    const display = struct {
        var pass_action: sg.PassAction = .{};
        var sgl_pip: sgl.Pipeline = .{};
    };
};

const offscreen_pixel_format = sg.PixelFormat.RGBA8;
const offscreen_sample_count = 1;
const offscreen_width = 32;
const offscreen_height = 32;

export fn init() void {
    // setup sokol-gfx
    sg.setup(.{
        .context = sgapp.context(),
        .logger = .{ .func = slog.func },
    });

    // setup sokol-gl with the default context compatible with the default
    // render pass (which means just keep pixelformats and sample count at defaults)
    //
    // reduce the vertex- and command-count though, otherwise we just waste memory
    //
    sgl.setup(.{
        .max_vertices = 64,
        .max_commands = 16,
        .logger = .{ .func = slog.func },
    });

    // initialize a pass action struct for the default pass to clear to a light-blue color
    state.display.pass_action.colors[0] = .{
        .action = .CLEAR, .value = .{ .r=0.5, .g=0.7, .b=1, .a=1 }
    };

    // create a sokol-gl pipeline object for 3D rendering into the default pass
    state.display.sgl_pip = sgl.contextMakePipeline(sgl.defaultContext(), .{
        .cull_mode = .BACK,
        .depth = .{
            .write_enabled = true,
            .compare = .LESS_EQUAL,
        },
    });

    // create a sokol-gl context compatible with the offscreen render pass
    // (specific color pixel format, no depth-stencil-surface, no MSAA)
    state.offscreen.sgl_ctx = sgl.makeContext(.{
        .max_vertices = 8,
        .max_commands = 4,
        .color_format = offscreen_pixel_format,
        .depth_format = .NONE,
        .sample_count = offscreen_sample_count,
    });

    // create an offscreen render target texture, pass and pass-action
    state.offscreen.img = sg.makeImage(.{
        .render_target = true,
        .width = offscreen_width,
        .height = offscreen_height,
        .pixel_format = offscreen_pixel_format,
        .sample_count = offscreen_sample_count,
        .wrap_u = .CLAMP_TO_EDGE,
        .wrap_v = .CLAMP_TO_EDGE,
        .min_filter = .NEAREST,
        .mag_filter = .NEAREST,
    });

    var pass_desc = sg.PassDesc{};
    pass_desc.color_attachments[0].image = state.offscreen.img;
    state.offscreen.pass = sg.makePass(pass_desc);

    state.offscreen.pass_action.colors[0] = .{ .action = .CLEAR, .value = .{ .r=0, .g=0, .b=0, .a=1 } };
}

export fn frame() void {
    const a = sgl.asRadians(@intToFloat(f32, sapp.frameCount()));

    // draw a rotating quad into the offscreen render target texture
    sgl.setContext(state.offscreen.sgl_ctx);
    sgl.defaults();
    sgl.matrixModeModelview();
    sgl.rotate(a, 0, 0, 1);
    draw_quad();

    // draw a rotating 3D cube, using the offscreen render target as texture
    sgl.setContext(sgl.defaultContext());
    sgl.defaults();
    sgl.enableTexture();
    sgl.texture(state.offscreen.img);
    sgl.loadPipeline(state.display.sgl_pip);
    sgl.matrixModeProjection();
    sgl.perspective(sgl.asRadians(45.0), sapp.widthf()/sapp.heightf(), 0.1, 100.0);
    const eye = .{ math.sin(a) * 6.0, math.sin(a) * 3.0, math.cos(a) * 6.0, };
    sgl.matrixModeModelview();
    sgl.lookat(eye[0], eye[1], eye[2], 0, 0, 0, 0, 1, 0);
    draw_cube();

    // do the actual offscreen and display rendering in sokol-gfx passes
    sg.beginPass(state.offscreen.pass, state.offscreen.pass_action);
    sgl.contextDraw(state.offscreen.sgl_ctx);
    sg.endPass();
    sg.beginDefaultPass(state.display.pass_action, sapp.width(), sapp.height());
    sgl.contextDraw(sgl.defaultContext());
    sg.endPass();
    sg.commit();
}

export fn cleanup() void {
    sgl.shutdown();
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
        .window_title = "sgl-context.zig",
        .logger = .{ .func = slog.func },
    });
}

fn draw_quad() void {
    sgl.beginQuads();
    sgl.v2fC3b( 0.0, -1.0, 255, 0, 0);
    sgl.v2fC3b( 1.0,  0.0, 0, 0, 255);
    sgl.v2fC3b( 0.0,  1.0, 0, 255, 255);
    sgl.v2fC3b(-1.0,  0.0, 0, 255, 0);
    sgl.end();
}

fn draw_cube() void {
    sgl.beginQuads();
    sgl.v3fT2f(-1.0,  1.0, -1.0, 0.0, 1.0);
    sgl.v3fT2f( 1.0,  1.0, -1.0, 1.0, 1.0);
    sgl.v3fT2f( 1.0, -1.0, -1.0, 1.0, 0.0);
    sgl.v3fT2f(-1.0, -1.0, -1.0, 0.0, 0.0);
    sgl.v3fT2f(-1.0, -1.0,  1.0, 0.0, 1.0);
    sgl.v3fT2f( 1.0, -1.0,  1.0, 1.0, 1.0);
    sgl.v3fT2f( 1.0,  1.0,  1.0, 1.0, 0.0);
    sgl.v3fT2f(-1.0,  1.0,  1.0, 0.0, 0.0);
    sgl.v3fT2f(-1.0, -1.0,  1.0, 0.0, 1.0);
    sgl.v3fT2f(-1.0,  1.0,  1.0, 1.0, 1.0);
    sgl.v3fT2f(-1.0,  1.0, -1.0, 1.0, 0.0);
    sgl.v3fT2f(-1.0, -1.0, -1.0, 0.0, 0.0);
    sgl.v3fT2f( 1.0, -1.0,  1.0, 0.0, 1.0);
    sgl.v3fT2f( 1.0, -1.0, -1.0, 1.0, 1.0);
    sgl.v3fT2f( 1.0,  1.0, -1.0, 1.0, 0.0);
    sgl.v3fT2f( 1.0,  1.0,  1.0, 0.0, 0.0);
    sgl.v3fT2f( 1.0, -1.0, -1.0, 0.0, 1.0);
    sgl.v3fT2f( 1.0, -1.0,  1.0, 1.0, 1.0);
    sgl.v3fT2f(-1.0, -1.0,  1.0, 1.0, 0.0);
    sgl.v3fT2f(-1.0, -1.0, -1.0, 0.0, 0.0);
    sgl.v3fT2f(-1.0,  1.0, -1.0, 0.0, 1.0);
    sgl.v3fT2f(-1.0,  1.0,  1.0, 1.0, 1.0);
    sgl.v3fT2f( 1.0,  1.0,  1.0, 1.0, 0.0);
    sgl.v3fT2f( 1.0,  1.0, -1.0, 0.0, 0.0);
    sgl.end();
}
