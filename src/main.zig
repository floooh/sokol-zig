const warn = @import("std").debug.warn;
const sapp = @import("sokol/sokol.zig").App;

fn init_cb() void {
    warn("init callback called!\n");
}

fn frame_cb() void {
    // bla
}

fn cleanup_cb() void {
    warn("cleanup callback called!");
}

pub fn main() void {
    sapp.run(&sapp.Desc{
        .init_cb = init_cb,
        .frame_cb = frame_cb,
        .cleanup_cb = cleanup_cb,
        .width = 640,
        .height = 480,
        .window_title = c"Hello sokol-zig!",
    });
}
