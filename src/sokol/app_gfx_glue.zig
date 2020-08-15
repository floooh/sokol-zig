const sg = @import("gfx.zig");
const sapp = @import("app.zig");

pub fn context() sg.ContextDesc {
    return sg.ContextDesc {
        .color_format = sapp.colorFormat(),
        .depth_format = sapp.depthFormat(),
        .sample_count = sapp.sampleCount(),
        .gl = .{
            .force_gles2 = sapp.gles2(),
        },
        .metal = .{
            .device = sapp.sapp_metal_get_device(),
            .renderpass_descriptor_cb = sapp.sapp_metal_get_renderpass_descriptor,
            .drawable_cb = sapp.sapp_metal_get_drawable,
        },
        .d3d11 = .{
            .device = sapp.sapp_d3d11_get_device(),
            .device_context = sapp.sapp_d3d11_get_device_context(),
            .render_target_view_cb = sapp.sapp_d3d11_get_render_target_view,
            .depth_stencil_view_cb = sapp.sapp_d3d11_get_depth_stencil_view
        },
        .wgpu = .{
            .device = sapp.sapp_wgpu_get_device(),
            .render_view_cb = sapp.sapp_wgpu_get_render_view,
            .resolve_view_cb = sapp.sapp_wgpu_get_resolve_view,
            .depth_stencil_view_cb = sapp.sapp_wgpu_get_depth_stencil_view
        }
    };
}



