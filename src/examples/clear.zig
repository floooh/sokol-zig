//------------------------------------------------------------------------------
//  clear.zig
//
//  Just clear the framebuffer with an animated color.
//------------------------------------------------------------------------------
const sokol = @import("sokol");
const slog  = sokol.log;
const sg    = sokol.gfx;
const sapp  = sokol.app;
const sgapp = sokol.app_gfx_glue;
const print = @import("std").debug.print;

var pass_action: sg.PassAction = .{};

export fn init() void {
    sg.setup(.{
        .context = sgapp.context(),
        .logger = .{ .func = slog.func }
    });
    pass_action.colors[0] = .{ .action=.CLEAR, .value=.{ .r=1, .g=1, .b=0, .a=1 } };
    print("Backend: {}\n", .{ sg.queryBackend()});
}

export fn frame() void {
    const g = pass_action.colors[0].value.g + 0.01;
    pass_action.colors[0].value.g = if (g > 1.0) 0.0 else g;
    sg.beginDefaultPass(pass_action, sapp.width(), sapp.height());
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
        .icon = .{
            .sokol_default = true,
        },
        .window_title = "clear.zig",
        .logger = .{
            .func = slog.func,
        },
        .win32_console_attach = true,
    });
}
