// machine generated, do not edit

//
// sokol_gfx.h -- simple 3D API wrapper
//
// Project URL: https://github.com/floooh/sokol
//
// Example code: https://github.com/floooh/sokol-samples
//
// Do this:
//     #define SOKOL_IMPL or
//     #define SOKOL_GFX_IMPL
// before you include this file in *one* C or C++ file to create the
// implementation.
//
// In the same place define one of the following to select the rendering
// backend:
//     #define SOKOL_GLCORE
//     #define SOKOL_GLES3
//     #define SOKOL_D3D11
//     #define SOKOL_METAL
//     #define SOKOL_WGPU
//     #define SOKOL_VULKAN
//     #define SOKOL_DUMMY_BACKEND
//
// I.e. for the desktop GL it should look like this:
//
// #include ...
// #include ...
// #define SOKOL_IMPL
// #define SOKOL_GLCORE
// #include "sokol_gfx.h"
//
// The dummy backend replaces the platform-specific backend code with empty
// stub functions. This is useful for writing tests that need to run on the
// command line.
//
// Optionally provide the following defines with your own implementations:
//
// SOKOL_ASSERT(c)             - your own assert macro (default: assert(c))
// SOKOL_UNREACHABLE()         - a guard macro for unreachable code (default: assert(false))
// SOKOL_GFX_API_DECL          - public function declaration prefix (default: extern)
// SOKOL_API_DECL              - same as SOKOL_GFX_API_DECL
// SOKOL_API_IMPL              - public function implementation prefix (default: -)
// SOKOL_TRACE_HOOKS           - enable trace hook callbacks (search below for TRACE HOOKS)
// SOKOL_EXTERNAL_GL_LOADER    - indicates that you're using your own GL loader, in this case
//                               sokol_gfx.h will not include any platform GL headers and disable
//                               the integrated Win32 GL loader
//
// If sokol_gfx.h is compiled as a DLL, define the following before
// including the declaration or implementation:
//
// SOKOL_DLL
//
// On Windows, SOKOL_DLL will define SOKOL_GFX_API_DECL as __declspec(dllexport)
// or __declspec(dllimport) as needed.
//
// Optionally define the following to force debug checks and validations
// even in release mode:
//
// SOKOL_DEBUG - by default this is defined if NDEBUG is not defined
//
// Link with the following system libraries (note that sokol_app.h has
// additional linker requirements):
//
// - on macOS/iOS with Metal: Metal
// - on macOS with GL: OpenGL
// - on iOS with GL: OpenGLES
// - on Linux with EGL: GL or GLESv2
// - on Linux with GLX: GL
// - on Android: GLESv3, log, android
// - on Windows with the MSVC or Clang toolchains: no action needed, libs are defined in-source via pragma-comment-lib
// - on Windows with MINGW/MSYS2 gcc: compile with '-mwin32' so that _WIN32 is defined
//     - with the D3D11 backend: -ld3d11
//
// On macOS and iOS, the implementation must be compiled as Objective-C.
//
// On Emscripten:
//     - for WebGL2: add the linker option `-s USE_WEBGL2=1`
//     - for WebGPU: compile and link with `--use-port=emdawnwebgpu`
//       (for more exotic situations, read: https://dawn.googlesource.com/dawn/+/refs/heads/main/src/emdawnwebgpu/pkg/README.md)
//
// sokol_gfx DOES NOT:
// ===================
// - create a window, swapchain or the 3D-API context/device, you must do this
//   before sokol_gfx is initialized, and pass any required information
//   (like 3D device pointers) to the sokol_gfx initialization call
//
// - present the rendered frame, how this is done exactly usually depends
//   on how the window and 3D-API context/device was created
//
// - provide a unified shader language, instead 3D-API-specific shader
//   source-code or shader-bytecode must be provided (for the "official"
//   offline shader cross-compiler / code-generator, see here:
//   https://github.com/floooh/sokol-tools/blob/master/docs/sokol-shdc.md)
//
//
// STEP BY STEP
// ============
// --- to initialize sokol_gfx, after creating a window and a 3D-API
//     context/device, call:
//
//         sg_setup(const sg_desc*)
//
//     Depending on the selected 3D backend, sokol-gfx requires some
//     information about its runtime environment, like a GPU device pointer,
//     default swapchain pixel formats and so on. If you are using sokol_app.h
//     for the window system glue, you can use a helper function provided in
//     the sokol_glue.h header:
//
//         #include "sokol_gfx.h"
//         #include "sokol_app.h"
//         #include "sokol_glue.h"
//         //...
//         sg_setup(&(sg_desc){
//             .environment = sglue_environment(),
//         });
//
//     To get any logging output for errors and from the validation layer, you
//     need to provide a logging callback. Easiest way is through sokol_log.h:
//
//         #include "sokol_log.h"
//         //...
//         sg_setup(&(sg_desc){
//             //...
//             .logger.func = slog_func,
//         });
//
// --- create resource objects (buffers, images, views, samplers, shaders
//     and pipeline objects)
//
//         sg_buffer sg_make_buffer(const sg_buffer_desc*)
//         sg_image sg_make_image(const sg_image_desc*)
//         sg_view sg_make_view(const sg_view_desc*)
//         sg_sampler sg_make_sampler(const sg_sampler_desc*)
//         sg_shader sg_make_shader(const sg_shader_desc*)
//         sg_pipeline sg_make_pipeline(const sg_pipeline_desc*)
//
// --- start a render- or compute-pass:
//
//         sg_begin_pass(const sg_pass* pass);
//
//     Typically, render passes render into an externally provided swapchain which
//     presents the rendering result on the display. Such a 'swapchain pass'
//     is started like this:
//
//         sg_begin_pass(&(sg_pass){ .action = { ... }, .swapchain = sglue_swapchain() })
//
//     ...where .action is an sg_pass_action struct containing actions to be performed
//     at the start and end of a render pass (such as clearing the render surfaces to
//     a specific color), and .swapchain is an sg_swapchain struct with all the required
//     information to render into the swapchain's surfaces.
//
//     To start an 'offscreen render pass' into sokol-gfx image objects, populate
//     the sg_pass.attachments nested struct with attachment view objects
//     (1..4 color-attachment-views for to render into, a depth-stencil-attachment-view
//     to provide the depth-stencil-buffer, and optionally 1..4 resolve-attachment-views
//     for an MSAA-resolve operation:
//
//         sg_begin_pass(&(sg_pass){
//             .action = { ... },
//             .attachments = {
//                 .colors[0] = color_attachment_view,
//                 .resolves[0] = optional_resolve_attachment_view,
//                 .depth_stencil = depth_stencil_attachment_view,
//             },
//         });
//
//     To start a compute-pass, just set the .compute item to true:
//
//         sg_begin_pass(&(sg_pass){ .compute = true });
//
// --- set the pipeline state for the next draw call with:
//
//         sg_apply_pipeline(sg_pipeline pip)
//
// --- fill an sg_bindings struct with the resource bindings for the next
//     draw- or dispatch-call (0..N vertex buffers, 0 or 1 index buffer, 0..N views,
//     0..N samplers), and call
//
//         sg_apply_bindings(const sg_bindings* bindings)
//
//     ...to update the resource bindings. Note that in a compute pass, no vertex-
//     or index-buffer bindings can be used, and in render passes, no storage-image bindings
//     are allowed. Those restrictions will be checked by the sokol-gfx validation layer.
//
// --- optionally update shader uniform data with:
//
//         sg_apply_uniforms(int ub_slot, const sg_range* data)
//
//     Read the section 'UNIFORM DATA LAYOUT' to learn about the expected memory layout
//     of the uniform data passed into sg_apply_uniforms().
//
// --- kick off a draw call with:
//
//         sg_draw(int base_element, int num_elements, int num_instances)
//
//     The sg_draw() function unifies all the different ways to render primitives
//     in a single call (indexed vs non-indexed rendering, and instanced vs non-instanced
//     rendering). In case of indexed rendering, base_element and num_element specify
//     indices in the currently bound index buffer. In case of non-indexed rendering
//     base_element and num_elements specify vertices in the currently bound
//     vertex-buffer(s). To perform instanced rendering, the rendering pipeline
//     must be setup for instancing (see sg_pipeline_desc below), a separate vertex buffer
//     containing per-instance data must be bound, and the num_instances parameter
//     must be > 1.
//
//     Alternatively, call:
//
//         sg_draw_ex(...)
//
//     to provide a base-vertex and/or base-instance which allows to render
//     from different sections of a vertex buffer without rebinding the
//     vertex buffer with a different offset. Note that the `sg_draw_ex()`
//     only has limited portability on OpenGL, check the sg_limits struct
//     members .draw_base_vertex and .draw_base_instance for runtime support,
//     those are generally true on non-GL-backends, and on GL the feature
//     flags are set according to the GL version:
//
//         - on GL base_instance != 0 is only supported since GL 4.2
//         - on GLES3.x, base_instance != 0 is not supported
//         - on GLES3.x, base_vertex is only supported since GLES3.2
//           (e.g. not supported on WebGL2)
//
// --- ...or kick of a dispatch call to invoke a compute shader workload:
//
//         sg_dispatch(int num_groups_x, int num_groups_y, int num_groups_z)
//
//     The dispatch args define the number of 'compute workgroups' processed
//     by the currently applied compute shader.
//
// --- finish the current pass with:
//
//         sg_end_pass()
//
// --- when done with the current frame, call
//
//         sg_commit()
//
// --- at the end of your program, shutdown sokol_gfx with:
//
//         sg_shutdown()
//
// --- if you need to destroy resources before sg_shutdown(), call:
//
//         sg_destroy_buffer(sg_buffer buf)
//         sg_destroy_image(sg_image img)
//         sg_destroy_sampler(sg_sampler smp)
//         sg_destroy_shader(sg_shader shd)
//         sg_destroy_pipeline(sg_pipeline pip)
//         sg_destroy_view(sg_view view)
//
// --- to set a new viewport rectangle, call:
//
//         sg_apply_viewport(int x, int y, int width, int height, bool origin_top_left)
//
//     ...or if you want to specify the viewport rectangle with float values:
//
//         sg_apply_viewportf(float x, float y, float width, float height, bool origin_top_left)
//
// --- to set a new scissor rect, call:
//
//         sg_apply_scissor_rect(int x, int y, int width, int height, bool origin_top_left)
//
//     ...or with float values:
//
//         sg_apply_scissor_rectf(float x, float y, float width, float height, bool origin_top_left)
//
//     Both sg_apply_viewport() and sg_apply_scissor_rect() must be called
//     inside a rendering pass (e.g. not in a compute pass, or outside a pass)
//
//     Note that sg_begin_pass() will reset both the viewport and scissor
//     rectangles to cover the entire framebuffer.
//
// --- to update (overwrite) the content of buffer and image resources, call:
//
//         sg_update_buffer(sg_buffer buf, const sg_range* data)
//         sg_update_image(sg_image img, const sg_image_data* data)
//
//     Buffers and images to be updated must have been created with
//     sg_buffer_desc.usage.dynamic_update or .stream_update.
//
//     Only one update per frame is allowed for buffer and image resources when
//     using the sg_update_*() functions. The rationale is to have a simple
//     protection from the CPU scribbling over data the GPU is currently
//     using, or the CPU having to wait for the GPU
//
//     Buffer and image updates can be partial, as long as a rendering
//     operation only references the valid (updated) data in the
//     buffer or image.
//
// --- to append a chunk of data to a buffer resource, call:
//
//         int sg_append_buffer(sg_buffer buf, const sg_range* data)
//
//     The difference to sg_update_buffer() is that sg_append_buffer()
//     can be called multiple times per frame to append new data to the
//     buffer piece by piece, optionally interleaved with draw calls referencing
//     the previously written data.
//
//     sg_append_buffer() returns a byte offset to the start of the
//     written data, this offset can be assigned to
//     sg_bindings.vertex_buffer_offsets[n] or
//     sg_bindings.index_buffer_offset
//
//     Code example:
//
//     for (...) {
//         const void* data = ...;
//         const int num_bytes = ...;
//         int offset = sg_append_buffer(buf, &(sg_range) { .ptr=data, .size=num_bytes });
//         bindings.vertex_buffer_offsets[0] = offset;
//         sg_apply_pipeline(pip);
//         sg_apply_bindings(&bindings);
//         sg_apply_uniforms(...);
//         sg_draw(...);
//     }
//
//     A buffer to be used with sg_append_buffer() must have been created
//     with sg_buffer_desc.usage.dynamic_update or .stream_update.
//
//     If the application appends more data to the buffer then fits into
//     the buffer, the buffer will go into the "overflow" state for the
//     rest of the frame.
//
//     Any draw calls attempting to render an overflown buffer will be
//     silently dropped (in debug mode this will also result in a
//     validation error).
//
//     You can also check manually if a buffer is in overflow-state by calling
//
//         bool sg_query_buffer_overflow(sg_buffer buf)
//
//     You can manually check to see if an overflow would occur before adding
//     any data to a buffer by calling
//
//         bool sg_query_buffer_will_overflow(sg_buffer buf, size_t size)
//
//     NOTE: Due to restrictions in underlying 3D-APIs, appended chunks of
//     data will be 4-byte aligned in the destination buffer. This means
//     that there will be gaps in index buffers containing 16-bit indices
//     when the number of indices in a call to sg_append_buffer() is
//     odd. This isn't a problem when each call to sg_append_buffer()
//     is associated with one draw call, but will be problematic when
//     a single indexed draw call spans several appended chunks of indices.
//
// --- to check at runtime for optional features, limits and pixelformat support,
//     call:
//
//         sg_features sg_query_features()
//         sg_limits sg_query_limits()
//         sg_pixelformat_info sg_query_pixelformat(sg_pixel_format fmt)
//
// --- if you need to call into the underlying 3D-API directly, you must call:
//
//         sg_reset_state_cache()
//
//     ...before calling sokol_gfx functions again
//
// --- you can inspect the original sg_desc structure handed to sg_setup()
//     by calling sg_query_desc(). This will return an sg_desc struct with
//     the default values patched in instead of any zero-initialized values
//
// --- you can get a desc struct matching the creation attributes of a
//     specific resource object via:
//
//         sg_buffer_desc sg_query_buffer_desc(sg_buffer buf)
//         sg_image_desc sg_query_image_desc(sg_image img)
//         sg_sampler_desc sg_query_sampler_desc(sg_sampler smp)
//         sg_shader_desc sq_query_shader_desc(sg_shader shd)
//         sg_pipeline_desc sg_query_pipeline_desc(sg_pipeline pip)
//         sg_view_desc sg_query_view_desc(sg_view view)
//
//     ...but NOTE that the returned desc structs may be incomplete, only
//     creation attributes that are kept around internally after resource
//     creation will be filled in, and in some cases (like shaders) that's
//     very little. Any missing attributes will be set to zero. The returned
//     desc structs might still be useful as partial blueprint for creating
//     similar resources if filled up with the missing attributes.
//
//     Calling the query-desc functions on an invalid resource will return
//     completely zeroed structs (it makes sense to check  the resource state
//     with sg_query_*_state() first)
//
// --- you can query the default resource creation parameters through the functions
//
//         sg_buffer_desc sg_query_buffer_defaults(const sg_buffer_desc* desc)
//         sg_image_desc sg_query_image_defaults(const sg_image_desc* desc)
//         sg_sampler_desc sg_query_sampler_defaults(const sg_sampler_desc* desc)
//         sg_shader_desc sg_query_shader_defaults(const sg_shader_desc* desc)
//         sg_pipeline_desc sg_query_pipeline_defaults(const sg_pipeline_desc* desc)
//         sg_view_desc sg_query_view_defaults(const sg_view_desc* desc)
//
//     These functions take a pointer to a desc structure which may contain
//     zero-initialized items for default values. These zero-init values
//     will be replaced with their concrete values in the returned desc
//     struct.
//
// --- you can inspect various internal resource runtime values via:
//
//         sg_buffer_info sg_query_buffer_info(sg_buffer buf)
//         sg_image_info sg_query_image_info(sg_image img)
//         sg_sampler_info sg_query_sampler_info(sg_sampler smp)
//         sg_shader_info sg_query_shader_info(sg_shader shd)
//         sg_pipeline_info sg_query_pipeline_info(sg_pipeline pip)
//         sg_view_info sg_query_view_info(sg_view view)
//
//     ...please note that the returned info-structs are tied quite closely
//     to sokol_gfx.h internals, and may change more often than other
//     public API functions and structs.
//
// -- you can query the type/flavour and parent resource of a view:
//
//         sg_view_type sg_query_view_type(sg_view view)
//         sg_image sg_query_view_image(sg_view view)
//         sg_buffer sg_query_view_buffer(sg_view view)
//
// --- you can query frame stats and control stats collection via:
//
//         sg_query_frame_stats()
//         sg_enable_frame_stats()
//         sg_disable_frame_stats()
//         sg_frame_stats_enabled()
//
// --- you can ask at runtime what backend sokol_gfx.h has been compiled for:
//
//         sg_backend sg_query_backend(void)
//
// --- call the following helper functions to compute the number of
//     bytes in a texture row or surface for a specific pixel format.
//     These functions might be helpful when preparing image data for consumption
//     by sg_make_image() or sg_update_image():
//
//         int sg_query_row_pitch(sg_pixel_format fmt, int width, int int row_align_bytes);
//         int sg_query_surface_pitch(sg_pixel_format fmt, int width, int height, int row_align_bytes);
//
//     Width and height are generally in number pixels, but note that 'row' has different meaning
//     for uncompressed vs compressed pixel formats: for uncompressed formats, a row is identical
//     with a single line if pixels, while in compressed formats, one row is a line of *compression blocks*.
//
//     This is why calling sg_query_surface_pitch() for a compressed pixel format and height
//     N, N+1, N+2, ... may return the same result.
//
//     The row_align_bytes parameter is for added flexibility. For image data that goes into
//     the sg_make_image() or sg_update_image() this should generally be 1, because these
//     functions take tightly packed image data as input no matter what alignment restrictions
//     exist in the backend 3D APIs.
//
// ON INITIALIZATION:
// ==================
// When calling sg_setup(), a pointer to an sg_desc struct must be provided
// which contains initialization options. These options provide two types
// of information to sokol-gfx:
//
//     (1) upper bounds and limits needed to allocate various internal
//         data structures:
//             - the max number of resources of each type that can
//               be alive at the same time, this is used for allocating
//               internal pools
//             - the max overall size of uniform data that can be
//               updated per frame, including a worst-case alignment
//               per uniform update (this worst-case alignment is 256 bytes)
//             - the max size of all dynamic resource updates (sg_update_buffer,
//               sg_append_buffer and sg_update_image) per frame
//             - the max number of compute-dispatch calls in a compute pass
//         Not all of those limit values are used by all backends, but it is
//         good practice to provide them none-the-less.
//
//     (2) 3D backend "environment information" in a nested sg_environment struct:
//         - pointers to backend-specific context- or device-objects (for instance
//           the D3D11, WebGPU or Metal device objects)
//         - defaults for external swapchain pixel formats and sample counts,
//           these will be used as default values in image and pipeline objects,
//           and the sg_swapchain struct passed into sg_begin_pass()
//         Usually you provide a complete sg_environment struct through
//         a helper function, as an example look at the sglue_environment()
//         function in the sokol_glue.h header.
//
// See the documentation block of the sg_desc struct below for more information.
//
//
// ON RENDER PASSES
// ================
// Relevant samples:
//     - https://floooh.github.io/sokol-html5/offscreen-sapp.html
//     - https://floooh.github.io/sokol-html5/offscreen-msaa-sapp.html
//     - https://floooh.github.io/sokol-html5/mrt-sapp.html
//     - https://floooh.github.io/sokol-html5/mrt-pixelformats-sapp.html
//
// A render pass groups rendering commands into a set of render target images
// (called 'render pass attachments'). Render target images can be used in subsequent
// passes as textures (it is invalid to use the same image both as render target
// and as texture in the same pass).
//
// The following sokol-gfx functions must only be called inside a render-pass:
//
//     sg_apply_viewport[f]
//     sg_apply_scissor_rect[f]
//     sg_draw
//
// The following function may be called inside a render- or compute-pass, but
// not outside a pass:
//
//     sg_apply_pipeline
//     sg_apply_bindings
//     sg_apply_uniforms
//
// A frame must have at least one 'swapchain render pass' which renders into an
// externally provided swapchain provided as an sg_swapchain struct to the
// sg_begin_pass() function. If you use sokol_gfx.h together with sokol_app.h,
// just call the sglue_swapchain() helper function in sokol_glue.h to
// provide the swapchain information. Otherwise the following information
// must be provided:
//
//     - the color pixel-format of the swapchain's render surface
//     - an optional depth/stencil pixel format if the swapchain
//       has a depth/stencil buffer
//     - an optional sample-count for MSAA rendering
//     - NOTE: the above three values can be zero-initialized, in that
//       case the defaults from the sg_environment struct will be used that
//       had been passed to the sg_setup() function.
//     - a number of backend specific objects:
//         - GL/GLES3: just a GL framebuffer handle
//         - D3D11:
//             - an ID3D11RenderTargetView for the rendering surface
//             - if MSAA is used, an ID3D11RenderTargetView as
//               MSAA resolve-target
//             - an optional ID3D11DepthStencilView for the
//               depth/stencil buffer
//         - WebGPU
//             - a WGPUTextureView object for the rendering surface
//             - if MSAA is used, a WGPUTextureView object as MSAA resolve target
//             - an optional WGPUTextureView for the
//         - Metal (NOTE that the roles of provided surfaces is slightly
//           different in Metal than in D3D11 or WebGPU, notably, the
//           CAMetalDrawable is either rendered to directly, or serves
//           as MSAA resolve target):
//             - a CAMetalDrawable object which is either rendered
//               into directly, or in case of MSAA rendering, serves
//               as MSAA-resolve-target
//             - if MSAA is used, an multisampled MTLTexture where
//               rendering goes into
//             - an optional MTLTexture for the depth/stencil buffer
//
// It's recommended that you create a helper function which returns an
// initialized sg_swapchain struct by value. This can then be directly plugged
// into the sg_begin_pass function like this:
//
//     sg_begin_pass(&(sg_pass){ .swapchain = sglue_swapchain() });
//
// As an example for such a helper function check out the function sglue_swapchain()
// in the sokol_glue.h header.
//
// For offscreen render passes, the render target images used in a render pass
// must be provided as sg_view objects specialized for the specific pass-attachment
// types:
//
//     - color-attachment-views for color-rendering
//     - depth-stencil-attachment-views for the depth-stencil-buffer surface
//     - resolve-attachment-views for MSAA-resolve operations
//
// For a simple offscreen scenario with one color-, one depth-stencil-render
// target and without multisampling, setting up the required image-
// and view-objects looks like this:
//
// First create two render target images, one with a color pixel format,
// and one with the depth- or depth-stencil pixel format. Both images
// must have the same dimensions. Also not the usage flags:
//
//     const sg_image color_img = sg_make_image(&(sg_image_desc){
//         .usage.color_attachment = true,
//         .width = 256,
//         .height = 256,
//         .pixel_format = SG_PIXELFORMAT_RGBA8,
//         .sample_count = 1,
//     });
//     const sg_image depth_img = sg_make_image(&(sg_image_desc){
//         .usage.depth_stencil_attachment = true,
//         .width = 256,
//         .height = 256,
//         .pixel_format = SG_PIXELFORMAT_DEPTH,
//         .sample_count = 1,
//     });
//
// NOTE: when creating render target images, have in mind that some default values
// are aligned with the default environment attributes in the sg_environment struct
// that was passed into the sg_setup() call:
//
//     - the default value for sg_image_desc.pixel_format is taken from
//       sg_environment.defaults.color_format
//     - the default value for sg_image_desc.sample_count is taken from
//       sg_environment.defaults.sample_count
//     - the default value for sg_image_desc.num_mipmaps is always 1
//
// Next, create two view objects, one color-attachment-view and one
// depth-stencil-attachment view:
//
//     const sg_view color_att_view = sg_make_view(&(sg_view_desc){
//         .color_attachment.image = color_img,
//     });
//     const sg_view depth_att_view = sg_make_view(&(sg_view_desc){
//         .depth_stencil_attachment.image = depth_img,
//     });
//
// You'll typically also want to create a texture-view on the color image
// to sample the color attachment image as texture in a later pass:
//
//     const sg_view tex_view = sg_make_view(&(sg_view_desc){
//         .texture.image = color_img,
//     });
//
// The attachment-view objects are then passed into the sg_begin_pass function in
// place of the nested swapchain struct:
//
//     sg_begin_pass(&(sg_pass){
//         .attachments = {
//             .colors[0] = color_att_view,
//             .depth_stencil = depth_att_view,
//         },
//     });
//
// ...in a later pass when you want to sample the color attachment image as
// texture, use the texture view in the sg_apply_bindings() call:
//
//     sg_apply_bindings(&(sg_bindings){
//         .vertex_buffers[0] = ...,
//         .index_buffer = ...,
//         .views[VIEW_tex] = tex_view,
//         .samplers[SMP_smp] = smp,
//     });
//
// Swapchain and offscreen passes form dependency trees with a swapchain
// pass at the root, offscreen passes as nodes, and attachment images as
// dependencies between passes.
//
// sg_pass_action structs are used to define actions that should happen at the
// start and end of render passes (such as clearing pass attachments to a
// specific color or depth-value, or performing an MSAA resolve operation at
// the end of a pass).
//
// A typical sg_pass_action object which clears the color attachment to black
// might look like this:
//
//     const sg_pass_action = {
//         .colors[0] = {
//             .load_action = SG_LOADACTION_CLEAR,
//             .clear_value = { 0.0f, 0.0f, 0.0f, 1.0f }
//         }
//     };
//
// This omits the defaults for the color attachment store action, and
// the depth-stencil-attachments actions. The same pass action with the
// defaults explicitly filled in would look like this:
//
//     const sg_pass_action pass_action = {
//         .colors[0] = {
//             .load_action = SG_LOADACTION_CLEAR,
//             .store_action = SG_STOREACTION_STORE,
//             .clear_value = { 0.0f, 0.0f, 0.0f, 1.0f }
//         },
//         .depth = = {
//             .load_action = SG_LOADACTION_CLEAR,
//             .store_action = SG_STOREACTION_DONTCARE,
//             .clear_value = 1.0f,
//         },
//         .stencil = {
//             .load_action = SG_LOADACTION_CLEAR,
//             .store_action = SG_STOREACTION_DONTCARE,
//             .clear_value = 0
//         }
//     };
//
// With the sg_pass object and sg_pass_action struct in place everything
// is ready now for the actual render pass:
//
// Using such this prepared sg_pass_action in a swapchain pass looks like
// this:
//
//     sg_begin_pass(&(sg_pass){
//         .action = pass_action,
//         .swapchain = sglue_swapchain()
//     });
//     ...
//     sg_end_pass();
//
// ...of alternatively in one offscreen pass:
//
//     sg_begin_pass(&(sg_pass){
//         .action = pass_action,
//         .attachments = {
//             .colors[0] = color_att_view,
//             .depth_stencil = ds_att_view,
//         },
//     });
//     ...
//     sg_end_pass();
//
// Offscreen rendering can also go into a mipmap, or a slice/face of
// a cube-, array- or 3d-image (which some restrictions, for instance
// it's not possible to create a 3D image with a depth/stencil pixel format,
// these exceptions are generally caught by the sokol-gfx validation layer).
//
// The mipmap/slice selection is baked into the attachment-view objects, for
// instance to create a color-attachment-view for rendering into mip-level
// 2 and slice 3 of an array texture:
//
//     const sg_view color_att_view = sg_make_view(&(sg_view_desc){
//         .color_attachment = {
//             .image = color_img,
//             .mip_level = 2,
//             .slice = 3,
//         },
//     });
//
// If MSAA offscreen rendering is desired, the multi-sample rendering result
// must be 'resolved' into a separate 'resolve image', before that image can
// be used as texture.
//
// Setting up MSAA offscreen 3D rendering requires three image objects
// (one color-attachment image with a sample count > 1), a resolve-attachment
// image with a sample count of 1, and a depth-stencil-attachment image
// with the same sample count as the color-attachment image:
//
//     const sg_image color_img = sg_make_image(&(sg_image_desc){
//         .usage.color_attachment = true,
//         .width = 256,
//         .height = 256,
//         .pixel_format = SG_PIXELFORMAT_RGBA8,
//         .sample_count = 4,
//     });
//     const sg_image resolve_img = sg_make_image(&(sg_image_desc){
//         .usage.resolve_attachment = true,
//         .width = 256,
//         .height = 256,
//         .pixel_format = SG_PIXELFORMAT_RGBA8,
//         .sample_count = 1,
//     });
//     const sg_image depth_img = sg_make_image(&(sg_image_desc){
//         .usage.depth_stencil_attachment = true,
//         .width = 256,
//         .height = 256,
//         .pixel_format = SG_PIXELFORMAT_DEPTH,
//         .sample_count = 4,
//     });
//
// Next you'll need the corresponding attachment-view objects:
//
//     const sg_view color_att_view = sg_make_view(&(sg_view_desc){
//         .color_attachment.image = color_img,
//     });
//     const sg_view resolve_att_view = sg_make_view(&(sg_view_desc){
//         .resolve_attachment.image = resolve_img,
//     });
//     const sg_view depth_att_view = sg_make_view(&(sg_view_desc){
//         .depth_stencil_attachment.image = depth_img,
//     });
//
// To sample the rendered image as a texture in a later pass you'll also
// need a texture-view on the resolve-attachment-image (not the color-attachment-image!):
//
//     const sg_view tex_view = sg_make_view(&(sg_view_desc){
//         .texture.image = resolve_img,
//     });
//
// Next start the render pass with all attachment-views, as soon as a
// resolve-attachment-view is provided, an MSAA resolve operation will happen
// at the end of the pass. Also note that the content of the MSAA color-attachment-image
// doesn't need to be preserved, since it's only needed until the MSAA-resolve
// at the end of the pass, so the .store_action should be set to "don't care":
//
//     sg_begin_pass(&(sg_pass){
//         .attachments = {
//             .colors[0] = color_att_view,
//             .resolves[0] = resolve_att_view,
//             .depth_stencil = depth_att_view,
//         },
//         .action = {
//             .colors[0] = {
//                 .load_action = SG_LOADACTION_CLEAR,
//                 .store_action = SG_STOREACTION_DONTCARE,
//                 .clear_value = { 0.0f, 0.0f, 0.0f, 1.0f },
//             }
//         },
//     });
//
// ...in a later pass, use the texture-view that had been created on the
// resolve-image to use the rendering result as texture:
//
//     sg_apply_bindings(&(sg_bindings){
//         .vertex_buffers[0] = ...,
//         .index_buffer = ...,
//         .views[VIEW_tex] = tex_view,
//         .samplers[SMP_smp] = smp,
//     });
//
// ON COMPUTE PASSES
// =================
// Compute passes are used to update the content of storage buffers and
// storage images by running compute shader code on
// the GPU. Updating storage resources with a compute shader will almost always
// be more efficient than computing the same data on the CPU and then uploading
// it via `sg_update_buffer()` or `sg_update_image()`.
//
// NOTE: compute passes are only supported on the following platforms and
// backends:
//
//     - macOS and iOS with Metal
//     - Windows with D3D11 and OpenGL
//     - Linux with OpenGL or GLES3.1+
//     - Web with WebGPU
//     - Android with GLES3.1+
//
// ...this means compute shaders can't be used on the following platform/backend
// combos (the same restrictions apply to using storage buffers without compute
// shaders):
//
//     - macOS with GL
//     - iOS with GLES3
//     - Web with WebGL2
//
// A compute pass is started with:
//
//     sg_begin_pass(&(sg_pass){ .compute = true });
//
// ...and finished with a regular:
//
//     sg_end_pass();
//
// Typically the following functions will be called inside a compute pass:
//
//     sg_apply_pipeline()
//     sg_apply_bindings()
//     sg_apply_uniforms()
//     sg_dispatch()
//
// The following functions are disallowed inside a compute pass
// and will cause validation layer errors:
//
//     sg_apply_viewport[f]()
//     sg_apply_scissor_rect[f]()
//     sg_draw()
//
// Only special 'compute shaders' and 'compute pipelines' can be used in
// compute passes. A compute shader only has a compute-function instead
// of a vertex- and fragment-function pair, and it doesn't accept vertex-
// and index-buffers as bindings, only storage-buffer-views (readable
// and writable), storage-image-views (read/write or writeonly) and
// texture-views (read-only).
//
// A compute pipeline is created by providing a compute shader object,
// setting the .compute creation parameter to true and not defining any
// 'render state':
//
//     sg_pipeline pip = sg_make_pipeline(&(sg_pipeline_desc){
//         .compute = true,
//         .shader = compute_shader,
//     });
//
// The sg_apply_bindings and sg_apply_uniforms calls are the same as in
// render passes, with the exception that no vertex- and index-buffers
// can be bound in the sg_apply_bindings call.
//
// Finally to kick off a compute workload, call sg_dispatch with the
// number of workgroups in the x, y and z-dimension:
//
//     sg_dispatch(int num_groups_x, int num_groups_y, int num_groups_z)
//
// Also see the following compute-shader samples:
//
//     - https://floooh.github.io/sokol-webgpu/instancing-compute-sapp.html
//     - https://floooh.github.io/sokol-webgpu/computeboids-sapp.html
//     - https://floooh.github.io/sokol-webgpu/imageblur-sapp.html
//
//
// ON SHADER CREATION
// ==================
// sokol-gfx doesn't come with an integrated shader cross-compiler, instead
// backend-specific shader sources or binary blobs need to be provided when
// creating a shader object, along with reflection information about the
// shader resource binding interface needed to bind sokol-gfx resources to the
// proper shader inputs.
//
// The easiest way to provide all this shader creation data is to use the
// sokol-shdc shader compiler tool to compile shaders from a common
// GLSL syntax into backend-specific sources or binary blobs, along with
// shader interface information and uniform blocks and storage buffer array items
// mapped to C structs.
//
// To create a shader using a C header which has been code-generated by sokol-shdc:
//
//     // include the C header code-generated by sokol-shdc:
//     #include "myshader.glsl.h"
//     ...
//
//     // create shader using a code-generated helper function from the C header:
//     sg_shader shd = sg_make_shader(myshader_shader_desc(sg_query_backend()));
//
// The samples in the 'sapp' subdirectory of the sokol-samples project
// also use the sokol-shdc approach:
//
//     https://github.com/floooh/sokol-samples/tree/master/sapp
//
// If you're planning to use sokol-shdc, you can stop reading here, instead
// continue with the sokol-shdc documentation:
//
//     https://github.com/floooh/sokol-tools/blob/master/docs/sokol-shdc.md
//
// To create shaders with backend-specific shader code or binary blobs,
// the sg_make_shader() function requires the following information:
//
// - Shader code or shader binary blobs for the vertex- and fragment-, or the
//   compute-shader-stage:
//     - for the desktop GL backend, source code can be provided in '#version 410' or
//       '#version 430', version 430 is required when using storage buffers and
//       compute shaders, but note that this is not available on macOS
//     - for the GLES3 backend, source code must be provided in '#version 300 es' or
//       '#version 310 es' syntax (version 310 is required for storage buffer and
//       compute shader support, but note that this is not supported on WebGL2)
//     - for the D3D11 backend, shaders can be provided as source or binary
//       blobs, the source code should be in HLSL4.0 (for compatibility with old
//       low-end GPUs) or preferably in HLSL5.0 syntax, note that when
//       shader source code is provided for the D3D11 backend, sokol-gfx will
//       dynamically load 'd3dcompiler_47.dll'
//     - for the Metal backends, shaders can be provided as source or binary blobs, the
//       MSL version should be in 'metal-1.1' (other versions may work but are not tested)
//     - for the WebGPU backend, shaders must be provided as WGSL source code
//     - optionally the following shader-code related attributes can be provided:
//         - an entry function name (only on D3D11 or Metal, but not OpenGL)
//         - on D3D11 only, a compilation target (default is "vs_4_0" and "ps_4_0")
//
// - Information about the input vertex attributes used by the vertex shader,
//   most of that backend-specific:
//     - An optional 'base type' (float, signed-/unsigned-int) for each vertex
//       attribute. When provided, this is used by the validation layer to check
//       that the CPU-side input vertex format is compatible with the input
//       vertex declaration of the vertex shader.
//     - Metal: no location information needed since vertex attributes are always bound
//       by their attribute location defined in the shader via '[[attribute(N)]]'
//     - WebGPU: no location information needed since vertex attributes are always
//       bound by their attribute location defined in the shader via `@location(N)`
//     - GLSL: vertex attribute names can be optionally provided, in that case their
//       location will be looked up by name, otherwise, the vertex attribute location
//       can be defined with 'layout(location = N)'
//     - D3D11: a 'semantic name' and 'semantic index' must be provided for each vertex
//       attribute, e.g. if the vertex attribute is defined as 'TEXCOORD1' in the shader,
//       the semantic name would be 'TEXCOORD', and the semantic index would be '1'
//
//   NOTE that vertex attributes currently must not have gaps. This requirement
//   may be relaxed in the future.
//
// - Specifically for Metal compute shaders, the 'number of threads per threadgroup'
//   must be provided. Normally this is extracted by sokol-shdc from the GLSL
//   shader source code. For instance the following statement in the input
//   GLSL:
//
//     layout(local_size_x=64, local_size_y=1, local_size_z=1) in;
//
//   ...will be communicated to the sokol-gfx Metal backend in the
//   code-generated sg_shader_desc struct:
//
//     (sg_shader_desc){
//         .mtl_threads_per_threadgroup = { .x = 64, .y = 1, .z = 1 },
//     }
//
// - Information about each uniform block binding used in the shader:
//     - the shader stage of the uniform block (vertex, fragment or compute)
//     - the size of the uniform block in number of bytes
//     - a memory layout hint (currently 'native' or 'std140') where 'native' defines a
//       backend-specific memory layout which shouldn't be used for cross-platform code.
//       Only std140 guarantees a backend-agnostic memory layout.
//     - a backend-specific bind slot:
//         - D3D11/HLSL: the buffer register N (`register(bN)`) where N is 0..7
//         - Metal/MSL: the buffer bind slot N (`[[buffer(N)]]`) where N is 0..7
//         - WebGPU: the binding N in `@group(0) @binding(N)` where N is 0..15
//     - For GLSL only: a description of the internal uniform block layout, which maps
//       member types and their offsets on the CPU side to uniform variable names
//       in the GLSL shader
//     - please also NOTE the documentation sections about UNIFORM DATA LAYOUT
//       and CROSS-BACKEND COMMON UNIFORM DATA LAYOUT below!
//
// - A description of each resource binding (texture-, storage-buffer-
//   and storage-image-bindings) which directly map to the sg_bindings.view[]
//   array slots.
//
//   Each resource binding slot comes in three flavours:
//
//     1. Texture bindings with the following properties:
//         - the shader stage of the texture (vertex, fragment or compute)
//         - the expected image type:
//             - SG_IMAGETYPE_2D
//             - SG_IMAGETYPE_CUBE
//             - SG_IMAGETYPE_3D
//             - SG_IMAGETYPE_ARRAY
//         - the expected 'image sample type':
//             - SG_IMAGESAMPLETYPE_FLOAT
//             - SG_IMAGESAMPLETYPE_DEPTH
//             - SG_IMAGESAMPLETYPE_SINT
//             - SG_IMAGESAMPLETYPE_UINT
//             - SG_IMAGESAMPLETYPE_UNFILTERABLE_FLOAT
//         - a flag whether the texture is expected to be multisampled
//         - a backend-specific bind slot:
//             - D3D11/HLSL: the texture register N (`register(tN)`) where N is 0..31
//             (in HLSL, readonly storage buffers and texture share the same bind space)
//             - Metal/MSL: the texture bind slot N (`[[texture(N)]]`) where N is 0..31
//             (the bind slot must not collide with storage image bindings on the same stage)
//             - WebGPU/WGSL: the binding N in `@group(0) @binding(N)` where N is 0..127
//
//     2. Storage buffer bindings with the following properties:
//         - the shader stage of the storage buffer
//         - a boolean 'readonly' flag, this is used for validation and hazard
//         tracking in some 3D backends. Note that in render passes, only
//         readonly storage buffer bindings are allowed. In compute passes, any
//         read/write storage buffer binding is assumed to be written to by the
//         compute shader.
//         - a backend-specific bind slot:
//             - D3D11/HLSL:
//                 - for readonly storage buffer bindings: the texture register N
//                 (`register(tN)`) where N is 0..31 (in HLSL, readonly storage
//                 buffers and textures share the same bind space for
//                 'shader resource views')
//                 - for read/write storage buffer buffer bindings: the UAV register N
//                 (`register(uN)`) where N is 0..31 (in HLSL, readwrite storage
//                 buffers use their own bind space for 'unordered access views')
//             - Metal/MSL: the buffer bind slot N (`[[buffer(N)]]`) where N is 8..23
//             - WebGPU/WGSL: the binding N in `@group(0) @binding(N)` where N is 0..127
//             - GL/GLSL: the buffer binding N in `layout(binding=N)`
//               where N is 0..sg_limits.max_storage_buffer_bindings_per_stage
//         - note that storage buffer bindings are not supported on all backends
//         and platforms
//
//     3. Storage image bindings with the following properties:
//         - the shader stage (*must* be compute)
//         - the expected image type:
//             - SG_IMAGETYPE_2D
//             - SG_IMAGETYPE_CUBE
//             - SG_IMAGETYPE_3D
//             - SG_IMAGETYPE_ARRAY
//         - the 'access pixel format', this is currently limited to:
//             - SG_PIXELFORMAT_RGBA8
//             - SG_PIXELFORMAT_RGBA8SN/UI/SI
//             - SG_PIXELFORMAT_RGBA16UI/SI/F
//             - SG_PIXELFORMAT_R32UIUI/SI/F
//             - SG_PIXELFORMAT_RG32UI/SI/F
//             - SG_PIXELFORMAT_RGBA32UI/SI/F
//         - the access type (readwrite or writeonly)
//         - a backend-specific bind slot:
//             - D3D11/HLSL: the UAV register N (`register(uN)` where N is 0..31, the
//             bind slot must not collide with UAV storage buffer bindings
//             - Metal/MSL: the texture bind slot N (`[[texture(N)]])` where N is 0..31,
//             the bind slot must not collide with other texture bindings on the same
//             stage
//             - WebGPU/WGSL: the binding N in `@group(1) @binding(N)` where N is 0..127
//             - GL/GLSL: the buffer binding N in `layout(binding=N)`
//               where N is 0.._sg.max_storage_image_bindings_per_stage
//         - note that storage image bindings are not supported on all backends and platforms
//
// - A description of each sampler used in the shader:
//     - the shader stage of the sampler (vertex, fragment or compute)
//     - the expected sampler type:
//         - SG_SAMPLERTYPE_FILTERING,
//         - SG_SAMPLERTYPE_NONFILTERING,
//         - SG_SAMPLERTYPE_COMPARISON,
//     - a backend-specific bind slot:
//         - D3D11/HLSL: the sampler register N (`register(sN)`) where N is 0..SG_MAX_SAMPLER_BINDINGS
//         - Metal/MSL: the sampler bind slot N (`[[sampler(N)]]`) where N is 0..SG_MAX_SAMPLER_BINDINGS
//         - WebGPU/WGSL: the binding N in `@group(0) @binding(N)` where N is 0..127
//
// - An array of 'texture-sampler-pairs' used by the shader to sample textures,
//   for D3D11, Metal and WebGPU this is used for validation purposes to check
//   whether the texture and sampler are compatible with each other (especially
//   WebGPU is very picky about combining the correct
//   texture-sample-type with the correct sampler-type). For GLSL an
//   additional 'combined-image-sampler name' must be provided because 'OpenGL
//   style GLSL' cannot handle separate texture and sampler objects, but still
//   groups them into a traditional GLSL 'sampler object'.
//
// Compatibility rules for image-sample-type vs sampler-type are as follows:
//
//     - SG_IMAGESAMPLETYPE_FLOAT => (SG_SAMPLERTYPE_FILTERING or SG_SAMPLERTYPE_NONFILTERING)
//     - SG_IMAGESAMPLETYPE_UNFILTERABLE_FLOAT => SG_SAMPLERTYPE_NONFILTERING
//     - SG_IMAGESAMPLETYPE_SINT => SG_SAMPLERTYPE_NONFILTERING
//     - SG_IMAGESAMPLETYPE_UINT => SG_SAMPLERTYPE_NONFILTERING
//     - SG_IMAGESAMPLETYPE_DEPTH => SG_SAMPLERTYPE_COMPARISON
//
// Backend-specific bindslot ranges (not relevant when using sokol-shdc):
//
//     - D3D11/HLSL:
//         - separate bindslot space per shader stage
//         - uniform block bindings (as cbuffer): `register(b0..b7)`
//         - texture- and readonly storage buffer bindings: `register(t0..t31)`
//         - read/write storage buffer and storage image bindings: `register(u0..u31)`
//         - samplers: `register(s0..s11)`
//     - Metal/MSL:
//         - separate bindslot space per shader stage
//         - uniform blocks: `[[buffer(0..7)]]`
//         - storage buffers: `[[buffer(8..23)]]`
//         - textures and storage image bindings: `[[texture(0..31)]]`
//         - samplers: `[[sampler(0..11)]]`
//     - WebGPU/WGSL:
//         - common bindslot space across shader stages
//         - uniform blocks: `@group(0) @binding(0..15)`
//         - textures, storage-images, storage-buffers and sampler: `@group(1) @binding(0..127)`
//     - GL/GLSL:
//         - uniforms and image-samplers are bound by name
//         - storage buffer bindings: `layout(std430, binding=0..sg_limits.max_storage_buffer_bindings_per_stage` (common
//           bindslot space across shader stages)
//         - storage image bindings: `layout(binding=0..sg_limits.max_storage_image_bindings_per_stage, [access_format])`
//
// For example code of how to create backend-specific shader objects,
// please refer to the following samples:
//
//     - for D3D11:    https://github.com/floooh/sokol-samples/tree/master/d3d11
//     - for Metal:    https://github.com/floooh/sokol-samples/tree/master/metal
//     - for OpenGL:   https://github.com/floooh/sokol-samples/tree/master/glfw
//     - for GLES3:    https://github.com/floooh/sokol-samples/tree/master/html5
//     - for WebGPU:   https://github.com/floooh/sokol-samples/tree/master/wgpu
//
//
// ON SG_IMAGESAMPLETYPE_UNFILTERABLE_FLOAT AND SG_SAMPLERTYPE_NONFILTERING
// ========================================================================
// The WebGPU backend introduces the concept of 'unfilterable-float' textures,
// which can only be combined with 'nonfiltering' samplers (this is a restriction
// specific to WebGPU, but since the same sokol-gfx code should work across
// all backend, the sokol-gfx validation layer also enforces this restriction
// - the alternative would be undefined behaviour in some backend APIs on
// some devices).
//
// The background is that some mobile devices (most notably iOS devices) can
// not perform linear filtering when sampling textures with certain pixel
// formats, most notable the 32F formats:
//
//     - SG_PIXELFORMAT_R32F
//     - SG_PIXELFORMAT_RG32F
//     - SG_PIXELFORMAT_RGBA32F
//
// The information of whether a shader is going to be used with such an
// unfilterable-float texture must already be provided in the sg_shader_desc
// struct when creating the shader (see the above section "ON SHADER CREATION").
//
// If you are using the sokol-shdc shader compiler, the information whether a
// texture/sampler binding expects an 'unfilterable-float/nonfiltering'
// texture/sampler combination cannot be inferred from the shader source
// alone, you'll need to provide this hint via annotation-tags. For instance
// here is an example from the ozz-skin-sapp.c sample shader which samples an
// RGBA32F texture with skinning matrices in the vertex shader:
//
// ```glsl
// @image_sample_type joint_tex unfilterable_float
// uniform texture2D joint_tex;
// @sampler_type smp nonfiltering
// uniform sampler smp;
// ```
//
// This will result in SG_IMAGESAMPLETYPE_UNFILTERABLE_FLOAT and
// SG_SAMPLERTYPE_NONFILTERING being written to the code-generated
// sg_shader_desc struct.
//
//
// ON VERTEX FORMATS
// =================
// Sokol-gfx implements the same strict mapping rules from CPU-side
// vertex component formats to GPU-side vertex input data types:
//
// - float and packed normalized CPU-side formats must be used as
//   floating point base type in the vertex shader
// - packed signed-integer CPU-side formats must be used as signed
//   integer base type in the vertex shader
// - packed unsigned-integer CPU-side formats must be used as unsigned
//   integer base type in the vertex shader
//
// These mapping rules are enforced by the sokol-gfx validation layer,
// but only when sufficient reflection information is provided in
// `sg_shader_desc.attrs[].base_type`. This is the case when sokol-shdc
// is used, otherwise the default base_type will be SG_SHADERATTRBASETYPE_UNDEFINED
// which causes the sokol-gfx validation check to be skipped (of course you
// can also provide the per-attribute base type information manually when
// not using sokol-shdc).
//
// The detailed mapping rules from SG_VERTEXFORMAT_* to GLSL data types
// are as follows:
//
// - FLOAT[*] => float, vec*
// - BYTE4N => vec* (scaled to -1.0 .. +1.0)
// - UBYTE4N => vec* (scaled to 0.0 .. +1.0)
// - SHORT[*]N => vec* (scaled to -1.0 .. +1.0)
// - USHORT[*]N => vec* (scaled to 0.0 .. +1.0)
// - INT[*] => int, ivec*
// - UINT[*] => uint, uvec*
// - BYTE4 => int*
// - UBYTE4 => uint*
// - SHORT[*] => int*
// - USHORT[*] => uint*
//
// NOTE that sokol-gfx only provides vertex formats with sizes of a multiple
// of 4 (e.g. BYTE4N but not BYTE2N). This is because vertex components must
// be 4-byte aligned anyway.
//
//
// UNIFORM DATA LAYOUT:
// ====================
// NOTE: if you use the sokol-shdc shader compiler tool, you don't need to worry
// about the following details.
//
// The data that's passed into the sg_apply_uniforms() function must adhere to
// specific layout rules so that the GPU shader finds the uniform block
// items at the right offset.
//
// For the D3D11 and Metal backends, sokol-gfx only cares about the size of uniform
// blocks, but not about the internal layout. The data will just be copied into
// a uniform/constant buffer in a single operation and it's up you to arrange the
// CPU-side layout so that it matches the GPU side layout. This also means that with
// the D3D11 and Metal backends you are not limited to a 'cross-platform' subset
// of uniform variable types.
//
// If you ever only use one of the D3D11, Metal *or* WebGPU backend, you can stop reading here.
//
// For the GL backends, the internal layout of uniform blocks matters though,
// and you are limited to a small number of uniform variable types. This is
// because sokol-gfx must be able to locate the uniform block members in order
// to upload them to the GPU with glUniformXXX() calls.
//
// To describe the uniform block layout to sokol-gfx, the following information
// must be passed to the sg_make_shader() call in the sg_shader_desc struct:
//
//     - a hint about the used packing rule (either SG_UNIFORMLAYOUT_NATIVE or
//       SG_UNIFORMLAYOUT_STD140)
//     - a list of the uniform block members types in the correct order they
//       appear on the CPU side
//
// For example if the GLSL shader has the following uniform declarations:
//
//     uniform mat4 mvp;
//     uniform vec2 offset0;
//     uniform vec2 offset1;
//     uniform vec2 offset2;
//
// ...and on the CPU side, there's a similar C struct:
//
//     typedef struct {
//         float mvp[16];
//         float offset0[2];
//         float offset1[2];
//         float offset2[2];
//     } params_t;
//
// ...the uniform block description in the sg_shader_desc must look like this:
//
//     sg_shader_desc desc = {
//         .vs.uniform_blocks[0] = {
//             .size = sizeof(params_t),
//             .layout = SG_UNIFORMLAYOUT_NATIVE,  // this is the default and can be omitted
//             .uniforms = {
//                 // order must be the same as in 'params_t':
//                 [0] = { .name = "mvp", .type = SG_UNIFORMTYPE_MAT4 },
//                 [1] = { .name = "offset0", .type = SG_UNIFORMTYPE_VEC2 },
//                 [2] = { .name = "offset1", .type = SG_UNIFORMTYPE_VEC2 },
//                 [3] = { .name = "offset2", .type = SG_UNIFORMTYPE_VEC2 },
//             }
//         }
//     };
//
// With this information sokol-gfx can now compute the correct offsets of the data items
// within the uniform block struct.
//
// The SG_UNIFORMLAYOUT_NATIVE packing rule works fine if only the GL backends are used,
// but for proper D3D11/Metal/GL a subset of the std140 layout must be used which is
// described in the next section:
//
//
// CROSS-BACKEND COMMON UNIFORM DATA LAYOUT
// ========================================
// For cross-platform / cross-3D-backend code it is important that the same uniform block
// layout on the CPU side can be used for all sokol-gfx backends. To achieve this,
// a common subset of the std140 layout must be used:
//
// - The uniform block layout hint in sg_shader_desc must be explicitly set to
//   SG_UNIFORMLAYOUT_STD140.
// - Only the following GLSL uniform types can be used (with their associated sokol-gfx enums):
//     - float => SG_UNIFORMTYPE_FLOAT
//     - vec2  => SG_UNIFORMTYPE_FLOAT2
//     - vec3  => SG_UNIFORMTYPE_FLOAT3
//     - vec4  => SG_UNIFORMTYPE_FLOAT4
//     - int   => SG_UNIFORMTYPE_INT
//     - ivec2 => SG_UNIFORMTYPE_INT2
//     - ivec3 => SG_UNIFORMTYPE_INT3
//     - ivec4 => SG_UNIFORMTYPE_INT4
//     - mat4  => SG_UNIFORMTYPE_MAT4
// - Alignment for those types must be as follows (in bytes):
//     - float => 4
//     - vec2  => 8
//     - vec3  => 16
//     - vec4  => 16
//     - int   => 4
//     - ivec2 => 8
//     - ivec3 => 16
//     - ivec4 => 16
//     - mat4  => 16
// - Arrays are only allowed for the following types: vec4, int4, mat4.
//
// Note that the HLSL cbuffer layout rules are slightly different from the
// std140 layout rules, this means that the cbuffer declarations in HLSL code
// must be tweaked so that the layout is compatible with std140.
//
// The by far easiest way to tackle the common uniform block layout problem is
// to use the sokol-shdc shader cross-compiler tool!
//
//
// ON STORAGE BUFFERS
// ==================
// The two main purpose of storage buffers are:
//
//     - to be populated by compute shaders with dynamically generated data
//     - for providing random-access data to all shader stages
//
// Storage buffers can be used to pass large amounts of random access structured
// data from the CPU side to the shaders. They are similar to data textures, but are
// more convenient to use both on the CPU and shader side since they can be accessed
// in shaders as as a 1-dimensional array of struct items.
//
// Storage buffers are *NOT* supported on the following platform/backend combos:
//
// - macOS+GL (because storage buffers require GL 4.3, while macOS only goes up to GL 4.1)
// - platforms which only support a GLES3.0 context (WebGL2 and iOS)
//
// To use storage buffers, the following steps are required:
//
//     - write a shader which uses storage buffers (vertex- and fragment-shaders
//       can only read from storage buffers, while compute-shaders can both read
//       and write storage buffers)
//     - create one or more storage buffers via sg_make_buffer() with the
//       `.usage.storage_buffer = true`
//     - when creating a shader via sg_make_shader(), populate the sg_shader_desc
//       struct with binding info (when using sokol-shdc, this step will be taken care
//       of automatically)
//         - which storage buffer bind slots on the vertex-, fragment- or compute-stage
//           are occupied
//         - whether the storage buffer on that bind slot is readonly (readonly
//           bindings are required for vertex- and fragment-shaders, and in compute
//           shaders the readonly flag is used to control hazard tracking in some
//           3D backends)
//
//     - when calling sg_apply_bindings(), apply the matching bind slots with the previously
//       created storage buffers
//     - ...and that's it.
//
// For more details, see the following backend-agnostic sokol samples:
//
// - simple vertex pulling from a storage buffer:
//     - C code: https://github.com/floooh/sokol-samples/blob/master/sapp/vertexpull-sapp.c
//     - shader: https://github.com/floooh/sokol-samples/blob/master/sapp/vertexpull-sapp.glsl
// - instanced rendering via storage buffers (vertex- and instance-pulling):
//     - C code: https://github.com/floooh/sokol-samples/blob/master/sapp/instancing-pull-sapp.c
//     - shader: https://github.com/floooh/sokol-samples/blob/master/sapp/instancing-pull-sapp.glsl
// - storage buffers both on the vertex- and fragment-stage:
//     - C code: https://github.com/floooh/sokol-samples/blob/master/sapp/sbuftex-sapp.c
//     - shader: https://github.com/floooh/sokol-samples/blob/master/sapp/sbuftex-sapp.glsl
// - the Ozz animation sample rewritten to pull all rendering data from storage buffers:
//     - C code: https://github.com/floooh/sokol-samples/blob/master/sapp/ozz-storagebuffer-sapp.cc
//     - shader: https://github.com/floooh/sokol-samples/blob/master/sapp/ozz-storagebuffer-sapp.glsl
// - the instancing sample modified to use compute shaders:
//     - C code: https://github.com/floooh/sokol-samples/blob/master/sapp/instancing-compute-sapp.c
//     - shader: https://github.com/floooh/sokol-samples/blob/master/sapp/instancing-compute-sapp.glsl
// - the Compute Boids sample ported to sokol-gfx:
//     - C code: https://github.com/floooh/sokol-samples/blob/master/sapp/computeboids-sapp.c
//     - shader: https://github.com/floooh/sokol-samples/blob/master/sapp/computeboids-sapp.glsl
//
// ...also see the following backend-specific vertex pulling samples (those also don't use sokol-shdc):
//
// - D3D11: https://github.com/floooh/sokol-samples/blob/master/d3d11/vertexpulling-d3d11.c
// - desktop GL: https://github.com/floooh/sokol-samples/blob/master/glfw/vertexpulling-glfw.c
// - Metal: https://github.com/floooh/sokol-samples/blob/master/metal/vertexpulling-metal.c
// - WebGPU: https://github.com/floooh/sokol-samples/blob/master/wgpu/vertexpulling-wgpu.c
//
// ...and the backend specific compute shader samples:
//
// - D3D11: https://github.com/floooh/sokol-samples/blob/master/d3d11/instancing-compute-d3d11.c
// - desktop GL: https://github.com/floooh/sokol-samples/blob/master/glfw/instancing-compute-glfw.c
// - Metal: https://github.com/floooh/sokol-samples/blob/master/metal/instancing-compute-metal.c
// - WebGPU: https://github.com/floooh/sokol-samples/blob/master/wgpu/instancing-compute-wgpu.c
//
// Storage buffer shader authoring caveats when using sokol-shdc:
//
//     - declare a read-only storage buffer interface block with `layout(binding=N) readonly buffer [name] { ... }`
//       (where 'N' is the index in `sg_bindings.storage_buffers[N]`)
//     - ...or a read/write storage buffer interface block with `layout(binding=N) buffer [name] { ... }`
//     - declare a struct which describes a single array item in the storage buffer interface block
//     - only put a single flexible array member into the storage buffer interface block
//
// E.g. a complete example in 'sokol-shdc GLSL':
//
//     ```glsl
//     @vs
//     // declare a struct:
//     struct sb_vertex {
//         vec3 pos;
//         vec4 color;
//     }
//     // declare a buffer interface block with a single flexible struct array:
//     layout(binding=0) readonly buffer vertices {
//         sb_vertex vtx[];
//     }
//     // in the shader function, access the storage buffer like this:
//     void main() {
//         vec3 pos = vtx[gl_VertexIndex].pos;
//         ...
//     }
//     @end
//     ```
//
// In a compute shader you can read and write the same item in the same
// storage buffer (but you'll have to be careful for random access since
// many threads of the same compute function run in parallel):
//
//     @cs
//     struct sb_item {
//         vec3 pos;
//         vec3 vel;
//     }
//     layout(binding=0) buffer items_ssbo {
//         sb_item items[];
//     }
//     layout(local_size_x=64, local_size_y=1, local_size_z=1) in;
//     void main() {
//         uint idx = gl_GlobalInvocationID.x;
//         vec3 pos = items[idx].pos;
//         ...
//         items[idx].pos = pos;
//     }
//     @end
//
// Backend-specific storage-buffer caveats (not relevant when using sokol-shdc):
//
//     D3D11:
//         - storage buffers are created as 'raw' Byte Address Buffers
//           (https://learn.microsoft.com/en-us/windows/win32/direct3d11/overviews-direct3d-11-resources-intro#raw-views-of-buffers)
//         - in HLSL, use a ByteAddressBuffer for readonly access of the buffer content:
//           (https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/sm5-object-byteaddressbuffer)
//         - ...or RWByteAddressBuffer for read/write access:
//           (https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/sm5-object-rwbyteaddressbuffer)
//         - readonly-storage buffers and textures are both bound as 'shader-resource-view' and
//           share the same bind slots (declared as `register(tN)` in HLSL), where N must be in the range 0..23)
//         - read/write storage buffers and storage images are bound as 'unordered-access-view'
//           (declared as `register(uN)` in HLSL where N is in the range 0..11)
//
//     Metal:
//         - in Metal there is no internal difference between vertex-, uniform- and
//           storage-buffers, all are bound to the same 'buffer bind slots' with the
//           following reserved ranges:
//             - vertex shader stage:
//                 - uniform buffers: slots 0..7
//                 - storage buffers: slots 8..15
//                 - vertex buffers: slots 15..23
//             - fragment shader stage:
//                 - uniform buffers: slots 0..7
//                 - storage buffers: slots 8..15
//         - this means in MSL, storage buffer bindings start at [[buffer(8)]] both in
//           the vertex and fragment stage
//
//     GL:
//         - the GL backend doesn't use name-lookup to find storage buffer bindings, this
//           means you must annotate buffers with `layout(std430, binding=N)` in GLSL
//         - ...where N is 0..sg_limits.max_storage_buffer_bindings_per_stage.
//
//     WebGPU:
//         - in WGSL, textures, samplers and storage buffers all use a shared
//           bindspace across all shader stages on bindgroup 1:
//
//           `@group(1) @binding(0..127)
//
// ON STORAGE IMAGES:
// ==================
// To write pixel data to texture objects in compute shaders, first an image
// object must be created with `storage_image usage`:
//
//     sg_image storage_image = sg_make_image(&(sg_image_desc){
//         .usage.storage_image = true,
//         },
//         .width = ...,
//         .height = ...,
//         .pixel_format = ...,
//     });
//
// Next a storage-image-view object is required which also allows to pick
// a specific mip-level or slice for the compute-shader to access:
//
//     sg_view simg_view = sg_make_view(&(sg_view_desc){
//         .storage_image = {
//             .image = storage_image,
//             .mip_level = ...,
//             .slice = ...
//         },
//     });
//
// Finally 'bind' the storage-image-view via a regular sg_apply_bindings() call
// inside a compute pass:
//
//     sg_begin_pass(&(sg_pass){ .compute = true });
//     sg_apply_pipeline(...);
//     sg_apply_bindings(&(sg_bindings){
//         .views[VIEW_simg] = simg_view,
//     });
//     sg_dispatch(...);
//     sg_end_pass();
//
// Currently, storage images can only be used with `readwrite` or `writeonly` access in
// shaders. For readonly access use a regular texture binding instead.
//
// For an example of using storage images in compute shaders see imageblur-sapp:
//
//     - C code: https://github.com/floooh/sokol-samples/blob/master/sapp/imageblur-sapp.c
//     - shader: https://github.com/floooh/sokol-samples/blob/master/sapp/imageblur-sapp.glsl
//
// TRACE HOOKS:
// ============
// sokol_gfx.h optionally allows to install "trace hook" callbacks for
// each public API functions. When a public API function is called, and
// a trace hook callback has been installed for this function, the
// callback will be invoked with the parameters and result of the function.
// This is useful for things like debugging- and profiling-tools, or
// keeping track of resource creation and destruction.
//
// To use the trace hook feature:
//
// --- Define SOKOL_TRACE_HOOKS before including the implementation.
//
// --- Setup an sg_trace_hooks structure with your callback function
//     pointers (keep all function pointers you're not interested
//     in zero-initialized), optionally set the user_data member
//     in the sg_trace_hooks struct.
//
// --- Install the trace hooks by calling sg_install_trace_hooks(),
//     the return value of this function is another sg_trace_hooks
//     struct which contains the previously set of trace hooks.
//     You should keep this struct around, and call those previous
//     functions pointers from your own trace callbacks for proper
//     chaining.
//
// As an example of how trace hooks are used, have a look at the
// imgui/sokol_gfx_imgui.h header which implements a realtime
// debugging UI for sokol_gfx.h on top of Dear ImGui.
//
//
// MEMORY ALLOCATION OVERRIDE
// ==========================
// You can override the memory allocation functions at initialization time
// like this:
//
//     void* my_alloc(size_t size, void* user_data) {
//         return malloc(size);
//     }
//
//     void my_free(void* ptr, void* user_data) {
//         free(ptr);
//     }
//
//     ...
//         sg_setup(&(sg_desc){
//             // ...
//             .allocator = {
//                 .alloc_fn = my_alloc,
//                 .free_fn = my_free,
//                 .user_data = ...,
//             }
//         });
//     ...
//
// If no overrides are provided, malloc and free will be used.
//
// This only affects memory allocation calls done by sokol_gfx.h
// itself though, not any allocations in OS libraries.
//
//
// ERROR REPORTING AND LOGGING
// ===========================
// To get any logging information at all you need to provide a logging callback in the setup call
// the easiest way is to use sokol_log.h:
//
//     #include "sokol_log.h"
//
//     sg_setup(&(sg_desc){ .logger.func = slog_func });
//
// To override logging with your own callback, first write a logging function like this:
//
//     void my_log(const char* tag,                // e.g. 'sg'
//                 uint32_t log_level,             // 0=panic, 1=error, 2=warn, 3=info
//                 uint32_t log_item_id,           // SG_LOGITEM_*
//                 const char* message_or_null,    // a message string, may be nullptr in release mode
//                 uint32_t line_nr,               // line number in sokol_gfx.h
//                 const char* filename_or_null,   // source filename, may be nullptr in release mode
//                 void* user_data)
//     {
//         ...
//     }
//
// ...and then setup sokol-gfx like this:
//
//     sg_setup(&(sg_desc){
//         .logger = {
//             .func = my_log,
//             .user_data = my_user_data,
//         }
//     });
//
// The provided logging function must be reentrant (e.g. be callable from
// different threads).
//
// If you don't want to provide your own custom logger it is highly recommended to use
// the standard logger in sokol_log.h instead, otherwise you won't see any warnings or
// errors.
//
//
// COMMIT LISTENERS
// ================
// It's possible to hook callback functions into sokol-gfx which are called from
// inside sg_commit() in unspecified order. This is mainly useful for libraries
// that build on top of sokol_gfx.h to be notified about the end/start of a frame.
//
// To add a commit listener, call:
//
//     static void my_commit_listener(void* user_data) {
//         ...
//     }
//
//     bool success = sg_add_commit_listener((sg_commit_listener){
//         .func = my_commit_listener,
//         .user_data = ...,
//     });
//
// The function returns false if the internal array of commit listeners is full,
// or the same commit listener had already been added.
//
// If the function returns true, my_commit_listener() will be called each frame
// from inside sg_commit().
//
// By default, 1024 distinct commit listeners can be added, but this number
// can be tweaked in the sg_setup() call:
//
//     sg_setup(&(sg_desc){
//         .max_commit_listeners = 2048,
//     });
//
// An sg_commit_listener item is equal to another if both the function
// pointer and user_data field are equal.
//
// To remove a commit listener:
//
//     bool success = sg_remove_commit_listener((sg_commit_listener){
//         .func = my_commit_listener,
//         .user_data = ...,
//     });
//
// ...where the .func and .user_data field are equal to a previous
// sg_add_commit_listener() call. The function returns true if the commit
// listener item was found and removed, and false otherwise.
//
//
// RESOURCE CREATION AND DESTRUCTION IN DETAIL
// ===========================================
// The 'vanilla' way to create resource objects is with the 'make functions':
//
//     sg_buffer sg_make_buffer(const sg_buffer_desc* desc)
//     sg_image sg_make_image(const sg_image_desc* desc)
//     sg_sampler sg_make_sampler(const sg_sampler_desc* desc)
//     sg_shader sg_make_shader(const sg_shader_desc* desc)
//     sg_pipeline sg_make_pipeline(const sg_pipeline_desc* desc)
//     sg_view sg_make_view(const sg_view_desc* desc)
//
// This will result in one of three cases:
//
//     1. The returned handle is invalid. This happens when there are no more
//        free slots in the resource pool for this resource type. An invalid
//        handle is associated with the INVALID resource state, for instance:
//
//             sg_buffer buf = sg_make_buffer(...)
//             if (sg_query_buffer_state(buf) == SG_RESOURCESTATE_INVALID) {
//                 // buffer pool is exhausted
//             }
//
//     2. The returned handle is valid, but creating the underlying resource
//        has failed for some reason. This results in a resource object in the
//        FAILED state. The reason *why* resource creation has failed differ
//        by resource type. Look for log messages with more details. A failed
//        resource state can be checked with:
//
//             sg_buffer buf = sg_make_buffer(...)
//             if (sg_query_buffer_state(buf) == SG_RESOURCESTATE_FAILED) {
//                 // creating the resource has failed
//             }
//
//     3. And finally, if everything goes right, the returned resource is
//        in resource state VALID and ready to use. This can be checked
//        with:
//
//             sg_buffer buf = sg_make_buffer(...)
//             if (sg_query_buffer_state(buf) == SG_RESOURCESTATE_VALID) {
//                 // creating the resource has failed
//             }
//
// When calling the 'make functions', the created resource goes through a number
// of states:
//
//     - INITIAL: the resource slot associated with the new resource is currently
//       free (technically, there is no resource yet, just an empty pool slot)
//     - ALLOC: a handle for the new resource has been allocated, this just means
//       a pool slot has been reserved.
//     - VALID or FAILED: in VALID state any 3D API backend resource objects have
//       been successfully created, otherwise if anything went wrong, the resource
//       will be in FAILED state.
//
// Sometimes it makes sense to first grab a handle, but initialize the
// underlying resource at a later time. For instance when loading data
// asynchronously from a slow data source, you may know what buffers and
// textures are needed at an early stage of the loading process, but actually
// loading the buffer or texture content can only be completed at a later time.
//
// For such situations, sokol-gfx resource objects can be created in two steps.
// You can allocate a handle upfront with one of the 'alloc functions':
//
//     sg_buffer sg_alloc_buffer(void)
//     sg_image sg_alloc_image(void)
//     sg_sampler sg_alloc_sampler(void)
//     sg_shader sg_alloc_shader(void)
//     sg_pipeline sg_alloc_pipeline(void)
//     sg_view sg_alloc_view(void)
//
// This will return a handle with the underlying resource object in the
// ALLOC state:
//
//     sg_image img = sg_alloc_image();
//     if (sg_query_image_state(img) == SG_RESOURCESTATE_ALLOC) {
//         // allocating an image handle has succeeded, otherwise
//         // the image pool is full
//     }
//
// Such an 'incomplete' handle can be used in most sokol-gfx rendering functions
// without doing any harm, sokol-gfx will simply skip any rendering operation
// that involve resources which are not in VALID state.
//
// At a later time (for instance once the texture has completed loading
// asynchronously), the resource creation can be completed by calling one of
// the 'init functions', those functions take an existing resource handle and
// 'desc struct':
//
//     void sg_init_buffer(sg_buffer buf, const sg_buffer_desc* desc)
//     void sg_init_image(sg_image img, const sg_image_desc* desc)
//     void sg_init_sampler(sg_sampler smp, const sg_sampler_desc* desc)
//     void sg_init_shader(sg_shader shd, const sg_shader_desc* desc)
//     void sg_init_pipeline(sg_pipeline pip, const sg_pipeline_desc* desc)
//     void sg_init_view(sg_view view, const sg_view_desc* desc)
//
// The init functions expect a resource in ALLOC state, and after the function
// returns, the resource will be either in VALID or FAILED state. Calling
// an 'alloc function' followed by the matching 'init function' is fully
// equivalent with calling the 'make function' alone.
//
// Destruction can also happen as a two-step process. The 'uninit functions'
// will put a resource object from the VALID or FAILED state back into the
// ALLOC state:
//
//     void sg_uninit_buffer(sg_buffer buf)
//     void sg_uninit_image(sg_image img)
//     void sg_uninit_sampler(sg_sampler smp)
//     void sg_uninit_shader(sg_shader shd)
//     void sg_uninit_pipeline(sg_pipeline pip)
//     void sg_uninit_view(sg_view view)
//
// Calling the 'uninit functions' with a resource that is not in the VALID or
// FAILED state is a no-op.
//
// To finally free the pool slot for recycling call the 'dealloc functions':
//
//     void sg_dealloc_buffer(sg_buffer buf)
//     void sg_dealloc_image(sg_image img)
//     void sg_dealloc_sampler(sg_sampler smp)
//     void sg_dealloc_shader(sg_shader shd)
//     void sg_dealloc_pipeline(sg_pipeline pip)
//     void sg_dealloc_view(sg_view view)
//
// Calling the 'dealloc functions' on a resource that's not in ALLOC state is
// a no-op, but will generate a warning log message.
//
// Calling an 'uninit function' and 'dealloc function' in sequence is equivalent
// with calling the associated 'destroy function':
//
//     void sg_destroy_buffer(sg_buffer buf)
//     void sg_destroy_image(sg_image img)
//     void sg_destroy_sampler(sg_sampler smp)
//     void sg_destroy_shader(sg_shader shd)
//     void sg_destroy_pipeline(sg_pipeline pip)
//     void sg_destroy_view(sg_view view)
//
// The 'destroy functions' can be called on resources in any state and generally
// do the right thing (for instance if the resource is in ALLOC state, the destroy
// function will be equivalent to the 'dealloc function' and skip the 'uninit part').
//
// And finally to close the circle, the 'fail functions' can be called to manually
// put a resource in ALLOC state into the FAILED state:
//
//     sg_fail_buffer(sg_buffer buf)
//     sg_fail_image(sg_image img)
//     sg_fail_sampler(sg_sampler smp)
//     sg_fail_shader(sg_shader shd)
//     sg_fail_pipeline(sg_pipeline pip)
//     sg_fail_view(sg_view view)
//
// This is recommended if anything went wrong outside of sokol-gfx during asynchronous
// resource setup (for instance a file loading operation failed). In this case,
// the 'fail function' should be called instead of the 'init function'.
//
// Calling a 'fail function' on a resource that's not in ALLOC state is a no-op,
// but will generate a warning log message.
//
// NOTE: that two-step resource creation usually only makes sense for buffers,
// images and views, but not for samplers, shaders or pipelines. Most notably, trying
// to create a pipeline object with a shader that's not in VALID state will
// trigger a validation layer error, or if the validation layer is disabled,
// result in a pipeline object in FAILED state.
//
//
// WEBGPU CAVEATS
// ==============
// For a general overview and design notes of the WebGPU backend see:
//
//     https://floooh.github.io/2023/10/16/sokol-webgpu.html
//
// In general, don't expect an automatic speedup when switching from the WebGL2
// backend to the WebGPU backend. Some WebGPU functions currently actually
// have a higher CPU overhead than similar WebGL2 functions, leading to the
// paradoxical situation that some WebGPU code may be slower than similar WebGL2
// code.
//
// - when writing WGSL shader code by hand, a specific bind-slot convention
//   must be used:
//
//   All uniform block structs must use `@group(0)` and bindings in the
//   range 0..15
//
//     @group(0) @binding(0..15)
//
//   All textures, samplers, storage-buffers and storage-images must use `@group(1)`
//   and bindings must be in the range 0..127:
//
//     @group(1) @binding(0..127)
//
//   Note that the number of texture, sampler, storage-buffer storage-image bindings
//   is still limited despite the large bind range:
//
//     - up to 16 textures and sampler across all shader stages
//     - up to 8 storage buffers across all shader stages
//     - up to 4 storage images on the compute shader stage
//
//   If you use sokol-shdc to generate WGSL shader code, you don't need to worry
//   about the above binding conventions since sokol-shdc will allocate
//   the WGSL bindslots).
//
// - The sokol-gfx WebGPU backend uses the sg_desc.uniform_buffer_size item
//   to allocate a single per-frame uniform buffer which must be big enough
//   to hold all data written by sg_apply_uniforms() during a single frame,
//   including a worst-case 256-byte alignment (e.g. each sg_apply_uniform
//   call will cost at least 256 bytes of uniform buffer size). The default size
//   is 4 MB, which is enough for 16384 sg_apply_uniform() calls per
//   frame (assuming the uniform data 'payload' is less than 256 bytes
//   per call). These rules are the same as for the Metal backend, so if
//   you are already using the Metal backend you'll be fine.
//
// - sg_apply_bindings(): the sokol-gfx WebGPU backend implements a bindgroup
//   cache to prevent excessive creation and destruction of BindGroup objects
//   when calling sg_apply_bindings(). The number of slots in the bindgroups
//   cache is defined in sg_desc.wgpu.bindgroups_cache_size when calling
//   sg_setup. The cache size must be a power-of-2 number, with the default being
//   1024. The bindgroups cache behaviour can be observed by calling the new
//   function sg_query_frame_stats(), where the following struct items are
//   of interest:
//
//     .wgpu.num_bindgroup_cache_hits
//     .wgpu.num_bindgroup_cache_misses
//     .wgpu.num_bindgroup_cache_collisions
//     .wgpu_num_bindgroup_cache_invalidates
//     .wgpu.num_bindgroup_cache_vs_hash_key_mismatch
//
//   The value to pay attention to is `.wgpu.num_bindgroup_cache_collisions`,
//   if this number is consistently higher than a few percent of the
//   .wgpu.num_set_bindgroup value, it might be a good idea to bump the
//   bindgroups cache size to the next power-of-2.
//
// - sg_apply_viewport(): WebGPU currently has a unique restriction that viewport
//   rectangles must be contained entirely within the framebuffer. As a shitty
//   workaround sokol_gfx.h will clip incoming viewport rectangles against
//   the framebuffer, but this will distort the clipspace-to-screenspace mapping.
//   There's no proper way to handle this inside sokol_gfx.h, this must be fixed
//   in a future WebGPU update (see: https://github.com/gpuweb/gpuweb/issues/373
//   and https://github.com/gpuweb/gpuweb/pull/5025)
//
// - The sokol shader compiler generally adds `diagnostic(off, derivative_uniformity);`
//   into the WGSL output. Currently only the Chrome WebGPU implementation seems
//   to recognize this.
//
// - Likewise, the following sokol-gfx pixel formats are not supported in WebGPU:
//   R16, R16SN, RG16, RG16SN, RGBA16, RGBA16SN.
//   Unlike unsupported vertex formats, unsupported pixel formats can be queried
//   in cross-backend code via sg_query_pixelformat() though.
//
// - The Emscripten WebGPU shim currently doesn't support the Closure minification
//   post-link-step (e.g. currently the emcc argument '--closure 1' or '--closure 2'
//   will generate broken Javascript code.
//
// - sokol-gfx requires the WebGPU device feature `depth32float-stencil8` to be enabled
//   (this should be widely supported)
//
// - sokol-gfx expects that the WebGPU device feature `float32-filterable` to *not* be
//   enabled (since this would exclude all iOS devices)
//
//
// LICENSE
// =======
// zlib/libpng license
//
// Copyright (c) 2018 Andre Weissflog
//
// This software is provided 'as-is', without any express or implied warranty.
// In no event will the authors be held liable for any damages arising from the
// use of this software.
//
// Permission is granted to anyone to use this software for any purpose,
// including commercial applications, and to alter it and redistribute it
// freely, subject to the following restrictions:
//
//     1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software in a
//     product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//
//     2. Altered source versions must be plainly marked as such, and must not
//     be misrepresented as being the original software.
//
//     3. This notice may not be removed or altered from any source
//     distribution.

