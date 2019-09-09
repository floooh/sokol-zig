const sapp = @import("sokol/sokol_app.zig").SokolApp;
const sg = @import("sokol/sokol_gfx.zig").SokolGfx;

var pass_action: sg.PassAction = undefined;

fn init_cb() void {
    sg.setup(sg.Desc{
        .mtl_device = sapp.metal_get_device(),
        .mtl_renderpass_descriptor_cb = sapp.metal_get_renderpass_descriptor,
        .mtl_drawable_cb = sapp.metal_get_drawable,
    });
    pass_action = sg.PassAction {
        .colors = [_]sg.ColorAttachmentAction {
            sg.ColorAttachmentAction { .action = .SG_ACTION_CLEAR, .val = [_]f32 {1.0, 0.0, 0.0} }
        }
    };
}

fn frame_cb() void {
    var g = pass_action.colors[0].val[1] + 0.01;
    pass_action.colors[0].val[1] = if (g > 1.0) 0.0 else g;
    sg.begin_default_pass(pass_action, sapp.width(), sapp.height());
    sg.end_pass();
    sg.commit();
}

fn cleanup_cb() void {
    sg.shutdown();
}

pub fn main() !void {
    try sapp.run(sapp.Desc {
        .init_cb = init_cb,
        .frame_cb = frame_cb,
        .cleanup_cb = cleanup_cb,
        .width = 640,
        .height = 480,
        .window_title = c"Hello sokol-zig!"
    });
}

