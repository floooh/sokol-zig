// machine generated, do not edit

pub const Buffer = extern struct {
    id: u32 = 0,
};
pub const Image = extern struct {
    id: u32 = 0,
};
pub const Shader = extern struct {
    id: u32 = 0,
};
pub const Pipeline = extern struct {
    id: u32 = 0,
};
pub const Pass = extern struct {
    id: u32 = 0,
};
pub const Context = extern struct {
    id: u32 = 0,
};
pub const Range = extern struct {
    ptr: ?*const c_void = null,
    size: usize = 0,
};
pub const invalid_id = 0;
pub const num_shader_stages = 2;
pub const num_inflight_frames = 2;
pub const max_color_attachments = 4;
pub const max_shaderstage_buffers = 8;
pub const max_shaderstage_images = 12;
pub const max_shaderstage_ubs = 4;
pub const max_ub_members = 16;
pub const max_vertex_attributes = 16;
pub const max_mipmaps = 16;
pub const max_texturearray_layers = 128;
pub const Backend = extern enum(i32) {
    GLCORE33,
    GLES2,
    GLES3,
    D3D11,
    METAL_IOS,
    METAL_MACOS,
    METAL_SIMULATOR,
    WGPU,
    DUMMY,
};
pub const PixelFormat = extern enum(i32) {
    DEFAULT,
    NONE,
    R8,
    R8SN,
    R8UI,
    R8SI,
    R16,
    R16SN,
    R16UI,
    R16SI,
    R16F,
    RG8,
    RG8SN,
    RG8UI,
    RG8SI,
    R32UI,
    R32SI,
    R32F,
    RG16,
    RG16SN,
    RG16UI,
    RG16SI,
    RG16F,
    RGBA8,
    RGBA8SN,
    RGBA8UI,
    RGBA8SI,
    BGRA8,
    RGB10A2,
    RG11B10F,
    RG32UI,
    RG32SI,
    RG32F,
    RGBA16,
    RGBA16SN,
    RGBA16UI,
    RGBA16SI,
    RGBA16F,
    RGBA32UI,
    RGBA32SI,
    RGBA32F,
    DEPTH,
    DEPTH_STENCIL,
    BC1_RGBA,
    BC2_RGBA,
    BC3_RGBA,
    BC4_R,
    BC4_RSN,
    BC5_RG,
    BC5_RGSN,
    BC6H_RGBF,
    BC6H_RGBUF,
    BC7_RGBA,
    PVRTC_RGB_2BPP,
    PVRTC_RGB_4BPP,
    PVRTC_RGBA_2BPP,
    PVRTC_RGBA_4BPP,
    ETC2_RGB8,
    ETC2_RGB8A1,
    ETC2_RGBA8,
    ETC2_RG11,
    ETC2_RG11SN,
    NUM,
};
pub const PixelformatInfo = extern struct {
    sample: bool = false,
    filter: bool = false,
    render: bool = false,
    blend: bool = false,
    msaa: bool = false,
    depth: bool = false,
    __pad: [3]u32 = [_]u32{0} ** 3,
};
pub const Features = extern struct {
    instancing: bool = false,
    origin_top_left: bool = false,
    multiple_render_targets: bool = false,
    msaa_render_targets: bool = false,
    imagetype_3d: bool = false,
    imagetype_array: bool = false,
    image_clamp_to_border: bool = false,
    __pad: [3]u32 = [_]u32{0} ** 3,
};
pub const Limits = extern struct {
    max_image_size_2d: u32 = 0,
    max_image_size_cube: u32 = 0,
    max_image_size_3d: u32 = 0,
    max_image_size_array: u32 = 0,
    max_image_array_layers: u32 = 0,
    max_vertex_attrs: u32 = 0,
};
pub const ResourceState = extern enum(i32) {
    INITIAL,
    ALLOC,
    VALID,
    FAILED,
    INVALID,
};
pub const Usage = extern enum(i32) {
    DEFAULT,
    IMMUTABLE,
    DYNAMIC,
    STREAM,
    NUM,
};
pub const BufferType = extern enum(i32) {
    DEFAULT,
    VERTEXBUFFER,
    INDEXBUFFER,
    NUM,
};
pub const IndexType = extern enum(i32) {
    DEFAULT,
    NONE,
    UINT16,
    UINT32,
    NUM,
};
pub const ImageType = extern enum(i32) {
    DEFAULT,
    _2D,
    CUBE,
    _3D,
    ARRAY,
    NUM,
};
pub const SamplerType = extern enum(i32) {
    DEFAULT,
    FLOAT,
    SINT,
    UINT,
};
pub const CubeFace = extern enum(i32) {
    POS_X,
    NEG_X,
    POS_Y,
    NEG_Y,
    POS_Z,
    NEG_Z,
    NUM,
};
pub const ShaderStage = extern enum(i32) {
    VS,
    FS,
};
pub const PrimitiveType = extern enum(i32) {
    DEFAULT,
    POINTS,
    LINES,
    LINE_STRIP,
    TRIANGLES,
    TRIANGLE_STRIP,
    NUM,
};
pub const Filter = extern enum(i32) {
    DEFAULT,
    NEAREST,
    LINEAR,
    NEAREST_MIPMAP_NEAREST,
    NEAREST_MIPMAP_LINEAR,
    LINEAR_MIPMAP_NEAREST,
    LINEAR_MIPMAP_LINEAR,
    NUM,
};
pub const Wrap = extern enum(i32) {
    DEFAULT,
    REPEAT,
    CLAMP_TO_EDGE,
    CLAMP_TO_BORDER,
    MIRRORED_REPEAT,
    NUM,
};
pub const BorderColor = extern enum(i32) {
    DEFAULT,
    TRANSPARENT_BLACK,
    OPAQUE_BLACK,
    OPAQUE_WHITE,
    NUM,
};
pub const VertexFormat = extern enum(i32) {
    INVALID,
    FLOAT,
    FLOAT2,
    FLOAT3,
    FLOAT4,
    BYTE4,
    BYTE4N,
    UBYTE4,
    UBYTE4N,
    SHORT2,
    SHORT2N,
    USHORT2N,
    SHORT4,
    SHORT4N,
    USHORT4N,
    UINT10_N2,
    NUM,
};
pub const VertexStep = extern enum(i32) {
    DEFAULT,
    PER_VERTEX,
    PER_INSTANCE,
    NUM,
};
pub const UniformType = extern enum(i32) {
    INVALID,
    FLOAT,
    FLOAT2,
    FLOAT3,
    FLOAT4,
    MAT4,
    NUM,
};
pub const CullMode = extern enum(i32) {
    DEFAULT,
    NONE,
    FRONT,
    BACK,
    NUM,
};
pub const FaceWinding = extern enum(i32) {
    DEFAULT,
    CCW,
    CW,
    NUM,
};
pub const CompareFunc = extern enum(i32) {
    DEFAULT,
    NEVER,
    LESS,
    EQUAL,
    LESS_EQUAL,
    GREATER,
    NOT_EQUAL,
    GREATER_EQUAL,
    ALWAYS,
    NUM,
};
pub const StencilOp = extern enum(i32) {
    DEFAULT,
    KEEP,
    ZERO,
    REPLACE,
    INCR_CLAMP,
    DECR_CLAMP,
    INVERT,
    INCR_WRAP,
    DECR_WRAP,
    NUM,
};
pub const BlendFactor = extern enum(i32) {
    DEFAULT,
    ZERO,
    ONE,
    SRC_COLOR,
    ONE_MINUS_SRC_COLOR,
    SRC_ALPHA,
    ONE_MINUS_SRC_ALPHA,
    DST_COLOR,
    ONE_MINUS_DST_COLOR,
    DST_ALPHA,
    ONE_MINUS_DST_ALPHA,
    SRC_ALPHA_SATURATED,
    BLEND_COLOR,
    ONE_MINUS_BLEND_COLOR,
    BLEND_ALPHA,
    ONE_MINUS_BLEND_ALPHA,
    NUM,
};
pub const BlendOp = extern enum(i32) {
    DEFAULT,
    ADD,
    SUBTRACT,
    REVERSE_SUBTRACT,
    NUM,
};
pub const ColorMask = extern enum(i32) {
    DEFAULT = 0,
    NONE = 16,
    R = 1,
    G = 2,
    B = 4,
    A = 8,
    RGB = 7,
    RGBA = 15,
};
pub const Action = extern enum(i32) {
    DEFAULT,
    CLEAR,
    LOAD,
    DONTCARE,
    NUM,
};
pub const ColorAttachmentAction = extern struct {
    action: Action = .DEFAULT,
    val: [4]f32 = [_]f32{0.0} ** 4,
};
pub const DepthAttachmentAction = extern struct {
    action: Action = .DEFAULT,
    val: f32 = 0.0,
};
pub const StencilAttachmentAction = extern struct {
    action: Action = .DEFAULT,
    val: u8 = 0,
};
pub const PassAction = extern struct {
    _start_canary: u32 = 0,
    colors: [4]ColorAttachmentAction = [_]ColorAttachmentAction{.{}} ** 4,
    depth: DepthAttachmentAction = .{ },
    stencil: StencilAttachmentAction = .{ },
    _end_canary: u32 = 0,
};
pub const Bindings = extern struct {
    _start_canary: u32 = 0,
    vertex_buffers: [8]Buffer = [_]Buffer{.{}} ** 8,
    vertex_buffer_offsets: [8]i32 = [_]i32{0} ** 8,
    index_buffer: Buffer = .{ },
    index_buffer_offset: i32 = 0,
    vs_images: [12]Image = [_]Image{.{}} ** 12,
    fs_images: [12]Image = [_]Image{.{}} ** 12,
    _end_canary: u32 = 0,
};
pub const BufferDesc = extern struct {
    _start_canary: u32 = 0,
    size: usize = 0,
    type: BufferType = .DEFAULT,
    usage: Usage = .DEFAULT,
    data: Range = .{ },
    label: [*c]const u8 = null,
    gl_buffers: [2]u32 = [_]u32{0} ** 2,
    mtl_buffers: [2]?*const c_void = [_]?*const c_void { null } ** 2,
    d3d11_buffer: ?*const c_void = null,
    wgpu_buffer: ?*const c_void = null,
    _end_canary: u32 = 0,
};
pub const ImageData = extern struct {
    subimage: [6][16]Range = [_][16]Range{[_]Range{ .{ } }**16}**6,
};
pub const ImageDesc = extern struct {
    _start_canary: u32 = 0,
    type: ImageType = .DEFAULT,
    render_target: bool = false,
    width: i32 = 0,
    height: i32 = 0,
    num_slices: i32 = 0,
    num_mipmaps: i32 = 0,
    usage: Usage = .DEFAULT,
    pixel_format: PixelFormat = .DEFAULT,
    sample_count: i32 = 0,
    min_filter: Filter = .DEFAULT,
    mag_filter: Filter = .DEFAULT,
    wrap_u: Wrap = .DEFAULT,
    wrap_v: Wrap = .DEFAULT,
    wrap_w: Wrap = .DEFAULT,
    border_color: BorderColor = .DEFAULT,
    max_anisotropy: u32 = 0,
    min_lod: f32 = 0.0,
    max_lod: f32 = 0.0,
    data: ImageData = .{ },
    label: [*c]const u8 = null,
    gl_textures: [2]u32 = [_]u32{0} ** 2,
    gl_texture_target: u32 = 0,
    mtl_textures: [2]?*const c_void = [_]?*const c_void { null } ** 2,
    d3d11_texture: ?*const c_void = null,
    d3d11_shader_resource_view: ?*const c_void = null,
    wgpu_texture: ?*const c_void = null,
    _end_canary: u32 = 0,
};
pub const ShaderAttrDesc = extern struct {
    name: [*c]const u8 = null,
    sem_name: [*c]const u8 = null,
    sem_index: i32 = 0,
};
pub const ShaderUniformDesc = extern struct {
    name: [*c]const u8 = null,
    type: UniformType = .INVALID,
    array_count: i32 = 0,
};
pub const ShaderUniformBlockDesc = extern struct {
    size: i32 = 0,
    uniforms: [16]ShaderUniformDesc = [_]ShaderUniformDesc{.{}} ** 16,
};
pub const ShaderImageDesc = extern struct {
    name: [*c]const u8 = null,
    type: ImageType = .DEFAULT,
    sampler_type: SamplerType = .DEFAULT,
};
pub const ShaderStageDesc = extern struct {
    source: [*c]const u8 = null,
    byte_code: ?[*]const u8 = null,
    byte_code_size: i32 = 0,
    entry: [*c]const u8 = null,
    d3d11_target: [*c]const u8 = null,
    uniform_blocks: [4]ShaderUniformBlockDesc = [_]ShaderUniformBlockDesc{.{}} ** 4,
    images: [12]ShaderImageDesc = [_]ShaderImageDesc{.{}} ** 12,
};
pub const ShaderDesc = extern struct {
    _start_canary: u32 = 0,
    attrs: [16]ShaderAttrDesc = [_]ShaderAttrDesc{.{}} ** 16,
    vs: ShaderStageDesc = .{ },
    fs: ShaderStageDesc = .{ },
    label: [*c]const u8 = null,
    _end_canary: u32 = 0,
};
pub const BufferLayoutDesc = extern struct {
    stride: i32 = 0,
    step_func: VertexStep = .DEFAULT,
    step_rate: i32 = 0,
};
pub const VertexAttrDesc = extern struct {
    buffer_index: i32 = 0,
    offset: i32 = 0,
    format: VertexFormat = .INVALID,
};
pub const LayoutDesc = extern struct {
    buffers: [8]BufferLayoutDesc = [_]BufferLayoutDesc{.{}} ** 8,
    attrs: [16]VertexAttrDesc = [_]VertexAttrDesc{.{}} ** 16,
};
pub const StencilState = extern struct {
    fail_op: StencilOp = .DEFAULT,
    depth_fail_op: StencilOp = .DEFAULT,
    pass_op: StencilOp = .DEFAULT,
    compare_func: CompareFunc = .DEFAULT,
};
pub const DepthStencilState = extern struct {
    stencil_front: StencilState = .{ },
    stencil_back: StencilState = .{ },
    depth_compare_func: CompareFunc = .DEFAULT,
    depth_write_enabled: bool = false,
    stencil_enabled: bool = false,
    stencil_read_mask: u8 = 0,
    stencil_write_mask: u8 = 0,
    stencil_ref: u8 = 0,
};
pub const BlendState = extern struct {
    enabled: bool = false,
    src_factor_rgb: BlendFactor = .DEFAULT,
    dst_factor_rgb: BlendFactor = .DEFAULT,
    op_rgb: BlendOp = .DEFAULT,
    src_factor_alpha: BlendFactor = .DEFAULT,
    dst_factor_alpha: BlendFactor = .DEFAULT,
    op_alpha: BlendOp = .DEFAULT,
    color_write_mask: u8 = 0,
    color_attachment_count: i32 = 0,
    color_format: PixelFormat = .DEFAULT,
    depth_format: PixelFormat = .DEFAULT,
    blend_color: [4]f32 = [_]f32{0.0} ** 4,
};
pub const RasterizerState = extern struct {
    alpha_to_coverage_enabled: bool = false,
    cull_mode: CullMode = .DEFAULT,
    face_winding: FaceWinding = .DEFAULT,
    sample_count: i32 = 0,
    depth_bias: f32 = 0.0,
    depth_bias_slope_scale: f32 = 0.0,
    depth_bias_clamp: f32 = 0.0,
};
pub const PipelineDesc = extern struct {
    _start_canary: u32 = 0,
    layout: LayoutDesc = .{ },
    shader: Shader = .{ },
    primitive_type: PrimitiveType = .DEFAULT,
    index_type: IndexType = .DEFAULT,
    depth_stencil: DepthStencilState = .{ },
    blend: BlendState = .{ },
    rasterizer: RasterizerState = .{ },
    label: [*c]const u8 = null,
    _end_canary: u32 = 0,
};
pub const AttachmentDesc = extern struct {
    image: Image = .{ },
    mip_level: i32 = 0,
    slice: i32 = 0,
};
pub const PassDesc = extern struct {
    _start_canary: u32 = 0,
    color_attachments: [4]AttachmentDesc = [_]AttachmentDesc{.{}} ** 4,
    depth_stencil_attachment: AttachmentDesc = .{ },
    label: [*c]const u8 = null,
    _end_canary: u32 = 0,
};
pub const TraceHooks = extern struct {
    user_data: ?*c_void = null,
    reset_state_cache: ?fn(?*c_void) callconv(.C) void = null,
    make_buffer: ?fn([*c]const BufferDesc, Buffer, ?*c_void) callconv(.C) void = null,
    make_image: ?fn([*c]const ImageDesc, Image, ?*c_void) callconv(.C) void = null,
    make_shader: ?fn([*c]const ShaderDesc, Shader, ?*c_void) callconv(.C) void = null,
    make_pipeline: ?fn([*c]const PipelineDesc, Pipeline, ?*c_void) callconv(.C) void = null,
    make_pass: ?fn([*c]const PassDesc, Pass, ?*c_void) callconv(.C) void = null,
    destroy_buffer: ?fn(Buffer, ?*c_void) callconv(.C) void = null,
    destroy_image: ?fn(Image, ?*c_void) callconv(.C) void = null,
    destroy_shader: ?fn(Shader, ?*c_void) callconv(.C) void = null,
    destroy_pipeline: ?fn(Pipeline, ?*c_void) callconv(.C) void = null,
    destroy_pass: ?fn(Pass, ?*c_void) callconv(.C) void = null,
    update_buffer: ?fn(Buffer, ?*const c_void, i32, ?*c_void) callconv(.C) void = null,
    update_image: ?fn(Image, [*c]const ImageData, ?*c_void) callconv(.C) void = null,
    append_buffer: ?fn(Buffer, ?*const c_void, i32, i32, ?*c_void) callconv(.C) void = null,
    begin_default_pass: ?fn([*c]const PassAction, i32, i32, ?*c_void) callconv(.C) void = null,
    begin_pass: ?fn(Pass, [*c]const PassAction, ?*c_void) callconv(.C) void = null,
    apply_viewport: ?fn(i32, i32, i32, i32, bool, ?*c_void) callconv(.C) void = null,
    apply_scissor_rect: ?fn(i32, i32, i32, i32, bool, ?*c_void) callconv(.C) void = null,
    apply_pipeline: ?fn(Pipeline, ?*c_void) callconv(.C) void = null,
    apply_bindings: ?fn([*c]const Bindings, ?*c_void) callconv(.C) void = null,
    apply_uniforms: ?fn(ShaderStage, i32, ?*const c_void, i32, ?*c_void) callconv(.C) void = null,
    draw: ?fn(i32, i32, i32, ?*c_void) callconv(.C) void = null,
    end_pass: ?fn(?*c_void) callconv(.C) void = null,
    commit: ?fn(?*c_void) callconv(.C) void = null,
    alloc_buffer: ?fn(Buffer, ?*c_void) callconv(.C) void = null,
    alloc_image: ?fn(Image, ?*c_void) callconv(.C) void = null,
    alloc_shader: ?fn(Shader, ?*c_void) callconv(.C) void = null,
    alloc_pipeline: ?fn(Pipeline, ?*c_void) callconv(.C) void = null,
    alloc_pass: ?fn(Pass, ?*c_void) callconv(.C) void = null,
    dealloc_buffer: ?fn(Buffer, ?*c_void) callconv(.C) void = null,
    dealloc_image: ?fn(Image, ?*c_void) callconv(.C) void = null,
    dealloc_shader: ?fn(Shader, ?*c_void) callconv(.C) void = null,
    dealloc_pipeline: ?fn(Pipeline, ?*c_void) callconv(.C) void = null,
    dealloc_pass: ?fn(Pass, ?*c_void) callconv(.C) void = null,
    init_buffer: ?fn(Buffer, [*c]const BufferDesc, ?*c_void) callconv(.C) void = null,
    init_image: ?fn(Image, [*c]const ImageDesc, ?*c_void) callconv(.C) void = null,
    init_shader: ?fn(Shader, [*c]const ShaderDesc, ?*c_void) callconv(.C) void = null,
    init_pipeline: ?fn(Pipeline, [*c]const PipelineDesc, ?*c_void) callconv(.C) void = null,
    init_pass: ?fn(Pass, [*c]const PassDesc, ?*c_void) callconv(.C) void = null,
    uninit_buffer: ?fn(Buffer, ?*c_void) callconv(.C) void = null,
    uninit_image: ?fn(Image, ?*c_void) callconv(.C) void = null,
    uninit_shader: ?fn(Shader, ?*c_void) callconv(.C) void = null,
    uninit_pipeline: ?fn(Pipeline, ?*c_void) callconv(.C) void = null,
    uninit_pass: ?fn(Pass, ?*c_void) callconv(.C) void = null,
    fail_buffer: ?fn(Buffer, ?*c_void) callconv(.C) void = null,
    fail_image: ?fn(Image, ?*c_void) callconv(.C) void = null,
    fail_shader: ?fn(Shader, ?*c_void) callconv(.C) void = null,
    fail_pipeline: ?fn(Pipeline, ?*c_void) callconv(.C) void = null,
    fail_pass: ?fn(Pass, ?*c_void) callconv(.C) void = null,
    push_debug_group: ?fn([*c]const u8, ?*c_void) callconv(.C) void = null,
    pop_debug_group: ?fn(?*c_void) callconv(.C) void = null,
    err_buffer_pool_exhausted: ?fn(?*c_void) callconv(.C) void = null,
    err_image_pool_exhausted: ?fn(?*c_void) callconv(.C) void = null,
    err_shader_pool_exhausted: ?fn(?*c_void) callconv(.C) void = null,
    err_pipeline_pool_exhausted: ?fn(?*c_void) callconv(.C) void = null,
    err_pass_pool_exhausted: ?fn(?*c_void) callconv(.C) void = null,
    err_context_mismatch: ?fn(?*c_void) callconv(.C) void = null,
    err_pass_invalid: ?fn(?*c_void) callconv(.C) void = null,
    err_draw_invalid: ?fn(?*c_void) callconv(.C) void = null,
    err_bindings_invalid: ?fn(?*c_void) callconv(.C) void = null,
};
pub const SlotInfo = extern struct {
    state: ResourceState = .INITIAL,
    res_id: u32 = 0,
    ctx_id: u32 = 0,
};
pub const BufferInfo = extern struct {
    slot: SlotInfo = .{ },
    update_frame_index: u32 = 0,
    append_frame_index: u32 = 0,
    append_pos: i32 = 0,
    append_overflow: bool = false,
    num_slots: i32 = 0,
    active_slot: i32 = 0,
};
pub const ImageInfo = extern struct {
    slot: SlotInfo = .{ },
    upd_frame_index: u32 = 0,
    num_slots: i32 = 0,
    active_slot: i32 = 0,
    width: i32 = 0,
    height: i32 = 0,
};
pub const ShaderInfo = extern struct {
    slot: SlotInfo = .{ },
};
pub const PipelineInfo = extern struct {
    slot: SlotInfo = .{ },
};
pub const PassInfo = extern struct {
    slot: SlotInfo = .{ },
};
pub const GlContextDesc = extern struct {
    force_gles2: bool = false,
};
pub const MetalContextDesc = extern struct {
    device: ?*const c_void = null,
    renderpass_descriptor_cb: ?fn() callconv(.C) ?*const c_void = null,
    renderpass_descriptor_userdata_cb: ?fn(?*c_void) callconv(.C) ?*const c_void = null,
    drawable_cb: ?fn() callconv(.C) ?*const c_void = null,
    drawable_userdata_cb: ?fn(?*c_void) callconv(.C) ?*const c_void = null,
    user_data: ?*c_void = null,
};
pub const D3d11ContextDesc = extern struct {
    device: ?*const c_void = null,
    device_context: ?*const c_void = null,
    render_target_view_cb: ?fn() callconv(.C) ?*const c_void = null,
    render_target_view_userdata_cb: ?fn(?*c_void) callconv(.C) ?*const c_void = null,
    depth_stencil_view_cb: ?fn() callconv(.C) ?*const c_void = null,
    depth_stencil_view_userdata_cb: ?fn(?*c_void) callconv(.C) ?*const c_void = null,
    user_data: ?*c_void = null,
};
pub const WgpuContextDesc = extern struct {
    device: ?*const c_void = null,
    render_view_cb: ?fn() callconv(.C) ?*const c_void = null,
    render_view_userdata_cb: ?fn(?*c_void) callconv(.C) ?*const c_void = null,
    resolve_view_cb: ?fn() callconv(.C) ?*const c_void = null,
    resolve_view_userdata_cb: ?fn(?*c_void) callconv(.C) ?*const c_void = null,
    depth_stencil_view_cb: ?fn() callconv(.C) ?*const c_void = null,
    depth_stencil_view_userdata_cb: ?fn(?*c_void) callconv(.C) ?*const c_void = null,
    user_data: ?*c_void = null,
};
pub const ContextDesc = extern struct {
    color_format: i32 = 0,
    depth_format: i32 = 0,
    sample_count: i32 = 0,
    gl: GlContextDesc = .{ },
    metal: MetalContextDesc = .{ },
    d3d11: D3d11ContextDesc = .{ },
    wgpu: WgpuContextDesc = .{ },
};
pub const Desc = extern struct {
    _start_canary: u32 = 0,
    buffer_pool_size: i32 = 0,
    image_pool_size: i32 = 0,
    shader_pool_size: i32 = 0,
    pipeline_pool_size: i32 = 0,
    pass_pool_size: i32 = 0,
    context_pool_size: i32 = 0,
    uniform_buffer_size: i32 = 0,
    staging_buffer_size: i32 = 0,
    sampler_cache_size: i32 = 0,
    context: ContextDesc = .{ },
    _end_canary: u32 = 0,
};
pub extern fn sg_setup([*c]const Desc) void;
pub fn setup(desc: Desc) void {
    sg_setup(&desc);
}
pub extern fn sg_shutdown() void;
pub fn shutdown() void {
    sg_shutdown();
}
pub extern fn sg_isvalid() bool;
pub fn isvalid() bool {
    return sg_isvalid();
}
pub extern fn sg_reset_state_cache() void;
pub fn resetStateCache() void {
    sg_reset_state_cache();
}
pub extern fn sg_install_trace_hooks([*c]const TraceHooks) TraceHooks;
pub fn installTraceHooks(trace_hooks: TraceHooks) TraceHooks {
    return sg_install_trace_hooks(&trace_hooks);
}
pub extern fn sg_push_debug_group([*c]const u8) void;
pub fn pushDebugGroup(name: []const u8) void {
    sg_push_debug_group(name);
}
pub extern fn sg_pop_debug_group() void;
pub fn popDebugGroup() void {
    sg_pop_debug_group();
}
pub extern fn sg_make_buffer([*c]const BufferDesc) Buffer;
pub fn makeBuffer(desc: BufferDesc) Buffer {
    return sg_make_buffer(&desc);
}
pub extern fn sg_make_image([*c]const ImageDesc) Image;
pub fn makeImage(desc: ImageDesc) Image {
    return sg_make_image(&desc);
}
pub extern fn sg_make_shader([*c]const ShaderDesc) Shader;
pub fn makeShader(desc: ShaderDesc) Shader {
    return sg_make_shader(&desc);
}
pub extern fn sg_make_pipeline([*c]const PipelineDesc) Pipeline;
pub fn makePipeline(desc: PipelineDesc) Pipeline {
    return sg_make_pipeline(&desc);
}
pub extern fn sg_make_pass([*c]const PassDesc) Pass;
pub fn makePass(desc: PassDesc) Pass {
    return sg_make_pass(&desc);
}
pub extern fn sg_destroy_buffer(Buffer) void;
pub fn destroyBuffer(buf: Buffer) void {
    sg_destroy_buffer(buf);
}
pub extern fn sg_destroy_image(Image) void;
pub fn destroyImage(img: Image) void {
    sg_destroy_image(img);
}
pub extern fn sg_destroy_shader(Shader) void;
pub fn destroyShader(shd: Shader) void {
    sg_destroy_shader(shd);
}
pub extern fn sg_destroy_pipeline(Pipeline) void;
pub fn destroyPipeline(pip: Pipeline) void {
    sg_destroy_pipeline(pip);
}
pub extern fn sg_destroy_pass(Pass) void;
pub fn destroyPass(pass: Pass) void {
    sg_destroy_pass(pass);
}
pub extern fn sg_update_buffer(Buffer, ?*const c_void, i32) void;
pub fn updateBuffer(buf: Buffer, data_ptr: ?*const c_void, data_size: i32) void {
    sg_update_buffer(buf, data_ptr, data_size);
}
pub extern fn sg_update_image(Image, [*c]const ImageData) void;
pub fn updateImage(img: Image, data: ImageData) void {
    sg_update_image(img, &data);
}
pub extern fn sg_append_buffer(Buffer, ?*const c_void, i32) i32;
pub fn appendBuffer(buf: Buffer, data_ptr: ?*const c_void, data_size: i32) i32 {
    return sg_append_buffer(buf, data_ptr, data_size);
}
pub extern fn sg_query_buffer_overflow(Buffer) bool;
pub fn queryBufferOverflow(buf: Buffer) bool {
    return sg_query_buffer_overflow(buf);
}
pub extern fn sg_begin_default_pass([*c]const PassAction, i32, i32) void;
pub fn beginDefaultPass(pass_action: PassAction, width: i32, height: i32) void {
    sg_begin_default_pass(&pass_action, width, height);
}
pub extern fn sg_begin_pass(Pass, [*c]const PassAction) void;
pub fn beginPass(pass: Pass, pass_action: PassAction) void {
    sg_begin_pass(pass, &pass_action);
}
pub extern fn sg_apply_viewport(i32, i32, i32, i32, bool) void;
pub fn applyViewport(x: i32, y: i32, width: i32, height: i32, origin_top_left: bool) void {
    sg_apply_viewport(x, y, width, height, origin_top_left);
}
pub extern fn sg_apply_scissor_rect(i32, i32, i32, i32, bool) void;
pub fn applyScissorRect(x: i32, y: i32, width: i32, height: i32, origin_top_left: bool) void {
    sg_apply_scissor_rect(x, y, width, height, origin_top_left);
}
pub extern fn sg_apply_pipeline(Pipeline) void;
pub fn applyPipeline(pip: Pipeline) void {
    sg_apply_pipeline(pip);
}
pub extern fn sg_apply_bindings([*c]const Bindings) void;
pub fn applyBindings(bindings: Bindings) void {
    sg_apply_bindings(&bindings);
}
pub extern fn sg_apply_uniforms(ShaderStage, i32, ?*const c_void, i32) void;
pub fn applyUniforms(stage: ShaderStage, ub_index: i32, data: ?*const c_void, num_bytes: i32) void {
    sg_apply_uniforms(stage, ub_index, data, num_bytes);
}
pub extern fn sg_draw(i32, i32, i32) void;
pub fn draw(base_element: i32, num_elements: i32, num_instances: i32) void {
    sg_draw(base_element, num_elements, num_instances);
}
pub extern fn sg_end_pass() void;
pub fn endPass() void {
    sg_end_pass();
}
pub extern fn sg_commit() void;
pub fn commit() void {
    sg_commit();
}
pub extern fn sg_query_desc() Desc;
pub fn queryDesc() Desc {
    return sg_query_desc();
}
pub extern fn sg_query_backend() Backend;
pub fn queryBackend() Backend {
    return sg_query_backend();
}
pub extern fn sg_query_features() Features;
pub fn queryFeatures() Features {
    return sg_query_features();
}
pub extern fn sg_query_limits() Limits;
pub fn queryLimits() Limits {
    return sg_query_limits();
}
pub extern fn sg_query_pixelformat(PixelFormat) PixelformatInfo;
pub fn queryPixelformat(fmt: PixelFormat) PixelformatInfo {
    return sg_query_pixelformat(fmt);
}
pub extern fn sg_query_buffer_state(Buffer) ResourceState;
pub fn queryBufferState(buf: Buffer) ResourceState {
    return sg_query_buffer_state(buf);
}
pub extern fn sg_query_image_state(Image) ResourceState;
pub fn queryImageState(img: Image) ResourceState {
    return sg_query_image_state(img);
}
pub extern fn sg_query_shader_state(Shader) ResourceState;
pub fn queryShaderState(shd: Shader) ResourceState {
    return sg_query_shader_state(shd);
}
pub extern fn sg_query_pipeline_state(Pipeline) ResourceState;
pub fn queryPipelineState(pip: Pipeline) ResourceState {
    return sg_query_pipeline_state(pip);
}
pub extern fn sg_query_pass_state(Pass) ResourceState;
pub fn queryPassState(pass: Pass) ResourceState {
    return sg_query_pass_state(pass);
}
pub extern fn sg_query_buffer_info(Buffer) BufferInfo;
pub fn queryBufferInfo(buf: Buffer) BufferInfo {
    return sg_query_buffer_info(buf);
}
pub extern fn sg_query_image_info(Image) ImageInfo;
pub fn queryImageInfo(img: Image) ImageInfo {
    return sg_query_image_info(img);
}
pub extern fn sg_query_shader_info(Shader) ShaderInfo;
pub fn queryShaderInfo(shd: Shader) ShaderInfo {
    return sg_query_shader_info(shd);
}
pub extern fn sg_query_pipeline_info(Pipeline) PipelineInfo;
pub fn queryPipelineInfo(pip: Pipeline) PipelineInfo {
    return sg_query_pipeline_info(pip);
}
pub extern fn sg_query_pass_info(Pass) PassInfo;
pub fn queryPassInfo(pass: Pass) PassInfo {
    return sg_query_pass_info(pass);
}
pub extern fn sg_query_buffer_defaults([*c]const BufferDesc) BufferDesc;
pub fn queryBufferDefaults(desc: BufferDesc) BufferDesc {
    return sg_query_buffer_defaults(&desc);
}
pub extern fn sg_query_image_defaults([*c]const ImageDesc) ImageDesc;
pub fn queryImageDefaults(desc: ImageDesc) ImageDesc {
    return sg_query_image_defaults(&desc);
}
pub extern fn sg_query_shader_defaults([*c]const ShaderDesc) ShaderDesc;
pub fn queryShaderDefaults(desc: ShaderDesc) ShaderDesc {
    return sg_query_shader_defaults(&desc);
}
pub extern fn sg_query_pipeline_defaults([*c]const PipelineDesc) PipelineDesc;
pub fn queryPipelineDefaults(desc: PipelineDesc) PipelineDesc {
    return sg_query_pipeline_defaults(&desc);
}
pub extern fn sg_query_pass_defaults([*c]const PassDesc) PassDesc;
pub fn queryPassDefaults(desc: PassDesc) PassDesc {
    return sg_query_pass_defaults(&desc);
}
pub extern fn sg_alloc_buffer() Buffer;
pub fn allocBuffer() Buffer {
    return sg_alloc_buffer();
}
pub extern fn sg_alloc_image() Image;
pub fn allocImage() Image {
    return sg_alloc_image();
}
pub extern fn sg_alloc_shader() Shader;
pub fn allocShader() Shader {
    return sg_alloc_shader();
}
pub extern fn sg_alloc_pipeline() Pipeline;
pub fn allocPipeline() Pipeline {
    return sg_alloc_pipeline();
}
pub extern fn sg_alloc_pass() Pass;
pub fn allocPass() Pass {
    return sg_alloc_pass();
}
pub extern fn sg_dealloc_buffer(Buffer) void;
pub fn deallocBuffer(buf_id: Buffer) void {
    sg_dealloc_buffer(buf_id);
}
pub extern fn sg_dealloc_image(Image) void;
pub fn deallocImage(img_id: Image) void {
    sg_dealloc_image(img_id);
}
pub extern fn sg_dealloc_shader(Shader) void;
pub fn deallocShader(shd_id: Shader) void {
    sg_dealloc_shader(shd_id);
}
pub extern fn sg_dealloc_pipeline(Pipeline) void;
pub fn deallocPipeline(pip_id: Pipeline) void {
    sg_dealloc_pipeline(pip_id);
}
pub extern fn sg_dealloc_pass(Pass) void;
pub fn deallocPass(pass_id: Pass) void {
    sg_dealloc_pass(pass_id);
}
pub extern fn sg_init_buffer(Buffer, [*c]const BufferDesc) void;
pub fn initBuffer(buf_id: Buffer, desc: BufferDesc) void {
    sg_init_buffer(buf_id, &desc);
}
pub extern fn sg_init_image(Image, [*c]const ImageDesc) void;
pub fn initImage(img_id: Image, desc: ImageDesc) void {
    sg_init_image(img_id, &desc);
}
pub extern fn sg_init_shader(Shader, [*c]const ShaderDesc) void;
pub fn initShader(shd_id: Shader, desc: ShaderDesc) void {
    sg_init_shader(shd_id, &desc);
}
pub extern fn sg_init_pipeline(Pipeline, [*c]const PipelineDesc) void;
pub fn initPipeline(pip_id: Pipeline, desc: PipelineDesc) void {
    sg_init_pipeline(pip_id, &desc);
}
pub extern fn sg_init_pass(Pass, [*c]const PassDesc) void;
pub fn initPass(pass_id: Pass, desc: PassDesc) void {
    sg_init_pass(pass_id, &desc);
}
pub extern fn sg_uninit_buffer(Buffer) bool;
pub fn uninitBuffer(buf_id: Buffer) bool {
    return sg_uninit_buffer(buf_id);
}
pub extern fn sg_uninit_image(Image) bool;
pub fn uninitImage(img_id: Image) bool {
    return sg_uninit_image(img_id);
}
pub extern fn sg_uninit_shader(Shader) bool;
pub fn uninitShader(shd_id: Shader) bool {
    return sg_uninit_shader(shd_id);
}
pub extern fn sg_uninit_pipeline(Pipeline) bool;
pub fn uninitPipeline(pip_id: Pipeline) bool {
    return sg_uninit_pipeline(pip_id);
}
pub extern fn sg_uninit_pass(Pass) bool;
pub fn uninitPass(pass_id: Pass) bool {
    return sg_uninit_pass(pass_id);
}
pub extern fn sg_fail_buffer(Buffer) void;
pub fn failBuffer(buf_id: Buffer) void {
    sg_fail_buffer(buf_id);
}
pub extern fn sg_fail_image(Image) void;
pub fn failImage(img_id: Image) void {
    sg_fail_image(img_id);
}
pub extern fn sg_fail_shader(Shader) void;
pub fn failShader(shd_id: Shader) void {
    sg_fail_shader(shd_id);
}
pub extern fn sg_fail_pipeline(Pipeline) void;
pub fn failPipeline(pip_id: Pipeline) void {
    sg_fail_pipeline(pip_id);
}
pub extern fn sg_fail_pass(Pass) void;
pub fn failPass(pass_id: Pass) void {
    sg_fail_pass(pass_id);
}
pub extern fn sg_setup_context() Context;
pub fn setupContext() Context {
    return sg_setup_context();
}
pub extern fn sg_activate_context(Context) void;
pub fn activateContext(ctx_id: Context) void {
    sg_activate_context(ctx_id);
}
pub extern fn sg_discard_context(Context) void;
pub fn discardContext(ctx_id: Context) void {
    sg_discard_context(ctx_id);
}
pub extern fn sg_d3d11_device() ?*const c_void;
pub fn d3d11Device() ?*const c_void {
    return sg_d3d11_device();
}
pub extern fn sg_mtl_device() ?*const c_void;
pub fn mtlDevice() ?*const c_void {
    return sg_mtl_device();
}
pub extern fn sg_mtl_render_command_encoder() ?*const c_void;
pub fn mtlRenderCommandEncoder() ?*const c_void {
    return sg_mtl_render_command_encoder();
}
