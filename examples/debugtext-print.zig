//------------------------------------------------------------------------------
//  debugtext-print.zig
//
//  Demonstrates formatted printing with sokol.debugtext
//------------------------------------------------------------------------------
const sokol = @import("sokol");
const slog = sokol.log;
const sg = sokol.gfx;
const sapp = sokol.app;
const sglue = sokol.glue;
const stm = sokol.time;
const sdtx = @import("sokol").debugtext;

// only needed when using std.fmt directly instead of sokol.debugtext.print()
const fmt = @import("std").fmt;

// font slots
const KC854 = 0;
const C64 = 1;
const ORIC = 2;

const Color = struct { r: u8, g: u8, b: u8 };

const state = struct {
    var pass_action: sg.PassAction = .{};
    var frame_count: u32 = 0;
    var time_stamp: u64 = 0;
    const colors = [_]Color{
        .{ .r = 0xf4, .g = 0x43, .b = 0x36 },
        .{ .r = 0x21, .g = 0x96, .b = 0xf3 },
        .{ .r = 0x4c, .g = 0xaf, .b = 0x50 },
    };
};

export fn init() void {
    // setup sokol.time and sokol.gfx
    stm.setup();
    sg.setup(.{
        .environment = sglue.environment(),
        .logger = .{ .func = slog.func },
    });

    // setup sokol.debugtext with 3 builtin fonts
    sdtx.setup(.{
        .fonts = init: {
            var f: [8]sdtx.FontDesc = @splat(.{});
            f[KC854] = sdtx.fontKc854();
            f[C64] = sdtx.fontC64();
            f[ORIC] = sdtx.fontOric();
            break :init f;
        },
        .logger = .{ .func = slog.func },
    });

    // pass-action for clearing to blue-ish
    state.pass_action.colors[0] = .{
        .load_action = .CLEAR,
        .clear_value = .{ .r = 0, .g = 0.125, .b = 0.25, .a = 1 },
    };
}

export fn frame() void {
    state.frame_count += 1;
    const frame_time = stm.ms(stm.laptime(&state.time_stamp));

    sdtx.canvas(sapp.widthf() * 0.5, sapp.heightf() * 0.5);
    sdtx.origin(3, 3);

    inline for (.{ KC854, C64, ORIC }) |font| {
        const color = state.colors[font];
        sdtx.font(font);
        sdtx.color3b(color.r, color.g, color.b);
        const world_str = if (0 == (state.frame_count & (1 << 7))) "Welt" else "World";
        sdtx.print("Hello '{s}'!\n", .{world_str});
        sdtx.print("\tFrame Time:\t\t{d:.3}ms\n", .{frame_time});
        sdtx.print("\tFrame Count:\t{d}\t0x{X:0>4}\n", .{ state.frame_count, state.frame_count });
        sdtx.moveY(2);
    }
    sdtx.font(KC854);
    sdtx.color3b(255, 128, 0);

    // render the frame via sokol.gfx
    sg.beginPass(.{ .action = state.pass_action, .swapchain = sglue.swapchain() });
    sdtx.draw();
    sg.endPass();
    sg.commit();
}

export fn cleanup() void {
    sdtx.shutdown();
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
        .window_title = "debugtext-print.zig",
        .logger = .{ .func = slog.func },
    });
}
