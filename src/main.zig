const sapp = @import("sokol_app.zig").App;
const sg = @import("sokol_gfx.zig").Gfx;

var green: f32 = 0.0;

fn init_cb() void {
    sg.setup(sg.Desc{
        .mtl_device = sapp.metal_get_device(),
        .mtl_renderpass_descriptor_cb = sapp.metal_get_renderpass_descriptor,
        .mtl_drawable_cb = sapp.metal_get_drawable,
    });
}

fn frame_cb() void {
    green = if (green >= 1.0) 0.0 else green + 0.01;
    const pass_action = sg.PassAction {
        .colors = [_]sg.ColorAttachmentAction {
            sg.ColorAttachmentAction {
                .action = .SG_ACTION_CLEAR,
                .val = [_]f32 {1.0, green, 0.0}
            }
        }
    };
    sg.begin_default_pass(pass_action, sapp.width(), sapp.height());
    sg.end_pass();
    sg.commit();
}

fn cleanup_cb() void {
    sg.shutdown();
}

pub fn main() !void {
    return sapp.run(sapp.Desc {
        .init_cb = init_cb,
        .frame_cb = frame_cb,
        .cleanup_cb = cleanup_cb,
        .width = 640,
        .height = 480,
        .window_title = c"Hello sokol-zig!"
    });
}

