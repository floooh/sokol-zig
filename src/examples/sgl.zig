//------------------------------------------------------------------------------
//  sgl.zig
//
//  sokol_gl.h / sokol.sgl sample program.
//------------------------------------------------------------------------------
const sokol = @import("sokol");
const slog  = sokol.log;
const sg    = sokol.gfx;
const sapp  = sokol.app;
const sgl   = sokol.gl;
const sgapp = sokol.app_gfx_glue;
const math  = @import("std").math;

const state = struct {
    var pass_action: sg.PassAction = .{};
    var img: sg.Image = .{};
    var pip3d: sgl.Pipeline = .{};
    const quad = struct {
        var rot: f32 = 0.0;
    };
    const cube = struct {
        var rot_x: f32 = 0.0;
        var rot_y: f32 = 0.0;
    };
    const texcube = struct {
        var time_accum: f32 = 0.0;
    };
};

export fn init() void {
    // setup sokol-gfx
    sg.setup(.{
        .context = sgapp.context(),
        .logger = .{ .func = slog.func },
    });
    // setup sokol-gl
    sgl.setup(.{
        .logger = .{ .func = slog.func },
    });

    // a checkerboard texture
    const img_width = 8;
    const img_height = 8;
    const pixels = init: {
        var res: [img_width][img_height]u32 = undefined;
        var y: usize = 0;
        while (y < img_height): (y += 1) {
            var x: usize = 0;
            while (x < img_width): (x += 1) {
                res[y][x] = if (0 == (y ^ x) & 1) 0xFF_00_00_00 else 0xFF_FF_FF_FF;
            }
        }
        break :init res;
    };
    var img_desc: sg.ImageDesc = .{
        .width = img_width,
        .height = img_height,
    };
    // FIXME: https://github.com/ziglang/zig/issues/6068
    img_desc.data.subimage[0][0] = sg.asRange(&pixels);
    state.img = sg.makeImage(img_desc);

    // create a pipeline object for 3d rendering, with less-equal
    // depth-test and cull-face enabled, note that we don't provide
    // a shader, vertex-layout, pixel formats and sample count here,
    // these are all filled in by sokol-gl
    state.pip3d = sgl.makePipeline(.{
        .depth = .{
            .write_enabled = true,
            .compare = .LESS_EQUAL,
        },
        .cull_mode = .BACK,
    });

    // pass-action to clear to black
    state.pass_action.colors[0] = .{ .load_action = .CLEAR, .clear_value = .{ .r=0, .g=0, .b=0, .a=1 }};
}

export fn frame() void {
    // frame time 'normalized' to 60fps
    const dt = @floatCast(f32, sapp.frameDuration()) * 60.0;

    // compute viewport rectangles so that the views are horizontally
    // centered and keep a 1:1 aspect ratio
    const dw = sapp.widthf();
    const dh = sapp.heightf();
    const ww = dh * 0.5;
    const hh = dh * 0.5;
    const x0 = dw * 0.5 - hh;
    const x1 = dw * 0.5;
    const y0 = 0.0;
    const y1 = dh * 0.5;

    sgl.viewportf(x0, y0, ww, hh, true);
    drawTriangle();
    sgl.viewportf(x1, y0, ww, hh, true);
    drawQuad(dt);
    sgl.viewportf(x0, y1, ww, hh, true);
    drawCubes(dt);
    sgl.viewportf(x1, y1, ww, hh, true);
    drawTexCube(dt);
    sgl.viewportf(0, 0, dw, dh, true);

    sg.beginDefaultPass(state.pass_action, sapp.width(), sapp.height());
    sgl.draw();
    sg.endPass();
    sg.commit();
}

export fn cleanup() void {
    sgl.shutdown();
    sg.shutdown();
}

fn drawTriangle() void {
    sgl.defaults();
    sgl.beginTriangles();
    sgl.v2fC3b( 0.0,  0.5, 255, 0, 0);
    sgl.v2fC3b(-0.5, -0.5, 0, 0, 255);
    sgl.v2fC3b( 0.5, -0.5, 0, 255, 0);
    sgl.end();
}

fn drawQuad(dt: f32) void {
    state.quad.rot += 1.0 * dt;
    const scale: f32 = 1.0 + math.sin(sgl.asRadians(state.quad.rot)) * 0.5;
    sgl.defaults();
    sgl.rotate(sgl.asRadians(state.quad.rot), 0.0, 0.0, 1.0);
    sgl.scale(scale, scale, 1.0);
    sgl.beginQuads();
    sgl.v2fC3b( -0.5, -0.5,  255, 255, 0);
    sgl.v2fC3b(  0.5, -0.5,  0, 255, 0);
    sgl.v2fC3b(  0.5,  0.5,  0, 0, 255);
    sgl.v2fC3b( -0.5,  0.5,  255, 0, 0);
    sgl.end();
}

