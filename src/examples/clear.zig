const sokol = @import("sokol");
const sg = sokol.gfx;
const sapp = sokol.app;
const sgapp = sokol.app_gfx_glue;

var pass_action = sg.PassAction.init(.{
    .colors = .{
        .{ .action = .CLEAR, .val = .{ 1.0, 1.0, 0.0, 1.0 } }
    }
});

fn init() callconv(.C) void {
    sg.setup(.{
        .context = sgapp.context()
    });
}

fn frame() callconv(.C) void {
    const g = pass_action.colors[0].val[1] + 0.01;
    pass_action.colors[0].val[1] = if (g > 1.0) 0.0 else g;
    sg.beginDefaultPass(pass_action, sapp.width(), sapp.height());
    sg.endPass();
    sg.commit();
}

fn cleanup() callconv(.C) void {
    sg.shutdown();
}

pub fn main() void {
    sapp.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .width = 640,
        .height = 480,
        .window_title = "clear.zig"
    });
}
