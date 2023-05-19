//------------------------------------------------------------------------------
//  texcube.zig
//
//  Texture creation, rendering with texture, packed vertex components.
//------------------------------------------------------------------------------
const sokol = @import("sokol");
const slog  = sokol.log;
const sg    = sokol.gfx;
const sapp  = sokol.app;
const sgapp = sokol.app_gfx_glue;
const vec3  = @import("math.zig").Vec3;
const mat4  = @import("math.zig").Mat4;
const shd   = @import("shaders/texcube.glsl.zig");

const state = struct {
    var rx: f32 = 0.0;
    var ry: f32 = 0.0;
    var pass_action: sg.PassAction = .{};
    var pip: sg.Pipeline = .{};
    var bind: sg.Bindings = .{};
    const view: mat4 = mat4.lookat(.{ .x=0.0, .y=1.5, .z=6.0 }, vec3.zero(), vec3.up());
};

// a vertex struct with position, color and uv-coords
const Vertex = extern struct {
    x: f32, y: f32, z: f32,
    color: u32,
    u: i16, v: i16
};

export fn init() void {
    sg.setup(.{
        .context = sgapp.context(),
        .logger = .{ .func = slog.func },
    });

    // Cube vertex buffer with packed vertex formats for color and texture coords.
    // Note that a vertex format which must be portable across all
    // backends must only use the normalized integer formats
    // (BYTE4N, UBYTE4N, SHORT2N, SHORT4N), which can be converted
    // to floating point formats in the vertex shader inputs.
    // The reason is that D3D11 cannot convert from non-normalized
    // formats to floating point inputs (only to integer inputs),
    // and WebGL2 / GLES2 don't support integer vertex shader inputs.
    state.bind.vertex_buffers[0] = sg.makeBuffer(.{
        .data = sg.asRange(&[_]Vertex{
            // pos                         color              texcoords
            .{ .x=-1.0, .y=-1.0, .z=-1.0,  .color=0xFF0000FF, .u=    0, .v=    0 },
            .{ .x= 1.0, .y=-1.0, .z=-1.0,  .color=0xFF0000FF, .u=32767, .v=    0 },
            .{ .x= 1.0, .y= 1.0, .z=-1.0,  .color=0xFF0000FF, .u=32767, .v=32767 },
            .{ .x=-1.0, .y= 1.0, .z=-1.0,  .color=0xFF0000FF, .u=    0, .v=32767 },

            .{ .x=-1.0, .y=-1.0, .z= 1.0,  .color=0xFF00FF00, .u=    0, .v=    0 },
            .{ .x= 1.0, .y=-1.0, .z= 1.0,  .color=0xFF00FF00, .u=32767, .v=    0 },
            .{ .x= 1.0, .y= 1.0, .z= 1.0,  .color=0xFF00FF00, .u=32767, .v=32767 },
            .{ .x=-1.0, .y= 1.0, .z= 1.0,  .color=0xFF00FF00, .u=    0, .v=32767 },

            .{ .x=-1.0, .y=-1.0, .z=-1.0,  .color=0xFFFF0000, .u=    0, .v=    0 },
            .{ .x=-1.0, .y= 1.0, .z=-1.0,  .color=0xFFFF0000, .u=32767, .v=    0 },
            .{ .x=-1.0, .y= 1.0, .z= 1.0,  .color=0xFFFF0000, .u=32767, .v=32767 },
            .{ .x=-1.0, .y=-1.0, .z= 1.0,  .color=0xFFFF0000, .u=    0, .v=32767 },

            .{ .x= 1.0, .y=-1.0, .z=-1.0,  .color=0xFFFF007F, .u=    0, .v=    0 },
            .{ .x= 1.0, .y= 1.0, .z=-1.0,  .color=0xFFFF007F, .u=32767, .v=    0 },
            .{ .x= 1.0, .y= 1.0, .z= 1.0,  .color=0xFFFF007F, .u=32767, .v=32767 },
            .{ .x= 1.0, .y=-1.0, .z= 1.0,  .color=0xFFFF007F, .u=    0, .v=32767 },

            .{ .x=-1.0, .y=-1.0, .z=-1.0,  .color=0xFFFF7F00, .u=    0, .v=    0 },
            .{ .x=-1.0, .y=-1.0, .z= 1.0,  .color=0xFFFF7F00, .u=32767, .v=    0 },
            .{ .x= 1.0, .y=-1.0, .z= 1.0,  .color=0xFFFF7F00, .u=32767, .v=32767 },
            .{ .x= 1.0, .y=-1.0, .z=-1.0,  .color=0xFFFF7F00, .u=    0, .v=32767 },

            .{ .x=-1.0, .y= 1.0, .z=-1.0,  .color=0xFF007FFF, .u=    0, .v=    0 },
            .{ .x=-1.0, .y= 1.0, .z= 1.0,  .color=0xFF007FFF, .u=32767, .v=    0 },
            .{ .x= 1.0, .y= 1.0, .z= 1.0,  .color=0xFF007FFF, .u=32767, .v=32767 },
            .{ .x= 1.0, .y= 1.0, .z=-1.0,  .color=0xFF007FFF, .u=    0, .v=32767 },
        })
    });

    // cube index buffer
    state.bind.index_buffer = sg.makeBuffer(.{
        .type = .INDEXBUFFER,
        .data = sg.asRange(&[_]u16{
            0, 1, 2,  0, 2, 3,
            6, 5, 4,  7, 6, 4,
            8, 9, 10,  8, 10, 11,
            14, 13, 12,  15, 14, 12,
            16, 17, 18,  16, 18, 19,
            22, 21, 20,  23, 22, 20
        })
    });

    // create a small checker-board texture
    var img_desc: sg.ImageDesc = .{
        .width = 4,
        .height = 4,
    };
    img_desc.data.subimage[0][0] = sg.asRange(&[4*4]u32{
        0xFFFFFFFF, 0xFF000000, 0xFFFFFFFF, 0xFF000000,
        0xFF000000, 0xFFFFFFFF, 0xFF000000, 0xFFFFFFFF,
        0xFFFFFFFF, 0xFF000000, 0xFFFFFFFF, 0xFF000000,
        0xFF000000, 0xFFFFFFFF, 0xFF000000, 0xFFFFFFFF,
    });
    state.bind.fs_images[shd.SLOT_tex] = sg.makeImage(img_desc);

    // shader and pipeline object
    var pip_desc: sg.PipelineDesc = .{
        .shader = sg.makeShader(shd.texcubeShaderDesc(sg.queryBackend())),
        .index_type = .UINT16,
        .depth = .{
            .compare = .LESS_EQUAL,
            .write_enabled = true,
        },
        .cull_mode = .BACK
    };
    pip_desc.layout.attrs[shd.ATTR_vs_pos].format = .FLOAT3;
    pip_desc.layout.attrs[shd.ATTR_vs_color0].format = .UBYTE4N;
    pip_desc.layout.attrs[shd.ATTR_vs_texcoord0].format = .SHORT2N;
    state.pip = sg.makePipeline(pip_desc);

    // pass action for clearing the frame buffer
    state.pass_action.colors[0] = .{ .load_action = .CLEAR, .clear_value = .{ .r=0.25, .g=0.5, .b=0.75, .a=1 } };
}

