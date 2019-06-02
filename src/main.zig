const std = @import("std");
const warn = std.debug.warn;
const sokol = @import("sokol.zig");
const sapp = sokol.App;
const sg = sokol.Gfx;

var green: f32 = 0.0;

extern fn init_cb() void {
    sg.setup(sg.Desc{
        .mtl_device = sapp.metal_get_device(),
        .mtl_renderpass_descriptor_cb = sapp.metal_get_renderpass_descriptor,
        .mtl_drawable_cb = sapp.metal_get_drawable,
    });
}

fn make_pass_action(r: f32, g: f32, b: f32) sg.PassAction {
    return sg.PassAction {
        .colors = [4]sg.ColorAttachmentAction {
            sg.ColorAttachmentAction {
                .action = sg.Action.SG_ACTION_CLEAR,
                .val = [4]f32{r, g, b, 1.0}
            },
            sg.ColorAttachmentAction { },
            sg.ColorAttachmentAction { },
            sg.ColorAttachmentAction { },
        }
    };
}

extern fn frame_cb() void {
    green += 0.01;
    if (green > 1.0) {
        green = 0.0;
    }
    sg.begin_default_pass(make_pass_action(1.0, green, 0.0), sapp.width(), sapp.height());
    sg.end_pass();
    sg.commit();
}

extern fn cleanup_cb() void {
    sg.shutdown();
}

pub fn main() anyerror!void {
    sapp.run(sapp.Desc {
        .init_cb = init_cb,
        .frame_cb = frame_cb,
        .cleanup_cb = cleanup_cb,
        .width = 640,
        .height = 480,
        .window_title = c"Hello sokol-zig!"
    });
}

