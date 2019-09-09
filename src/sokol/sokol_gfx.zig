const std = @import("std");
const assert = std.debug.assert;
const panic = std.debug.panic;
const c = @cImport({
    @cInclude("sokol_gfx.h");
});

pub const SokolGfx = struct {

pub const Desc = struct {
    _start_canary: u32 = 0,
    buffer_pool_size: c_int = 0,
    image_pool_size: c_int = 0,
    shader_pool_size: c_int = 0,
    pipeline_pool_size: c_int = 0,
    pass_pool_size: c_int = 0,
    context_pool_size: c_int = 0,
    gl_force_gles2: bool = false,
    mtl_device: ?*const c_void = null,
    mtl_renderpass_descriptor_cb: ?extern fn() ?*const c_void = null,
    mtl_drawable_cb: ?extern fn() ?*const c_void = null,
    mtl_global_uniform_buffer_size: c_int = 0,
    mtl_sampler_cache_size: c_int = 0,
    d3d11_device: ?*const c_void = null,
    d3d11_device_context: ?*const c_void = null,
    d3d11_render_target_view_cb: ?extern fn() ?*const c_void = null,
    d3d11_depth_stencil_view_cb: ?extern fn() ?*const c_void = null,
    _end_canary: u32 = 0
};

pub const Action = c.sg_action;
pub const ColorAttachmentAction = struct {
    action: Action = Action._SG_ACTION_DEFAULT,
    val: [4]f32 = [4]f32{ 0, 0, 0, 1 }
};
pub const DepthAttachmentAction = struct {
    action: Action = Action._SG_ACTION_DEFAULT,
    val: f32 = 0.0
};
pub const StencilAttachmentAction = struct {
    action: Action = Action._SG_ACTION_DEFAULT,
    val: u8 = 0,
};

pub const PassAction = struct {
    _start_canary: u32 = 0,
    colors: [4]ColorAttachmentAction = [4].ColorAttachmentAction {
        ColorAttachmentAction { },
        ColorAttachmentAction { },
        ColorAttachmentAction { },
        ColorAttachmentAction { },
    },
    depth: DepthAttachmentAction = DepthAttachmentAction { },
    stencil: StencilAttachmentAction = StencilAttachmentAction { },
    _end_canary: u32 = 0,
};

pub fn setup(desc: Desc) void {
    const sg_desc = c.sg_desc {
        ._start_canary = 0,
        .buffer_pool_size = desc.buffer_pool_size,
        .image_pool_size = desc.image_pool_size,
        .shader_pool_size = desc.shader_pool_size,
        .pipeline_pool_size = desc.pipeline_pool_size,
        .pass_pool_size = desc.pass_pool_size,
        .context_pool_size = desc.context_pool_size,
        .gl_force_gles2 = desc.gl_force_gles2,
        .mtl_device = desc.mtl_device,
        .mtl_renderpass_descriptor_cb = desc.mtl_renderpass_descriptor_cb,
        .mtl_drawable_cb = desc.mtl_drawable_cb,
        .mtl_global_uniform_buffer_size = desc.mtl_global_uniform_buffer_size,
        .mtl_sampler_cache_size = desc.mtl_sampler_cache_size,
        .d3d11_device = desc.d3d11_device,
        .d3d11_device_context = desc.d3d11_device_context,
        .d3d11_render_target_view_cb = desc.d3d11_render_target_view_cb,
        .d3d11_depth_stencil_view_cb = desc.d3d11_depth_stencil_view_cb,
        ._end_canary = 0
    };
    c.sg_setup(&sg_desc);
}
pub fn shutdown() void {
    c.sg_shutdown();
}

pub fn begin_default_pass(pass_action: PassAction, width: c_int, height: c_int) void {
    const ps = c.sg_pass_action{
        ._start_canary = 0,
        .colors = [4]c.sg_color_attachment_action {
            c.sg_color_attachment_action {
                .action = pass_action.colors[0].action,
                .val = pass_action.colors[0].val,
            },
            c.sg_color_attachment_action {
                .action = pass_action.colors[1].action,
                .val = pass_action.colors[1].val,
            },
            c.sg_color_attachment_action {
                .action = pass_action.colors[2].action,
                .val = pass_action.colors[2].val,
            },
            c.sg_color_attachment_action {
                .action = pass_action.colors[3].action,
                .val = pass_action.colors[3].val,
            },
        },
        .depth = c.sg_depth_attachment_action {
            .action = pass_action.depth.action,
            .val = pass_action.depth.val,
        },
        .stencil = c.sg_stencil_attachment_action {
            .action = pass_action.stencil.action,
            .val = pass_action.stencil.val,
        },
        ._end_canary = 0,
    };
    c.sg_begin_default_pass(&ps, width, height);
}
pub fn end_pass() void {
    c.sg_end_pass();
}

pub fn commit() void {
    c.sg_commit();
}

}; // sokol-gfx