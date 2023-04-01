//------------------------------------------------------------------------------
//  sgl-points.zig
//
//  Test sokol-gl point rendering.
//
//  (port of this C sample: https://floooh.github.io/sokol-html5/sgl-points-sapp.html)
//------------------------------------------------------------------------------
const sokol = @import("sokol");
const slog  = sokol.log;
const sg    = sokol.gfx;
const sapp  = sokol.app;
const sgl   = sokol.gl;
const sgapp = sokol.app_gfx_glue;
const math = @import("std").math;

const Rgb = struct { r: f32, g: f32, b: f32 };
const state = struct {
    var pass_action = sg.PassAction{};
};

const palette = [16]Rgb {
    .{ .r=0.957, .g=0.263, .b=0.212 },
    .{ .r=0.914, .g=0.118, .b=0.388 },
    .{ .r=0.612, .g=0.153, .b=0.690 },
    .{ .r=0.404, .g=0.227, .b=0.718 },
    .{ .r=0.247, .g=0.318, .b=0.710 },
    .{ .r=0.129, .g=0.588, .b=0.953 },
    .{ .r=0.012, .g=0.663, .b=0.957 },
    .{ .r=0.000, .g=0.737, .b=0.831 },
    .{ .r=0.000, .g=0.588, .b=0.533 },
    .{ .r=0.298, .g=0.686, .b=0.314 },
    .{ .r=0.545, .g=0.765, .b=0.290 },
    .{ .r=0.804, .g=0.863, .b=0.224 },
    .{ .r=1.000, .g=0.922, .b=0.231 },
    .{ .r=1.000, .g=0.757, .b=0.027 },
    .{ .r=1.000, .g=0.596, .b=0.000 },
    .{ .r=1.000, .g=0.341, .b=0.133 },
};

export fn init() void {
    sg.setup(.{
        .context = sgapp.context(),
        .logger = .{ .func = slog.func },
    });
    sgl.setup(.{
        .logger = .{ .func = slog.func },
    });
    state.pass_action.colors[0] = .{ .action=.CLEAR, .value=.{ .r=0, .g=0, .b=0 } };
}

fn computeColor(t: f32) Rgb {
    const idx0 = @floatToInt(usize, t * 16) % 16;
    const idx1 = (idx0 + 1) % 16;
    const l = (t * 16) - @floor(t * 16);
    const c0 = palette[idx0];
    const c1 = palette[idx1];
    return .{
        .r = (c0.r * (1 - l)) + (c1.r * l),
        .g = (c0.g * (1 - l)) + (c1.g * l),
        .b = (c0.b * (1 - l)) + (c1.b * l)
    };
}

export fn frame() void {
    const angle = @intToFloat(f32, sapp.frameCount() % 360);

    sgl.defaults();
    sgl.beginPoints();
    var psize: f32 = 5;
    var i: usize = 0;
    while (i < 300): (i += 1) {
        const a = sgl.asRadians(angle + @intToFloat(f32,i));
        const color = computeColor(@intToFloat(f32, (sapp.frameCount() + i) % 300) / 300);
        const r = math.sin(a * 4.0);
        const s = math.sin(a);
        const c = math.cos(a);
        const x = s * r;
        const y = c * r;
        sgl.c3f(color.r, color.g, color.b);
        sgl.pointSize(psize);
        sgl.v2f(x, y);
        psize *= 1.005;
    }
    sgl.end();

    sg.beginDefaultPass(state.pass_action, sapp.width(), sapp.height());
    sgl.draw();
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
        .width = 512,
        .height = 512,
        .icon = .{ .sokol_default = true },
        .window_title = "sgl-points.zig",
        .logger = .{ .func = slog.func },
    });
}