const builtin = @import("builtin");

// helper function to convert a C string to a Zig string slice
fn cStrToZig(c_str: [*c]const u8) [:0]const u8 {
    return @import("std").mem.span(c_str);
}
// helper function to convert "anything" to a Range struct
pub fn asRange(val: anytype) Range {
    const type_info = @typeInfo(@TypeOf(val));
    switch (type_info) {
        .pointer => |pointer| {
            switch (pointer.size) {
                .one => switch (@typeInfo(pointer.child)) {
                    .array => |array| return .{ .ptr = val, .size = array.len * @sizeOf(array.child) },
                    else => return .{ .ptr = val, .size = @sizeOf(pointer.child) },
                },
                .slice => return .{ .ptr = val.ptr, .size = val.len * @sizeOf(pointer.child) },
                else => @compileError("FIXME: Pointer type!"),
            }
        },
        .@"struct", .array => {
            @compileError("Structs and arrays must be passed as pointers to asRange");
        },
        else => {
            @compileError("Cannot convert to Range!");
        },
    }
}

/// Resource id typedefs:
///
/// sg_buffer:      vertex- and index-buffers
/// sg_image:       images used as textures and render-pass attachments
/// sg_sampler      sampler objects describing how a texture is sampled in a shader
/// sg_shader:      vertex- and fragment-shaders and shader interface information
/// sg_pipeline:    associated shader and vertex-layouts, and render states
/// sg_view:        a resource view object used for bindings and render-pass attachments
///
/// Instead of pointers, resource creation functions return a 32-bit
/// handle which uniquely identifies the resource object.
///
/// The 32-bit resource id is split into a 16-bit pool index in the lower bits,
/// and a 16-bit 'generation counter' in the upper bits. The index allows fast
/// pool lookups, and combined with the generation-counter it allows to detect
/// 'dangling accesses' (trying to use an object which no longer exists, and
/// its pool slot has been reused for a new object)
///
/// The resource ids are wrapped into a strongly-typed struct so that
/// trying to pass an incompatible resource id is a compile error.
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