export fn frame() void {
    const dt = @floatCast(f32, sapp.frameDuration()) * 60.0;

    state.rx += 1.0 * dt;
    state.ry += 2.0 * dt;
    const vs_params = computeVsParams(state.rx, state.ry);

    sg.beginDefaultPass(state.pass_action, sapp.width(), sapp.height());
    sg.applyPipeline(state.pip);
    sg.applyBindings(state.bind);
    sg.applyUniforms(.VS, shd.SLOT_vs_params, sg.asRange(&vs_params));
    sg.draw(0, 36, 1);
    sg.endPass();
    sg.commit();
}

export fn cleanup() void {
    sg.shutdown();
}

pub fn main() void {
    sapp.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .width = 800,
        .height = 600,
        .sample_count = 4,
        .icon = .{ .sokol_default = true },
        .window_title = "texcube.zig",
        .logger = .{ .func = slog.func },
    });
}

fn computeVsParams(rx: f32, ry: f32) shd.VsParams {
    const rxm = mat4.rotate(rx, .{ .x=1.0, .y=0.0, .z=0.0 });
    const rym = mat4.rotate(ry, .{ .x=0.0, .y=1.0, .z=0.0 });
    const model = mat4.mul(rxm, rym);
    const aspect = sapp.widthf() / sapp.heightf();
    const proj = mat4.persp(60.0, aspect, 0.01, 10.0);
    return shd.VsParams {
        .mvp = mat4.mul(mat4.mul(proj, state.view), model)
    };
}
