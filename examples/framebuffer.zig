//------------------------------------------------------------------------------
//  framebuffer.zig
//
//  Render into a CPU framebuffer and blit to window.
//------------------------------------------------------------------------------
const std = @import("std");

const sokol = @import("sokol");
const slog = sokol.log;
const sg = sokol.gfx;
const sapp = sokol.app;
const sglue = sokol.glue;
const sfb = sokol.framebuffer;
const print = @import("std").debug.print;

const state = struct {
    var pass_action: sg.PassAction = .{};
    var fb: sfb.Framebuffer = .{};
    var pixels: [240][320]u32 = undefined;
};

export fn init() void {
    sg.setup(.{
        .environment = sglue.environment(),
        .logger = .{ .func = slog.func },
    });
    sfb.setup(.{
        .logger = .{ .func = slog.func },
    });

    state.pass_action.colors[0] = .{ .load_action = .CLEAR, .clear_value = .{ .r = 0.25, .g = 0.5, .b = 0.75, .a = 1 } };
    state.fb = sfb.makeFramebuffer(.{ .width = 320, .height = 240 });
}

fn rgb(r: u32, g: u32, b: u32) u32 {
    return r + (g << 8) + (b << 16);
}

const palette_rgb: [16]u32 = [_]u32{
    rgb(0x0d, 0x08, 0x14),
    rgb(0x36, 0x1d, 0x59),
    rgb(0x65, 0x33, 0x99),
    rgb(0x5c, 0x69, 0xd4),
    rgb(0x5c, 0xc1, 0xe5),
    rgb(0x88, 0xe3, 0xbb),
    rgb(0xd8, 0xea, 0x79),
    rgb(0xff, 0xe0, 0x6d),
    rgb(0xff, 0xad, 0x58),
    rgb(0xf0, 0x70, 0x44),
    rgb(0xd0, 0x42, 0x5f),
    rgb(0xaf, 0x42, 0x95),
    rgb(0x82, 0x3e, 0xb0),
    rgb(0x52, 0x3d, 0x82),
    rgb(0x28, 0x24, 0x49),
    rgb(0x12, 0x0b, 0x18),
};

fn sintab(i: f32) f32 {
    const f: f32 = i * 2 + 1;
    return 128.0 + 125.0 * std.math.sin(f * 3.14159265358979 / 256.0);
}

export fn frame() void {
    // CPU render some pixels.  Loosely ported from https://www.shadertoy.com/view/4dXfWf.
    const t: f32 = @as(f32, @floatFromInt(sapp.frameCount())) * 0.1;
    const s: f32 = 75.0 + 12.0 * std.math.sin(t * 0.02);
    for (0..state.pixels.len) |y| {
        const row = state.pixels[y][0..];
        for (0..row.len) |x| {
            const fx: f32 = @as(f32, @floatFromInt(x)) / 4.0;
            const fy: f32 = @as(f32, @floatFromInt(y)) / 4.0;
            const xs = (sintab(((fx - 40) * s * 8 + t * 456) / 256) + sintab(((fx - 40) * s * 13 - t * 321) / 256)) / 16;
            const ys = (sintab(((fy - 25) * s * 9 + t * 567) / 256) + sintab(((fy - 25) * s * 13 - t * 123) / 256)) / 16;
            const idx: i32 = @intFromFloat(xs + ys);
            row[x] = palette_rgb[@intCast(idx & 15)];
        }
    }

    // Update the pixel data.
    sfb.update(state.fb, .{ .pixels = sg.asRange(&state.pixels) });

    sg.beginPass(.{ .action = state.pass_action, .swapchain = sglue.swapchain() });
    // Blit to screen.
    sfb.renderEx(state.fb, .{ .use_nearest_filter = true });
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
        .width = 640,
        .height = 480,
        .icon = .{ .sokol_default = true },
        .depth_format = .NONE,
        .window_title = "framebuffer.zig",
        .logger = .{ .func = slog.func },
        .win32 = .{ .console_attach = true },
    });
}