pub const View = extern struct {
    id: u32 = 0,
};

/// sg_range is a pointer-size-pair struct used to pass memory blobs into
/// sokol-gfx. When initialized from a value type (array or struct), you can
/// use the SG_RANGE() macro to build an sg_range struct. For functions which
/// take either a sg_range pointer, or a (C++) sg_range reference, use the
/// SG_RANGE_REF macro as a solution which compiles both in C and C++.
pub const Range = extern struct {
    ptr: ?*const anyopaque = null,
    size: usize = 0,
};

/// various compile-time constants in the public API
pub const invalid_id = 0;
pub const num_inflight_frames = 2;
pub const max_color_attachments = 8;
pub const max_uniformblock_members = 16;
pub const max_vertex_attributes = 16;
pub const max_mipmaps = 16;
pub const max_vertexbuffer_bindslots = 8;
pub const max_uniformblock_bindslots = 8;
pub const max_view_bindslots = 32;
pub const max_sampler_bindslots = 12;
pub const max_texture_sampler_pairs = 32;
pub const max_portable_color_attachments = 4;
pub const max_portable_texture_bindings_per_stage = 16;
pub const max_portable_storagebuffer_bindings_per_stage = 8;
pub const max_portable_storageimage_bindings_per_stage = 4;

/// sg_color
///
/// An RGBA color value.
pub const Color = extern struct {
    r: f32 = 0.0,
    g: f32 = 0.0,
    b: f32 = 0.0,
    a: f32 = 0.0,
};

