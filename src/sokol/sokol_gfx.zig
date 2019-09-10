const std = @import("std");
const assert = std.debug.assert;
const panic = std.debug.panic;
const c = @cImport({
    @cInclude("sokol_gfx.h");
});

pub const SokolGfx = struct {

pub const MaxShaderStageBuffers = c.SG_MAX_SHADERSTAGE_BUFFERS;
pub const MaxShaderStageImages = c.SG_MAX_SHADERSTAGE_IMAGES;
pub const MaxColorAttachments = c.SG_MAX_COLOR_ATTACHMENTS;

pub const Buffer = struct { id:u32 = 0 };
pub const Image = struct { id:u32 = 0 };
pub const Shader = struct { id:u32 = 0 };
pub const Pipeline = struct { id:u32 = 0 };
pub const Pass = struct { id:u32 = 0 };

pub const Backend = c.sg_backend;
pub const PixelFormat = c.sg_pixel_format;
pub const PixelFormatInfo = c.sg_pixelformat_info;
pub const Features = c.sg_features;
pub const Limits = c.sg_limits;
pub const ResourceState = c.sg_resource_state;
pub const Usage = c.sg_usage;
pub const BufferType = c.sg_buffer_type;
pub const IndexType = c.sg_index_type;
pub const ImageType = c.sg_image_type;
pub const CubeFace = c.sg_cube_face;
pub const ShaderStage = c.sg_shader_stage;
pub const PrimitiveType = c.sg_primitive_type;
pub const Filter = c.sg_filter;
pub const Wrap = c.sg_wrap;
pub const BorderColor = c.sg_border_color;
pub const VertexFormat = c.sg_vertex_format;
pub const VertexStep = c.sg_vertex_step;
pub const UniformType = c.sg_uniform_type;
pub const CullMode = c.sg_cull_mode;
pub const FaceWinding = c.sg_face_winding;
pub const CompareFunc = c.sg_compare_func;
pub const StencilOp = c.sg_stencil_op;
pub const BlendFactor = c.sg_blend_factor;
pub const BlendOp = c.sg_blend_op;
pub const ColorMask = c.sg_color_mask;
pub const Action = c.sg_action;

pub const ColorAttachmentAction = struct {
    action: Action = ._SG_ACTION_DEFAULT,
    val: [4]f32 = [4]f32{ 0, 0, 0, 1 }
};

pub const DepthAttachmentAction = struct {
    action: Action = ._SG_ACTION_DEFAULT,
    val: f32 = 0.0
};

pub const StencilAttachmentAction = struct {
    action: Action = ._SG_ACTION_DEFAULT,
    val: u8 = 0,
};

pub const PassAction = struct {
    colors: [MaxColorAttachments]ColorAttachmentAction = [_].ColorAttachmentAction {ColorAttachmentAction{}} ** MaxColorAttachments,
    depth: DepthAttachmentAction = DepthAttachmentAction { },
    stencil: StencilAttachmentAction = StencilAttachmentAction { },
};

pub const Bindings = struct {
    vertex_buffers: [MaxShaderStageBuffers]Buffer = [_]Buffer {Buffer{}} ** MaxShaderStageBuffers,
    vertex_buffer_offsets: [MaxShaderStageBuffers]i32 = [_]i32 {0} ** MaxShaderStageBuffers,
    index_buffer: Buffer = Buffer{},
    index_buffer_offset: i32 = 0,
    vs_images: [MaxShaderStageImages]Image = [_]Image {Image{}} ** MaxShaderStageImages,
    fs_images: [MaxShaderStageImages]Image = [_]Image {Image{}} ** MaxShaderStageImages,
};

pub const Desc = struct {
    buffer_pool_size: i32 = 0,
    image_pool_size: i32 = 0,
    shader_pool_size: i32 = 0,
    pipeline_pool_size: i32 = 0,
    pass_pool_size: i32 = 0,
    context_pool_size: i32 = 0,
    gl_force_gles2: bool = false,
    mtl_device: ?*const c_void = null,
    mtl_renderpass_descriptor_cb: ?extern fn() ?*const c_void = null,
    mtl_drawable_cb: ?extern fn() ?*const c_void = null,
    mtl_global_uniform_buffer_size: i32 = 0,
    mtl_sampler_cache_size: i32 = 0,
    d3d11_device: ?*const c_void = null,
    d3d11_device_context: ?*const c_void = null,
    d3d11_render_target_view_cb: ?extern fn() ?*const c_void = null,
    d3d11_depth_stencil_view_cb: ?extern fn() ?*const c_void = null,
};

fn conv_desc(desc:Desc) c.sg_desc {
    return c.sg_desc {
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
}

fn conv_pass_action(pass_action: PassAction) c.sg_pass_action {
    return c.sg_pass_action{
        ._start_canary = 0,
        .colors = [_]c.sg_color_attachment_action {
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
}

//== PUBLIC FUNCTIONS ==========================================================
pub fn setup(desc: Desc) void {
    c.sg_setup(&conv_desc(desc));
}

pub fn shutdown() void {
    c.sg_shutdown();
}

pub fn isvalid() bool {
    return c.sg_isvalid();
}

pub fn reset_state_cache() void {
    c.sg_reset_state_cache();
}

// FIXME: install_trace_hooks
// FIXME: push_debug_group
// FIMXE: pop_debug_group

// FIXME: make_buffer
// FIXME: make_image
// FIXME: make_pipeline
// FIXME: make_pass
// FIXME: destroy_buffer
// FIXME: destroy_image
// FIXME: destroy_shader
// FIXME: destroy_pipeline
// FIXME: destroy_pass
// FIXME: update_buffer
// FIXME: update_image
// FIXME: append_buffer
// FIXME: query_buffer_overflow

pub fn begin_default_pass(pass_action: PassAction, width: c_int, height: c_int) void {
    c.sg_begin_default_pass(&conv_pass_action(pass_action), width, height);
}

// FIXME: begin_pass
// FIXME: apply_viewport
// FIXME: apply_scissor_rect
// FIXME: apply_pipeline
// FIXME: apply_bindings
// FIXME: apply_uniforms
// FIXME: draw

pub fn end_pass() void {
    c.sg_end_pass();
}

pub fn commit() void {
    c.sg_commit();
}

// FIXME: query_desc

pub fn query_backend() Backend {
    return c.sg_query_backend();
}

pub fn query_features() Features {
    // FIXME FIXME FIXME: returned struct has random values
    return c.sg_query_features();
}

}; // sokol-gfx