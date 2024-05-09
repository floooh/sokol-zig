// machine generated, do not edit

const builtin = @import("builtin");

// helper function to convert a C string to a Zig string slice
fn cStrToZig(c_str: [*c]const u8) [:0]const u8 {
    return @import("std").mem.span(c_str);
}
// helper function to convert "anything" to a Range struct
pub fn asRange(val: anytype) Range {
    const type_info = @typeInfo(@TypeOf(val));
    switch (type_info) {
        .Pointer => {
            switch (type_info.Pointer.size) {
                .One => return .{ .ptr = val, .size = @sizeOf(type_info.Pointer.child) },
                .Slice => return .{ .ptr = val.ptr, .size = @sizeOf(type_info.Pointer.child) * val.len },
                else => @compileError("FIXME: Pointer type!"),
            }
        },
        .Struct, .Array => {
            @compileError("Structs and arrays must be passed as pointers to asRange");
        },
        else => {
            @compileError("Cannot convert to range!");
        },
    }
}

pub const Buffer = extern struct {
    id: u32 = 0,
};
pub const Image = extern struct {
    id: u32 = 0,
};
pub const Sampler = extern struct {
    id: u32 = 0,
};
pub const Shader = extern struct {
    id: u32 = 0,
};
pub const Pipeline = extern struct {
    id: u32 = 0,
};
pub const Attachments = extern struct {
    id: u32 = 0,
};
pub const Range = extern struct {
    ptr: ?*const anyopaque = null,
    size: usize = 0,
};
pub const invalid_id = 0;
pub const num_shader_stages = 2;
pub const num_inflight_frames = 2;
pub const max_color_attachments = 4;
pub const max_vertex_buffers = 8;
pub const max_shaderstage_images = 12;
pub const max_shaderstage_samplers = 8;
pub const max_shaderstage_imagesamplerpairs = 12;
pub const max_shaderstage_storagebuffers = 8;
pub const max_shaderstage_ubs = 4;
pub const max_ub_members = 16;
pub const max_vertex_attributes = 16;
pub const max_mipmaps = 16;
pub const max_texturearray_layers = 128;
pub const Color = extern struct {
    r: f32 = 0.0,
    g: f32 = 0.0,
    b: f32 = 0.0,
    a: f32 = 0.0,
};
pub const Backend = enum(i32) {
    GLCORE,
    GLES3,
    D3D11,
    METAL_IOS,
    METAL_MACOS,
    METAL_SIMULATOR,
    WGPU,
    DUMMY,
};
pub const PixelFormat = enum(i32) {
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
    SRGB8A8,
    RGBA8SN,
    RGBA8UI,
    RGBA8SI,
    BGRA8,
    RGB10A2,
    RG11B10F,
    RGB9E5,
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
    BC3_SRGBA,
    BC4_R,
    BC4_RSN,
    BC5_RG,
    BC5_RGSN,
    BC6H_RGBF,
    BC6H_RGBUF,
    BC7_RGBA,
    BC7_SRGBA,
    PVRTC_RGB_2BPP,
    PVRTC_RGB_4BPP,
    PVRTC_RGBA_2BPP,
    PVRTC_RGBA_4BPP,
    ETC2_RGB8,
    ETC2_SRGB8,
    ETC2_RGB8A1,
    ETC2_RGBA8,
    ETC2_SRGB8A8,
    ETC2_RG11,
    ETC2_RG11SN,
    ASTC_4x4_RGBA,
    ASTC_4x4_SRGBA,
    NUM,
};
pub const PixelformatInfo = extern struct {
    sample: bool = false,
    filter: bool = false,
    render: bool = false,
    blend: bool = false,
    msaa: bool = false,
    depth: bool = false,
    compressed: bool = false,
    bytes_per_pixel: i32 = 0,
};
pub const Features = extern struct {
    origin_top_left: bool = false,
    image_clamp_to_border: bool = false,
    mrt_independent_blend_state: bool = false,
    mrt_independent_write_mask: bool = false,
    storage_buffer: bool = false,
};
pub const Limits = extern struct {
    max_image_size_2d: i32 = 0,
    max_image_size_cube: i32 = 0,
    max_image_size_3d: i32 = 0,
    max_image_size_array: i32 = 0,
    max_image_array_layers: i32 = 0,
    max_vertex_attrs: i32 = 0,
    gl_max_vertex_uniform_components: i32 = 0,
    gl_max_combined_texture_image_units: i32 = 0,
};
pub const ResourceState = enum(i32) {
    INITIAL,
    ALLOC,
    VALID,
    FAILED,
    INVALID,
};
pub const Usage = enum(i32) {
    DEFAULT,
    IMMUTABLE,
    DYNAMIC,
    STREAM,
    NUM,
};
pub const BufferType = enum(i32) {
    DEFAULT,
    VERTEXBUFFER,
    INDEXBUFFER,
    STORAGEBUFFER,
    NUM,
};
pub const IndexType = enum(i32) {
    DEFAULT,
    NONE,
    UINT16,
    UINT32,
    NUM,
};
pub const ImageType = enum(i32) {
    DEFAULT,
    _2D,
    CUBE,
    _3D,
    ARRAY,
    NUM,
};
pub const ImageSampleType = enum(i32) {
    DEFAULT,
    FLOAT,
    DEPTH,
    SINT,
    UINT,
    UNFILTERABLE_FLOAT,
    NUM,
};
pub const SamplerType = enum(i32) {
    DEFAULT,
    FILTERING,
    NONFILTERING,
    COMPARISON,
    NUM,
};
pub const CubeFace = enum(i32) {
    POS_X,
    NEG_X,
    POS_Y,
    NEG_Y,
    POS_Z,
    NEG_Z,
    NUM,
};
pub const ShaderStage = enum(i32) {
    VS,
    FS,
};
pub const PrimitiveType = enum(i32) {
    DEFAULT,
    POINTS,
    LINES,
    LINE_STRIP,
    TRIANGLES,
    TRIANGLE_STRIP,
    NUM,
};
pub const Filter = enum(i32) {
    DEFAULT,
    NONE,
    NEAREST,
    LINEAR,
    NUM,
};
pub const Wrap = enum(i32) {
    DEFAULT,
    REPEAT,
    CLAMP_TO_EDGE,
    CLAMP_TO_BORDER,
    MIRRORED_REPEAT,
    NUM,
};
pub const BorderColor = enum(i32) {
    DEFAULT,
    TRANSPARENT_BLACK,
    OPAQUE_BLACK,
    OPAQUE_WHITE,
    NUM,
};
pub const VertexFormat = enum(i32) {
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
    HALF2,
    HALF4,
    NUM,
};
pub const VertexStep = enum(i32) {
    DEFAULT,
    PER_VERTEX,
    PER_INSTANCE,
    NUM,
};
pub const UniformType = enum(i32) {
    INVALID,
    FLOAT,
    FLOAT2,
    FLOAT3,
    FLOAT4,
    INT,
    INT2,
    INT3,
    INT4,
    MAT4,
    NUM,
};
pub const UniformLayout = enum(i32) {
    DEFAULT,
    NATIVE,
    STD140,
    NUM,
};
pub const CullMode = enum(i32) {
    DEFAULT,
    NONE,
    FRONT,
    BACK,
    NUM,
};
pub const FaceWinding = enum(i32) {
    DEFAULT,
    CCW,
    CW,
    NUM,
};
pub const CompareFunc = enum(i32) {
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
pub const StencilOp = enum(i32) {
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
pub const BlendFactor = enum(i32) {
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
pub const BlendOp = enum(i32) {
    DEFAULT,
    ADD,
    SUBTRACT,
    REVERSE_SUBTRACT,
    NUM,
};
pub const ColorMask = enum(i32) {
    DEFAULT = 0,
    NONE = 16,
    R = 1,
    G = 2,
    RG = 3,
    B = 4,
    RB = 5,
    GB = 6,
    RGB = 7,
    A = 8,
    RA = 9,
    GA = 10,
    RGA = 11,
    BA = 12,
    RBA = 13,
    GBA = 14,
    RGBA = 15,
};
pub const LoadAction = enum(i32) {
    DEFAULT,
    CLEAR,
    LOAD,
    DONTCARE,
};
pub const StoreAction = enum(i32) {
    DEFAULT,
    STORE,
    DONTCARE,
};
pub const ColorAttachmentAction = extern struct {
    load_action: LoadAction = .DEFAULT,
    store_action: StoreAction = .DEFAULT,
    clear_value: Color = .{},
};
pub const DepthAttachmentAction = extern struct {
    load_action: LoadAction = .DEFAULT,
    store_action: StoreAction = .DEFAULT,
    clear_value: f32 = 0.0,
};
pub const StencilAttachmentAction = extern struct {
    load_action: LoadAction = .DEFAULT,
    store_action: StoreAction = .DEFAULT,
    clear_value: u8 = 0,
};
pub const PassAction = extern struct {
    colors: [4]ColorAttachmentAction = [_]ColorAttachmentAction{.{}} ** 4,
    depth: DepthAttachmentAction = .{},
    stencil: StencilAttachmentAction = .{},
};
pub const MetalSwapchain = extern struct {
    current_drawable: ?*const anyopaque = null,
    depth_stencil_texture: ?*const anyopaque = null,
    msaa_color_texture: ?*const anyopaque = null,
};
pub const D3d11Swapchain = extern struct {
    render_view: ?*const anyopaque = null,
    resolve_view: ?*const anyopaque = null,
    depth_stencil_view: ?*const anyopaque = null,
};
pub const WgpuSwapchain = extern struct {
    render_view: ?*const anyopaque = null,
    resolve_view: ?*const anyopaque = null,
    depth_stencil_view: ?*const anyopaque = null,
};
pub const GlSwapchain = extern struct {
    framebuffer: u32 = 0,
};
pub const Swapchain = extern struct {
    width: i32 = 0,
    height: i32 = 0,
    sample_count: i32 = 0,
    color_format: PixelFormat = .DEFAULT,
    depth_format: PixelFormat = .DEFAULT,
    metal: MetalSwapchain = .{},
    d3d11: D3d11Swapchain = .{},
    wgpu: WgpuSwapchain = .{},
    gl: GlSwapchain = .{},
};
pub const Pass = extern struct {
    _start_canary: u32 = 0,
    action: PassAction = .{},
    attachments: Attachments = .{},
    swapchain: Swapchain = .{},
    label: [*c]const u8 = null,
    _end_canary: u32 = 0,
};
pub const StageBindings = extern struct {
    images: [12]Image = [_]Image{.{}} ** 12,
    samplers: [8]Sampler = [_]Sampler{.{}} ** 8,
    storage_buffers: [8]Buffer = [_]Buffer{.{}} ** 8,
};
pub const Bindings = extern struct {
    _start_canary: u32 = 0,
    vertex_buffers: [8]Buffer = [_]Buffer{.{}} ** 8,
    vertex_buffer_offsets: [8]i32 = [_]i32{0} ** 8,
    index_buffer: Buffer = .{},
    index_buffer_offset: i32 = 0,
    vs: StageBindings = .{},
    fs: StageBindings = .{},
    _end_canary: u32 = 0,
};
pub const BufferDesc = extern struct {
    _start_canary: u32 = 0,
    size: usize = 0,
    type: BufferType = .DEFAULT,
    usage: Usage = .DEFAULT,
    data: Range = .{},
    label: [*c]const u8 = null,
    gl_buffers: [2]u32 = [_]u32{0} ** 2,
    mtl_buffers: [2]?*const anyopaque = [_]?*const anyopaque{null} ** 2,
    d3d11_buffer: ?*const anyopaque = null,
    wgpu_buffer: ?*const anyopaque = null,
    _end_canary: u32 = 0,
};
pub const ImageData = extern struct {
    subimage: [6][16]Range = [_][16]Range{[_]Range{.{}} ** 16} ** 6,
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
    data: ImageData = .{},
    label: [*c]const u8 = null,
    gl_textures: [2]u32 = [_]u32{0} ** 2,
    gl_texture_target: u32 = 0,
    mtl_textures: [2]?*const anyopaque = [_]?*const anyopaque{null} ** 2,
    d3d11_texture: ?*const anyopaque = null,
    d3d11_shader_resource_view: ?*const anyopaque = null,
    wgpu_texture: ?*const anyopaque = null,
    wgpu_texture_view: ?*const anyopaque = null,
    _end_canary: u32 = 0,
};
pub const SamplerDesc = extern struct {
    _start_canary: u32 = 0,
    min_filter: Filter = .DEFAULT,
    mag_filter: Filter = .DEFAULT,
    mipmap_filter: Filter = .DEFAULT,
    wrap_u: Wrap = .DEFAULT,
    wrap_v: Wrap = .DEFAULT,
    wrap_w: Wrap = .DEFAULT,
    min_lod: f32 = 0.0,
    max_lod: f32 = 0.0,
    border_color: BorderColor = .DEFAULT,
    compare: CompareFunc = .DEFAULT,
    max_anisotropy: u32 = 0,
    label: [*c]const u8 = null,
    gl_sampler: u32 = 0,
    mtl_sampler: ?*const anyopaque = null,
    d3d11_sampler: ?*const anyopaque = null,
    wgpu_sampler: ?*const anyopaque = null,
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
    size: usize = 0,
    layout: UniformLayout = .DEFAULT,
    uniforms: [16]ShaderUniformDesc = [_]ShaderUniformDesc{.{}} ** 16,
};
pub const ShaderStorageBufferDesc = extern struct {
    used: bool = false,
    readonly: bool = false,
};
pub const ShaderImageDesc = extern struct {
    used: bool = false,
    multisampled: bool = false,
    image_type: ImageType = .DEFAULT,
    sample_type: ImageSampleType = .DEFAULT,
};
pub const ShaderSamplerDesc = extern struct {
    used: bool = false,
    sampler_type: SamplerType = .DEFAULT,
};
pub const ShaderImageSamplerPairDesc = extern struct {
    used: bool = false,
    image_slot: i32 = 0,
    sampler_slot: i32 = 0,
    glsl_name: [*c]const u8 = null,
};
pub const ShaderStageDesc = extern struct {
    source: [*c]const u8 = null,
    bytecode: Range = .{},
    entry: [*c]const u8 = null,
    d3d11_target: [*c]const u8 = null,
    uniform_blocks: [4]ShaderUniformBlockDesc = [_]ShaderUniformBlockDesc{.{}} ** 4,
    storage_buffers: [8]ShaderStorageBufferDesc = [_]ShaderStorageBufferDesc{.{}} ** 8,
    images: [12]ShaderImageDesc = [_]ShaderImageDesc{.{}} ** 12,
    samplers: [8]ShaderSamplerDesc = [_]ShaderSamplerDesc{.{}} ** 8,
    image_sampler_pairs: [12]ShaderImageSamplerPairDesc = [_]ShaderImageSamplerPairDesc{.{}} ** 12,
};
pub const ShaderDesc = extern struct {
    _start_canary: u32 = 0,
    attrs: [16]ShaderAttrDesc = [_]ShaderAttrDesc{.{}} ** 16,
    vs: ShaderStageDesc = .{},
    fs: ShaderStageDesc = .{},
    label: [*c]const u8 = null,
    _end_canary: u32 = 0,
};
pub const VertexBufferLayoutState = extern struct {
    stride: i32 = 0,
    step_func: VertexStep = .DEFAULT,
    step_rate: i32 = 0,
};
pub const VertexAttrState = extern struct {
    buffer_index: i32 = 0,
    offset: i32 = 0,
    format: VertexFormat = .INVALID,
};
pub const VertexLayoutState = extern struct {
    buffers: [8]VertexBufferLayoutState = [_]VertexBufferLayoutState{.{}} ** 8,
    attrs: [16]VertexAttrState = [_]VertexAttrState{.{}} ** 16,
};
pub const StencilFaceState = extern struct {
    compare: CompareFunc = .DEFAULT,
    fail_op: StencilOp = .DEFAULT,
    depth_fail_op: StencilOp = .DEFAULT,
    pass_op: StencilOp = .DEFAULT,
};
pub const StencilState = extern struct {
    enabled: bool = false,
    front: StencilFaceState = .{},
    back: StencilFaceState = .{},
    read_mask: u8 = 0,
    write_mask: u8 = 0,
    ref: u8 = 0,
};
pub const DepthState = extern struct {
    pixel_format: PixelFormat = .DEFAULT,
    compare: CompareFunc = .DEFAULT,
    write_enabled: bool = false,
    bias: f32 = 0.0,
    bias_slope_scale: f32 = 0.0,
    bias_clamp: f32 = 0.0,
};
pub const BlendState = extern struct {
    enabled: bool = false,
    src_factor_rgb: BlendFactor = .DEFAULT,
    dst_factor_rgb: BlendFactor = .DEFAULT,
    op_rgb: BlendOp = .DEFAULT,
    src_factor_alpha: BlendFactor = .DEFAULT,
    dst_factor_alpha: BlendFactor = .DEFAULT,
    op_alpha: BlendOp = .DEFAULT,
};
pub const ColorTargetState = extern struct {
    pixel_format: PixelFormat = .DEFAULT,
    write_mask: ColorMask = .DEFAULT,
    blend: BlendState = .{},
};
pub const PipelineDesc = extern struct {
    _start_canary: u32 = 0,
    shader: Shader = .{},
    layout: VertexLayoutState = .{},
    depth: DepthState = .{},
    stencil: StencilState = .{},
    color_count: i32 = 0,
    colors: [4]ColorTargetState = [_]ColorTargetState{.{}} ** 4,
    primitive_type: PrimitiveType = .DEFAULT,
    index_type: IndexType = .DEFAULT,
    cull_mode: CullMode = .DEFAULT,
    face_winding: FaceWinding = .DEFAULT,
    sample_count: i32 = 0,
    blend_color: Color = .{},
    alpha_to_coverage_enabled: bool = false,
    label: [*c]const u8 = null,
    _end_canary: u32 = 0,
};
pub const AttachmentDesc = extern struct {
    image: Image = .{},
    mip_level: i32 = 0,
    slice: i32 = 0,
};
pub const AttachmentsDesc = extern struct {
    _start_canary: u32 = 0,
    colors: [4]AttachmentDesc = [_]AttachmentDesc{.{}} ** 4,
    resolves: [4]AttachmentDesc = [_]AttachmentDesc{.{}} ** 4,
    depth_stencil: AttachmentDesc = .{},
    label: [*c]const u8 = null,
    _end_canary: u32 = 0,
};
pub const SlotInfo = extern struct {
    state: ResourceState = .INITIAL,
    res_id: u32 = 0,
};
pub const BufferInfo = extern struct {
    slot: SlotInfo = .{},
    update_frame_index: u32 = 0,
    append_frame_index: u32 = 0,
    append_pos: i32 = 0,
    append_overflow: bool = false,
    num_slots: i32 = 0,
    active_slot: i32 = 0,
};
pub const ImageInfo = extern struct {
    slot: SlotInfo = .{},
    upd_frame_index: u32 = 0,
    num_slots: i32 = 0,
    active_slot: i32 = 0,
};
pub const SamplerInfo = extern struct {
    slot: SlotInfo = .{},
};
pub const ShaderInfo = extern struct {
    slot: SlotInfo = .{},
};
pub const PipelineInfo = extern struct {
    slot: SlotInfo = .{},
};
pub const AttachmentsInfo = extern struct {
    slot: SlotInfo = .{},
};
pub const FrameStatsGl = extern struct {
    num_bind_buffer: u32 = 0,
    num_active_texture: u32 = 0,
    num_bind_texture: u32 = 0,
    num_bind_sampler: u32 = 0,
    num_use_program: u32 = 0,
    num_render_state: u32 = 0,
    num_vertex_attrib_pointer: u32 = 0,
    num_vertex_attrib_divisor: u32 = 0,
    num_enable_vertex_attrib_array: u32 = 0,
    num_disable_vertex_attrib_array: u32 = 0,
    num_uniform: u32 = 0,
};
pub const FrameStatsD3d11Pass = extern struct {
    num_om_set_render_targets: u32 = 0,
    num_clear_render_target_view: u32 = 0,
    num_clear_depth_stencil_view: u32 = 0,
    num_resolve_subresource: u32 = 0,
};
pub const FrameStatsD3d11Pipeline = extern struct {
    num_rs_set_state: u32 = 0,
    num_om_set_depth_stencil_state: u32 = 0,
    num_om_set_blend_state: u32 = 0,
    num_ia_set_primitive_topology: u32 = 0,
    num_ia_set_input_layout: u32 = 0,
    num_vs_set_shader: u32 = 0,
    num_vs_set_constant_buffers: u32 = 0,
    num_ps_set_shader: u32 = 0,
    num_ps_set_constant_buffers: u32 = 0,
};
pub const FrameStatsD3d11Bindings = extern struct {
    num_ia_set_vertex_buffers: u32 = 0,
    num_ia_set_index_buffer: u32 = 0,
    num_vs_set_shader_resources: u32 = 0,
    num_ps_set_shader_resources: u32 = 0,
    num_vs_set_samplers: u32 = 0,
    num_ps_set_samplers: u32 = 0,
};
pub const FrameStatsD3d11Uniforms = extern struct {
    num_update_subresource: u32 = 0,
};
pub const FrameStatsD3d11Draw = extern struct {
    num_draw_indexed_instanced: u32 = 0,
    num_draw_indexed: u32 = 0,
    num_draw_instanced: u32 = 0,
    num_draw: u32 = 0,
};
pub const FrameStatsD3d11 = extern struct {
    pass: FrameStatsD3d11Pass = .{},
    pipeline: FrameStatsD3d11Pipeline = .{},
    bindings: FrameStatsD3d11Bindings = .{},
    uniforms: FrameStatsD3d11Uniforms = .{},
    draw: FrameStatsD3d11Draw = .{},
    num_map: u32 = 0,
    num_unmap: u32 = 0,
};
pub const FrameStatsMetalIdpool = extern struct {
    num_added: u32 = 0,
    num_released: u32 = 0,
    num_garbage_collected: u32 = 0,
};
pub const FrameStatsMetalPipeline = extern struct {
    num_set_blend_color: u32 = 0,
    num_set_cull_mode: u32 = 0,
    num_set_front_facing_winding: u32 = 0,
    num_set_stencil_reference_value: u32 = 0,
    num_set_depth_bias: u32 = 0,
    num_set_render_pipeline_state: u32 = 0,
    num_set_depth_stencil_state: u32 = 0,
};
pub const FrameStatsMetalBindings = extern struct {
    num_set_vertex_buffer: u32 = 0,
    num_set_vertex_texture: u32 = 0,
    num_set_vertex_sampler_state: u32 = 0,
    num_set_fragment_buffer: u32 = 0,
    num_set_fragment_texture: u32 = 0,
    num_set_fragment_sampler_state: u32 = 0,
};
pub const FrameStatsMetalUniforms = extern struct {
    num_set_vertex_buffer_offset: u32 = 0,
    num_set_fragment_buffer_offset: u32 = 0,
};
pub const FrameStatsMetal = extern struct {
    idpool: FrameStatsMetalIdpool = .{},
    pipeline: FrameStatsMetalPipeline = .{},
    bindings: FrameStatsMetalBindings = .{},
    uniforms: FrameStatsMetalUniforms = .{},
};
pub const FrameStatsWgpuUniforms = extern struct {
    num_set_bindgroup: u32 = 0,
    size_write_buffer: u32 = 0,
};
pub const FrameStatsWgpuBindings = extern struct {
    num_set_vertex_buffer: u32 = 0,
    num_skip_redundant_vertex_buffer: u32 = 0,
    num_set_index_buffer: u32 = 0,
    num_skip_redundant_index_buffer: u32 = 0,
    num_create_bindgroup: u32 = 0,
    num_discard_bindgroup: u32 = 0,
    num_set_bindgroup: u32 = 0,
    num_skip_redundant_bindgroup: u32 = 0,
    num_bindgroup_cache_hits: u32 = 0,
    num_bindgroup_cache_misses: u32 = 0,
    num_bindgroup_cache_collisions: u32 = 0,
    num_bindgroup_cache_hash_vs_key_mismatch: u32 = 0,
};
pub const FrameStatsWgpu = extern struct {
    uniforms: FrameStatsWgpuUniforms = .{},
    bindings: FrameStatsWgpuBindings = .{},
};
pub const FrameStats = extern struct {
    frame_index: u32 = 0,
    num_passes: u32 = 0,
    num_apply_viewport: u32 = 0,
    num_apply_scissor_rect: u32 = 0,
    num_apply_pipeline: u32 = 0,
    num_apply_bindings: u32 = 0,
    num_apply_uniforms: u32 = 0,
    num_draw: u32 = 0,
    num_update_buffer: u32 = 0,
    num_append_buffer: u32 = 0,
    num_update_image: u32 = 0,
    size_apply_uniforms: u32 = 0,
    size_update_buffer: u32 = 0,
    size_append_buffer: u32 = 0,
    size_update_image: u32 = 0,
    gl: FrameStatsGl = .{},
    d3d11: FrameStatsD3d11 = .{},
    metal: FrameStatsMetal = .{},
    wgpu: FrameStatsWgpu = .{},
};
pub const LogItem = enum(i32) {
    OK,
    MALLOC_FAILED,
    GL_TEXTURE_FORMAT_NOT_SUPPORTED,
    GL_3D_TEXTURES_NOT_SUPPORTED,
    GL_ARRAY_TEXTURES_NOT_SUPPORTED,
    GL_SHADER_COMPILATION_FAILED,
    GL_SHADER_LINKING_FAILED,
    GL_VERTEX_ATTRIBUTE_NOT_FOUND_IN_SHADER,
    GL_TEXTURE_NAME_NOT_FOUND_IN_SHADER,
    GL_FRAMEBUFFER_STATUS_UNDEFINED,
    GL_FRAMEBUFFER_STATUS_INCOMPLETE_ATTACHMENT,
    GL_FRAMEBUFFER_STATUS_INCOMPLETE_MISSING_ATTACHMENT,
    GL_FRAMEBUFFER_STATUS_UNSUPPORTED,
    GL_FRAMEBUFFER_STATUS_INCOMPLETE_MULTISAMPLE,
    GL_FRAMEBUFFER_STATUS_UNKNOWN,
    D3D11_CREATE_BUFFER_FAILED,
    D3D11_CREATE_BUFFER_SRV_FAILED,
    D3D11_CREATE_DEPTH_TEXTURE_UNSUPPORTED_PIXEL_FORMAT,
    D3D11_CREATE_DEPTH_TEXTURE_FAILED,
    D3D11_CREATE_2D_TEXTURE_UNSUPPORTED_PIXEL_FORMAT,
    D3D11_CREATE_2D_TEXTURE_FAILED,
    D3D11_CREATE_2D_SRV_FAILED,
    D3D11_CREATE_3D_TEXTURE_UNSUPPORTED_PIXEL_FORMAT,
    D3D11_CREATE_3D_TEXTURE_FAILED,
    D3D11_CREATE_3D_SRV_FAILED,
    D3D11_CREATE_MSAA_TEXTURE_FAILED,
    D3D11_CREATE_SAMPLER_STATE_FAILED,
    D3D11_LOAD_D3DCOMPILER_47_DLL_FAILED,
    D3D11_SHADER_COMPILATION_FAILED,
    D3D11_SHADER_COMPILATION_OUTPUT,
    D3D11_CREATE_CONSTANT_BUFFER_FAILED,
    D3D11_CREATE_INPUT_LAYOUT_FAILED,
    D3D11_CREATE_RASTERIZER_STATE_FAILED,
    D3D11_CREATE_DEPTH_STENCIL_STATE_FAILED,
    D3D11_CREATE_BLEND_STATE_FAILED,
    D3D11_CREATE_RTV_FAILED,
    D3D11_CREATE_DSV_FAILED,
    D3D11_MAP_FOR_UPDATE_BUFFER_FAILED,
    D3D11_MAP_FOR_APPEND_BUFFER_FAILED,
    D3D11_MAP_FOR_UPDATE_IMAGE_FAILED,
    METAL_CREATE_BUFFER_FAILED,
    METAL_TEXTURE_FORMAT_NOT_SUPPORTED,
    METAL_CREATE_TEXTURE_FAILED,
    METAL_CREATE_SAMPLER_FAILED,
    METAL_SHADER_COMPILATION_FAILED,
    METAL_SHADER_CREATION_FAILED,
    METAL_SHADER_COMPILATION_OUTPUT,
    METAL_VERTEX_SHADER_ENTRY_NOT_FOUND,
    METAL_FRAGMENT_SHADER_ENTRY_NOT_FOUND,
    METAL_CREATE_RPS_FAILED,
    METAL_CREATE_RPS_OUTPUT,
    METAL_CREATE_DSS_FAILED,
    WGPU_BINDGROUPS_POOL_EXHAUSTED,
    WGPU_BINDGROUPSCACHE_SIZE_GREATER_ONE,
    WGPU_BINDGROUPSCACHE_SIZE_POW2,
    WGPU_CREATEBINDGROUP_FAILED,
    WGPU_CREATE_BUFFER_FAILED,
    WGPU_CREATE_TEXTURE_FAILED,
    WGPU_CREATE_TEXTURE_VIEW_FAILED,
    WGPU_CREATE_SAMPLER_FAILED,
    WGPU_CREATE_SHADER_MODULE_FAILED,
    WGPU_SHADER_TOO_MANY_IMAGES,
    WGPU_SHADER_TOO_MANY_SAMPLERS,
    WGPU_SHADER_TOO_MANY_STORAGEBUFFERS,
    WGPU_SHADER_CREATE_BINDGROUP_LAYOUT_FAILED,
    WGPU_CREATE_PIPELINE_LAYOUT_FAILED,
    WGPU_CREATE_RENDER_PIPELINE_FAILED,
    WGPU_ATTACHMENTS_CREATE_TEXTURE_VIEW_FAILED,
    IDENTICAL_COMMIT_LISTENER,
    COMMIT_LISTENER_ARRAY_FULL,
    TRACE_HOOKS_NOT_ENABLED,
    DEALLOC_BUFFER_INVALID_STATE,
    DEALLOC_IMAGE_INVALID_STATE,
    DEALLOC_SAMPLER_INVALID_STATE,
    DEALLOC_SHADER_INVALID_STATE,
    DEALLOC_PIPELINE_INVALID_STATE,
    DEALLOC_ATTACHMENTS_INVALID_STATE,
    INIT_BUFFER_INVALID_STATE,
    INIT_IMAGE_INVALID_STATE,
    INIT_SAMPLER_INVALID_STATE,
    INIT_SHADER_INVALID_STATE,
    INIT_PIPELINE_INVALID_STATE,
    INIT_ATTACHMENTS_INVALID_STATE,
    UNINIT_BUFFER_INVALID_STATE,
    UNINIT_IMAGE_INVALID_STATE,
    UNINIT_SAMPLER_INVALID_STATE,
    UNINIT_SHADER_INVALID_STATE,
    UNINIT_PIPELINE_INVALID_STATE,
    UNINIT_ATTACHMENTS_INVALID_STATE,
    FAIL_BUFFER_INVALID_STATE,
    FAIL_IMAGE_INVALID_STATE,
    FAIL_SAMPLER_INVALID_STATE,
    FAIL_SHADER_INVALID_STATE,
    FAIL_PIPELINE_INVALID_STATE,
    FAIL_ATTACHMENTS_INVALID_STATE,
    BUFFER_POOL_EXHAUSTED,
    IMAGE_POOL_EXHAUSTED,
    SAMPLER_POOL_EXHAUSTED,
    SHADER_POOL_EXHAUSTED,
    PIPELINE_POOL_EXHAUSTED,
    PASS_POOL_EXHAUSTED,
    BEGINPASS_ATTACHMENT_INVALID,
    DRAW_WITHOUT_BINDINGS,
    VALIDATE_BUFFERDESC_CANARY,
    VALIDATE_BUFFERDESC_SIZE,
    VALIDATE_BUFFERDESC_DATA,
    VALIDATE_BUFFERDESC_DATA_SIZE,
    VALIDATE_BUFFERDESC_NO_DATA,
    VALIDATE_BUFFERDESC_STORAGEBUFFER_SUPPORTED,
    VALIDATE_BUFFERDESC_STORAGEBUFFER_SIZE_MULTIPLE_4,
    VALIDATE_IMAGEDATA_NODATA,
    VALIDATE_IMAGEDATA_DATA_SIZE,
    VALIDATE_IMAGEDESC_CANARY,
    VALIDATE_IMAGEDESC_WIDTH,
    VALIDATE_IMAGEDESC_HEIGHT,
    VALIDATE_IMAGEDESC_RT_PIXELFORMAT,
    VALIDATE_IMAGEDESC_NONRT_PIXELFORMAT,
    VALIDATE_IMAGEDESC_MSAA_BUT_NO_RT,
    VALIDATE_IMAGEDESC_NO_MSAA_RT_SUPPORT,
    VALIDATE_IMAGEDESC_MSAA_NUM_MIPMAPS,
    VALIDATE_IMAGEDESC_MSAA_3D_IMAGE,
    VALIDATE_IMAGEDESC_DEPTH_3D_IMAGE,
    VALIDATE_IMAGEDESC_RT_IMMUTABLE,
    VALIDATE_IMAGEDESC_RT_NO_DATA,
    VALIDATE_IMAGEDESC_INJECTED_NO_DATA,
    VALIDATE_IMAGEDESC_DYNAMIC_NO_DATA,
    VALIDATE_IMAGEDESC_COMPRESSED_IMMUTABLE,
    VALIDATE_SAMPLERDESC_CANARY,
    VALIDATE_SAMPLERDESC_MINFILTER_NONE,
    VALIDATE_SAMPLERDESC_MAGFILTER_NONE,
    VALIDATE_SAMPLERDESC_ANISTROPIC_REQUIRES_LINEAR_FILTERING,
    VALIDATE_SHADERDESC_CANARY,
    VALIDATE_SHADERDESC_SOURCE,
    VALIDATE_SHADERDESC_BYTECODE,
    VALIDATE_SHADERDESC_SOURCE_OR_BYTECODE,
    VALIDATE_SHADERDESC_NO_BYTECODE_SIZE,
    VALIDATE_SHADERDESC_NO_CONT_UBS,
    VALIDATE_SHADERDESC_NO_CONT_UB_MEMBERS,
    VALIDATE_SHADERDESC_NO_UB_MEMBERS,
    VALIDATE_SHADERDESC_UB_MEMBER_NAME,
    VALIDATE_SHADERDESC_UB_SIZE_MISMATCH,
    VALIDATE_SHADERDESC_UB_ARRAY_COUNT,
    VALIDATE_SHADERDESC_UB_STD140_ARRAY_TYPE,
    VALIDATE_SHADERDESC_NO_CONT_STORAGEBUFFERS,
    VALIDATE_SHADERDESC_STORAGEBUFFER_READONLY,
    VALIDATE_SHADERDESC_NO_CONT_IMAGES,
    VALIDATE_SHADERDESC_NO_CONT_SAMPLERS,
    VALIDATE_SHADERDESC_IMAGE_SAMPLER_PAIR_IMAGE_SLOT_OUT_OF_RANGE,
    VALIDATE_SHADERDESC_IMAGE_SAMPLER_PAIR_SAMPLER_SLOT_OUT_OF_RANGE,
    VALIDATE_SHADERDESC_IMAGE_SAMPLER_PAIR_NAME_REQUIRED_FOR_GL,
    VALIDATE_SHADERDESC_IMAGE_SAMPLER_PAIR_HAS_NAME_BUT_NOT_USED,
    VALIDATE_SHADERDESC_IMAGE_SAMPLER_PAIR_HAS_IMAGE_BUT_NOT_USED,
    VALIDATE_SHADERDESC_IMAGE_SAMPLER_PAIR_HAS_SAMPLER_BUT_NOT_USED,
    VALIDATE_SHADERDESC_NONFILTERING_SAMPLER_REQUIRED,
    VALIDATE_SHADERDESC_COMPARISON_SAMPLER_REQUIRED,
    VALIDATE_SHADERDESC_IMAGE_NOT_REFERENCED_BY_IMAGE_SAMPLER_PAIRS,
    VALIDATE_SHADERDESC_SAMPLER_NOT_REFERENCED_BY_IMAGE_SAMPLER_PAIRS,
    VALIDATE_SHADERDESC_NO_CONT_IMAGE_SAMPLER_PAIRS,
    VALIDATE_SHADERDESC_ATTR_STRING_TOO_LONG,
    VALIDATE_PIPELINEDESC_CANARY,
    VALIDATE_PIPELINEDESC_SHADER,
    VALIDATE_PIPELINEDESC_NO_CONT_ATTRS,
    VALIDATE_PIPELINEDESC_LAYOUT_STRIDE4,
    VALIDATE_PIPELINEDESC_ATTR_SEMANTICS,
    VALIDATE_ATTACHMENTSDESC_CANARY,
    VALIDATE_ATTACHMENTSDESC_NO_ATTACHMENTS,
    VALIDATE_ATTACHMENTSDESC_NO_CONT_COLOR_ATTS,
    VALIDATE_ATTACHMENTSDESC_IMAGE,
    VALIDATE_ATTACHMENTSDESC_MIPLEVEL,
    VALIDATE_ATTACHMENTSDESC_FACE,
    VALIDATE_ATTACHMENTSDESC_LAYER,
    VALIDATE_ATTACHMENTSDESC_SLICE,
    VALIDATE_ATTACHMENTSDESC_IMAGE_NO_RT,
    VALIDATE_ATTACHMENTSDESC_COLOR_INV_PIXELFORMAT,
    VALIDATE_ATTACHMENTSDESC_DEPTH_INV_PIXELFORMAT,
    VALIDATE_ATTACHMENTSDESC_IMAGE_SIZES,
    VALIDATE_ATTACHMENTSDESC_IMAGE_SAMPLE_COUNTS,
    VALIDATE_ATTACHMENTSDESC_RESOLVE_COLOR_IMAGE_MSAA,
    VALIDATE_ATTACHMENTSDESC_RESOLVE_IMAGE,
    VALIDATE_ATTACHMENTSDESC_RESOLVE_SAMPLE_COUNT,
    VALIDATE_ATTACHMENTSDESC_RESOLVE_MIPLEVEL,
    VALIDATE_ATTACHMENTSDESC_RESOLVE_FACE,
    VALIDATE_ATTACHMENTSDESC_RESOLVE_LAYER,
    VALIDATE_ATTACHMENTSDESC_RESOLVE_SLICE,
    VALIDATE_ATTACHMENTSDESC_RESOLVE_IMAGE_NO_RT,
    VALIDATE_ATTACHMENTSDESC_RESOLVE_IMAGE_SIZES,
    VALIDATE_ATTACHMENTSDESC_RESOLVE_IMAGE_FORMAT,
    VALIDATE_ATTACHMENTSDESC_DEPTH_IMAGE,
    VALIDATE_ATTACHMENTSDESC_DEPTH_MIPLEVEL,
    VALIDATE_ATTACHMENTSDESC_DEPTH_FACE,
    VALIDATE_ATTACHMENTSDESC_DEPTH_LAYER,
    VALIDATE_ATTACHMENTSDESC_DEPTH_SLICE,
    VALIDATE_ATTACHMENTSDESC_DEPTH_IMAGE_NO_RT,
    VALIDATE_ATTACHMENTSDESC_DEPTH_IMAGE_SIZES,
    VALIDATE_ATTACHMENTSDESC_DEPTH_IMAGE_SAMPLE_COUNT,
    VALIDATE_BEGINPASS_CANARY,
    VALIDATE_BEGINPASS_ATTACHMENTS_EXISTS,
    VALIDATE_BEGINPASS_ATTACHMENTS_VALID,
    VALIDATE_BEGINPASS_COLOR_ATTACHMENT_IMAGE,
    VALIDATE_BEGINPASS_RESOLVE_ATTACHMENT_IMAGE,
    VALIDATE_BEGINPASS_DEPTHSTENCIL_ATTACHMENT_IMAGE,
    VALIDATE_BEGINPASS_SWAPCHAIN_EXPECT_WIDTH,
    VALIDATE_BEGINPASS_SWAPCHAIN_EXPECT_WIDTH_NOTSET,
    VALIDATE_BEGINPASS_SWAPCHAIN_EXPECT_HEIGHT,
    VALIDATE_BEGINPASS_SWAPCHAIN_EXPECT_HEIGHT_NOTSET,
    VALIDATE_BEGINPASS_SWAPCHAIN_EXPECT_SAMPLECOUNT,
    VALIDATE_BEGINPASS_SWAPCHAIN_EXPECT_SAMPLECOUNT_NOTSET,
    VALIDATE_BEGINPASS_SWAPCHAIN_EXPECT_COLORFORMAT,
    VALIDATE_BEGINPASS_SWAPCHAIN_EXPECT_COLORFORMAT_NOTSET,
    VALIDATE_BEGINPASS_SWAPCHAIN_EXPECT_DEPTHFORMAT_NOTSET,
    VALIDATE_BEGINPASS_SWAPCHAIN_METAL_EXPECT_CURRENTDRAWABLE,
    VALIDATE_BEGINPASS_SWAPCHAIN_METAL_EXPECT_CURRENTDRAWABLE_NOTSET,
    VALIDATE_BEGINPASS_SWAPCHAIN_METAL_EXPECT_DEPTHSTENCILTEXTURE,
    VALIDATE_BEGINPASS_SWAPCHAIN_METAL_EXPECT_DEPTHSTENCILTEXTURE_NOTSET,
    VALIDATE_BEGINPASS_SWAPCHAIN_METAL_EXPECT_MSAACOLORTEXTURE,
    VALIDATE_BEGINPASS_SWAPCHAIN_METAL_EXPECT_MSAACOLORTEXTURE_NOTSET,
    VALIDATE_BEGINPASS_SWAPCHAIN_D3D11_EXPECT_RENDERVIEW,
    VALIDATE_BEGINPASS_SWAPCHAIN_D3D11_EXPECT_RENDERVIEW_NOTSET,
    VALIDATE_BEGINPASS_SWAPCHAIN_D3D11_EXPECT_RESOLVEVIEW,
    VALIDATE_BEGINPASS_SWAPCHAIN_D3D11_EXPECT_RESOLVEVIEW_NOTSET,
    VALIDATE_BEGINPASS_SWAPCHAIN_D3D11_EXPECT_DEPTHSTENCILVIEW,
    VALIDATE_BEGINPASS_SWAPCHAIN_D3D11_EXPECT_DEPTHSTENCILVIEW_NOTSET,
    VALIDATE_BEGINPASS_SWAPCHAIN_WGPU_EXPECT_RENDERVIEW,
    VALIDATE_BEGINPASS_SWAPCHAIN_WGPU_EXPECT_RENDERVIEW_NOTSET,
    VALIDATE_BEGINPASS_SWAPCHAIN_WGPU_EXPECT_RESOLVEVIEW,
    VALIDATE_BEGINPASS_SWAPCHAIN_WGPU_EXPECT_RESOLVEVIEW_NOTSET,
    VALIDATE_BEGINPASS_SWAPCHAIN_WGPU_EXPECT_DEPTHSTENCILVIEW,
    VALIDATE_BEGINPASS_SWAPCHAIN_WGPU_EXPECT_DEPTHSTENCILVIEW_NOTSET,
    VALIDATE_BEGINPASS_SWAPCHAIN_GL_EXPECT_FRAMEBUFFER_NOTSET,
    VALIDATE_APIP_PIPELINE_VALID_ID,
    VALIDATE_APIP_PIPELINE_EXISTS,
    VALIDATE_APIP_PIPELINE_VALID,
    VALIDATE_APIP_SHADER_EXISTS,
    VALIDATE_APIP_SHADER_VALID,
    VALIDATE_APIP_CURPASS_ATTACHMENTS_EXISTS,
    VALIDATE_APIP_CURPASS_ATTACHMENTS_VALID,
    VALIDATE_APIP_ATT_COUNT,
    VALIDATE_APIP_COLOR_FORMAT,
    VALIDATE_APIP_DEPTH_FORMAT,
    VALIDATE_APIP_SAMPLE_COUNT,
    VALIDATE_ABND_PIPELINE,
    VALIDATE_ABND_PIPELINE_EXISTS,
    VALIDATE_ABND_PIPELINE_VALID,
    VALIDATE_ABND_VBS,
    VALIDATE_ABND_VB_EXISTS,
    VALIDATE_ABND_VB_TYPE,
    VALIDATE_ABND_VB_OVERFLOW,
    VALIDATE_ABND_NO_IB,
    VALIDATE_ABND_IB,
    VALIDATE_ABND_IB_EXISTS,
    VALIDATE_ABND_IB_TYPE,
    VALIDATE_ABND_IB_OVERFLOW,
    VALIDATE_ABND_VS_EXPECTED_IMAGE_BINDING,
    VALIDATE_ABND_VS_IMG_EXISTS,
    VALIDATE_ABND_VS_IMAGE_TYPE_MISMATCH,
    VALIDATE_ABND_VS_IMAGE_MSAA,
    VALIDATE_ABND_VS_EXPECTED_FILTERABLE_IMAGE,
    VALIDATE_ABND_VS_EXPECTED_DEPTH_IMAGE,
    VALIDATE_ABND_VS_UNEXPECTED_IMAGE_BINDING,
    VALIDATE_ABND_VS_EXPECTED_SAMPLER_BINDING,
    VALIDATE_ABND_VS_UNEXPECTED_SAMPLER_COMPARE_NEVER,
    VALIDATE_ABND_VS_EXPECTED_SAMPLER_COMPARE_NEVER,
    VALIDATE_ABND_VS_EXPECTED_NONFILTERING_SAMPLER,
    VALIDATE_ABND_VS_UNEXPECTED_SAMPLER_BINDING,
    VALIDATE_ABND_VS_SMP_EXISTS,
    VALIDATE_ABND_VS_EXPECTED_STORAGEBUFFER_BINDING,
    VALIDATE_ABND_VS_STORAGEBUFFER_EXISTS,
    VALIDATE_ABND_VS_STORAGEBUFFER_BINDING_BUFFERTYPE,
    VALIDATE_ABND_VS_UNEXPECTED_STORAGEBUFFER_BINDING,
    VALIDATE_ABND_FS_EXPECTED_IMAGE_BINDING,
    VALIDATE_ABND_FS_IMG_EXISTS,
    VALIDATE_ABND_FS_IMAGE_TYPE_MISMATCH,
    VALIDATE_ABND_FS_IMAGE_MSAA,
    VALIDATE_ABND_FS_EXPECTED_FILTERABLE_IMAGE,
    VALIDATE_ABND_FS_EXPECTED_DEPTH_IMAGE,
    VALIDATE_ABND_FS_UNEXPECTED_IMAGE_BINDING,
    VALIDATE_ABND_FS_EXPECTED_SAMPLER_BINDING,
    VALIDATE_ABND_FS_UNEXPECTED_SAMPLER_COMPARE_NEVER,
    VALIDATE_ABND_FS_EXPECTED_SAMPLER_COMPARE_NEVER,
    VALIDATE_ABND_FS_EXPECTED_NONFILTERING_SAMPLER,
    VALIDATE_ABND_FS_UNEXPECTED_SAMPLER_BINDING,
    VALIDATE_ABND_FS_SMP_EXISTS,
    VALIDATE_ABND_FS_EXPECTED_STORAGEBUFFER_BINDING,
    VALIDATE_ABND_FS_STORAGEBUFFER_EXISTS,
    VALIDATE_ABND_FS_STORAGEBUFFER_BINDING_BUFFERTYPE,
    VALIDATE_ABND_FS_UNEXPECTED_STORAGEBUFFER_BINDING,
    VALIDATE_AUB_NO_PIPELINE,
    VALIDATE_AUB_NO_UB_AT_SLOT,
    VALIDATE_AUB_SIZE,
    VALIDATE_UPDATEBUF_USAGE,
    VALIDATE_UPDATEBUF_SIZE,
    VALIDATE_UPDATEBUF_ONCE,
    VALIDATE_UPDATEBUF_APPEND,
    VALIDATE_APPENDBUF_USAGE,
    VALIDATE_APPENDBUF_SIZE,
    VALIDATE_APPENDBUF_UPDATE,
    VALIDATE_UPDIMG_USAGE,
    VALIDATE_UPDIMG_ONCE,
    VALIDATION_FAILED,
};
pub const EnvironmentDefaults = extern struct {
    color_format: PixelFormat = .DEFAULT,
    depth_format: PixelFormat = .DEFAULT,
    sample_count: i32 = 0,
};
pub const MetalEnvironment = extern struct {
    device: ?*const anyopaque = null,
};
pub const D3d11Environment = extern struct {
    device: ?*const anyopaque = null,
    device_context: ?*const anyopaque = null,
};
pub const WgpuEnvironment = extern struct {
    device: ?*const anyopaque = null,
};
pub const Environment = extern struct {
    defaults: EnvironmentDefaults = .{},
    metal: MetalEnvironment = .{},
    d3d11: D3d11Environment = .{},
    wgpu: WgpuEnvironment = .{},
};
pub const CommitListener = extern struct {
    func: ?*const fn (?*anyopaque) callconv(.C) void = null,
    user_data: ?*anyopaque = null,
};
pub const Allocator = extern struct {
    alloc_fn: ?*const fn (usize, ?*anyopaque) callconv(.C) ?*anyopaque = null,
    free_fn: ?*const fn (?*anyopaque, ?*anyopaque) callconv(.C) void = null,
    user_data: ?*anyopaque = null,
};
pub const Logger = extern struct {
    func: ?*const fn ([*c]const u8, u32, u32, [*c]const u8, u32, [*c]const u8, ?*anyopaque) callconv(.C) void = null,
    user_data: ?*anyopaque = null,
};
pub const Desc = extern struct {
    _start_canary: u32 = 0,
    buffer_pool_size: i32 = 0,
    image_pool_size: i32 = 0,
    sampler_pool_size: i32 = 0,
    shader_pool_size: i32 = 0,
    pipeline_pool_size: i32 = 0,
    attachments_pool_size: i32 = 0,
    uniform_buffer_size: i32 = 0,
    max_commit_listeners: i32 = 0,
    disable_validation: bool = false,
    mtl_force_managed_storage_mode: bool = false,
    mtl_use_command_buffer_with_retained_references: bool = false,
    wgpu_disable_bindgroups_cache: bool = false,
    wgpu_bindgroups_cache_size: i32 = 0,
    allocator: Allocator = .{},
    logger: Logger = .{},
    environment: Environment = .{},
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
pub extern fn sg_push_debug_group([*c]const u8) void;
pub fn pushDebugGroup(name: [:0]const u8) void {
    sg_push_debug_group(@ptrCast(name));
}
pub extern fn sg_pop_debug_group() void;
pub fn popDebugGroup() void {
    sg_pop_debug_group();
}
pub extern fn sg_add_commit_listener(CommitListener) bool;
pub fn addCommitListener(listener: CommitListener) bool {
    return sg_add_commit_listener(listener);
}
pub extern fn sg_remove_commit_listener(CommitListener) bool;
pub fn removeCommitListener(listener: CommitListener) bool {
    return sg_remove_commit_listener(listener);
}
pub extern fn sg_make_buffer([*c]const BufferDesc) Buffer;
pub fn makeBuffer(desc: BufferDesc) Buffer {
    return sg_make_buffer(&desc);
}
pub extern fn sg_make_image([*c]const ImageDesc) Image;
pub fn makeImage(desc: ImageDesc) Image {
    return sg_make_image(&desc);
}
pub extern fn sg_make_sampler([*c]const SamplerDesc) Sampler;
pub fn makeSampler(desc: SamplerDesc) Sampler {
    return sg_make_sampler(&desc);
}
pub extern fn sg_make_shader([*c]const ShaderDesc) Shader;
pub fn makeShader(desc: ShaderDesc) Shader {
    return sg_make_shader(&desc);
}
pub extern fn sg_make_pipeline([*c]const PipelineDesc) Pipeline;
pub fn makePipeline(desc: PipelineDesc) Pipeline {
    return sg_make_pipeline(&desc);
}
pub extern fn sg_make_attachments([*c]const AttachmentsDesc) Attachments;
pub fn makeAttachments(desc: AttachmentsDesc) Attachments {
    return sg_make_attachments(&desc);
}
pub extern fn sg_destroy_buffer(Buffer) void;
pub fn destroyBuffer(buf: Buffer) void {
    sg_destroy_buffer(buf);
}
pub extern fn sg_destroy_image(Image) void;
pub fn destroyImage(img: Image) void {
    sg_destroy_image(img);
}
pub extern fn sg_destroy_sampler(Sampler) void;
pub fn destroySampler(smp: Sampler) void {
    sg_destroy_sampler(smp);
}
pub extern fn sg_destroy_shader(Shader) void;
pub fn destroyShader(shd: Shader) void {
    sg_destroy_shader(shd);
}
pub extern fn sg_destroy_pipeline(Pipeline) void;
pub fn destroyPipeline(pip: Pipeline) void {
    sg_destroy_pipeline(pip);
}
pub extern fn sg_destroy_attachments(Attachments) void;
pub fn destroyAttachments(atts: Attachments) void {
    sg_destroy_attachments(atts);
}
pub extern fn sg_update_buffer(Buffer, [*c]const Range) void;
pub fn updateBuffer(buf: Buffer, data: Range) void {
    sg_update_buffer(buf, &data);
}
pub extern fn sg_update_image(Image, [*c]const ImageData) void;
pub fn updateImage(img: Image, data: ImageData) void {
    sg_update_image(img, &data);
}
pub extern fn sg_append_buffer(Buffer, [*c]const Range) i32;
pub fn appendBuffer(buf: Buffer, data: Range) i32 {
    return sg_append_buffer(buf, &data);
}
pub extern fn sg_query_buffer_overflow(Buffer) bool;
pub fn queryBufferOverflow(buf: Buffer) bool {
    return sg_query_buffer_overflow(buf);
}
pub extern fn sg_query_buffer_will_overflow(Buffer, usize) bool;
pub fn queryBufferWillOverflow(buf: Buffer, size: usize) bool {
    return sg_query_buffer_will_overflow(buf, size);
}
pub extern fn sg_begin_pass([*c]const Pass) void;
pub fn beginPass(pass: Pass) void {
    sg_begin_pass(&pass);
}
pub extern fn sg_apply_viewport(i32, i32, i32, i32, bool) void;
pub fn applyViewport(x: i32, y: i32, width: i32, height: i32, origin_top_left: bool) void {
    sg_apply_viewport(x, y, width, height, origin_top_left);
}
pub extern fn sg_apply_viewportf(f32, f32, f32, f32, bool) void;
pub fn applyViewportf(x: f32, y: f32, width: f32, height: f32, origin_top_left: bool) void {
    sg_apply_viewportf(x, y, width, height, origin_top_left);
}
pub extern fn sg_apply_scissor_rect(i32, i32, i32, i32, bool) void;
pub fn applyScissorRect(x: i32, y: i32, width: i32, height: i32, origin_top_left: bool) void {
    sg_apply_scissor_rect(x, y, width, height, origin_top_left);
}
pub extern fn sg_apply_scissor_rectf(f32, f32, f32, f32, bool) void;
pub fn applyScissorRectf(x: f32, y: f32, width: f32, height: f32, origin_top_left: bool) void {
    sg_apply_scissor_rectf(x, y, width, height, origin_top_left);
}
pub extern fn sg_apply_pipeline(Pipeline) void;
pub fn applyPipeline(pip: Pipeline) void {
    sg_apply_pipeline(pip);
}
pub extern fn sg_apply_bindings([*c]const Bindings) void;
pub fn applyBindings(bindings: Bindings) void {
    sg_apply_bindings(&bindings);
}
pub extern fn sg_apply_uniforms(ShaderStage, u32, [*c]const Range) void;
pub fn applyUniforms(stage: ShaderStage, ub_index: u32, data: Range) void {
    sg_apply_uniforms(stage, ub_index, &data);
}
pub extern fn sg_draw(u32, u32, u32) void;
pub fn draw(base_element: u32, num_elements: u32, num_instances: u32) void {
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
pub extern fn sg_query_row_pitch(PixelFormat, i32, i32) i32;
pub fn queryRowPitch(fmt: PixelFormat, width: i32, row_align_bytes: i32) i32 {
    return sg_query_row_pitch(fmt, width, row_align_bytes);
}
pub extern fn sg_query_surface_pitch(PixelFormat, i32, i32, i32) i32;
pub fn querySurfacePitch(fmt: PixelFormat, width: i32, height: i32, row_align_bytes: i32) i32 {
    return sg_query_surface_pitch(fmt, width, height, row_align_bytes);
}
pub extern fn sg_query_buffer_state(Buffer) ResourceState;
pub fn queryBufferState(buf: Buffer) ResourceState {
    return sg_query_buffer_state(buf);
}
pub extern fn sg_query_image_state(Image) ResourceState;
pub fn queryImageState(img: Image) ResourceState {
    return sg_query_image_state(img);
}
pub extern fn sg_query_sampler_state(Sampler) ResourceState;
pub fn querySamplerState(smp: Sampler) ResourceState {
    return sg_query_sampler_state(smp);
}
pub extern fn sg_query_shader_state(Shader) ResourceState;
pub fn queryShaderState(shd: Shader) ResourceState {
    return sg_query_shader_state(shd);
}
pub extern fn sg_query_pipeline_state(Pipeline) ResourceState;
pub fn queryPipelineState(pip: Pipeline) ResourceState {
    return sg_query_pipeline_state(pip);
}
pub extern fn sg_query_attachments_state(Attachments) ResourceState;
pub fn queryAttachmentsState(atts: Attachments) ResourceState {
    return sg_query_attachments_state(atts);
}
pub extern fn sg_query_buffer_info(Buffer) BufferInfo;
pub fn queryBufferInfo(buf: Buffer) BufferInfo {
    return sg_query_buffer_info(buf);
}
pub extern fn sg_query_image_info(Image) ImageInfo;
pub fn queryImageInfo(img: Image) ImageInfo {
    return sg_query_image_info(img);
}
pub extern fn sg_query_sampler_info(Sampler) SamplerInfo;
pub fn querySamplerInfo(smp: Sampler) SamplerInfo {
    return sg_query_sampler_info(smp);
}
pub extern fn sg_query_shader_info(Shader) ShaderInfo;
pub fn queryShaderInfo(shd: Shader) ShaderInfo {
    return sg_query_shader_info(shd);
}
pub extern fn sg_query_pipeline_info(Pipeline) PipelineInfo;
pub fn queryPipelineInfo(pip: Pipeline) PipelineInfo {
    return sg_query_pipeline_info(pip);
}
pub extern fn sg_query_attachments_info(Attachments) AttachmentsInfo;
pub fn queryAttachmentsInfo(atts: Attachments) AttachmentsInfo {
    return sg_query_attachments_info(atts);
}
pub extern fn sg_query_buffer_desc(Buffer) BufferDesc;
pub fn queryBufferDesc(buf: Buffer) BufferDesc {
    return sg_query_buffer_desc(buf);
}
pub extern fn sg_query_image_desc(Image) ImageDesc;
pub fn queryImageDesc(img: Image) ImageDesc {
    return sg_query_image_desc(img);
}
pub extern fn sg_query_sampler_desc(Sampler) SamplerDesc;
pub fn querySamplerDesc(smp: Sampler) SamplerDesc {
    return sg_query_sampler_desc(smp);
}
pub extern fn sg_query_shader_desc(Shader) ShaderDesc;
pub fn queryShaderDesc(shd: Shader) ShaderDesc {
    return sg_query_shader_desc(shd);
}
pub extern fn sg_query_pipeline_desc(Pipeline) PipelineDesc;
pub fn queryPipelineDesc(pip: Pipeline) PipelineDesc {
    return sg_query_pipeline_desc(pip);
}
pub extern fn sg_query_attachments_desc(Attachments) AttachmentsDesc;
pub fn queryAttachmentsDesc(atts: Attachments) AttachmentsDesc {
    return sg_query_attachments_desc(atts);
}
pub extern fn sg_query_buffer_defaults([*c]const BufferDesc) BufferDesc;
pub fn queryBufferDefaults(desc: BufferDesc) BufferDesc {
    return sg_query_buffer_defaults(&desc);
}
pub extern fn sg_query_image_defaults([*c]const ImageDesc) ImageDesc;
pub fn queryImageDefaults(desc: ImageDesc) ImageDesc {
    return sg_query_image_defaults(&desc);
}
pub extern fn sg_query_sampler_defaults([*c]const SamplerDesc) SamplerDesc;
pub fn querySamplerDefaults(desc: SamplerDesc) SamplerDesc {
    return sg_query_sampler_defaults(&desc);
}
pub extern fn sg_query_shader_defaults([*c]const ShaderDesc) ShaderDesc;
pub fn queryShaderDefaults(desc: ShaderDesc) ShaderDesc {
    return sg_query_shader_defaults(&desc);
}
pub extern fn sg_query_pipeline_defaults([*c]const PipelineDesc) PipelineDesc;
pub fn queryPipelineDefaults(desc: PipelineDesc) PipelineDesc {
    return sg_query_pipeline_defaults(&desc);
}
pub extern fn sg_query_attachments_defaults([*c]const AttachmentsDesc) AttachmentsDesc;
pub fn queryAttachmentsDefaults(desc: AttachmentsDesc) AttachmentsDesc {
    return sg_query_attachments_defaults(&desc);
}
pub extern fn sg_alloc_buffer() Buffer;
pub fn allocBuffer() Buffer {
    return sg_alloc_buffer();
}
pub extern fn sg_alloc_image() Image;
pub fn allocImage() Image {
    return sg_alloc_image();
}
pub extern fn sg_alloc_sampler() Sampler;
pub fn allocSampler() Sampler {
    return sg_alloc_sampler();
}
pub extern fn sg_alloc_shader() Shader;
pub fn allocShader() Shader {
    return sg_alloc_shader();
}
pub extern fn sg_alloc_pipeline() Pipeline;
pub fn allocPipeline() Pipeline {
    return sg_alloc_pipeline();
}
pub extern fn sg_alloc_attachments() Attachments;
pub fn allocAttachments() Attachments {
    return sg_alloc_attachments();
}
pub extern fn sg_dealloc_buffer(Buffer) void;
pub fn deallocBuffer(buf: Buffer) void {
    sg_dealloc_buffer(buf);
}
pub extern fn sg_dealloc_image(Image) void;
pub fn deallocImage(img: Image) void {
    sg_dealloc_image(img);
}
pub extern fn sg_dealloc_sampler(Sampler) void;
pub fn deallocSampler(smp: Sampler) void {
    sg_dealloc_sampler(smp);
}
pub extern fn sg_dealloc_shader(Shader) void;
pub fn deallocShader(shd: Shader) void {
    sg_dealloc_shader(shd);
}
pub extern fn sg_dealloc_pipeline(Pipeline) void;
pub fn deallocPipeline(pip: Pipeline) void {
    sg_dealloc_pipeline(pip);
}
pub extern fn sg_dealloc_attachments(Attachments) void;
pub fn deallocAttachments(attachments: Attachments) void {
    sg_dealloc_attachments(attachments);
}
pub extern fn sg_init_buffer(Buffer, [*c]const BufferDesc) void;
pub fn initBuffer(buf: Buffer, desc: BufferDesc) void {
    sg_init_buffer(buf, &desc);
}
pub extern fn sg_init_image(Image, [*c]const ImageDesc) void;
pub fn initImage(img: Image, desc: ImageDesc) void {
    sg_init_image(img, &desc);
}
pub extern fn sg_init_sampler(Sampler, [*c]const SamplerDesc) void;
pub fn initSampler(smg: Sampler, desc: SamplerDesc) void {
    sg_init_sampler(smg, &desc);
}
pub extern fn sg_init_shader(Shader, [*c]const ShaderDesc) void;
pub fn initShader(shd: Shader, desc: ShaderDesc) void {
    sg_init_shader(shd, &desc);
}
pub extern fn sg_init_pipeline(Pipeline, [*c]const PipelineDesc) void;
pub fn initPipeline(pip: Pipeline, desc: PipelineDesc) void {
    sg_init_pipeline(pip, &desc);
}
pub extern fn sg_init_attachments(Attachments, [*c]const AttachmentsDesc) void;
pub fn initAttachments(attachments: Attachments, desc: AttachmentsDesc) void {
    sg_init_attachments(attachments, &desc);
}
pub extern fn sg_uninit_buffer(Buffer) void;
pub fn uninitBuffer(buf: Buffer) void {
    sg_uninit_buffer(buf);
}
pub extern fn sg_uninit_image(Image) void;
pub fn uninitImage(img: Image) void {
    sg_uninit_image(img);
}
pub extern fn sg_uninit_sampler(Sampler) void;
pub fn uninitSampler(smp: Sampler) void {
    sg_uninit_sampler(smp);
}
pub extern fn sg_uninit_shader(Shader) void;
pub fn uninitShader(shd: Shader) void {
    sg_uninit_shader(shd);
}
pub extern fn sg_uninit_pipeline(Pipeline) void;
pub fn uninitPipeline(pip: Pipeline) void {
    sg_uninit_pipeline(pip);
}
pub extern fn sg_uninit_attachments(Attachments) void;
pub fn uninitAttachments(atts: Attachments) void {
    sg_uninit_attachments(atts);
}
pub extern fn sg_fail_buffer(Buffer) void;
pub fn failBuffer(buf: Buffer) void {
    sg_fail_buffer(buf);
}
pub extern fn sg_fail_image(Image) void;
pub fn failImage(img: Image) void {
    sg_fail_image(img);
}
pub extern fn sg_fail_sampler(Sampler) void;
pub fn failSampler(smp: Sampler) void {
    sg_fail_sampler(smp);
}
pub extern fn sg_fail_shader(Shader) void;
pub fn failShader(shd: Shader) void {
    sg_fail_shader(shd);
}
pub extern fn sg_fail_pipeline(Pipeline) void;
pub fn failPipeline(pip: Pipeline) void {
    sg_fail_pipeline(pip);
}
pub extern fn sg_fail_attachments(Attachments) void;
pub fn failAttachments(atts: Attachments) void {
    sg_fail_attachments(atts);
}
pub extern fn sg_enable_frame_stats() void;
pub fn enableFrameStats() void {
    sg_enable_frame_stats();
}
pub extern fn sg_disable_frame_stats() void;
pub fn disableFrameStats() void {
    sg_disable_frame_stats();
}
pub extern fn sg_frame_stats_enabled() bool;
pub fn frameStatsEnabled() bool {
    return sg_frame_stats_enabled();
}
pub extern fn sg_query_frame_stats() FrameStats;
pub fn queryFrameStats() FrameStats {
    return sg_query_frame_stats();
}
pub const D3d11BufferInfo = extern struct {
    buf: ?*const anyopaque = null,
};
pub const D3d11ImageInfo = extern struct {
    tex2d: ?*const anyopaque = null,
    tex3d: ?*const anyopaque = null,
    res: ?*const anyopaque = null,
    srv: ?*const anyopaque = null,
};
pub const D3d11SamplerInfo = extern struct {
    smp: ?*const anyopaque = null,
};
pub const D3d11ShaderInfo = extern struct {
    vs_cbufs: [4]?*const anyopaque = [_]?*const anyopaque{null} ** 4,
    fs_cbufs: [4]?*const anyopaque = [_]?*const anyopaque{null} ** 4,
    vs: ?*const anyopaque = null,
    fs: ?*const anyopaque = null,
};
pub const D3d11PipelineInfo = extern struct {
    il: ?*const anyopaque = null,
    rs: ?*const anyopaque = null,
    dss: ?*const anyopaque = null,
    bs: ?*const anyopaque = null,
};
pub const D3d11AttachmentsInfo = extern struct {
    color_rtv: [4]?*const anyopaque = [_]?*const anyopaque{null} ** 4,
    resolve_rtv: [4]?*const anyopaque = [_]?*const anyopaque{null} ** 4,
    dsv: ?*const anyopaque = null,
};
pub const MtlBufferInfo = extern struct {
    buf: [2]?*const anyopaque = [_]?*const anyopaque{null} ** 2,
    active_slot: i32 = 0,
};
pub const MtlImageInfo = extern struct {
    tex: [2]?*const anyopaque = [_]?*const anyopaque{null} ** 2,
    active_slot: i32 = 0,
};
pub const MtlSamplerInfo = extern struct {
    smp: ?*const anyopaque = null,
};
pub const MtlShaderInfo = extern struct {
    vs_lib: ?*const anyopaque = null,
    fs_lib: ?*const anyopaque = null,
    vs_func: ?*const anyopaque = null,
    fs_func: ?*const anyopaque = null,
};
pub const MtlPipelineInfo = extern struct {
    rps: ?*const anyopaque = null,
    dss: ?*const anyopaque = null,
};
pub const WgpuBufferInfo = extern struct {
    buf: ?*const anyopaque = null,
};
pub const WgpuImageInfo = extern struct {
    tex: ?*const anyopaque = null,
    view: ?*const anyopaque = null,
};
pub const WgpuSamplerInfo = extern struct {
    smp: ?*const anyopaque = null,
};
pub const WgpuShaderInfo = extern struct {
    vs_mod: ?*const anyopaque = null,
    fs_mod: ?*const anyopaque = null,
    bgl: ?*const anyopaque = null,
};
pub const WgpuPipelineInfo = extern struct {
    pip: ?*const anyopaque = null,
};
pub const WgpuAttachmentsInfo = extern struct {
    color_view: [4]?*const anyopaque = [_]?*const anyopaque{null} ** 4,
    resolve_view: [4]?*const anyopaque = [_]?*const anyopaque{null} ** 4,
    ds_view: ?*const anyopaque = null,
};
pub const GlBufferInfo = extern struct {
    buf: [2]u32 = [_]u32{0} ** 2,
    active_slot: i32 = 0,
};
pub const GlImageInfo = extern struct {
    tex: [2]u32 = [_]u32{0} ** 2,
    tex_target: u32 = 0,
    msaa_render_buffer: u32 = 0,
    active_slot: i32 = 0,
};
pub const GlSamplerInfo = extern struct {
    smp: u32 = 0,
};
pub const GlShaderInfo = extern struct {
    prog: u32 = 0,
};
pub const GlAttachmentsInfo = extern struct {
    framebuffer: u32 = 0,
    msaa_resolve_framebuffer: [4]u32 = [_]u32{0} ** 4,
};
pub extern fn sg_d3d11_device() ?*const anyopaque;
pub fn d3d11Device() ?*const anyopaque {
    return sg_d3d11_device();
}
pub extern fn sg_d3d11_device_context() ?*const anyopaque;
pub fn d3d11DeviceContext() ?*const anyopaque {
    return sg_d3d11_device_context();
}
pub extern fn sg_d3d11_query_buffer_info(Buffer) D3d11BufferInfo;
pub fn d3d11QueryBufferInfo(buf: Buffer) D3d11BufferInfo {
    return sg_d3d11_query_buffer_info(buf);
}
pub extern fn sg_d3d11_query_image_info(Image) D3d11ImageInfo;
pub fn d3d11QueryImageInfo(img: Image) D3d11ImageInfo {
    return sg_d3d11_query_image_info(img);
}
pub extern fn sg_d3d11_query_sampler_info(Sampler) D3d11SamplerInfo;
pub fn d3d11QuerySamplerInfo(smp: Sampler) D3d11SamplerInfo {
    return sg_d3d11_query_sampler_info(smp);
}
pub extern fn sg_d3d11_query_shader_info(Shader) D3d11ShaderInfo;
pub fn d3d11QueryShaderInfo(shd: Shader) D3d11ShaderInfo {
    return sg_d3d11_query_shader_info(shd);
}
pub extern fn sg_d3d11_query_pipeline_info(Pipeline) D3d11PipelineInfo;
pub fn d3d11QueryPipelineInfo(pip: Pipeline) D3d11PipelineInfo {
    return sg_d3d11_query_pipeline_info(pip);
}
pub extern fn sg_d3d11_query_attachments_info(Attachments) D3d11AttachmentsInfo;
pub fn d3d11QueryAttachmentsInfo(atts: Attachments) D3d11AttachmentsInfo {
    return sg_d3d11_query_attachments_info(atts);
}
pub extern fn sg_mtl_device() ?*const anyopaque;
pub fn mtlDevice() ?*const anyopaque {
    return sg_mtl_device();
}
pub extern fn sg_mtl_render_command_encoder() ?*const anyopaque;
pub fn mtlRenderCommandEncoder() ?*const anyopaque {
    return sg_mtl_render_command_encoder();
}
pub extern fn sg_mtl_query_buffer_info(Buffer) MtlBufferInfo;
pub fn mtlQueryBufferInfo(buf: Buffer) MtlBufferInfo {
    return sg_mtl_query_buffer_info(buf);
}
pub extern fn sg_mtl_query_image_info(Image) MtlImageInfo;
pub fn mtlQueryImageInfo(img: Image) MtlImageInfo {
    return sg_mtl_query_image_info(img);
}
pub extern fn sg_mtl_query_sampler_info(Sampler) MtlSamplerInfo;
pub fn mtlQuerySamplerInfo(smp: Sampler) MtlSamplerInfo {
    return sg_mtl_query_sampler_info(smp);
}
pub extern fn sg_mtl_query_shader_info(Shader) MtlShaderInfo;
pub fn mtlQueryShaderInfo(shd: Shader) MtlShaderInfo {
    return sg_mtl_query_shader_info(shd);
}
pub extern fn sg_mtl_query_pipeline_info(Pipeline) MtlPipelineInfo;
pub fn mtlQueryPipelineInfo(pip: Pipeline) MtlPipelineInfo {
    return sg_mtl_query_pipeline_info(pip);
}
pub extern fn sg_wgpu_device() ?*const anyopaque;
pub fn wgpuDevice() ?*const anyopaque {
    return sg_wgpu_device();
}
pub extern fn sg_wgpu_queue() ?*const anyopaque;
pub fn wgpuQueue() ?*const anyopaque {
    return sg_wgpu_queue();
}
pub extern fn sg_wgpu_command_encoder() ?*const anyopaque;
pub fn wgpuCommandEncoder() ?*const anyopaque {
    return sg_wgpu_command_encoder();
}
pub extern fn sg_wgpu_render_pass_encoder() ?*const anyopaque;
pub fn wgpuRenderPassEncoder() ?*const anyopaque {
    return sg_wgpu_render_pass_encoder();
}
pub extern fn sg_wgpu_query_buffer_info(Buffer) WgpuBufferInfo;
pub fn wgpuQueryBufferInfo(buf: Buffer) WgpuBufferInfo {
    return sg_wgpu_query_buffer_info(buf);
}
pub extern fn sg_wgpu_query_image_info(Image) WgpuImageInfo;
pub fn wgpuQueryImageInfo(img: Image) WgpuImageInfo {
    return sg_wgpu_query_image_info(img);
}
pub extern fn sg_wgpu_query_sampler_info(Sampler) WgpuSamplerInfo;
pub fn wgpuQuerySamplerInfo(smp: Sampler) WgpuSamplerInfo {
    return sg_wgpu_query_sampler_info(smp);
}
pub extern fn sg_wgpu_query_shader_info(Shader) WgpuShaderInfo;
pub fn wgpuQueryShaderInfo(shd: Shader) WgpuShaderInfo {
    return sg_wgpu_query_shader_info(shd);
}
pub extern fn sg_wgpu_query_pipeline_info(Pipeline) WgpuPipelineInfo;
pub fn wgpuQueryPipelineInfo(pip: Pipeline) WgpuPipelineInfo {
    return sg_wgpu_query_pipeline_info(pip);
}
pub extern fn sg_wgpu_query_attachments_info(Attachments) WgpuAttachmentsInfo;
pub fn wgpuQueryAttachmentsInfo(atts: Attachments) WgpuAttachmentsInfo {
    return sg_wgpu_query_attachments_info(atts);
}
pub extern fn sg_gl_query_buffer_info(Buffer) GlBufferInfo;
pub fn glQueryBufferInfo(buf: Buffer) GlBufferInfo {
    return sg_gl_query_buffer_info(buf);
}
pub extern fn sg_gl_query_image_info(Image) GlImageInfo;
pub fn glQueryImageInfo(img: Image) GlImageInfo {
    return sg_gl_query_image_info(img);
}
pub extern fn sg_gl_query_sampler_info(Sampler) GlSamplerInfo;
pub fn glQuerySamplerInfo(smp: Sampler) GlSamplerInfo {
    return sg_gl_query_sampler_info(smp);
}
pub extern fn sg_gl_query_shader_info(Shader) GlShaderInfo;
pub fn glQueryShaderInfo(shd: Shader) GlShaderInfo {
    return sg_gl_query_shader_info(shd);
}
pub extern fn sg_gl_query_attachments_info(Attachments) GlAttachmentsInfo;
pub fn glQueryAttachmentsInfo(atts: Attachments) GlAttachmentsInfo {
    return sg_gl_query_attachments_info(atts);
}