/// sg_backend
///
/// The active 3D-API backend, use the function sg_query_backend()
/// to get the currently active backend.
pub const Backend = enum(i32) {
    GLCORE,
    GLES3,
    D3D11,
    METAL_IOS,
    METAL_MACOS,
    METAL_SIMULATOR,
    WGPU,
    VULKAN,
    DUMMY,
};

/// sg_pixel_format
///
/// sokol_gfx.h basically uses the same pixel formats as WebGPU, since these
/// are supported on most newer GPUs.
///
/// A pixelformat name consist of three parts:
///
///     - components (R, RG, RGB or RGBA)
///     - bit width per component (8, 16 or 32)
///     - component data type:
///         - unsigned normalized (no postfix)
///         - signed normalized (SN postfix)
///         - unsigned integer (UI postfix)
///         - signed integer (SI postfix)
///         - float (F postfix)
///
/// Not all pixel formats can be used for everything, call sg_query_pixelformat()
/// to inspect the capabilities of a given pixelformat. The function returns
/// an sg_pixelformat_info struct with the following members:
///
///     - sample: the pixelformat can be sampled as texture at least with
///               nearest filtering
///     - filter: the pixelformat can be sampled as texture with linear
///               filtering
///     - render: the pixelformat can be used as render-pass attachment
///     - blend:  blending is supported when used as render-pass attachment
///     - msaa:   multisample-antialiasing is supported when used
///               as render-pass attachment
///     - depth:  the pixelformat can be used for depth-stencil attachments
///     - compressed: this is a block-compressed format
///     - bytes_per_pixel: the numbers of bytes in a pixel (0 for compressed formats)
///
/// The default pixel format for texture images is SG_PIXELFORMAT_RGBA8.
///
/// The default pixel format for render target images is platform-dependent
/// and taken from the sg_environment struct passed into sg_setup(). Typically
/// the default formats are:
///
///     - for the Metal, D3D11 and WebGPU backends: SG_PIXELFORMAT_BGRA8
///     - for GL backends: SG_PIXELFORMAT_RGBA8
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
    ETC2_RGB8,
    ETC2_SRGB8,
    ETC2_RGB8A1,
    ETC2_RGBA8,
    ETC2_SRGB8A8,
    EAC_R11,
    EAC_R11SN,
    EAC_RG11,
    EAC_RG11SN,
    ASTC_4x4_RGBA,
    ASTC_4x4_SRGBA,
    NUM,
};

/// Runtime information about a pixel format, returned by sg_query_pixelformat().
pub const PixelformatInfo = extern struct {
    sample: bool = false,
    filter: bool = false,
    render: bool = false,
    blend: bool = false,
    msaa: bool = false,
    depth: bool = false,
    compressed: bool = false,
    read: bool = false,
    write: bool = false,
    bytes_per_pixel: i32 = 0,
};

/// Runtime information about available optional features, returned by sg_query_features()
pub const Features = extern struct {
    origin_top_left: bool = false,
    image_clamp_to_border: bool = false,
    mrt_independent_blend_state: bool = false,
    mrt_independent_write_mask: bool = false,
    compute: bool = false,
    msaa_texture_bindings: bool = false,
    separate_buffer_types: bool = false,
    draw_base_vertex: bool = false,
    draw_base_instance: bool = false,
    gl_texture_views: bool = false,
};

/// Runtime information about resource limits, returned by sg_query_limit()
pub const Limits = extern struct {
    max_image_size_2d: i32 = 0,
    max_image_size_cube: i32 = 0,
    max_image_size_3d: i32 = 0,
    max_image_size_array: i32 = 0,
    max_image_array_layers: i32 = 0,
    max_vertex_attrs: i32 = 0,
    max_color_attachments: i32 = 0,
    max_texture_bindings_per_stage: i32 = 0,
    max_storage_buffer_bindings_per_stage: i32 = 0,
    max_storage_image_bindings_per_stage: i32 = 0,
    gl_max_vertex_uniform_components: i32 = 0,
    gl_max_combined_texture_image_units: i32 = 0,
    d3d11_max_unordered_access_views: i32 = 0,
    vk_min_uniform_buffer_offset_alignment: i32 = 0,
};

/// sg_resource_state
///
/// The current state of a resource in its resource pool.
/// Resources start in the INITIAL state, which means the
/// pool slot is unoccupied and can be allocated. When a resource is
/// created, first an id is allocated, and the resource pool slot
/// is set to state ALLOC. After allocation, the resource is
/// initialized, which may result in the VALID or FAILED state. The
/// reason why allocation and initialization are separate is because
/// some resource types (e.g. buffers and images) might be asynchronously
/// initialized by the user application. If a resource which is not
/// in the VALID state is attempted to be used for rendering, rendering
/// operations will silently be dropped.
///
/// The special INVALID state is returned in sg_query_xxx_state() if no
/// resource object exists for the provided resource id.
pub const ResourceState = enum(i32) {
    INITIAL,
    ALLOC,
    VALID,
    FAILED,
    INVALID,
};

/// sg_index_type
///
/// Indicates whether indexed rendering (fetching vertex-indices from an
/// index buffer) is used, and if yes, the index data type (16- or 32-bits).
///
/// This is used in the sg_pipeline_desc.index_type member when creating a
/// pipeline object.
///
/// The default index type is SG_INDEXTYPE_NONE.
pub const IndexType = enum(i32) {
    DEFAULT,
    NONE,
    UINT16,
    UINT32,
    NUM,
};

/// sg_image_type
///
/// Indicates the basic type of an image object (2D-texture, cubemap,
/// 3D-texture or 2D-array-texture). Used in the sg_image_desc.type member when
/// creating an image, and in sg_shader_image_desc to describe a sampled texture
/// in the shader (both must match and will be checked in the validation layer
/// when calling sg_apply_bindings).
///
/// The default image type when creating an image is SG_IMAGETYPE_2D.
pub const ImageType = enum(i32) {
    DEFAULT,
    _2D,
    CUBE,
    _3D,
    ARRAY,
    NUM,
};

/// sg_image_sample_type
///
/// The basic data type of a texture sample as expected by a shader.
/// Must be provided in sg_shader_image and used by the validation
/// layer in sg_apply_bindings() to check if the provided image object
/// is compatible with what the shader expects. Apart from the sokol-gfx
/// validation layer, WebGPU is the only backend API which actually requires
/// matching texture and sampler type to be provided upfront for validation
/// (other 3D APIs treat texture/sampler type mismatches as undefined behaviour).
///
/// NOTE that the following texture pixel formats require the use
/// of SG_IMAGESAMPLETYPE_UNFILTERABLE_FLOAT, combined with a sampler
/// of type SG_SAMPLERTYPE_NONFILTERING:
///
/// - SG_PIXELFORMAT_R32F
/// - SG_PIXELFORMAT_RG32F
/// - SG_PIXELFORMAT_RGBA32F
///
/// (when using sokol-shdc, also check out the meta tags `@image_sample_type`
/// and `@sampler_type`)
pub const ImageSampleType = enum(i32) {
    DEFAULT,
    FLOAT,
    DEPTH,
    SINT,
    UINT,
    UNFILTERABLE_FLOAT,
    NUM,
};

/// sg_sampler_type
///
/// The basic type of a texture sampler (sampling vs comparison) as
/// defined in a shader. Must be provided in sg_shader_sampler_desc.
///
/// sg_image_sample_type and sg_sampler_type for a texture/sampler
/// pair must be compatible with each other, specifically only
/// the following pairs are allowed:
///
/// - SG_IMAGESAMPLETYPE_FLOAT => (SG_SAMPLERTYPE_FILTERING or SG_SAMPLERTYPE_NONFILTERING)
/// - SG_IMAGESAMPLETYPE_UNFILTERABLE_FLOAT => SG_SAMPLERTYPE_NONFILTERING
/// - SG_IMAGESAMPLETYPE_SINT => SG_SAMPLERTYPE_NONFILTERING
/// - SG_IMAGESAMPLETYPE_UINT => SG_SAMPLERTYPE_NONFILTERING
/// - SG_IMAGESAMPLETYPE_DEPTH => SG_SAMPLERTYPE_COMPARISON
pub const SamplerType = enum(i32) {
    DEFAULT,
    FILTERING,
    NONFILTERING,
    COMPARISON,
    NUM,
};

/// sg_primitive_type
///
/// This is the common subset of 3D primitive types supported across all 3D
/// APIs. This is used in the sg_pipeline_desc.primitive_type member when
/// creating a pipeline object.
///
/// The default primitive type is SG_PRIMITIVETYPE_TRIANGLES.
pub const PrimitiveType = enum(i32) {
    DEFAULT,
    POINTS,
    LINES,
    LINE_STRIP,
    TRIANGLES,
    TRIANGLE_STRIP,
    NUM,
};

/// sg_filter
///
/// The filtering mode when sampling a texture image. This is
/// used in the sg_sampler_desc.min_filter, sg_sampler_desc.mag_filter
/// and sg_sampler_desc.mipmap_filter members when creating a sampler object.
///
/// For the default is SG_FILTER_NEAREST.
pub const Filter = enum(i32) {
    DEFAULT,
    NEAREST,
    LINEAR,
    NUM,
};

/// sg_wrap
///
/// The texture coordinates wrapping mode when sampling a texture
/// image. This is used in the sg_image_desc.wrap_u, .wrap_v
/// and .wrap_w members when creating an image.
///
/// The default wrap mode is SG_WRAP_REPEAT.
///
/// NOTE: SG_WRAP_CLAMP_TO_BORDER is not supported on all backends
/// and platforms. To check for support, call sg_query_features()
/// and check the "clamp_to_border" boolean in the returned
/// sg_features struct.
///
/// Platforms which don't support SG_WRAP_CLAMP_TO_BORDER will silently fall back
/// to SG_WRAP_CLAMP_TO_EDGE without a validation error.
pub const Wrap = enum(i32) {
    DEFAULT,
    REPEAT,
    CLAMP_TO_EDGE,
    CLAMP_TO_BORDER,
    MIRRORED_REPEAT,
    NUM,
};

/// sg_border_color
///
/// The border color to use when sampling a texture, and the UV wrap
/// mode is SG_WRAP_CLAMP_TO_BORDER.
///
/// The default border color is SG_BORDERCOLOR_OPAQUE_BLACK
pub const BorderColor = enum(i32) {
    DEFAULT,
    TRANSPARENT_BLACK,
    OPAQUE_BLACK,
    OPAQUE_WHITE,
    NUM,
};

/// sg_vertex_format
///
/// The data type of a vertex component. This is used to describe
/// the layout of input vertex data when creating a pipeline object.
///
/// NOTE that specific mapping rules exist from the CPU-side vertex
/// formats to the vertex attribute base type in the vertex shader code
/// (see doc header section 'ON VERTEX FORMATS').
pub const VertexFormat = enum(i32) {
    INVALID,
    FLOAT,
    FLOAT2,
    FLOAT3,
    FLOAT4,
    INT,
    INT2,
    INT3,
    INT4,
    UINT,
    UINT2,
    UINT3,
    UINT4,
    BYTE4,
    BYTE4N,
    UBYTE4,
    UBYTE4N,
    SHORT2,
    SHORT2N,
    USHORT2,
    USHORT2N,
    SHORT4,
    SHORT4N,
    USHORT4,
    USHORT4N,
    UINT10_N2,
    HALF2,
    HALF4,
    NUM,
};

/// sg_vertex_step
///
/// Defines whether the input pointer of a vertex input stream is advanced
/// 'per vertex' or 'per instance'. The default step-func is
/// SG_VERTEXSTEP_PER_VERTEX. SG_VERTEXSTEP_PER_INSTANCE is used with
/// instanced-rendering.
///
/// The vertex-step is part of the vertex-layout definition
/// when creating pipeline objects.
pub const VertexStep = enum(i32) {
    DEFAULT,
    PER_VERTEX,
    PER_INSTANCE,
    NUM,
};

/// sg_uniform_type
///
/// The data type of a uniform block member. This is used to
/// describe the internal layout of uniform blocks when creating
/// a shader object. This is only required for the GL backend, all
/// other backends will ignore the interior layout of uniform blocks.
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

/// sg_uniform_layout
///
/// A hint for the interior memory layout of uniform blocks. This is
/// only relevant for the GL backend where the internal layout
/// of uniform blocks must be known to sokol-gfx. For all other backends the
/// internal memory layout of uniform blocks doesn't matter, sokol-gfx
/// will just pass uniform data as an opaque memory blob to the
/// 3D backend.
///
/// SG_UNIFORMLAYOUT_NATIVE (default)
///     Native layout means that a 'backend-native' memory layout
///     is used. For the GL backend this means that uniforms
///     are packed tightly in memory (e.g. there are no padding
///     bytes).
///
/// SG_UNIFORMLAYOUT_STD140
///     The memory layout is a subset of std140. Arrays are only
///     allowed for the FLOAT4, INT4 and MAT4. Alignment is as
///     is as follows:
///
///         FLOAT, INT:         4 byte alignment
///         FLOAT2, INT2:       8 byte alignment
///         FLOAT3, INT3:       16 byte alignment(!)
///         FLOAT4, INT4:       16 byte alignment
///         MAT4:               16 byte alignment
///         FLOAT4[], INT4[]:   16 byte alignment
///
///     The overall size of the uniform block must be a multiple
///     of 16.
///
/// For more information search for 'UNIFORM DATA LAYOUT' in the documentation block
/// at the start of the header.
pub const UniformLayout = enum(i32) {
    DEFAULT,
    NATIVE,
    STD140,
    NUM,
};

/// sg_cull_mode
///
/// The face-culling mode, this is used in the
/// sg_pipeline_desc.cull_mode member when creating a
/// pipeline object.
///
/// The default cull mode is SG_CULLMODE_NONE
pub const CullMode = enum(i32) {
    DEFAULT,
    NONE,
    FRONT,
    BACK,
    NUM,
};

/// sg_face_winding
///
/// The vertex-winding rule that determines a front-facing primitive. This
/// is used in the member sg_pipeline_desc.face_winding
/// when creating a pipeline object.
///
/// The default winding is SG_FACEWINDING_CW (clockwise)
pub const FaceWinding = enum(i32) {
    DEFAULT,
    CCW,
    CW,
    NUM,
};

/// sg_compare_func
///
/// The compare-function for configuring depth- and stencil-ref tests
/// in pipeline objects, and for texture samplers which perform a comparison
/// instead of regular sampling operation.
///
/// Used in the following structs:
///
/// sg_pipeline_desc
///     .depth
///         .compare
///     .stencil
///         .front.compare
///         .back.compare
///
/// sg_sampler_desc
///     .compare
///
/// The default compare func for depth- and stencil-tests is
/// SG_COMPAREFUNC_ALWAYS.
///
/// The default compare func for samplers is SG_COMPAREFUNC_NEVER.
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

/// sg_stencil_op
///
/// The operation performed on a currently stored stencil-value when a
/// comparison test passes or fails. This is used when creating a pipeline
/// object in the following sg_pipeline_desc struct items:
///
/// sg_pipeline_desc
///     .stencil
///         .front
///             .fail_op
///             .depth_fail_op
///             .pass_op
///         .back
///             .fail_op
///             .depth_fail_op
///             .pass_op
///
/// The default value is SG_STENCILOP_KEEP.
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

/// sg_blend_factor
///
/// The source and destination factors in blending operations.
/// This is used in the following members when creating a pipeline object:
///
/// sg_pipeline_desc
///     .colors[i]
///         .blend
///             .src_factor_rgb
///             .dst_factor_rgb
///             .src_factor_alpha
///             .dst_factor_alpha
///
/// The default value is SG_BLENDFACTOR_ONE for source
/// factors, and for the destination SG_BLENDFACTOR_ZERO if the associated
/// blend-op is ADD, SUBTRACT or REVERSE_SUBTRACT or SG_BLENDFACTOR_ONE
/// if the associated blend-op is MIN or MAX.
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

/// sg_blend_op
///
/// Describes how the source and destination values are combined in the
/// fragment blending operation. It is used in the following struct items
/// when creating a pipeline object:
///
/// sg_pipeline_desc
///     .colors[i]
///         .blend
///             .op_rgb
///             .op_alpha
///
/// The default value is SG_BLENDOP_ADD.
pub const BlendOp = enum(i32) {
    DEFAULT,
    ADD,
    SUBTRACT,
    REVERSE_SUBTRACT,
    MIN,
    MAX,
    NUM,
};

/// sg_color_mask
///
/// Selects the active color channels when writing a fragment color to the
/// framebuffer. This is used in the members
/// sg_pipeline_desc.colors[i].write_mask when creating a pipeline object.
///
/// The default colormask is SG_COLORMASK_RGBA (write all colors channels)
///
/// NOTE: since the color mask value 0 is reserved for the default value
/// (SG_COLORMASK_RGBA), use SG_COLORMASK_NONE if all color channels
/// should be disabled.
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

/// sg_load_action
///
/// Defines the load action that should be performed at the start of a render pass:
///
/// SG_LOADACTION_CLEAR:        clear the render target
/// SG_LOADACTION_LOAD:         load the previous content of the render target
/// SG_LOADACTION_DONTCARE:     leave the render target in an undefined state
///
/// This is used in the sg_pass_action structure.
///
/// The default load action for all pass attachments is SG_LOADACTION_CLEAR,
/// with the values rgba = { 0.5f, 0.5f, 0.5f, 1.0f }, depth=1.0f and stencil=0.
///
/// If you want to override the default behaviour, it is important to not
/// only set the clear color, but the 'action' field as well (as long as this
/// is _SG_LOADACTION_DEFAULT, the value fields will be ignored).
pub const LoadAction = enum(i32) {
    DEFAULT,
    CLEAR,
    LOAD,
    DONTCARE,
};

/// sg_store_action
///
/// Defines the store action that should be performed at the end of a render pass:
///
/// SG_STOREACTION_STORE:       store the rendered content to the color attachment image
/// SG_STOREACTION_DONTCARE:    allows the GPU to discard the rendered content
pub const StoreAction = enum(i32) {
    DEFAULT,
    STORE,
    DONTCARE,
};

/// sg_pass_action
///
/// The sg_pass_action struct defines the actions to be performed
/// at the start and end of a render pass.
///
/// - at the start of the pass: whether the render attachments should be cleared,
///   loaded with their previous content, or start in an undefined state
/// - for clear operations: the clear value (color, depth, or stencil values)
/// - at the end of the pass: whether the rendering result should be
///   stored back into the render attachment or discarded
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
    colors: [8]ColorAttachmentAction = [_]ColorAttachmentAction{.{}} ** 8,
    depth: DepthAttachmentAction = .{},
    stencil: StencilAttachmentAction = .{},
};

/// sg_swapchain
///
/// Used in sg_begin_pass() to provide details about an external swapchain
/// (pixel formats, sample count and backend-API specific render surface objects).
///
/// The following information must be provided:
///
/// - the width and height of the swapchain surfaces in number of pixels,
/// - the pixel format of the render- and optional msaa-resolve-surface
/// - the pixel format of the optional depth- or depth-stencil-surface
/// - the MSAA sample count for the render and depth-stencil surface
///
/// If the pixel formats and MSAA sample counts are left zero-initialized,
/// their defaults are taken from the sg_environment struct provided in the
/// sg_setup() call.
///
/// The width and height *must* be > 0.
///
/// Additionally the following backend API specific objects must be passed in
/// as 'type erased' void pointers:
///
/// GL:
///     - on all GL backends, a GL framebuffer object must be provided. This
///       can be zero for the default framebuffer.
///
/// D3D11:
///     - an ID3D11RenderTargetView for the rendering surface, without
///       MSAA rendering this surface will also be displayed
///     - an optional ID3D11DepthStencilView for the depth- or depth/stencil
///       buffer surface
///     - when MSAA rendering is used, another ID3D11RenderTargetView
///       which serves as MSAA resolve target and will be displayed
///
/// WebGPU (same as D3D11, except different types)
///     - a WGPUTextureView for the rendering surface, without
///       MSAA rendering this surface will also be displayed
///     - an optional WGPUTextureView for the depth- or depth/stencil
///       buffer surface
///     - when MSAA rendering is used, another WGPUTextureView
///       which serves as MSAA resolve target and will be displayed
///
/// Metal (NOTE that the roles of provided surfaces is slightly different
/// than on D3D11 or WebGPU in case of MSAA vs non-MSAA rendering):
///
///     - A current CAMetalDrawable (NOT an MTLDrawable!) which will be presented.
///       This will either be rendered to directly (if no MSAA is used), or serve
///       as MSAA-resolve target.
///     - an optional MTLTexture for the depth- or depth-stencil buffer
///     - an optional multisampled MTLTexture which serves as intermediate
///       rendering surface which will then be resolved into the
///       CAMetalDrawable.
///
/// NOTE that for Metal you must use an ObjC __bridge cast to
/// properly tunnel the ObjC object id through a C void*, e.g.:
///
///     swapchain.metal.current_drawable = (__bridge const void*) [mtkView currentDrawable];
///
/// On all other backends you shouldn't need to mess with the reference count.
///
/// It's a good practice to write a helper function which returns an initialized
/// sg_swapchain struct, which can then be plugged directly into
/// sg_pass.swapchain. Look at the function sglue_swapchain() in the sokol_glue.h
/// as an example.
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

pub const VulkanSwapchain = extern struct {
    render_image: ?*const anyopaque = null,
    render_view: ?*const anyopaque = null,
    resolve_image: ?*const anyopaque = null,
    resolve_view: ?*const anyopaque = null,
    depth_stencil_image: ?*const anyopaque = null,
    depth_stencil_view: ?*const anyopaque = null,
    render_finished_semaphore: ?*const anyopaque = null,
    present_complete_semaphore: ?*const anyopaque = null,
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
    vulkan: VulkanSwapchain = .{},
    gl: GlSwapchain = .{},
};

/// sg_attachments
///
/// Used in sg_pass to provide render pass attachment views. Each
/// type of pass attachment has it corresponding view type:
///
/// sg_attachments.colors[]:
///     populate with color-attachment views, e.g.:
///
///     sg_make_view(&(sg_view_desc){
///         .color_attachment = { ... },
///     });
///
/// sg_attachments.resolves[]:
///     populate with resolve-attachment views, e.g.:
///
///     sg_make_view(&(sg_view_desc){
///         .resolve_attachment = { ... },
///     });
///
/// sg_attachments.depth_stencil:
///     populate with depth-stencil-attachment views, e.g.:
///
///     sg_make_view(&(sg_view_desc){
///         .depth_stencil_attachment = { ... },
///     });
pub const Attachments = extern struct {
    colors: [8]View = [_]View{.{}} ** 8,
    resolves: [8]View = [_]View{.{}} ** 8,
    depth_stencil: View = .{},
};

/// sg_pass
///
/// The sg_pass structure is passed as argument into the sg_begin_pass()
/// function.
///
/// For a swapchain render pass, provide an sg_pass_action and sg_swapchain
/// struct (for instance via the sglue_swapchain() helper function from
/// sokol_glue.h):
///
///     sg_begin_pass(&(sg_pass){
///         .action = { ... },
///         .swapchain = sglue_swapchain(),
///     });
///
/// For an offscreen render pass, provide an sg_pass_action struct with
/// attachment view objects:
///
///     sg_begin_pass(&(sg_pass){
///         .action = { ... },
///         .attachments = {
///             .colors = { ... },
///             .resolves = { ... },
///             .depth_stencil = ...,
///         },
///     });
///
/// You can also omit the .action object to get default pass action behaviour
/// (clear to color=grey, depth=1 and stencil=0).
///
/// For a compute pass, just set the sg_pass.compute boolean to true:
///
///     sg_begin_pass(&(sg_pass){ .compute = true });
pub const Pass = extern struct {
    _start_canary: u32 = 0,
    compute: bool = false,
    action: PassAction = .{},
    attachments: Attachments = .{},
    swapchain: Swapchain = .{},
    label: [*c]const u8 = null,
    _end_canary: u32 = 0,
};

/// sg_bindings
///
/// The sg_bindings structure defines the resource bindings for
/// the next draw call.
///
/// To update the resource bindings, call sg_apply_bindings() with
/// a pointer to a populated sg_bindings struct. Note that
/// sg_apply_bindings() must be called after sg_apply_pipeline()
/// and that bindings are not preserved across sg_apply_pipeline()
/// calls, even when the new pipeline uses the same 'bindings layout'.
///
/// A resource binding struct contains:
///
/// - 1..N vertex buffers
/// - 1..N vertex buffer offsets
/// - 0..1 index buffer
/// - 0..1 index buffer offset
/// - 0..N resource views (texture-, storage-image, storage-buffer-views)
/// - 0..N samplers
///
/// Where 'N' is defined in the following constants:
///
/// - SG_MAX_VERTEXBUFFER_BINDSLOTS
/// - SG_MAX_VIEW_BINDSLOTS
/// - SG_MAX_SAMPLER_BINDSLOTS
///
/// Note that inside compute passes vertex- and index-buffer-bindings are
/// disallowed.
///
/// When using sokol-shdc for shader authoring, the `layout(binding=N)`
/// for texture-, storage-image- and storage-buffer-bindings directly
/// maps to the views-array index, for instance the following vertex-
/// and fragment-shader interface for sokol-shdc:
///
///     @vs vs
///     layout(binding=0) uniform vs_params { ... };
///     layout(binding=0) readonly buffer ssbo { ... };
///     layout(binding=1) uniform texture2D vs_tex;
///     layout(binding=0) uniform sampler vs_smp;
///     ...
///     @end
///
///     @fs fs
///     layout(binding=1) uniform fs_params { ... };
///     layout(binding=2) uniform texture2D fs_tex;
///     layout(binding=1) uniform sampler fs_smp;
///     ...
///     @end
///
/// ...would map to the following sg_bindings struct:
///
///     const sg_bindings bnd = {
///         .vertex_buffers[0] = ...,
///         .views[0] = ssbo_view,
///         .views[1] = vs_tex_view,
///         .views[2] = fs_tex_view,
///         .samplers[0] = vs_smp,
///         .samplers[1] = fs_smp,
///     };
///
/// ...alternatively you can use code-generated slot indices:
///
///     const sg_bindings bnd = {
///         .vertex_buffers[0] = ...,
///         .views[VIEW_ssbo] = ssbo_view,
///         .views[VIEW_vs_tex] = vs_tex_view,
///         .views[VIEW_fs_tex] = fs_tex_view,
///         .samplers[SMP_vs_smp] = vs_smp,
///         .samplers[SMP_fs_smp] = fs_smp,
///     };
///
/// Resource bindslots for a specific shader/pipeline may have gaps, and an
/// sg_bindings struct may have populated bind slots which are not used by a
/// specific shader. This allows to use the same sg_bindings struct across
/// different shader variants.
///
/// When not using sokol-shdc, the bindslot indices in the sg_bindings
/// struct need to match the per-binding reflection info slot indices
/// in the sg_shader_desc struct (for details about that see the
/// sg_shader_desc struct documentation).
///
/// The optional buffer offsets can be used to put different unrelated
/// chunks of vertex- and/or index-data into the same buffer objects.
pub const Bindings = extern struct {
    _start_canary: u32 = 0,
    vertex_buffers: [8]Buffer = [_]Buffer{.{}} ** 8,
    vertex_buffer_offsets: [8]i32 = [_]i32{0} ** 8,
    index_buffer: Buffer = .{},
    index_buffer_offset: i32 = 0,
    views: [32]View = [_]View{.{}} ** 32,
    samplers: [12]Sampler = [_]Sampler{.{}} ** 12,
    _end_canary: u32 = 0,
};

