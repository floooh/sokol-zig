const sapp = @import("sokol/sokol_app.zig").SokolApp;
const sg = @import("sokol/sokol_gfx.zig").SokolGfx;
const warn = @import("std").debug.warn;

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

    var bind = sg.Bindings { };
    var buf = sg.Buffer { .id=123 };
    var img = sg.Image { .id=234 };

    warn("Backend: ");
    switch (sg.query_backend()) {
        .SG_BACKEND_GLCORE33 => { warn("GLCORE33\n"); },
        .SG_BACKEND_GLES2 => { warn("GLES2\n"); },
        .SG_BACKEND_GLES3 => { warn("GLES3\n"); },
        .SG_BACKEND_D3D11 => { warn("D3D11\n"); },
        .SG_BACKEND_METAL_IOS => { warn("METAL_IOS\n"); },
        .SG_BACKEND_METAL_MACOS => { warn("METAL_MACOS\n"); },
        .SG_BACKEND_METAL_SIMULATOR => { warn("METAL_SIMULATOR\n"); },
        else => { warn("???"); }
    }

    warn("Features:\n");
    const features = sg.query_features();
    warn("  instancing: {}\n", features.instancing);
    warn("  origin_top_left: {}\n", features.origin_top_left);
    warn("  multiple_render_targets: {}\n", features.multiple_render_targets);
    warn("  msaa_render_targets: {}\n", features.msaa_render_targets);
    warn("  imagetype_3d: {}\n", features.imagetype_3d);
    warn("  imagetype_array: {}\n", features.imagetype_array);
    warn("  image_clamp_to_border: {}\n", features.image_clamp_to_border);
}

fn frame_cb() void {
    const g = pass_action.colors[0].val[1] + 0.01;
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