// vertex specification for a cube with colored sides and texture coords
fn drawCube() void {
    sgl.beginQuads();
    sgl.c3f(1.0, 0.0, 0.0);
        sgl.v3fT2f(-1.0,  1.0, -1.0, -1.0,  1.0);
        sgl.v3fT2f( 1.0,  1.0, -1.0,  1.0,  1.0);
        sgl.v3fT2f( 1.0, -1.0, -1.0,  1.0, -1.0);
        sgl.v3fT2f(-1.0, -1.0, -1.0, -1.0, -1.0);
    sgl.c3f(0.0, 1.0, 0.0);
        sgl.v3fT2f(-1.0, -1.0,  1.0, -1.0,  1.0);
        sgl.v3fT2f( 1.0, -1.0,  1.0,  1.0,  1.0);
        sgl.v3fT2f( 1.0,  1.0,  1.0,  1.0, -1.0);
        sgl.v3fT2f(-1.0,  1.0,  1.0, -1.0, -1.0);
    sgl.c3f(0.0, 0.0, 1.0);
        sgl.v3fT2f(-1.0, -1.0,  1.0, -1.0,  1.0);
        sgl.v3fT2f(-1.0,  1.0,  1.0,  1.0,  1.0);
        sgl.v3fT2f(-1.0,  1.0, -1.0,  1.0, -1.0);
        sgl.v3fT2f(-1.0, -1.0, -1.0, -1.0, -1.0);
    sgl.c3f(1.0, 0.5, 0.0);
        sgl.v3fT2f(1.0, -1.0,  1.0, -1.0,   1.0);
        sgl.v3fT2f(1.0, -1.0, -1.0,  1.0,   1.0);
        sgl.v3fT2f(1.0,  1.0, -1.0,  1.0,  -1.0);
        sgl.v3fT2f(1.0,  1.0,  1.0, -1.0,  -1.0);
    sgl.c3f(0.0, 0.5, 1.0);
        sgl.v3fT2f( 1.0, -1.0, -1.0, -1.0,  1.0);
        sgl.v3fT2f( 1.0, -1.0,  1.0,  1.0,  1.0);
        sgl.v3fT2f(-1.0, -1.0,  1.0,  1.0, -1.0);
        sgl.v3fT2f(-1.0, -1.0, -1.0, -1.0, -1.0);
    sgl.c3f(1.0, 0.0, 0.5);
        sgl.v3fT2f(-1.0,  1.0, -1.0, -1.0,  1.0);
        sgl.v3fT2f(-1.0,  1.0,  1.0,  1.0,  1.0);
        sgl.v3fT2f( 1.0,  1.0,  1.0,  1.0, -1.0);
        sgl.v3fT2f( 1.0,  1.0, -1.0, -1.0, -1.0);
    sgl.end();
}

fn drawCubes(dt: f32) void {
    state.cube.rot_x += 1.0 * dt;
    state.cube.rot_y += 2.0 * dt;

    sgl.defaults();
    sgl.loadPipeline(state.pip3d);

    sgl.matrixModeProjection();
    sgl.perspective(sgl.asRadians(45.0), 1.0, 0.1, 100.0);

    sgl.matrixModeModelview();
    sgl.translate(0.0, 0.0, -12.0);
    sgl.rotate(sgl.asRadians(state.cube.rot_x), 1.0, 0.0, 0.0);
    sgl.rotate(sgl.asRadians(state.cube.rot_y), 0.0, 1.0, 0.0);
    drawCube();
    sgl.pushMatrix();
        sgl.translate(0.0, 0.0, 3.0);
        sgl.scale(0.5, 0.5, 0.5);
        sgl.rotate(-2.0 * sgl.asRadians(state.cube.rot_x), 1.0, 0.0, 0.0);
        sgl.rotate(-2.0 * sgl.asRadians(state.cube.rot_y), 0.0, 1.0, 0.0);
        drawCube();
        sgl.pushMatrix();
            sgl.translate(0.0, 0.0, 3.0);
            sgl.scale(0.5, 0.5, 0.5);
            sgl.rotate(-3.0 * sgl.asRadians(state.cube.rot_x), 1.0, 0.0, 0.0);
            sgl.rotate(3.0 * sgl.asRadians(state.cube.rot_y), 0.0, 0.0, 1.0);
            drawCube();
        sgl.popMatrix();
    sgl.popMatrix();
}

fn drawTexCube(dt: f32) void {
    state.texcube.time_accum += dt;
    const a = sgl.asRadians(state.texcube.time_accum);

    // texture matrix rotation and scale
    const tex_rot = a * 0.5;
    const tex_scale = 1.0 + math.sin(a) * 0.5;

    // compute an orbiting eye position for testing sgl.lookat()
    const eye_x = math.sin(a) * 6.0;
    const eye_y = math.sin(a) * 3.0;
    const eye_z = math.cos(a) * 6.0;

    sgl.defaults();
    sgl.loadPipeline(state.pip3d);

    sgl.enableTexture();
    sgl.texture(state.img);

    sgl.matrixModeProjection();
    sgl.perspective(sgl.asRadians(45.0), 1.0, 0.1, 100.0);
    sgl.matrixModeModelview();
    sgl.lookat(eye_x, eye_y, eye_z, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);
    sgl.matrixModeTexture();
    sgl.rotate(tex_rot, 0.0, 0.0, 1.0);
    sgl.scale(tex_scale, tex_scale, 1.0);
    drawCube();
}

pub fn main() void {
    sapp.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .width = 512,
        .height = 512,
        .sample_count = 4,
        .icon = .{ .sokol_default = true },
        .window_title = "sgl.zig",
        .logger = .{ .func = slog.func },
    });
}