/// sg_buffer_usage
///
/// Describes how a buffer object is going to be used:
///
/// .vertex_buffer (default: true)
///     the buffer will be bound as vertex buffer via sg_bindings.vertex_buffers[]
/// .index_buffer (default: false)
///     the buffer will be bound as index buffer via sg_bindings.index_buffer
/// .storage_buffer (default: false)
///     the buffer will be bound as storage buffer via storage-buffer-view
///     in sg_bindings.views[]
/// .immutable (default: true)
///     the buffer content will never be updated from the CPU side (but
///     may be written to by a compute shader)
/// .dynamic_update (default: false)
///     the buffer content will be infrequently updated from the CPU side
/// .stream_upate (default: false)
///     the buffer content will be updated each frame from the CPU side
pub const BufferUsage = extern struct {
    vertex_buffer: bool = false,
    index_buffer: bool = false,
    storage_buffer: bool = false,
    immutable: bool = false,
    dynamic_update: bool = false,
    stream_update: bool = false,
};

/// sg_buffer_desc
///
/// Creation parameters for sg_buffer objects, used in the sg_make_buffer() call.
///
/// The default configuration is:
///
/// .size:      0       (*must* be >0 for buffers without data)
/// .usage      { .vertex_buffer = true, .immutable = true }
/// .data.ptr   0       (*must* be valid for immutable buffers without storage buffer usage)
/// .data.size  0       (*must* be > 0 for immutable buffers without storage buffer usage)
/// .label      0       (optional string label)
///
/// For immutable buffers which are initialized with initial data,
/// keep the .size item zero-initialized, and set the size together with the
/// pointer to the initial data in the .data item.
///
/// For immutable or mutable buffers without initial data, keep the .data item
/// zero-initialized, and set the buffer size in the .size item instead.
///
/// You can also set both size values, but currently both size values must
/// be identical (this may change in the future when the dynamic resource
/// management may become more flexible).
///
/// NOTE: Immutable buffers without storage-buffer-usage *must* be created
/// with initial content, this restriction doesn't apply to storage buffer usage,
/// because storage buffers may also get their initial content by running
/// a compute shader on them.
///
/// NOTE: Buffers without initial data will have undefined content, e.g.
/// do *not* expect the buffer to be zero-initialized!
///
/// ADVANCED TOPIC: Injecting native 3D-API buffers:
///
/// The following struct members allow to inject your own GL, Metal
/// or D3D11 buffers into sokol_gfx:
///
/// .gl_buffers[SG_NUM_INFLIGHT_FRAMES]
/// .mtl_buffers[SG_NUM_INFLIGHT_FRAMES]
/// .d3d11_buffer
///
/// You must still provide all other struct items except the .data item, and
/// these must match the creation parameters of the native buffers you provide.
/// For sg_buffer_desc.usage.immutable buffers, only provide a single native
/// 3D-API buffer, otherwise you need to provide SG_NUM_INFLIGHT_FRAMES buffers
/// (only for GL and Metal, not D3D11). Providing multiple buffers for GL and
/// Metal is necessary because sokol_gfx will rotate through them when calling
/// sg_update_buffer() to prevent lock-stalls.
///
/// Note that it is expected that immutable injected buffer have already been
/// initialized with content, and the .content member must be 0!
///
/// Also you need to call sg_reset_state_cache() after calling native 3D-API
/// functions, and before calling any sokol_gfx function.
pub const BufferDesc = extern struct {
    _start_canary: u32 = 0,
    size: usize = 0,
    usage: BufferUsage = .{},
    data: Range = .{},
    label: [*c]const u8 = null,
    gl_buffers: [2]u32 = [_]u32{0} ** 2,
    mtl_buffers: [2]?*const anyopaque = [_]?*const anyopaque{null} ** 2,
    d3d11_buffer: ?*const anyopaque = null,
    wgpu_buffer: ?*const anyopaque = null,
    _end_canary: u32 = 0,
};

/// sg_image_usage
///
/// Describes the intended usage of an image object:
///
/// .storage_image (default: false)
///     the image can be used as parent resource of a storage-image-view,
///     which allows compute shaders to write to the image in a compute
///     pass (for read-only access in compute shaders bind the image
///     via a texture view instead
/// .color_attachment (default: false)
///     the image can be used as parent resource of a color-attachment-view,
///     which is then passed into sg_begin_pass via sg_pass.attachments.colors[]
///     so that fragment shaders can render into the image
/// .resolve_attachment (default: false)
///     the image can be used as parent resource of a resolve-attachment-view,
///     which is then passed into sg_begin_pass via sg_pass.attachments.resolves[]
///     as target for an MSAA-resolve operation in sg_end_pass()
/// .depth_stencil_attachment (default: false)
///     the image can be used as parent resource of a depth-stencil-attachmnet-view
///     which is then passes into sg_begin_pass via sg_pass.attachments.depth_stencil
///     as depth-stencil-buffer
/// .immutable (default: true)
///     the image content cannot be updated from the CPU side
///     (but may be updated by the GPU in a render- or compute-pass)
/// .dynamic_update (default: false)
///     the image content is updated infrequently by the CPU
/// .stream_update (default: false)
///     the image content is updated each frame by the CPU via
///
/// Note that creating a texture view from the image to be used for
/// texture-sampling in vertex-, fragment- or compute-shaders
/// is always implicitly allowed.
pub const ImageUsage = extern struct {
    storage_image: bool = false,
    color_attachment: bool = false,
    resolve_attachment: bool = false,
    depth_stencil_attachment: bool = false,
    immutable: bool = false,
    dynamic_update: bool = false,
    stream_update: bool = false,
};

/// sg_view_type
///
/// Allows to query the type of a view object via the function sg_query_view_type()
pub const ViewType = enum(i32) {
    INVALID,
    STORAGEBUFFER,
    STORAGEIMAGE,
    TEXTURE,
    COLORATTACHMENT,
    RESOLVEATTACHMENT,
    DEPTHSTENCILATTACHMENT,
};

/// sg_image_data
///
/// Defines the content of an image through an array of sg_range structs, each
/// range pointing to the pixel data for one mip-level. For array-, cubemap- and
/// 3D-images each mip-level contains all slice-surfaces for that mip-level in a
/// single tightly packed memory block.
///
/// The size of a single surface in a mip-level for a regular 2D texture
/// can be computed via:
///
///     sg_query_surface_pitch(pixel_format, mip_width, mip_height, 1);
///
/// For array- and 3d-images the size of a single miplevel is:
///
///     num_slices * sg_query_surface_pitch(pixel_format, mip_width, mip_height, 1);
///
/// For cubemap-images the size of a single mip-level is:
///
///     6 * sg_query_surface_pitch(pixel_format, mip_width, mip_height, 1);
///
/// The order of cubemap-faces is in a mip-level data chunk is:
///
///     [0] => +X
///     [1] => -X
///     [2] => +Y
///     [3] => -Y
///     [4] => +Z
///     [5] => -Z
pub const ImageData = extern struct {
    mip_levels: [16]Range = [_]Range{.{}} ** 16,
};

/// sg_image_desc
///
/// Creation parameters for sg_image objects, used in the sg_make_image() call.
///
/// The default configuration is:
///
/// .type               SG_IMAGETYPE_2D
/// .usage              .immutable = true
/// .width              0 (must be set to >0)
/// .height             0 (must be set to >0)
/// .num_slices         1 (3D textures: depth; array textures: number of layers)
/// .num_mipmaps        1
/// .pixel_format       SG_PIXELFORMAT_RGBA8 for textures, or sg_desc.environment.defaults.color_format for render targets
/// .sample_count       1 for textures, or sg_desc.environment.defaults.sample_count for render targets
/// .data               an sg_image_data struct to define the initial content
/// .label              0 (optional string label for trace hooks)
///
/// Q: Why is the default sample_count for render targets identical with the
/// "default sample count" from sg_desc.environment.defaults.sample_count?
///
/// A: So that it matches the default sample count in pipeline objects. Even
/// though it is a bit strange/confusing that offscreen render targets by default
/// get the same sample count as 'default swapchains', but it's better that
/// an offscreen render target created with default parameters matches
/// a pipeline object created with default parameters.
///
/// NOTE:
///
/// Regular images used as texture binding with usage.immutable must be fully
/// initialized by providing a valid .data member which points to initialization
/// data.
///
/// Images with usage.*_attachment or usage.storage_image must
/// *not* be created with initial content. Be aware that the initial
/// content of pass attachment and storage images is undefined
/// (not guaranteed to be zeroed).
///
/// ADVANCED TOPIC: Injecting native 3D-API textures:
///
/// The following struct members allow to inject your own GL, Metal or D3D11
/// textures into sokol_gfx:
///
/// .gl_textures[SG_NUM_INFLIGHT_FRAMES]
/// .mtl_textures[SG_NUM_INFLIGHT_FRAMES]
/// .d3d11_texture
/// .wgpu_texture
///
/// For GL, you can also specify the texture target or leave it empty to use
/// the default texture target for the image type (GL_TEXTURE_2D for
/// SG_IMAGETYPE_2D etc)
///
/// The same rules apply as for injecting native buffers (see sg_buffer_desc
/// documentation for more details).
pub const ImageDesc = extern struct {
    _start_canary: u32 = 0,
    type: ImageType = .DEFAULT,
    usage: ImageUsage = .{},
    width: i32 = 0,
    height: i32 = 0,
    num_slices: i32 = 0,
    num_mipmaps: i32 = 0,
    pixel_format: PixelFormat = .DEFAULT,
    sample_count: i32 = 0,
    data: ImageData = .{},
    label: [*c]const u8 = null,
    gl_textures: [2]u32 = [_]u32{0} ** 2,
    gl_texture_target: u32 = 0,
    mtl_textures: [2]?*const anyopaque = [_]?*const anyopaque{null} ** 2,
    d3d11_texture: ?*const anyopaque = null,
    wgpu_texture: ?*const anyopaque = null,
    _end_canary: u32 = 0,
};

/// sg_sampler_desc
///
/// Creation parameters for sg_sampler objects, used in the sg_make_sampler() call
///
/// .min_filter:        SG_FILTER_NEAREST
/// .mag_filter:        SG_FILTER_NEAREST
/// .mipmap_filter      SG_FILTER_NEAREST
/// .wrap_u:            SG_WRAP_REPEAT
/// .wrap_v:            SG_WRAP_REPEAT
/// .wrap_w:            SG_WRAP_REPEAT (only SG_IMAGETYPE_3D)
/// .min_lod            0.0f
/// .max_lod            FLT_MAX
/// .border_color       SG_BORDERCOLOR_OPAQUE_BLACK
/// .compare            SG_COMPAREFUNC_NEVER
/// .max_anisotropy     1 (must be 1..16)
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

/// sg_shader_desc
///
/// Used as parameter of sg_make_shader() to create a shader object which
/// communicates shader source or bytecode and shader interface
/// reflection information to sokol-gfx.
///
/// If you use sokol-shdc you can ignore the following information since
/// the sg_shader_desc struct will be code-generated.
///
/// Otherwise you need to provide the following information to the
/// sg_make_shader() call:
///
/// - a vertex- and fragment-shader function:
///     - the shader source or bytecode
///     - an optional entry point name
///     - for D3D11: an optional compile target when source code is provided
///       (the defaults are "vs_4_0" and "ps_4_0")
///
/// - ...or alternatively, a compute function:
///     - the shader source or bytecode
///     - an optional entry point name
///     - for D3D11: an optional compile target when source code is provided
///       (the default is "cs_5_0")
///
/// - vertex attributes required by some backends (not for compute shaders):
///     - the vertex attribute base type (undefined, float, signed int, unsigned int),
///       this information is only used in the validation layer to check that the
///       pipeline object vertex formats are compatible with the input vertex attribute
///       type used in the vertex shader. NOTE that the default base type
///       'undefined' skips the validation layer check.
///     - for the GL backend: optional vertex attribute names used for name lookup
///     - for the D3D11 backend: semantic names and indices
///
/// - only for compute shaders on the Metal backend:
///     - the workgroup size aka 'threads per thread-group'
///
///       In other 3D APIs this is declared in the shader code:
///         - GLSL: `layout(local_size_x=x, local_size_y=y, local_size_y=z) in;`
///         - HLSL: `[numthreads(x, y, z)]`
///         - WGSL: `@workgroup_size(x, y, z)`
///       ...but in Metal the workgroup size is declared on the CPU side
///
/// - reflection information for each uniform block binding used by the shader:
///     - the shader stage the uniform block appears in (SG_SHADERSTAGE_*)
///     - the size in bytes of the uniform block
///     - backend-specific bindslots:
///         - HLSL: the constant buffer register `register(b0..7)`
///         - MSL: the buffer attribute `[[buffer(0..7)]]`
///         - WGSL: the binding in `@group(0) @binding(0..15)`
///     - GLSL only: a description of the uniform block interior
///         - the memory layout standard (SG_UNIFORMLAYOUT_*)
///         - for each member in the uniform block:
///             - the member type (SG_UNIFORM_*)
///             - if the member is an array, the array count
///             - the member name
///
/// - reflection information for each texture-, storage-buffer and
///   storage-image bindings by the shader, each with an associated
///   view type:
///     - texture bindings => texture views
///     - storage-buffer bindings => storage-buffer views
///     - storage-image bindings => storage-image views
///
/// - texture bindings must provide the following information:
///     - the shader stage the texture binding appears in (SG_SHADERSTAGE_*)
///     - the image type (SG_IMAGETYPE_*)
///     - the image-sample type (SG_IMAGESAMPLETYPE_*)
///     - whether the texture is multisampled
///     - backend specific bindslots:
///         - HLSL: the texture register `register(t0..31)`
///         - MSL: the texture attribute `[[texture(0..31)]]`
///         - WGSL: the binding in `@group(1) @binding(0..127)`
///
/// - storage-buffer bindings must provide the following information:
///     - the shader stage the storage buffer appears in (SG_SHADERSTAGE_*)
///     - whether the storage buffer is readonly
///     - backend specific bindslots:
///         - HLSL:
///             - for storage buffer bindings: `register(t0..31)`
///             - for read/write storage buffer bindings: `register(u0..31)`
///         - MSL: the buffer attribute `[[buffer(8..23)]]`
///         - WGSL: the binding in `@group(1) @binding(0..127)`
///         - GL: the binding in `layout(binding=0..sg_limits.max_storage_buffer_bindings_per_stage)`
///
/// - storage-image bindings must provide the following information:
///     - the shader stage (*must* be SG_SHADERSTAGE_COMPUTE)
///     - whether the storage image is writeonly or readwrite (for readonly
///       access use a regular texture binding instead)
///     - the image type expected by the shader (SG_IMAGETYPE_*)
///     - the access pixel format expected by the shader (SG_PIXELFORMAT_*),
///       note that only a subset of pixel formats is allowed for storage image
///       bindings
///     - backend specific bindslots:
///         - HLSL: the UAV register `register(u0..31)`
///         - MSL: the texture attribute `[[texture(0..31)]]`
///         - WGSL: the binding in `@group(1) @binding(0..127)`
///         - GLSL: the binding in `layout(binding=0..sg_imits.max_storage_buffer_bindings_per_stage, [access_format])`
///
/// - reflection information for each sampler used by the shader:
///     - the shader stage the sampler appears in (SG_SHADERSTAGE_*)
///     - the sampler type (SG_SAMPLERTYPE_*)
///     - backend specific bindslots:
///         - HLSL: the sampler register `register(s0..11)`
///         - MSL: the sampler attribute `[[sampler(0..11)]]`
///         - WGSL: the binding in `@group(0) @binding(0..127)`
///
/// - reflection information for each texture-sampler pair used by
///   the shader:
///     - the shader stage (SG_SHADERSTAGE_*)
///     - the texture's array index in the sg_shader_desc.views[] array
///     - the sampler's array index in the sg_shader_desc.samplers[] array
///     - GLSL only: the name of the combined image-sampler object
///
/// The number and order of items in the sg_shader_desc.attrs[]
/// array corresponds to the items in sg_pipeline_desc.layout.attrs.
///
///     - sg_shader_desc.attrs[N] => sg_pipeline_desc.layout.attrs[N]
///
/// NOTE that vertex attribute indices currently cannot have gaps.
///
/// The items index in the sg_shader_desc.uniform_blocks[] array corresponds
/// to the ub_slot arg in sg_apply_uniforms():
///
///     - sg_shader_desc.uniform_blocks[N] => sg_apply_uniforms(N, ...)
///
/// The items in the sg_shader_desc.views[] array directly map to
/// the views in the sg_bindings.views[] array!
///
/// For all GL backends, shader source-code must be provided. For D3D11 and Metal,
/// either shader source-code or byte-code can be provided.
///
/// NOTE that the uniform-block, view and sampler arrays may have gaps. This
/// allows to use the same sg_bindings struct for different but related
/// shader variations.
///
/// For D3D11, if source code is provided, the d3dcompiler_47.dll will be loaded
/// on demand. If this fails, shader creation will fail. When compiling HLSL
/// source code, you can provide an optional target string via
/// sg_shader_stage_desc.d3d11_target, the default target is "vs_4_0" for the
/// vertex shader stage and "ps_4_0" for the pixel shader stage.
/// You may optionally provide the file path to enable the default #include handler
/// behavior when compiling source code.
pub const ShaderStage = enum(i32) {
    NONE,
    VERTEX,
    FRAGMENT,
    COMPUTE,
};

pub const ShaderFunction = extern struct {
    source: [*c]const u8 = null,
    bytecode: Range = .{},
    entry: [*c]const u8 = null,
    d3d11_target: [*c]const u8 = null,
    d3d11_filepath: [*c]const u8 = null,
};

pub const ShaderAttrBaseType = enum(i32) {
    UNDEFINED,
    FLOAT,
    SINT,
    UINT,
};

pub const ShaderVertexAttr = extern struct {
    base_type: ShaderAttrBaseType = .UNDEFINED,
    glsl_name: [*c]const u8 = null,
    hlsl_sem_name: [*c]const u8 = null,
    hlsl_sem_index: u8 = 0,
};

pub const GlslShaderUniform = extern struct {
    type: UniformType = .INVALID,
    array_count: u16 = 0,
    glsl_name: [*c]const u8 = null,
};

pub const ShaderUniformBlock = extern struct {
    stage: ShaderStage = .NONE,
    size: u32 = 0,
    hlsl_register_b_n: u8 = 0,
    msl_buffer_n: u8 = 0,
    wgsl_group0_binding_n: u8 = 0,
    spirv_set0_binding_n: u8 = 0,
    layout: UniformLayout = .DEFAULT,
    glsl_uniforms: [16]GlslShaderUniform = [_]GlslShaderUniform{.{}} ** 16,
};

pub const ShaderTextureView = extern struct {
    stage: ShaderStage = .NONE,
    image_type: ImageType = .DEFAULT,
    sample_type: ImageSampleType = .DEFAULT,
    multisampled: bool = false,
    hlsl_register_t_n: u8 = 0,
    msl_texture_n: u8 = 0,
    wgsl_group1_binding_n: u8 = 0,
    spirv_set1_binding_n: u8 = 0,
};

pub const ShaderStorageBufferView = extern struct {
    stage: ShaderStage = .NONE,
    readonly: bool = false,
    hlsl_register_t_n: u8 = 0,
    hlsl_register_u_n: u8 = 0,
    msl_buffer_n: u8 = 0,
    wgsl_group1_binding_n: u8 = 0,
    spirv_set1_binding_n: u8 = 0,
    glsl_binding_n: u8 = 0,
};

pub const ShaderStorageImageView = extern struct {
    stage: ShaderStage = .NONE,
    image_type: ImageType = .DEFAULT,
    access_format: PixelFormat = .DEFAULT,
    writeonly: bool = false,
    hlsl_register_u_n: u8 = 0,
    msl_texture_n: u8 = 0,
    wgsl_group1_binding_n: u8 = 0,
    spirv_set1_binding_n: u8 = 0,
    glsl_binding_n: u8 = 0,
};

pub const ShaderView = extern struct {
    texture: ShaderTextureView = .{},
    storage_buffer: ShaderStorageBufferView = .{},
    storage_image: ShaderStorageImageView = .{},
};

pub const ShaderSampler = extern struct {
    stage: ShaderStage = .NONE,
    sampler_type: SamplerType = .DEFAULT,
    hlsl_register_s_n: u8 = 0,
    msl_sampler_n: u8 = 0,
    wgsl_group1_binding_n: u8 = 0,
    spirv_set1_binding_n: u8 = 0,
};

pub const ShaderTextureSamplerPair = extern struct {
    stage: ShaderStage = .NONE,
    view_slot: u8 = 0,
    sampler_slot: u8 = 0,
    glsl_name: [*c]const u8 = null,
};

pub const MtlShaderThreadsPerThreadgroup = extern struct {
    x: i32 = 0,
    y: i32 = 0,
    z: i32 = 0,
};

pub const ShaderDesc = extern struct {
    _start_canary: u32 = 0,
    vertex_func: ShaderFunction = .{},
    fragment_func: ShaderFunction = .{},
    compute_func: ShaderFunction = .{},
    attrs: [16]ShaderVertexAttr = [_]ShaderVertexAttr{.{}} ** 16,
    uniform_blocks: [8]ShaderUniformBlock = [_]ShaderUniformBlock{.{}} ** 8,
    views: [32]ShaderView = [_]ShaderView{.{}} ** 32,
    samplers: [12]ShaderSampler = [_]ShaderSampler{.{}} ** 12,
    texture_sampler_pairs: [32]ShaderTextureSamplerPair = [_]ShaderTextureSamplerPair{.{}} ** 32,
    mtl_threads_per_threadgroup: MtlShaderThreadsPerThreadgroup = .{},
    label: [*c]const u8 = null,
    _end_canary: u32 = 0,
};

/// sg_pipeline_desc
///
/// The sg_pipeline_desc struct defines all creation parameters for an
/// sg_pipeline object, used as argument to the sg_make_pipeline() function:
///
/// Pipeline objects come in two flavours:
///
/// - render pipelines for use in render passes
/// - compute pipelines for use in compute passes
///
/// A compute pipeline only requires a compute shader object but no
/// 'render state', while a render pipeline requires a vertex/fragment shader
/// object and additional render state declarations:
///
/// - the vertex layout for all input vertex buffers
/// - a shader object
/// - the 3D primitive type (points, lines, triangles, ...)
/// - the index type (none, 16- or 32-bit)
/// - all the fixed-function-pipeline state (depth-, stencil-, blend-state, etc...)
///
/// If the vertex data has no gaps between vertex components, you can omit
/// the .layout.buffers[].stride and layout.attrs[].offset items (leave them
/// default-initialized to 0), sokol-gfx will then compute the offsets and
/// strides from the vertex component formats (.layout.attrs[].format).
/// Please note that ALL vertex attribute offsets must be 0 in order for the
/// automatic offset computation to kick in.
///
/// Note that if you use vertex-pulling from storage buffers instead of
/// fixed-function vertex input you can simply omit the entire nested .layout
/// struct.
///
/// The default configuration is as follows:
///
/// .compute:               false (must be set to true for a compute pipeline)
/// .shader:                0 (must be initialized with a valid sg_shader id!)
/// .layout:
///     .buffers[]:         vertex buffer layouts
///         .stride:        0 (if no stride is given it will be computed)
///         .step_func      SG_VERTEXSTEP_PER_VERTEX
///         .step_rate      1
///     .attrs[]:           vertex attribute declarations
///         .buffer_index   0 the vertex buffer bind slot
///         .offset         0 (offsets can be omitted if the vertex layout has no gaps)
///         .format         SG_VERTEXFORMAT_INVALID (must be initialized!)
/// .depth:
///     .pixel_format:      sg_desc.context.depth_format
///     .compare:           SG_COMPAREFUNC_ALWAYS
///     .write_enabled:     false
///     .bias:              0.0f
///     .bias_slope_scale:  0.0f
///     .bias_clamp:        0.0f
/// .stencil:
///     .enabled:           false
///     .front/back:
///         .compare:       SG_COMPAREFUNC_ALWAYS
///         .fail_op:       SG_STENCILOP_KEEP
///         .depth_fail_op: SG_STENCILOP_KEEP
///         .pass_op:       SG_STENCILOP_KEEP
///     .read_mask:         0
///     .write_mask:        0
///     .ref:               0
/// .color_count            1
/// .colors[0..color_count]
///     .pixel_format       sg_desc.context.color_format
///     .write_mask:        SG_COLORMASK_RGBA
///     .blend:
///         .enabled:           false
///         .src_factor_rgb:    SG_BLENDFACTOR_ONE
///         .dst_factor_rgb:    SG_BLENDFACTOR_ZERO
///         .op_rgb:            SG_BLENDOP_ADD
///         .src_factor_alpha:  SG_BLENDFACTOR_ONE
///         .dst_factor_alpha:  SG_BLENDFACTOR_ZERO
///         .op_alpha:          SG_BLENDOP_ADD
/// .primitive_type:            SG_PRIMITIVETYPE_TRIANGLES
/// .index_type:                SG_INDEXTYPE_NONE
/// .cull_mode:                 SG_CULLMODE_NONE
/// .face_winding:              SG_FACEWINDING_CW
/// .sample_count:              sg_desc.context.sample_count
/// .blend_color:               (sg_color) { 0.0f, 0.0f, 0.0f, 0.0f }
/// .alpha_to_coverage_enabled: false
/// .label  0       (optional string label for trace hooks)
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
    compute: bool = false,
    shader: Shader = .{},
    layout: VertexLayoutState = .{},
    depth: DepthState = .{},
    stencil: StencilState = .{},
    color_count: i32 = 0,
    colors: [8]ColorTargetState = [_]ColorTargetState{.{}} ** 8,
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

/// sg_view_desc
///
/// Creation params for sg_view objects, passed into sg_make_view() calls.
///
/// View objects are passed into sg_apply_bindings() (for texture-, storage-buffer-
/// and storage-image views), and sg_begin_pass() (for color-, resolve-
/// and depth-stencil-attachment views).
///
/// The view type is determined by initializing one of the sub-structs of
/// sg_view_desc:
///
/// .texture            a texture-view object will be created
///     .image          the sg_image parent resource
///     .mip_levels     optional mip-level range, keep zero-initialized for the
///                     entire mipmap chain
///         .base       the first mip level
///         .count      number of mip levels, keeping this zero-initialized means
///                     'all remaining mip levels'
///     .slices         optional slice range, keep zero-initialized to include
///                     all slices
///         .base       the first slice
///         .count      number of slices, keeping this zero-initializied means 'all remaining slices'
///
/// .storage_buffer     a storage-buffer-view object will be created
///     .buffer         the sg_buffer parent resource, must have been created
///                     with `sg_buffer_desc.usage.storage_buffer = true`
///     .offset         optional 256-byte aligned byte-offset into the buffer
///
/// .storage_image      a storage-image-view object will be created
///     .image          the sg_image parent resource, must have been created
///                     with `sg_image_desc.usage.storage_image = true`
///     .mip_level      selects the mip-level for the compute shader to write
///     .slice          selects the slice for the compute shader to write
///
/// .color_attachment   a color-attachment-view object will be created
///     .image          the sg_image parent resource, must have been created
///                     with `sg_image_desc.usage.color_attachment = true`
///     .mip_level      selects the mip-level to render into
///     .slice          selects the slice to render into
///
/// .resolve_attachment a resolve-attachment-view object will be created
///     .image          the sg_image parent resource, must have been created
///                     with `sg_image_desc.usage.resolve_attachment = true`
///     .mip_level      selects the mip-level to msaa-resolve into
///     .slice          selects the slice to msaa-resolve into
///
/// .depth_stencil_attachment   a depth-stencil-attachment-view object will be created
///     .image          the sg_image parent resource, must have been created
///                     with `sg_image_desc.usage.depth_stencil_attachment = true`
///     .mip_level      selects the mip-level to render into
///     .slice          selects the slice to render into
pub const BufferViewDesc = extern struct {
    buffer: Buffer = .{},
    offset: i32 = 0,
};

pub const ImageViewDesc = extern struct {
    image: Image = .{},
    mip_level: i32 = 0,
    slice: i32 = 0,
};

pub const TextureViewRange = extern struct {
    base: i32 = 0,
    count: i32 = 0,
};

pub const TextureViewDesc = extern struct {
    image: Image = .{},
    mip_levels: TextureViewRange = .{},
    slices: TextureViewRange = .{},
};

pub const ViewDesc = extern struct {
    _start_canary: u32 = 0,
    texture: TextureViewDesc = .{},
    storage_buffer: BufferViewDesc = .{},
    storage_image: ImageViewDesc = .{},
    color_attachment: ImageViewDesc = .{},
    resolve_attachment: ImageViewDesc = .{},
    depth_stencil_attachment: ImageViewDesc = .{},
    label: [*c]const u8 = null,
    _end_canary: u32 = 0,
};

/// sg_buffer_info
/// sg_image_info
/// sg_sampler_info
/// sg_shader_info
/// sg_pipeline_info
/// sg_view_info
///
/// These structs contain various internal resource attributes which
/// might be useful for debug-inspection. Please don't rely on the
/// actual content of those structs too much, as they are quite closely
/// tied to sokol_gfx.h internals and may change more frequently than
/// the other public API elements.
///
/// The *_info structs are used as the return values of the following functions:
///
/// sg_query_buffer_info()
/// sg_query_image_info()
/// sg_query_sampler_info()
/// sg_query_shader_info()
/// sg_query_pipeline_info()
/// sg_query_view_info()
pub const SlotInfo = extern struct {
    state: ResourceState = .INITIAL,
    res_id: u32 = 0,
    uninit_count: u32 = 0,
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

pub const ViewInfo = extern struct {
    slot: SlotInfo = .{},
};

/// sg_frame_stats
///
/// Allows to track generic and backend-specific stats about a
/// render frame. Obtained by calling sg_query_frame_stats(). The returned
/// struct contains information about the *previous* frame.
pub const FrameStatsGl = extern struct {
    num_bind_buffer: u32 = 0,
    num_active_texture: u32 = 0,
    num_bind_texture: u32 = 0,
    num_bind_sampler: u32 = 0,
    num_bind_image_texture: u32 = 0,
    num_use_program: u32 = 0,
    num_render_state: u32 = 0,
    num_vertex_attrib_pointer: u32 = 0,
    num_vertex_attrib_divisor: u32 = 0,
    num_enable_vertex_attrib_array: u32 = 0,
    num_disable_vertex_attrib_array: u32 = 0,
    num_uniform: u32 = 0,
    num_memory_barriers: u32 = 0,
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
    num_cs_set_shader: u32 = 0,
    num_cs_set_constant_buffers: u32 = 0,
};

pub const FrameStatsD3d11Bindings = extern struct {
    num_ia_set_vertex_buffers: u32 = 0,
    num_ia_set_index_buffer: u32 = 0,
    num_vs_set_shader_resources: u32 = 0,
    num_vs_set_samplers: u32 = 0,
    num_ps_set_shader_resources: u32 = 0,
    num_ps_set_samplers: u32 = 0,
    num_cs_set_shader_resources: u32 = 0,
    num_cs_set_samplers: u32 = 0,
    num_cs_set_unordered_access_views: u32 = 0,
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
    num_set_vertex_buffer_offset: u32 = 0,
    num_skip_redundant_vertex_buffer: u32 = 0,
    num_set_vertex_texture: u32 = 0,
    num_skip_redundant_vertex_texture: u32 = 0,
    num_set_vertex_sampler_state: u32 = 0,
    num_skip_redundant_vertex_sampler_state: u32 = 0,
    num_set_fragment_buffer: u32 = 0,
    num_set_fragment_buffer_offset: u32 = 0,
    num_skip_redundant_fragment_buffer: u32 = 0,
    num_set_fragment_texture: u32 = 0,
    num_skip_redundant_fragment_texture: u32 = 0,
    num_set_fragment_sampler_state: u32 = 0,
    num_skip_redundant_fragment_sampler_state: u32 = 0,
    num_set_compute_buffer: u32 = 0,
    num_set_compute_buffer_offset: u32 = 0,
    num_skip_redundant_compute_buffer: u32 = 0,
    num_set_compute_texture: u32 = 0,
    num_skip_redundant_compute_texture: u32 = 0,
    num_set_compute_sampler_state: u32 = 0,
    num_skip_redundant_compute_sampler_state: u32 = 0,
};

pub const FrameStatsMetalUniforms = extern struct {
    num_set_vertex_buffer_offset: u32 = 0,
    num_set_fragment_buffer_offset: u32 = 0,
    num_set_compute_buffer_offset: u32 = 0,
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
    num_bindgroup_cache_invalidates: u32 = 0,
    num_bindgroup_cache_hash_vs_key_mismatch: u32 = 0,
};

pub const FrameStatsWgpu = extern struct {
    uniforms: FrameStatsWgpuUniforms = .{},
    bindings: FrameStatsWgpuBindings = .{},
};

pub const FrameStatsVk = extern struct {
    num_cmd_pipeline_barrier: u32 = 0,
    num_allocate_memory: u32 = 0,
    num_free_memory: u32 = 0,
    size_allocate_memory: u32 = 0,
    num_delete_queue_added: u32 = 0,
    num_delete_queue_collected: u32 = 0,
    num_cmd_copy_buffer: u32 = 0,
    num_cmd_copy_buffer_to_image: u32 = 0,
    num_cmd_set_descriptor_buffer_offsets: u32 = 0,
    size_descriptor_buffer_writes: u32 = 0,
};

pub const ResourceStats = extern struct {
    total_alive: u32 = 0,
    total_free: u32 = 0,
    allocated: u32 = 0,
    deallocated: u32 = 0,
    inited: u32 = 0,
    uninited: u32 = 0,
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
    num_draw_ex: u32 = 0,
    num_dispatch: u32 = 0,
    num_update_buffer: u32 = 0,
    num_append_buffer: u32 = 0,
    num_update_image: u32 = 0,
    size_apply_uniforms: u32 = 0,
    size_update_buffer: u32 = 0,
    size_append_buffer: u32 = 0,
    size_update_image: u32 = 0,
    buffers: ResourceStats = .{},
    images: ResourceStats = .{},
    samplers: ResourceStats = .{},
    views: ResourceStats = .{},
    shaders: ResourceStats = .{},
    pipelines: ResourceStats = .{},
    gl: FrameStatsGl = .{},
    d3d11: FrameStatsD3d11 = .{},
    metal: FrameStatsMetal = .{},
    wgpu: FrameStatsWgpu = .{},
    vk: FrameStatsVk = .{},
};

pub const LogItem = enum(i32) {
    OK,
    MALLOC_FAILED,
    GL_TEXTURE_FORMAT_NOT_SUPPORTED,
    GL_3D_TEXTURES_NOT_SUPPORTED,
    GL_ARRAY_TEXTURES_NOT_SUPPORTED,
    GL_STORAGEBUFFER_GLSL_BINDING_OUT_OF_RANGE,
    GL_STORAGEIMAGE_GLSL_BINDING_OUT_OF_RANGE,
    GL_SHADER_COMPILATION_FAILED,
    GL_SHADER_LINKING_FAILED,
    GL_VERTEX_ATTRIBUTE_NOT_FOUND_IN_SHADER,
    GL_UNIFORMBLOCK_NAME_NOT_FOUND_IN_SHADER,
    GL_IMAGE_SAMPLER_NAME_NOT_FOUND_IN_SHADER,
    GL_FRAMEBUFFER_STATUS_UNDEFINED,
    GL_FRAMEBUFFER_STATUS_INCOMPLETE_ATTACHMENT,
    GL_FRAMEBUFFER_STATUS_INCOMPLETE_MISSING_ATTACHMENT,
    GL_FRAMEBUFFER_STATUS_UNSUPPORTED,
    GL_FRAMEBUFFER_STATUS_INCOMPLETE_MULTISAMPLE,
    GL_FRAMEBUFFER_STATUS_UNKNOWN,
    D3D11_FEATURE_LEVEL_0_DETECTED,
    D3D11_CREATE_BUFFER_FAILED,
    D3D11_CREATE_BUFFER_SRV_FAILED,
    D3D11_CREATE_BUFFER_UAV_FAILED,
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
    D3D11_UNIFORMBLOCK_HLSL_REGISTER_B_OUT_OF_RANGE,
    D3D11_STORAGEBUFFER_HLSL_REGISTER_T_OUT_OF_RANGE,
    D3D11_STORAGEBUFFER_HLSL_REGISTER_U_OUT_OF_RANGE,
    D3D11_IMAGE_HLSL_REGISTER_T_OUT_OF_RANGE,
    D3D11_STORAGEIMAGE_HLSL_REGISTER_U_OUT_OF_RANGE,
    D3D11_SAMPLER_HLSL_REGISTER_S_OUT_OF_RANGE,
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
    D3D11_CREATE_UAV_FAILED,
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
    METAL_SHADER_ENTRY_NOT_FOUND,
    METAL_UNIFORMBLOCK_MSL_BUFFER_SLOT_OUT_OF_RANGE,
    METAL_STORAGEBUFFER_MSL_BUFFER_SLOT_OUT_OF_RANGE,
    METAL_STORAGEIMAGE_MSL_TEXTURE_SLOT_OUT_OF_RANGE,
    METAL_IMAGE_MSL_TEXTURE_SLOT_OUT_OF_RANGE,
    METAL_SAMPLER_MSL_SAMPLER_SLOT_OUT_OF_RANGE,
    METAL_CREATE_CPS_FAILED,
    METAL_CREATE_CPS_OUTPUT,
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
    WGPU_SHADER_CREATE_BINDGROUP_LAYOUT_FAILED,
    WGPU_UNIFORMBLOCK_WGSL_GROUP0_BINDING_OUT_OF_RANGE,
    WGPU_TEXTURE_WGSL_GROUP1_BINDING_OUT_OF_RANGE,
    WGPU_STORAGEBUFFER_WGSL_GROUP1_BINDING_OUT_OF_RANGE,
    WGPU_STORAGEIMAGE_WGSL_GROUP1_BINDING_OUT_OF_RANGE,
    WGPU_SAMPLER_WGSL_GROUP1_BINDING_OUT_OF_RANGE,
    WGPU_CREATE_PIPELINE_LAYOUT_FAILED,
    WGPU_CREATE_RENDER_PIPELINE_FAILED,
    WGPU_CREATE_COMPUTE_PIPELINE_FAILED,
    VULKAN_REQUIRED_EXTENSION_FUNCTION_MISSING,
    VULKAN_ALLOC_DEVICE_MEMORY_NO_SUITABLE_MEMORY_TYPE,
    VULKAN_ALLOCATE_MEMORY_FAILED,
    VULKAN_ALLOC_BUFFER_DEVICE_MEMORY_FAILED,
    VULKAN_ALLOC_IMAGE_DEVICE_MEMORY_FAILED,
    VULKAN_DELETE_QUEUE_EXHAUSTED,
    VULKAN_STAGING_CREATE_BUFFER_FAILED,
    VULKAN_STAGING_ALLOCATE_MEMORY_FAILED,
    VULKAN_STAGING_BIND_BUFFER_MEMORY_FAILED,
    VULKAN_STAGING_STREAM_BUFFER_OVERFLOW,
    VULKAN_CREATE_SHARED_BUFFER_FAILED,
    VULKAN_ALLOCATE_SHARED_BUFFER_MEMORY_FAILED,
    VULKAN_BIND_SHARED_BUFFER_MEMORY_FAILED,
    VULKAN_MAP_SHARED_BUFFER_MEMORY_FAILED,
    VULKAN_CREATE_BUFFER_FAILED,
    VULKAN_BIND_BUFFER_MEMORY_FAILED,
    VULKAN_CREATE_IMAGE_FAILED,
    VULKAN_BIND_IMAGE_MEMORY_FAILED,
    VULKAN_CREATE_SHADER_MODULE_FAILED,
    VULKAN_UNIFORMBLOCK_SPIRV_SET0_BINDING_OUT_OF_RANGE,
    VULKAN_TEXTURE_SPIRV_SET1_BINDING_OUT_OF_RANGE,
    VULKAN_STORAGEBUFFER_SPIRV_SET1_BINDING_OUT_OF_RANGE,
    VULKAN_STORAGEIMAGE_SPIRV_SET1_BINDING_OUT_OF_RANGE,
    VULKAN_SAMPLER_SPIRV_SET1_BINDING_OUT_OF_RANGE,
    VULKAN_CREATE_DESCRIPTOR_SET_LAYOUT_FAILED,
    VULKAN_CREATE_PIPELINE_LAYOUT_FAILED,
    VULKAN_CREATE_GRAPHICS_PIPELINE_FAILED,
    VULKAN_CREATE_COMPUTE_PIPELINE_FAILED,
    VULKAN_CREATE_IMAGE_VIEW_FAILED,
    VULKAN_VIEW_MAX_DESCRIPTOR_SIZE,
    VULKAN_CREATE_SAMPLER_FAILED,
    VULKAN_SAMPLER_MAX_DESCRIPTOR_SIZE,
    VULKAN_WAIT_FOR_FENCE_FAILED,
    VULKAN_UNIFORM_BUFFER_OVERFLOW,
    VULKAN_DESCRIPTOR_BUFFER_OVERFLOW,
    IDENTICAL_COMMIT_LISTENER,
    COMMIT_LISTENER_ARRAY_FULL,
    TRACE_HOOKS_NOT_ENABLED,
    DEALLOC_BUFFER_INVALID_STATE,
    DEALLOC_IMAGE_INVALID_STATE,
    DEALLOC_SAMPLER_INVALID_STATE,
    DEALLOC_SHADER_INVALID_STATE,
    DEALLOC_PIPELINE_INVALID_STATE,
    DEALLOC_VIEW_INVALID_STATE,
    INIT_BUFFER_INVALID_STATE,
    INIT_IMAGE_INVALID_STATE,
    INIT_SAMPLER_INVALID_STATE,
    INIT_SHADER_INVALID_STATE,
    INIT_PIPELINE_INVALID_STATE,
    INIT_VIEW_INVALID_STATE,
    UNINIT_BUFFER_INVALID_STATE,
    UNINIT_IMAGE_INVALID_STATE,
    UNINIT_SAMPLER_INVALID_STATE,
    UNINIT_SHADER_INVALID_STATE,
    UNINIT_PIPELINE_INVALID_STATE,
    UNINIT_VIEW_INVALID_STATE,
    FAIL_BUFFER_INVALID_STATE,
    FAIL_IMAGE_INVALID_STATE,
    FAIL_SAMPLER_INVALID_STATE,
    FAIL_SHADER_INVALID_STATE,
    FAIL_PIPELINE_INVALID_STATE,
    FAIL_VIEW_INVALID_STATE,
    BUFFER_POOL_EXHAUSTED,
    IMAGE_POOL_EXHAUSTED,
    SAMPLER_POOL_EXHAUSTED,
    SHADER_POOL_EXHAUSTED,
    PIPELINE_POOL_EXHAUSTED,
    VIEW_POOL_EXHAUSTED,
    BEGINPASS_TOO_MANY_COLOR_ATTACHMENTS,
    BEGINPASS_TOO_MANY_RESOLVE_ATTACHMENTS,
    BEGINPASS_ATTACHMENTS_ALIVE,
    DRAW_WITHOUT_BINDINGS,
    SHADERDESC_TOO_MANY_VERTEXSTAGE_TEXTURES,
    SHADERDESC_TOO_MANY_FRAGMENTSTAGE_TEXTURES,
    SHADERDESC_TOO_MANY_COMPUTESTAGE_TEXTURES,
    SHADERDESC_TOO_MANY_VERTEXSTAGE_STORAGEBUFFERS,
    SHADERDESC_TOO_MANY_FRAGMENTSTAGE_STORAGEBUFFERS,
    SHADERDESC_TOO_MANY_COMPUTESTAGE_STORAGEBUFFERS,
    SHADERDESC_TOO_MANY_VERTEXSTAGE_STORAGEIMAGES,
    SHADERDESC_TOO_MANY_FRAGMENTSTAGE_STORAGEIMAGES,
    SHADERDESC_TOO_MANY_COMPUTESTAGE_STORAGEIMAGES,
    SHADERDESC_TOO_MANY_VERTEXSTAGE_TEXTURESAMPLERPAIRS,
    SHADERDESC_TOO_MANY_FRAGMENTSTAGE_TEXTURESAMPLERPAIRS,
    SHADERDESC_TOO_MANY_COMPUTESTAGE_TEXTURESAMPLERPAIRS,
    VALIDATE_BUFFERDESC_CANARY,
    VALIDATE_BUFFERDESC_IMMUTABLE_DYNAMIC_STREAM,
    VALIDATE_BUFFERDESC_SEPARATE_BUFFER_TYPES,
    VALIDATE_BUFFERDESC_EXPECT_NONZERO_SIZE,
    VALIDATE_BUFFERDESC_EXPECT_MATCHING_DATA_SIZE,
    VALIDATE_BUFFERDESC_EXPECT_ZERO_DATA_SIZE,
    VALIDATE_BUFFERDESC_EXPECT_NO_DATA,
    VALIDATE_BUFFERDESC_EXPECT_DATA,
    VALIDATE_BUFFERDESC_STORAGEBUFFER_SUPPORTED,
    VALIDATE_BUFFERDESC_STORAGEBUFFER_SIZE_MULTIPLE_4,
    VALIDATE_IMAGEDATA_NODATA,
    VALIDATE_IMAGEDATA_DATA_SIZE,
    VALIDATE_IMAGEDESC_CANARY,
    VALIDATE_IMAGEDESC_IMMUTABLE_DYNAMIC_STREAM,
    VALIDATE_IMAGEDESC_IMAGETYPE_2D_NUMSLICES,
    VALIDATE_IMAGEDESC_IMAGETYPE_CUBE_NUMSLICES,
    VALIDATE_IMAGEDESC_IMAGETYPE_ARRAY_NUMSLICES,
    VALIDATE_IMAGEDESC_IMAGETYPE_3D_NUMSLICES,
    VALIDATE_IMAGEDESC_NUMSLICES,
    VALIDATE_IMAGEDESC_WIDTH,
    VALIDATE_IMAGEDESC_HEIGHT,
    VALIDATE_IMAGEDESC_NONRT_PIXELFORMAT,
    VALIDATE_IMAGEDESC_MSAA_BUT_NO_ATTACHMENT,
    VALIDATE_IMAGEDESC_DEPTH_3D_IMAGE,
    VALIDATE_IMAGEDESC_ATTACHMENT_EXPECT_IMMUTABLE,
    VALIDATE_IMAGEDESC_ATTACHMENT_EXPECT_NO_DATA,
    VALIDATE_IMAGEDESC_ATTACHMENT_PIXELFORMAT,
    VALIDATE_IMAGEDESC_ATTACHMENT_RESOLVE_EXPECT_NO_MSAA,
    VALIDATE_IMAGEDESC_ATTACHMENT_NO_MSAA_SUPPORT,
    VALIDATE_IMAGEDESC_ATTACHMENT_MSAA_NUM_MIPMAPS,
    VALIDATE_IMAGEDESC_ATTACHMENT_MSAA_3D_IMAGE,
    VALIDATE_IMAGEDESC_ATTACHMENT_MSAA_CUBE_IMAGE,
    VALIDATE_IMAGEDESC_ATTACHMENT_MSAA_ARRAY_IMAGE,
    VALIDATE_IMAGEDESC_STORAGEIMAGE_PIXELFORMAT,
    VALIDATE_IMAGEDESC_STORAGEIMAGE_EXPECT_NO_MSAA,
    VALIDATE_IMAGEDESC_INJECTED_NO_DATA,
    VALIDATE_IMAGEDESC_DYNAMIC_NO_DATA,
    VALIDATE_IMAGEDESC_COMPRESSED_IMMUTABLE,
    VALIDATE_SAMPLERDESC_CANARY,
    VALIDATE_SAMPLERDESC_ANISTROPIC_REQUIRES_LINEAR_FILTERING,
    VALIDATE_SHADERDESC_CANARY,
    VALIDATE_SHADERDESC_VERTEX_SOURCE,
    VALIDATE_SHADERDESC_FRAGMENT_SOURCE,
    VALIDATE_SHADERDESC_COMPUTE_SOURCE,
    VALIDATE_SHADERDESC_VERTEX_SOURCE_OR_BYTECODE,
    VALIDATE_SHADERDESC_FRAGMENT_SOURCE_OR_BYTECODE,
    VALIDATE_SHADERDESC_COMPUTE_SOURCE_OR_BYTECODE,
    VALIDATE_SHADERDESC_INVALID_SHADER_COMBO,
    VALIDATE_SHADERDESC_NO_BYTECODE_SIZE,
    VALIDATE_SHADERDESC_METAL_THREADS_PER_THREADGROUP_INITIALIZED,
    VALIDATE_SHADERDESC_METAL_THREADS_PER_THREADGROUP_MULTIPLE_32,
    VALIDATE_SHADERDESC_UNIFORMBLOCK_NO_CONT_MEMBERS,
    VALIDATE_SHADERDESC_UNIFORMBLOCK_SIZE_IS_ZERO,
    VALIDATE_SHADERDESC_UNIFORMBLOCK_METAL_BUFFER_SLOT_COLLISION,
    VALIDATE_SHADERDESC_UNIFORMBLOCK_HLSL_REGISTER_B_COLLISION,
    VALIDATE_SHADERDESC_UNIFORMBLOCK_WGSL_GROUP0_BINDING_COLLISION,
    VALIDATE_SHADERDESC_UNIFORMBLOCK_SPIRV_SET0_BINDING_COLLISION,
    VALIDATE_SHADERDESC_UNIFORMBLOCK_NO_MEMBERS,
    VALIDATE_SHADERDESC_UNIFORMBLOCK_UNIFORM_GLSL_NAME,
    VALIDATE_SHADERDESC_UNIFORMBLOCK_SIZE_MISMATCH,
    VALIDATE_SHADERDESC_UNIFORMBLOCK_ARRAY_COUNT,
    VALIDATE_SHADERDESC_UNIFORMBLOCK_STD140_ARRAY_TYPE,
    VALIDATE_SHADERDESC_VIEW_STORAGEBUFFER_METAL_BUFFER_SLOT_COLLISION,
    VALIDATE_SHADERDESC_VIEW_STORAGEBUFFER_HLSL_REGISTER_T_COLLISION,
    VALIDATE_SHADERDESC_VIEW_STORAGEBUFFER_HLSL_REGISTER_U_COLLISION,
    VALIDATE_SHADERDESC_VIEW_STORAGEBUFFER_GLSL_BINDING_COLLISION,
    VALIDATE_SHADERDESC_VIEW_STORAGEBUFFER_WGSL_GROUP1_BINDING_COLLISION,
    VALIDATE_SHADERDESC_VIEW_STORAGEBUFFER_SPIRV_SET1_BINDING_COLLISION,
    VALIDATE_SHADERDESC_VIEW_STORAGEIMAGE_EXPECT_COMPUTE_STAGE,
    VALIDATE_SHADERDESC_VIEW_STORAGEIMAGE_METAL_TEXTURE_SLOT_COLLISION,
    VALIDATE_SHADERDESC_VIEW_STORAGEIMAGE_HLSL_REGISTER_U_COLLISION,
    VALIDATE_SHADERDESC_VIEW_STORAGEIMAGE_GLSL_BINDING_COLLISION,
    VALIDATE_SHADERDESC_VIEW_STORAGEIMAGE_WGSL_GROUP1_BINDING_COLLISION,
    VALIDATE_SHADERDESC_VIEW_STORAGEIMAGE_SPIRV_SET1_BINDING_COLLISION,
    VALIDATE_SHADERDESC_VIEW_TEXTURE_METAL_TEXTURE_SLOT_COLLISION,
    VALIDATE_SHADERDESC_VIEW_TEXTURE_HLSL_REGISTER_T_COLLISION,
    VALIDATE_SHADERDESC_VIEW_TEXTURE_WGSL_GROUP1_BINDING_COLLISION,
    VALIDATE_SHADERDESC_VIEW_TEXTURE_SPIRV_SET1_BINDING_COLLISION,
    VALIDATE_SHADERDESC_SAMPLER_METAL_SAMPLER_SLOT_COLLISION,
    VALIDATE_SHADERDESC_SAMPLER_HLSL_REGISTER_S_COLLISION,
    VALIDATE_SHADERDESC_SAMPLER_WGSL_GROUP1_BINDING_COLLISION,
    VALIDATE_SHADERDESC_SAMPLER_SPIRV_SET1_BINDING_COLLISION,
    VALIDATE_SHADERDESC_TEXTURE_SAMPLER_PAIR_VIEW_SLOT_OUT_OF_RANGE,
    VALIDATE_SHADERDESC_TEXTURE_SAMPLER_PAIR_SAMPLER_SLOT_OUT_OF_RANGE,
    VALIDATE_SHADERDESC_TEXTURE_SAMPLER_PAIR_TEXTURE_STAGE_MISMATCH,
    VALIDATE_SHADERDESC_TEXTURE_SAMPLER_PAIR_EXPECT_TEXTURE_VIEW,
    VALIDATE_SHADERDESC_TEXTURE_SAMPLER_PAIR_SAMPLER_STAGE_MISMATCH,
    VALIDATE_SHADERDESC_TEXTURE_SAMPLER_PAIR_GLSL_NAME,
    VALIDATE_SHADERDESC_NONFILTERING_SAMPLER_REQUIRED,
    VALIDATE_SHADERDESC_COMPARISON_SAMPLER_REQUIRED,
    VALIDATE_SHADERDESC_TEXVIEW_NOT_REFERENCED_BY_TEXTURE_SAMPLER_PAIRS,
    VALIDATE_SHADERDESC_SAMPLER_NOT_REFERENCED_BY_TEXTURE_SAMPLER_PAIRS,
    VALIDATE_SHADERDESC_ATTR_STRING_TOO_LONG,
    VALIDATE_PIPELINEDESC_CANARY,
    VALIDATE_PIPELINEDESC_SHADER,
    VALIDATE_PIPELINEDESC_COMPUTE_SHADER_EXPECTED,
    VALIDATE_PIPELINEDESC_NO_COMPUTE_SHADER_EXPECTED,
    VALIDATE_PIPELINEDESC_NO_CONT_ATTRS,
    VALIDATE_PIPELINEDESC_ATTR_BASETYPE_MISMATCH,
    VALIDATE_PIPELINEDESC_LAYOUT_STRIDE4,
    VALIDATE_PIPELINEDESC_ATTR_SEMANTICS,
    VALIDATE_PIPELINEDESC_SHADER_READONLY_STORAGEBUFFERS,
    VALIDATE_PIPELINEDESC_BLENDOP_MINMAX_REQUIRES_BLENDFACTOR_ONE,
    VALIDATE_VIEWDESC_CANARY,
    VALIDATE_VIEWDESC_UNIQUE_VIEWTYPE,
    VALIDATE_VIEWDESC_ANY_VIEWTYPE,
    VALIDATE_VIEWDESC_RESOURCE_ALIVE,
    VALIDATE_VIEWDESC_RESOURCE_FAILED,
    VALIDATE_VIEWDESC_STORAGEBUFFER_OFFSET_VS_BUFFER_SIZE,
    VALIDATE_VIEWDESC_STORAGEBUFFER_OFFSET_MULTIPLE_256,
    VALIDATE_VIEWDESC_STORAGEBUFFER_USAGE,
    VALIDATE_VIEWDESC_STORAGEIMAGE_USAGE,
    VALIDATE_VIEWDESC_COLORATTACHMENT_USAGE,
    VALIDATE_VIEWDESC_RESOLVEATTACHMENT_USAGE,
    VALIDATE_VIEWDESC_DEPTHSTENCILATTACHMENT_USAGE,
    VALIDATE_VIEWDESC_IMAGE_MIPLEVEL,
    VALIDATE_VIEWDESC_IMAGE_2D_SLICE,
    VALIDATE_VIEWDESC_IMAGE_CUBEMAP_SLICE,
    VALIDATE_VIEWDESC_IMAGE_ARRAY_SLICE,
    VALIDATE_VIEWDESC_IMAGE_3D_SLICE,
    VALIDATE_VIEWDESC_TEXTURE_EXPECT_NO_MSAA,
    VALIDATE_VIEWDESC_TEXTURE_MIPLEVELS,
    VALIDATE_VIEWDESC_TEXTURE_2D_SLICES,
    VALIDATE_VIEWDESC_TEXTURE_CUBEMAP_SLICES,
    VALIDATE_VIEWDESC_TEXTURE_ARRAY_SLICES,
    VALIDATE_VIEWDESC_TEXTURE_3D_SLICES,
    VALIDATE_VIEWDESC_STORAGEIMAGE_PIXELFORMAT,
    VALIDATE_VIEWDESC_COLORATTACHMENT_PIXELFORMAT,
    VALIDATE_VIEWDESC_DEPTHSTENCILATTACHMENT_PIXELFORMAT,
    VALIDATE_VIEWDESC_RESOLVEATTACHMENT_SAMPLECOUNT,
    VALIDATE_BEGINPASS_CANARY,
    VALIDATE_BEGINPASS_COMPUTEPASS_EXPECT_NO_ATTACHMENTS,
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
    VALIDATE_BEGINPASS_COLORATTACHMENTVIEWS_CONTINUOUS,
    VALIDATE_BEGINPASS_COLORATTACHMENTVIEW_ALIVE,
    VALIDATE_BEGINPASS_COLORATTACHMENTVIEW_VALID,
    VALIDATE_BEGINPASS_COLORATTACHMENTVIEW_TYPE,
    VALIDATE_BEGINPASS_COLORATTACHMENTVIEW_IMAGE_ALIVE,
    VALIDATE_BEGINPASS_COLORATTACHMENTVIEW_IMAGE_VALID,
    VALIDATE_BEGINPASS_COLORATTACHMENTVIEW_SIZES,
    VALIDATE_BEGINPASS_COLORATTACHMENTVIEW_SAMPLECOUNT,
    VALIDATE_BEGINPASS_COLORATTACHMENTVIEW_SAMPLECOUNTS_EQUAL,
    VALIDATE_BEGINPASS_RESOLVEATTACHMENTVIEW_NO_COLORATTACHMENTVIEW,
    VALIDATE_BEGINPASS_RESOLVEATTACHMENTVIEW_ALIVE,
    VALIDATE_BEGINPASS_RESOLVEATTACHMENTVIEW_VALID,
    VALIDATE_BEGINPASS_RESOLVEATTACHMENTVIEW_TYPE,
    VALIDATE_BEGINPASS_RESOLVEATTACHMENTVIEW_IMAGE_ALIVE,
    VALIDATE_BEGINPASS_RESOLVEATTACHMENTVIEW_IMAGE_VALID,
    VALIDATE_BEGINPASS_RESOLVEATTACHMENTVIEW_SIZES,
    VALIDATE_BEGINPASS_DEPTHSTENCILATTACHMENTVIEWS_CONTINUOUS,
    VALIDATE_BEGINPASS_DEPTHSTENCILATTACHMENTVIEW_ALIVE,
    VALIDATE_BEGINPASS_DEPTHSTENCILATTACHMENTVIEW_VALID,
    VALIDATE_BEGINPASS_DEPTHSTENCILATTACHMENTVIEW_TYPE,
    VALIDATE_BEGINPASS_DEPTHSTENCILATTACHMENTVIEW_IMAGE_ALIVE,
    VALIDATE_BEGINPASS_DEPTHSTENCILATTACHMENTVIEW_IMAGE_VALID,
    VALIDATE_BEGINPASS_DEPTHSTENCILATTACHMENTVIEW_SIZES,
    VALIDATE_BEGINPASS_DEPTHSTENCILATTACHMENTVIEW_SAMPLECOUNT,
    VALIDATE_BEGINPASS_ATTACHMENTS_EXPECTED,
    VALIDATE_AVP_RENDERPASS_EXPECTED,
    VALIDATE_ASR_RENDERPASS_EXPECTED,
    VALIDATE_APIP_PIPELINE_VALID_ID,
    VALIDATE_APIP_PIPELINE_EXISTS,
    VALIDATE_APIP_PIPELINE_VALID,
    VALIDATE_APIP_PASS_EXPECTED,
    VALIDATE_APIP_PIPELINE_SHADER_ALIVE,
    VALIDATE_APIP_PIPELINE_SHADER_VALID,
    VALIDATE_APIP_COMPUTEPASS_EXPECTED,
    VALIDATE_APIP_RENDERPASS_EXPECTED,
    VALIDATE_APIP_SWAPCHAIN_COLOR_COUNT,
    VALIDATE_APIP_SWAPCHAIN_COLOR_FORMAT,
    VALIDATE_APIP_SWAPCHAIN_DEPTH_FORMAT,
    VALIDATE_APIP_SWAPCHAIN_SAMPLE_COUNT,
    VALIDATE_APIP_ATTACHMENTS_ALIVE,
    VALIDATE_APIP_COLORATTACHMENTS_COUNT,
    VALIDATE_APIP_COLORATTACHMENTS_VIEW_VALID,
    VALIDATE_APIP_COLORATTACHMENTS_IMAGE_VALID,
    VALIDATE_APIP_COLORATTACHMENTS_FORMAT,
    VALIDATE_APIP_DEPTHSTENCILATTACHMENT_VIEW_VALID,
    VALIDATE_APIP_DEPTHSTENCILATTACHMENT_IMAGE_VALID,
    VALIDATE_APIP_DEPTHSTENCILATTACHMENT_FORMAT,
    VALIDATE_APIP_ATTACHMENT_SAMPLE_COUNT,
    VALIDATE_ABND_PASS_EXPECTED,
    VALIDATE_ABND_EMPTY_BINDINGS,
    VALIDATE_ABND_NO_PIPELINE,
    VALIDATE_ABND_PIPELINE_ALIVE,
    VALIDATE_ABND_PIPELINE_VALID,
    VALIDATE_ABND_PIPELINE_SHADER_ALIVE,
    VALIDATE_ABND_PIPELINE_SHADER_VALID,
    VALIDATE_ABND_COMPUTE_EXPECTED_NO_VBUFS,
    VALIDATE_ABND_COMPUTE_EXPECTED_NO_IBUF,
    VALIDATE_ABND_EXPECTED_VBUF,
    VALIDATE_ABND_VBUF_ALIVE,
    VALIDATE_ABND_VBUF_USAGE,
    VALIDATE_ABND_VBUF_OVERFLOW,
    VALIDATE_ABND_EXPECTED_NO_IBUF,
    VALIDATE_ABND_EXPECTED_IBUF,
    VALIDATE_ABND_IBUF_ALIVE,
    VALIDATE_ABND_IBUF_USAGE,
    VALIDATE_ABND_IBUF_OVERFLOW,
    VALIDATE_ABND_EXPECTED_VIEW_BINDING,
    VALIDATE_ABND_VIEW_ALIVE,
    VALIDATE_ABND_EXPECT_TEXVIEW,
    VALIDATE_ABND_EXPECT_SBVIEW,
    VALIDATE_ABND_EXPECT_SIMGVIEW,
    VALIDATE_ABND_TEXVIEW_IMAGETYPE_MISMATCH,
    VALIDATE_ABND_TEXVIEW_EXPECTED_MULTISAMPLED_IMAGE,
    VALIDATE_ABND_TEXVIEW_EXPECTED_NON_MULTISAMPLED_IMAGE,
    VALIDATE_ABND_TEXVIEW_EXPECTED_FILTERABLE_IMAGE,
    VALIDATE_ABND_TEXVIEW_EXPECTED_DEPTH_IMAGE,
    VALIDATE_ABND_SBVIEW_READWRITE_IMMUTABLE,
    VALIDATE_ABND_SIMGVIEW_COMPUTE_PASS_EXPECTED,
    VALIDATE_ABND_SIMGVIEW_IMAGETYPE_MISMATCH,
    VALIDATE_ABND_SIMGVIEW_ACCESSFORMAT,
    VALIDATE_ABND_EXPECTED_SAMPLER_BINDING,
    VALIDATE_ABND_UNEXPECTED_SAMPLER_COMPARE_NEVER,
    VALIDATE_ABND_EXPECTED_SAMPLER_COMPARE_NEVER,
    VALIDATE_ABND_EXPECTED_NONFILTERING_SAMPLER,
    VALIDATE_ABND_SAMPLER_ALIVE,
    VALIDATE_ABND_SAMPLER_VALID,
    VALIDATE_ABND_TEXTURE_BINDING_VS_DEPTHSTENCIL_ATTACHMENT,
    VALIDATE_ABND_TEXTURE_BINDING_VS_COLOR_ATTACHMENT,
    VALIDATE_ABND_TEXTURE_BINDING_VS_RESOLVE_ATTACHMENT,
    VALIDATE_ABND_TEXTURE_VS_STORAGEIMAGE_BINDING,
    VALIDATE_AU_PASS_EXPECTED,
    VALIDATE_AU_NO_PIPELINE,
    VALIDATE_AU_PIPELINE_ALIVE,
    VALIDATE_AU_PIPELINE_VALID,
    VALIDATE_AU_PIPELINE_SHADER_ALIVE,
    VALIDATE_AU_PIPELINE_SHADER_VALID,
    VALIDATE_AU_NO_UNIFORMBLOCK_AT_SLOT,
    VALIDATE_AU_SIZE,
    VALIDATE_DRAW_RENDERPASS_EXPECTED,
    VALIDATE_DRAW_BASEELEMENT_GE_ZERO,
    VALIDATE_DRAW_NUMELEMENTS_GE_ZERO,
    VALIDATE_DRAW_NUMINSTANCES_GE_ZERO,
    VALIDATE_DRAW_EX_RENDERPASS_EXPECTED,
    VALIDATE_DRAW_EX_BASEELEMENT_GE_ZERO,
    VALIDATE_DRAW_EX_NUMELEMENTS_GE_ZERO,
    VALIDATE_DRAW_EX_NUMINSTANCES_GE_ZERO,
    VALIDATE_DRAW_EX_BASEINSTANCE_GE_ZERO,
    VALIDATE_DRAW_EX_BASEVERTEX_VS_INDEXED,
    VALIDATE_DRAW_EX_BASEINSTANCE_VS_INSTANCED,
    VALIDATE_DRAW_EX_BASEVERTEX_NOT_SUPPORTED,
    VALIDATE_DRAW_EX_BASEINSTANCE_NOT_SUPPORTED,
    VALIDATE_DRAW_REQUIRED_BINDINGS_OR_UNIFORMS_MISSING,
    VALIDATE_DISPATCH_COMPUTEPASS_EXPECTED,
    VALIDATE_DISPATCH_NUMGROUPSX,
    VALIDATE_DISPATCH_NUMGROUPSY,
    VALIDATE_DISPATCH_NUMGROUPSZ,
    VALIDATE_DISPATCH_REQUIRED_BINDINGS_OR_UNIFORMS_MISSING,
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

/// sg_desc
///
/// The sg_desc struct contains configuration values for sokol_gfx,
/// it is used as parameter to the sg_setup() call.
///
/// The default configuration is:
///
/// .buffer_pool_size                   128
/// .image_pool_size                    128
/// .sampler_pool_size                  64
/// .shader_pool_size                   32
/// .pipeline_pool_size                 64
/// .view_pool_size                     256
/// .uniform_buffer_size                4 MB (4*1024*1024)
/// .max_commit_listeners               1024
/// .disable_validation                 false
/// .metal.force_managed_storage_mode   false
/// .metal.use_command_buffer_with_retained_references  false
/// .wgpu.disable_bindgroups_cache      false
/// .wgpu.bindgroups_cache_size         1024
/// .vulkan.copy_staging_buffer_size    4 MB
/// .vulkan.stream_staging_buffer_size  16 MB
/// .vulkan.descriptor_buffer_size      16 MB
///
/// .allocator.alloc_fn     0 (in this case, malloc() will be called)
/// .allocator.free_fn      0 (in this case, free() will be called)
/// .allocator.user_data    0
///
/// .environment.defaults.color_format: default value depends on selected backend:
///     all GL backends:    SG_PIXELFORMAT_RGBA8
///     Metal and D3D11:    SG_PIXELFORMAT_BGRA8
///     WebGPU:             *no default* (must be queried from WebGPU swapchain object)
/// .environment.defaults.depth_format: SG_PIXELFORMAT_DEPTH_STENCIL
/// .environment.defaults.sample_count: 1
///
/// Metal specific:
///     (NOTE: All Objective-C object references are transferred through
///     a bridged cast (__bridge const void*) to sokol_gfx, which will use an
///     unretained bridged cast (__bridge id<xxx>) to retrieve the Objective-C
///     references back. Since the bridge cast is unretained, the caller
///     must hold a strong reference to the Objective-C object until sg_setup()
///     returns.
///
///     .metal.force_managed_storage_mode
///         when enabled, Metal buffers and texture resources are created in managed storage
///         mode, otherwise sokol-gfx will decide whether to create buffers and
///         textures in managed or shared storage mode (this is mainly a debugging option)
///     .metal.use_command_buffer_with_retained_references
///         when true, the sokol-gfx Metal backend will use Metal command buffers which
///         bump the reference count of resource objects as long as they are inflight,
///         this is slower than the default command-buffer-with-unretained-references
///         method, this may be a workaround when confronted with lifetime validation
///         errors from the Metal validation layer until a proper fix has been implemented
///     .environment.metal.device
///         a pointer to the MTLDevice object
///
/// D3D11 specific:
///     .environment.d3d11.device
///         a pointer to the ID3D11Device object, this must have been created
///         before sg_setup() is called
///     .environment.d3d11.device_context
///         a pointer to the ID3D11DeviceContext object
///     .d3d11.shader_debugging
///         set this to true to compile shaders which are provided as HLSL source
///         code with debug information and without optimization, this allows
///         shader debugging in tools like RenderDoc, to output source code
///         instead of byte code from sokol-shdc, omit the `--binary` cmdline
///         option
///
/// WebGPU specific:
///     .wgpu.disable_bindgroups_cache
///         When this is true, the WebGPU backend will create and immediately
///         release a BindGroup object in the sg_apply_bindings() call, only
///         use this for debugging purposes.
///     .wgpu.bindgroups_cache_size
///         The size of the bindgroups cache for re-using BindGroup objects
///         between sg_apply_bindings() calls. The smaller the cache size,
///         the more likely are cache slot collisions which will cause
///         a BindGroups object to be destroyed and a new one created.
///         Use the information returned by sg_query_stats() to check
///         if this is a frequent occurrence, and increase the cache size as
///         needed (the default is 1024).
///         NOTE: wgpu_bindgroups_cache_size must be a power-of-2 number!
///     .environment.wgpu.device
///         a WGPUDevice handle
///
/// Vulkan specific:
///     .vulkan.copy_staging_buffer_size
///         Size of the staging buffer in bytes for uploading the initial
///         content of buffers and images, and for updating
///         .usage.dynamic_update resources. The default is 4 MB,
///         bigger resource updates are split into multiple chunks
///         of the staging buffer size
///     .vulkan.stream_staging_buffer_size
///         Size of the staging buffer in bytes for updating .usage.stream_update
///         resources. The default is 16 MB. The size must be big enough
///         to accomodate all update into .usage.stream_update resources.
///         Any additional data will cause an error log message and
///         incomplete rendering. Note that the actually allocated size
///         will be twice as much because the stream-staging-buffer is
///         double-buffered.
///     .vulkan.descriptor_buffer_size
///         Size of the descriptor-upload buffer in bytes. The default
///         size is 16 bytes. The size must be big enough to accomodate
///         all unifrom-block, view- and sampler-bindings in a single
///         frame (assume a worst-case of 256 bytes per binding). Note
///         that the actually allocated size will be twice as much
///         because the descriptor-buffer is double-buffered.
///
/// When using sokol_gfx.h and sokol_app.h together, consider using the
/// helper function sglue_environment() in the sokol_glue.h header to
/// initialize the sg_desc.environment nested struct. sglue_environment() returns
/// a completely initialized sg_environment struct with information
/// provided by sokol_app.h.
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

pub const VulkanEnvironment = extern struct {
    physical_device: ?*const anyopaque = null,
    device: ?*const anyopaque = null,
    queue: ?*const anyopaque = null,
    queue_family_index: u32 = 0,
};

pub const Environment = extern struct {
    defaults: EnvironmentDefaults = .{},
    metal: MetalEnvironment = .{},
    d3d11: D3d11Environment = .{},
    wgpu: WgpuEnvironment = .{},
    vulkan: VulkanEnvironment = .{},
};

/// sg_commit_listener
///
/// Used with function sg_add_commit_listener() to add a callback
/// which will be called in sg_commit(). This is useful for libraries
/// building on top of sokol-gfx to be notified about when a frame
/// ends (instead of having to guess, or add a manual 'new-frame'
/// function.
pub const CommitListener = extern struct {
    func: ?*const fn (?*anyopaque) callconv(.c) void = null,
    user_data: ?*anyopaque = null,
};

/// sg_allocator
///
/// Used in sg_desc to provide custom memory-alloc and -free functions
/// to sokol_gfx.h. If memory management should be overridden, both the
/// alloc_fn and free_fn function must be provided (e.g. it's not valid to
/// override one function but not the other).
pub const Allocator = extern struct {
    alloc_fn: ?*const fn (usize, ?*anyopaque) callconv(.c) ?*anyopaque = null,
    free_fn: ?*const fn (?*anyopaque, ?*anyopaque) callconv(.c) void = null,
    user_data: ?*anyopaque = null,
};

/// sg_logger
///
/// Used in sg_desc to provide a logging function. Please be aware
/// that without logging function, sokol-gfx will be completely
/// silent, e.g. it will not report errors, warnings and
/// validation layer messages. For maximum error verbosity,
/// compile in debug mode (e.g. NDEBUG *not* defined) and provide a
/// compatible logger function in the sg_setup() call
/// (for instance the standard logging function from sokol_log.h).
pub const Logger = extern struct {
    func: ?*const fn ([*c]const u8, u32, u32, [*c]const u8, u32, [*c]const u8, ?*anyopaque) callconv(.c) void = null,
    user_data: ?*anyopaque = null,
};

pub const D3d11Desc = extern struct {
    shader_debugging: bool = false,
};

pub const MetalDesc = extern struct {
    force_managed_storage_mode: bool = false,
    use_command_buffer_with_retained_references: bool = false,
};

pub const WgpuDesc = extern struct {
    disable_bindgroups_cache: bool = false,
    bindgroups_cache_size: i32 = 0,
};

pub const VulkanDesc = extern struct {
    copy_staging_buffer_size: i32 = 0,
    stream_staging_buffer_size: i32 = 0,
    descriptor_buffer_size: i32 = 0,
};

pub const Desc = extern struct {
    _start_canary: u32 = 0,
    buffer_pool_size: i32 = 0,
    image_pool_size: i32 = 0,
    sampler_pool_size: i32 = 0,
    shader_pool_size: i32 = 0,
    pipeline_pool_size: i32 = 0,
    view_pool_size: i32 = 0,
    uniform_buffer_size: i32 = 0,
    max_commit_listeners: i32 = 0,
    disable_validation: bool = false,
    enforce_portable_limits: bool = false,
    d3d11: D3d11Desc = .{},
    metal: MetalDesc = .{},
    wgpu: WgpuDesc = .{},
    vulkan: VulkanDesc = .{},
    allocator: Allocator = .{},
    logger: Logger = .{},
    environment: Environment = .{},
    _end_canary: u32 = 0,
};

/// setup and misc functions
extern fn sg_setup([*c]const Desc) void;

/// setup and misc functions
pub fn setup(desc: Desc) void {
    sg_setup(&desc);
}

extern fn sg_shutdown() void;

pub fn shutdown() void {
    sg_shutdown();
}

extern fn sg_isvalid() bool;

pub fn isvalid() bool {
    return sg_isvalid();
}

extern fn sg_reset_state_cache() void;

pub fn resetStateCache() void {
    sg_reset_state_cache();
}

extern fn sg_push_debug_group([*c]const u8) void;

pub fn pushDebugGroup(name: [:0]const u8) void {
    sg_push_debug_group(@ptrCast(name));
}

extern fn sg_pop_debug_group() void;

pub fn popDebugGroup() void {
    sg_pop_debug_group();
}

extern fn sg_add_commit_listener(CommitListener) bool;

pub fn addCommitListener(listener: CommitListener) bool {
    return sg_add_commit_listener(listener);
}

extern fn sg_remove_commit_listener(CommitListener) bool;

pub fn removeCommitListener(listener: CommitListener) bool {
    return sg_remove_commit_listener(listener);
}

/// resource creation, destruction and updating
extern fn sg_make_buffer([*c]const BufferDesc) Buffer;

/// resource creation, destruction and updating
pub fn makeBuffer(desc: BufferDesc) Buffer {
    return sg_make_buffer(&desc);
}

extern fn sg_make_image([*c]const ImageDesc) Image;

pub fn makeImage(desc: ImageDesc) Image {
    return sg_make_image(&desc);
}

extern fn sg_make_sampler([*c]const SamplerDesc) Sampler;

pub fn makeSampler(desc: SamplerDesc) Sampler {
    return sg_make_sampler(&desc);
}

extern fn sg_make_shader([*c]const ShaderDesc) Shader;

pub fn makeShader(desc: ShaderDesc) Shader {
    return sg_make_shader(&desc);
}

extern fn sg_make_pipeline([*c]const PipelineDesc) Pipeline;

pub fn makePipeline(desc: PipelineDesc) Pipeline {
    return sg_make_pipeline(&desc);
}

extern fn sg_make_view([*c]const ViewDesc) View;

pub fn makeView(desc: ViewDesc) View {
    return sg_make_view(&desc);
}

extern fn sg_destroy_buffer(Buffer) void;

pub fn destroyBuffer(buf: Buffer) void {
    sg_destroy_buffer(buf);
}

extern fn sg_destroy_image(Image) void;

pub fn destroyImage(img: Image) void {
    sg_destroy_image(img);
}

extern fn sg_destroy_sampler(Sampler) void;

pub fn destroySampler(smp: Sampler) void {
    sg_destroy_sampler(smp);
}

extern fn sg_destroy_shader(Shader) void;

pub fn destroyShader(shd: Shader) void {
    sg_destroy_shader(shd);
}

extern fn sg_destroy_pipeline(Pipeline) void;

pub fn destroyPipeline(pip: Pipeline) void {
    sg_destroy_pipeline(pip);
}

extern fn sg_destroy_view(View) void;

pub fn destroyView(view: View) void {
    sg_destroy_view(view);
}

extern fn sg_update_buffer(Buffer, [*c]const Range) void;

pub fn updateBuffer(buf: Buffer, data: Range) void {
    sg_update_buffer(buf, &data);
}

extern fn sg_update_image(Image, [*c]const ImageData) void;

pub fn updateImage(img: Image, data: ImageData) void {
    sg_update_image(img, &data);
}

extern fn sg_append_buffer(Buffer, [*c]const Range) i32;

pub fn appendBuffer(buf: Buffer, data: Range) i32 {
    return sg_append_buffer(buf, &data);
}

extern fn sg_query_buffer_overflow(Buffer) bool;

pub fn queryBufferOverflow(buf: Buffer) bool {
    return sg_query_buffer_overflow(buf);
}

extern fn sg_query_buffer_will_overflow(Buffer, usize) bool;

pub fn queryBufferWillOverflow(buf: Buffer, size: usize) bool {
    return sg_query_buffer_will_overflow(buf, size);
}

/// render and compute functions
extern fn sg_begin_pass([*c]const Pass) void;

/// render and compute functions
pub fn beginPass(pass: Pass) void {
    sg_begin_pass(&pass);
}

extern fn sg_apply_viewport(i32, i32, i32, i32, bool) void;

pub fn applyViewport(x: i32, y: i32, width: i32, height: i32, origin_top_left: bool) void {
    sg_apply_viewport(x, y, width, height, origin_top_left);
}

extern fn sg_apply_viewportf(f32, f32, f32, f32, bool) void;

pub fn applyViewportf(x: f32, y: f32, width: f32, height: f32, origin_top_left: bool) void {
    sg_apply_viewportf(x, y, width, height, origin_top_left);
}

extern fn sg_apply_scissor_rect(i32, i32, i32, i32, bool) void;

pub fn applyScissorRect(x: i32, y: i32, width: i32, height: i32, origin_top_left: bool) void {
    sg_apply_scissor_rect(x, y, width, height, origin_top_left);
}

extern fn sg_apply_scissor_rectf(f32, f32, f32, f32, bool) void;

pub fn applyScissorRectf(x: f32, y: f32, width: f32, height: f32, origin_top_left: bool) void {
    sg_apply_scissor_rectf(x, y, width, height, origin_top_left);
}

extern fn sg_apply_pipeline(Pipeline) void;

pub fn applyPipeline(pip: Pipeline) void {
    sg_apply_pipeline(pip);
}

extern fn sg_apply_bindings([*c]const Bindings) void;

pub fn applyBindings(bindings: Bindings) void {
    sg_apply_bindings(&bindings);
}

extern fn sg_apply_uniforms(u32, [*c]const Range) void;

pub fn applyUniforms(ub_slot: u32, data: Range) void {
    sg_apply_uniforms(ub_slot, &data);
}

extern fn sg_draw(u32, u32, u32) void;

pub fn draw(base_element: u32, num_elements: u32, num_instances: u32) void {
    sg_draw(base_element, num_elements, num_instances);
}

extern fn sg_draw_ex(i32, i32, i32, i32, i32) void;

pub fn drawEx(base_element: i32, num_elements: i32, num_instances: i32, base_vertex: i32, base_instance: i32) void {
    sg_draw_ex(base_element, num_elements, num_instances, base_vertex, base_instance);
}

extern fn sg_dispatch(i32, i32, i32) void;

pub fn dispatch(num_groups_x: i32, num_groups_y: i32, num_groups_z: i32) void {
    sg_dispatch(num_groups_x, num_groups_y, num_groups_z);
}

extern fn sg_end_pass() void;

pub fn endPass() void {
    sg_end_pass();
}

extern fn sg_commit() void;

pub fn commit() void {
    sg_commit();
}

/// getting information
extern fn sg_query_desc() Desc;

/// getting information
pub fn queryDesc() Desc {
    return sg_query_desc();
}

extern fn sg_query_backend() Backend;

pub fn queryBackend() Backend {
    return sg_query_backend();
}

extern fn sg_query_features() Features;

pub fn queryFeatures() Features {
    return sg_query_features();
}

extern fn sg_query_limits() Limits;

pub fn queryLimits() Limits {
    return sg_query_limits();
}

extern fn sg_query_pixelformat(PixelFormat) PixelformatInfo;

pub fn queryPixelformat(fmt: PixelFormat) PixelformatInfo {
    return sg_query_pixelformat(fmt);
}

extern fn sg_query_row_pitch(PixelFormat, i32, i32) i32;

pub fn queryRowPitch(fmt: PixelFormat, width: i32, row_align_bytes: i32) i32 {
    return sg_query_row_pitch(fmt, width, row_align_bytes);
}

extern fn sg_query_surface_pitch(PixelFormat, i32, i32, i32) i32;

pub fn querySurfacePitch(fmt: PixelFormat, width: i32, height: i32, row_align_bytes: i32) i32 {
    return sg_query_surface_pitch(fmt, width, height, row_align_bytes);
}

/// get current state of a resource (INITIAL, ALLOC, VALID, FAILED, INVALID)
extern fn sg_query_buffer_state(Buffer) ResourceState;

/// get current state of a resource (INITIAL, ALLOC, VALID, FAILED, INVALID)
pub fn queryBufferState(buf: Buffer) ResourceState {
    return sg_query_buffer_state(buf);
}

extern fn sg_query_image_state(Image) ResourceState;

pub fn queryImageState(img: Image) ResourceState {
    return sg_query_image_state(img);
}

extern fn sg_query_sampler_state(Sampler) ResourceState;

pub fn querySamplerState(smp: Sampler) ResourceState {
    return sg_query_sampler_state(smp);
}

extern fn sg_query_shader_state(Shader) ResourceState;

pub fn queryShaderState(shd: Shader) ResourceState {
    return sg_query_shader_state(shd);
}

extern fn sg_query_pipeline_state(Pipeline) ResourceState;

pub fn queryPipelineState(pip: Pipeline) ResourceState {
    return sg_query_pipeline_state(pip);
}

extern fn sg_query_view_state(View) ResourceState;

pub fn queryViewState(view: View) ResourceState {
    return sg_query_view_state(view);
}

/// get runtime information about a resource
extern fn sg_query_buffer_info(Buffer) BufferInfo;

/// get runtime information about a resource
pub fn queryBufferInfo(buf: Buffer) BufferInfo {
    return sg_query_buffer_info(buf);
}

extern fn sg_query_image_info(Image) ImageInfo;

pub fn queryImageInfo(img: Image) ImageInfo {
    return sg_query_image_info(img);
}

extern fn sg_query_sampler_info(Sampler) SamplerInfo;

pub fn querySamplerInfo(smp: Sampler) SamplerInfo {
    return sg_query_sampler_info(smp);
}

extern fn sg_query_shader_info(Shader) ShaderInfo;

pub fn queryShaderInfo(shd: Shader) ShaderInfo {
    return sg_query_shader_info(shd);
}

extern fn sg_query_pipeline_info(Pipeline) PipelineInfo;

pub fn queryPipelineInfo(pip: Pipeline) PipelineInfo {
    return sg_query_pipeline_info(pip);
}

extern fn sg_query_view_info(View) ViewInfo;

pub fn queryViewInfo(view: View) ViewInfo {
    return sg_query_view_info(view);
}

/// get desc structs matching a specific resource (NOTE that not all creation attributes may be provided)
extern fn sg_query_buffer_desc(Buffer) BufferDesc;

/// get desc structs matching a specific resource (NOTE that not all creation attributes may be provided)
pub fn queryBufferDesc(buf: Buffer) BufferDesc {
    return sg_query_buffer_desc(buf);
}

extern fn sg_query_image_desc(Image) ImageDesc;

pub fn queryImageDesc(img: Image) ImageDesc {
    return sg_query_image_desc(img);
}

extern fn sg_query_sampler_desc(Sampler) SamplerDesc;

pub fn querySamplerDesc(smp: Sampler) SamplerDesc {
    return sg_query_sampler_desc(smp);
}

extern fn sg_query_shader_desc(Shader) ShaderDesc;

pub fn queryShaderDesc(shd: Shader) ShaderDesc {
    return sg_query_shader_desc(shd);
}

extern fn sg_query_pipeline_desc(Pipeline) PipelineDesc;

pub fn queryPipelineDesc(pip: Pipeline) PipelineDesc {
    return sg_query_pipeline_desc(pip);
}

extern fn sg_query_view_desc(View) ViewDesc;

pub fn queryViewDesc(view: View) ViewDesc {
    return sg_query_view_desc(view);
}

/// get resource creation desc struct with their default values replaced
extern fn sg_query_buffer_defaults([*c]const BufferDesc) BufferDesc;

/// get resource creation desc struct with their default values replaced
pub fn queryBufferDefaults(desc: BufferDesc) BufferDesc {
    return sg_query_buffer_defaults(&desc);
}

extern fn sg_query_image_defaults([*c]const ImageDesc) ImageDesc;

pub fn queryImageDefaults(desc: ImageDesc) ImageDesc {
    return sg_query_image_defaults(&desc);
}

extern fn sg_query_sampler_defaults([*c]const SamplerDesc) SamplerDesc;

pub fn querySamplerDefaults(desc: SamplerDesc) SamplerDesc {
    return sg_query_sampler_defaults(&desc);
}

extern fn sg_query_shader_defaults([*c]const ShaderDesc) ShaderDesc;

pub fn queryShaderDefaults(desc: ShaderDesc) ShaderDesc {
    return sg_query_shader_defaults(&desc);
}

extern fn sg_query_pipeline_defaults([*c]const PipelineDesc) PipelineDesc;

pub fn queryPipelineDefaults(desc: PipelineDesc) PipelineDesc {
    return sg_query_pipeline_defaults(&desc);
}

extern fn sg_query_view_defaults([*c]const ViewDesc) ViewDesc;

pub fn queryViewDefaults(desc: ViewDesc) ViewDesc {
    return sg_query_view_defaults(&desc);
}

/// assorted query functions
extern fn sg_query_buffer_size(Buffer) usize;

/// assorted query functions
pub fn queryBufferSize(buf: Buffer) usize {
    return sg_query_buffer_size(buf);
}

extern fn sg_query_buffer_usage(Buffer) BufferUsage;

pub fn queryBufferUsage(buf: Buffer) BufferUsage {
    return sg_query_buffer_usage(buf);
}

extern fn sg_query_image_type(Image) ImageType;

pub fn queryImageType(img: Image) ImageType {
    return sg_query_image_type(img);
}

extern fn sg_query_image_width(Image) i32;

pub fn queryImageWidth(img: Image) i32 {
    return sg_query_image_width(img);
}

extern fn sg_query_image_height(Image) i32;

pub fn queryImageHeight(img: Image) i32 {
    return sg_query_image_height(img);
}

extern fn sg_query_image_num_slices(Image) i32;

pub fn queryImageNumSlices(img: Image) i32 {
    return sg_query_image_num_slices(img);
}

extern fn sg_query_image_num_mipmaps(Image) i32;

pub fn queryImageNumMipmaps(img: Image) i32 {
    return sg_query_image_num_mipmaps(img);
}

extern fn sg_query_image_pixelformat(Image) PixelFormat;

pub fn queryImagePixelformat(img: Image) PixelFormat {
    return sg_query_image_pixelformat(img);
}

extern fn sg_query_image_usage(Image) ImageUsage;

pub fn queryImageUsage(img: Image) ImageUsage {
    return sg_query_image_usage(img);
}

extern fn sg_query_image_sample_count(Image) i32;

pub fn queryImageSampleCount(img: Image) i32 {
    return sg_query_image_sample_count(img);
}

extern fn sg_query_view_type(View) ViewType;

pub fn queryViewType(view: View) ViewType {
    return sg_query_view_type(view);
}

extern fn sg_query_view_image(View) Image;

pub fn queryViewImage(view: View) Image {
    return sg_query_view_image(view);
}

extern fn sg_query_view_buffer(View) Buffer;

pub fn queryViewBuffer(view: View) Buffer {
    return sg_query_view_buffer(view);
}

/// separate resource allocation and initialization (for async setup)
extern fn sg_alloc_buffer() Buffer;

/// separate resource allocation and initialization (for async setup)
pub fn allocBuffer() Buffer {
    return sg_alloc_buffer();
}

extern fn sg_alloc_image() Image;

pub fn allocImage() Image {
    return sg_alloc_image();
}

extern fn sg_alloc_sampler() Sampler;

pub fn allocSampler() Sampler {
    return sg_alloc_sampler();
}

extern fn sg_alloc_shader() Shader;

pub fn allocShader() Shader {
    return sg_alloc_shader();
}

extern fn sg_alloc_pipeline() Pipeline;

pub fn allocPipeline() Pipeline {
    return sg_alloc_pipeline();
}

extern fn sg_alloc_view() View;

pub fn allocView() View {
    return sg_alloc_view();
}

extern fn sg_dealloc_buffer(Buffer) void;

pub fn deallocBuffer(buf: Buffer) void {
    sg_dealloc_buffer(buf);
}

extern fn sg_dealloc_image(Image) void;

pub fn deallocImage(img: Image) void {
    sg_dealloc_image(img);
}

extern fn sg_dealloc_sampler(Sampler) void;

pub fn deallocSampler(smp: Sampler) void {
    sg_dealloc_sampler(smp);
}

extern fn sg_dealloc_shader(Shader) void;

pub fn deallocShader(shd: Shader) void {
    sg_dealloc_shader(shd);
}

extern fn sg_dealloc_pipeline(Pipeline) void;

pub fn deallocPipeline(pip: Pipeline) void {
    sg_dealloc_pipeline(pip);
}

extern fn sg_dealloc_view(View) void;

pub fn deallocView(view: View) void {
    sg_dealloc_view(view);
}

extern fn sg_init_buffer(Buffer, [*c]const BufferDesc) void;

pub fn initBuffer(buf: Buffer, desc: BufferDesc) void {
    sg_init_buffer(buf, &desc);
}

extern fn sg_init_image(Image, [*c]const ImageDesc) void;

pub fn initImage(img: Image, desc: ImageDesc) void {
    sg_init_image(img, &desc);
}

extern fn sg_init_sampler(Sampler, [*c]const SamplerDesc) void;

pub fn initSampler(smg: Sampler, desc: SamplerDesc) void {
    sg_init_sampler(smg, &desc);
}

extern fn sg_init_shader(Shader, [*c]const ShaderDesc) void;

pub fn initShader(shd: Shader, desc: ShaderDesc) void {
    sg_init_shader(shd, &desc);
}

extern fn sg_init_pipeline(Pipeline, [*c]const PipelineDesc) void;

pub fn initPipeline(pip: Pipeline, desc: PipelineDesc) void {
    sg_init_pipeline(pip, &desc);
}

extern fn sg_init_view(View, [*c]const ViewDesc) void;

pub fn initView(view: View, desc: ViewDesc) void {
    sg_init_view(view, &desc);
}

extern fn sg_uninit_buffer(Buffer) void;

pub fn uninitBuffer(buf: Buffer) void {
    sg_uninit_buffer(buf);
}

extern fn sg_uninit_image(Image) void;

pub fn uninitImage(img: Image) void {
    sg_uninit_image(img);
}

extern fn sg_uninit_sampler(Sampler) void;

pub fn uninitSampler(smp: Sampler) void {
    sg_uninit_sampler(smp);
}

extern fn sg_uninit_shader(Shader) void;

pub fn uninitShader(shd: Shader) void {
    sg_uninit_shader(shd);
}

extern fn sg_uninit_pipeline(Pipeline) void;

pub fn uninitPipeline(pip: Pipeline) void {
    sg_uninit_pipeline(pip);
}

extern fn sg_uninit_view(View) void;

pub fn uninitView(view: View) void {
    sg_uninit_view(view);
}

extern fn sg_fail_buffer(Buffer) void;

pub fn failBuffer(buf: Buffer) void {
    sg_fail_buffer(buf);
}

extern fn sg_fail_image(Image) void;

pub fn failImage(img: Image) void {
    sg_fail_image(img);
}

extern fn sg_fail_sampler(Sampler) void;

pub fn failSampler(smp: Sampler) void {
    sg_fail_sampler(smp);
}

extern fn sg_fail_shader(Shader) void;

pub fn failShader(shd: Shader) void {
    sg_fail_shader(shd);
}

extern fn sg_fail_pipeline(Pipeline) void;

pub fn failPipeline(pip: Pipeline) void {
    sg_fail_pipeline(pip);
}

extern fn sg_fail_view(View) void;

pub fn failView(view: View) void {
    sg_fail_view(view);
}

/// frame stats
extern fn sg_enable_frame_stats() void;

/// frame stats
pub fn enableFrameStats() void {
    sg_enable_frame_stats();
}

extern fn sg_disable_frame_stats() void;

pub fn disableFrameStats() void {
    sg_disable_frame_stats();
}

extern fn sg_frame_stats_enabled() bool;

pub fn frameStatsEnabled() bool {
    return sg_frame_stats_enabled();
}

extern fn sg_query_frame_stats() FrameStats;

pub fn queryFrameStats() FrameStats {
    return sg_query_frame_stats();
}

/// Backend-specific structs and functions, these may come in handy for mixing
///   sokol-gfx rendering with 'native backend' rendering functions.
///
///   This group of functions will be expanded as needed.
pub const D3d11BufferInfo = extern struct {
    buf: ?*const anyopaque = null,
};

pub const D3d11ImageInfo = extern struct {
    tex2d: ?*const anyopaque = null,
    tex3d: ?*const anyopaque = null,
    res: ?*const anyopaque = null,
};

pub const D3d11SamplerInfo = extern struct {
    smp: ?*const anyopaque = null,
};

pub const D3d11ShaderInfo = extern struct {
    cbufs: [8]?*const anyopaque = [_]?*const anyopaque{null} ** 8,
    vs: ?*const anyopaque = null,
    fs: ?*const anyopaque = null,
};

pub const D3d11PipelineInfo = extern struct {
    il: ?*const anyopaque = null,
    rs: ?*const anyopaque = null,
    dss: ?*const anyopaque = null,
    bs: ?*const anyopaque = null,
};

pub const D3d11ViewInfo = extern struct {
    srv: ?*const anyopaque = null,
    uav: ?*const anyopaque = null,
    rtv: ?*const anyopaque = null,
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
    vertex_lib: ?*const anyopaque = null,
    fragment_lib: ?*const anyopaque = null,
    vertex_func: ?*const anyopaque = null,
    fragment_func: ?*const anyopaque = null,
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
    render_pipeline: ?*const anyopaque = null,
    compute_pipeline: ?*const anyopaque = null,
};

pub const WgpuViewInfo = extern struct {
    view: ?*const anyopaque = null,
};

pub const GlBufferInfo = extern struct {
    buf: [2]u32 = [_]u32{0} ** 2,
    active_slot: i32 = 0,
};

pub const GlImageInfo = extern struct {
    tex: [2]u32 = [_]u32{0} ** 2,
    tex_target: u32 = 0,
    active_slot: i32 = 0,
};

pub const GlSamplerInfo = extern struct {
    smp: u32 = 0,
};

pub const GlShaderInfo = extern struct {
    prog: u32 = 0,
};

pub const GlViewInfo = extern struct {
    tex_view: [2]u32 = [_]u32{0} ** 2,
    msaa_render_buffer: u32 = 0,
    msaa_resolve_frame_buffer: u32 = 0,
};

/// D3D11: return ID3D11Device
extern fn sg_d3d11_device() ?*const anyopaque;

/// D3D11: return ID3D11Device
pub fn d3d11Device() ?*const anyopaque {
    return sg_d3d11_device();
}

/// D3D11: return ID3D11DeviceContext
extern fn sg_d3d11_device_context() ?*const anyopaque;

/// D3D11: return ID3D11DeviceContext
pub fn d3d11DeviceContext() ?*const anyopaque {
    return sg_d3d11_device_context();
}

/// D3D11: get internal buffer resource objects
extern fn sg_d3d11_query_buffer_info(Buffer) D3d11BufferInfo;

/// D3D11: get internal buffer resource objects
pub fn d3d11QueryBufferInfo(buf: Buffer) D3d11BufferInfo {
    return sg_d3d11_query_buffer_info(buf);
}

/// D3D11: get internal image resource objects
extern fn sg_d3d11_query_image_info(Image) D3d11ImageInfo;

/// D3D11: get internal image resource objects
pub fn d3d11QueryImageInfo(img: Image) D3d11ImageInfo {
    return sg_d3d11_query_image_info(img);
}

/// D3D11: get internal sampler resource objects
extern fn sg_d3d11_query_sampler_info(Sampler) D3d11SamplerInfo;

/// D3D11: get internal sampler resource objects
pub fn d3d11QuerySamplerInfo(smp: Sampler) D3d11SamplerInfo {
    return sg_d3d11_query_sampler_info(smp);
}

/// D3D11: get internal shader resource objects
extern fn sg_d3d11_query_shader_info(Shader) D3d11ShaderInfo;

/// D3D11: get internal shader resource objects
pub fn d3d11QueryShaderInfo(shd: Shader) D3d11ShaderInfo {
    return sg_d3d11_query_shader_info(shd);
}

/// D3D11: get internal pipeline resource objects
extern fn sg_d3d11_query_pipeline_info(Pipeline) D3d11PipelineInfo;

/// D3D11: get internal pipeline resource objects
pub fn d3d11QueryPipelineInfo(pip: Pipeline) D3d11PipelineInfo {
    return sg_d3d11_query_pipeline_info(pip);
}

/// D3D11: get internal view resource objects
extern fn sg_d3d11_query_view_info(View) D3d11ViewInfo;

/// D3D11: get internal view resource objects
pub fn d3d11QueryViewInfo(view: View) D3d11ViewInfo {
    return sg_d3d11_query_view_info(view);
}

/// Metal: return __bridge-casted MTLDevice
extern fn sg_mtl_device() ?*const anyopaque;

/// Metal: return __bridge-casted MTLDevice
pub fn mtlDevice() ?*const anyopaque {
    return sg_mtl_device();
}

/// Metal: return __bridge-casted MTLRenderCommandEncoder when inside render pass (otherwise zero)
extern fn sg_mtl_render_command_encoder() ?*const anyopaque;

/// Metal: return __bridge-casted MTLRenderCommandEncoder when inside render pass (otherwise zero)
pub fn mtlRenderCommandEncoder() ?*const anyopaque {
    return sg_mtl_render_command_encoder();
}

/// Metal: return __bridge-casted MTLComputeCommandEncoder when inside compute pass (otherwise zero)
extern fn sg_mtl_compute_command_encoder() ?*const anyopaque;

/// Metal: return __bridge-casted MTLComputeCommandEncoder when inside compute pass (otherwise zero)
pub fn mtlComputeCommandEncoder() ?*const anyopaque {
    return sg_mtl_compute_command_encoder();
}

/// Metal: get internal __bridge-casted buffer resource objects
extern fn sg_mtl_query_buffer_info(Buffer) MtlBufferInfo;

/// Metal: get internal __bridge-casted buffer resource objects
pub fn mtlQueryBufferInfo(buf: Buffer) MtlBufferInfo {
    return sg_mtl_query_buffer_info(buf);
}

/// Metal: get internal __bridge-casted image resource objects
extern fn sg_mtl_query_image_info(Image) MtlImageInfo;

/// Metal: get internal __bridge-casted image resource objects
pub fn mtlQueryImageInfo(img: Image) MtlImageInfo {
    return sg_mtl_query_image_info(img);
}

/// Metal: get internal __bridge-casted sampler resource objects
extern fn sg_mtl_query_sampler_info(Sampler) MtlSamplerInfo;

/// Metal: get internal __bridge-casted sampler resource objects
pub fn mtlQuerySamplerInfo(smp: Sampler) MtlSamplerInfo {
    return sg_mtl_query_sampler_info(smp);
}

/// Metal: get internal __bridge-casted shader resource objects
extern fn sg_mtl_query_shader_info(Shader) MtlShaderInfo;

/// Metal: get internal __bridge-casted shader resource objects
pub fn mtlQueryShaderInfo(shd: Shader) MtlShaderInfo {
    return sg_mtl_query_shader_info(shd);
}

/// Metal: get internal __bridge-casted pipeline resource objects
extern fn sg_mtl_query_pipeline_info(Pipeline) MtlPipelineInfo;

/// Metal: get internal __bridge-casted pipeline resource objects
pub fn mtlQueryPipelineInfo(pip: Pipeline) MtlPipelineInfo {
    return sg_mtl_query_pipeline_info(pip);
}

/// WebGPU: return WGPUDevice object
extern fn sg_wgpu_device() ?*const anyopaque;

/// WebGPU: return WGPUDevice object
pub fn wgpuDevice() ?*const anyopaque {
    return sg_wgpu_device();
}

/// WebGPU: return WGPUQueue object
extern fn sg_wgpu_queue() ?*const anyopaque;

/// WebGPU: return WGPUQueue object
pub fn wgpuQueue() ?*const anyopaque {
    return sg_wgpu_queue();
}

/// WebGPU: return this frame's WGPUCommandEncoder
extern fn sg_wgpu_command_encoder() ?*const anyopaque;

/// WebGPU: return this frame's WGPUCommandEncoder
pub fn wgpuCommandEncoder() ?*const anyopaque {
    return sg_wgpu_command_encoder();
}

/// WebGPU: return WGPURenderPassEncoder of current pass (returns 0 when outside pass or in a compute pass)
extern fn sg_wgpu_render_pass_encoder() ?*const anyopaque;

/// WebGPU: return WGPURenderPassEncoder of current pass (returns 0 when outside pass or in a compute pass)
pub fn wgpuRenderPassEncoder() ?*const anyopaque {
    return sg_wgpu_render_pass_encoder();
}

/// WebGPU: return WGPUComputePassEncoder of current pass (returns 0 when outside pass or in a render pass)
extern fn sg_wgpu_compute_pass_encoder() ?*const anyopaque;

/// WebGPU: return WGPUComputePassEncoder of current pass (returns 0 when outside pass or in a render pass)
pub fn wgpuComputePassEncoder() ?*const anyopaque {
    return sg_wgpu_compute_pass_encoder();
}

/// WebGPU: get internal buffer resource objects
extern fn sg_wgpu_query_buffer_info(Buffer) WgpuBufferInfo;

/// WebGPU: get internal buffer resource objects
pub fn wgpuQueryBufferInfo(buf: Buffer) WgpuBufferInfo {
    return sg_wgpu_query_buffer_info(buf);
}

/// WebGPU: get internal image resource objects
extern fn sg_wgpu_query_image_info(Image) WgpuImageInfo;

/// WebGPU: get internal image resource objects
pub fn wgpuQueryImageInfo(img: Image) WgpuImageInfo {
    return sg_wgpu_query_image_info(img);
}

/// WebGPU: get internal sampler resource objects
extern fn sg_wgpu_query_sampler_info(Sampler) WgpuSamplerInfo;

/// WebGPU: get internal sampler resource objects
pub fn wgpuQuerySamplerInfo(smp: Sampler) WgpuSamplerInfo {
    return sg_wgpu_query_sampler_info(smp);
}

/// WebGPU: get internal shader resource objects
extern fn sg_wgpu_query_shader_info(Shader) WgpuShaderInfo;

/// WebGPU: get internal shader resource objects
pub fn wgpuQueryShaderInfo(shd: Shader) WgpuShaderInfo {
    return sg_wgpu_query_shader_info(shd);
}

/// WebGPU: get internal pipeline resource objects
extern fn sg_wgpu_query_pipeline_info(Pipeline) WgpuPipelineInfo;

/// WebGPU: get internal pipeline resource objects
pub fn wgpuQueryPipelineInfo(pip: Pipeline) WgpuPipelineInfo {
    return sg_wgpu_query_pipeline_info(pip);
}

/// WebGPU: get internal view resource objects
extern fn sg_wgpu_query_view_info(View) WgpuViewInfo;

/// WebGPU: get internal view resource objects
pub fn wgpuQueryViewInfo(view: View) WgpuViewInfo {
    return sg_wgpu_query_view_info(view);
}

/// GL: get internal buffer resource objects
extern fn sg_gl_query_buffer_info(Buffer) GlBufferInfo;

/// GL: get internal buffer resource objects
pub fn glQueryBufferInfo(buf: Buffer) GlBufferInfo {
    return sg_gl_query_buffer_info(buf);
}

/// GL: get internal image resource objects
extern fn sg_gl_query_image_info(Image) GlImageInfo;

/// GL: get internal image resource objects
pub fn glQueryImageInfo(img: Image) GlImageInfo {
    return sg_gl_query_image_info(img);
}

/// GL: get internal sampler resource objects
extern fn sg_gl_query_sampler_info(Sampler) GlSamplerInfo;

/// GL: get internal sampler resource objects
pub fn glQuerySamplerInfo(smp: Sampler) GlSamplerInfo {
    return sg_gl_query_sampler_info(smp);
}

/// GL: get internal shader resource objects
extern fn sg_gl_query_shader_info(Shader) GlShaderInfo;

/// GL: get internal shader resource objects
pub fn glQueryShaderInfo(shd: Shader) GlShaderInfo {
    return sg_gl_query_shader_info(shd);
}

/// GL: get internal view resource objects
extern fn sg_gl_query_view_info(View) GlViewInfo;

/// GL: get internal view resource objects
pub fn glQueryViewInfo(view: View) GlViewInfo {
    return sg_gl_query_view_info(view);
}

