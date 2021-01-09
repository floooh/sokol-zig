//------------------------------------------------------------------------------
//  instancing.zig
//
//  Demonstrate simple hardware-instancing using a static geometry buffer
//  and a dynamic instance-data buffer.
//------------------------------------------------------------------------------
const sg    = @import("sokol").gfx;
const sapp  = @import("sokol").app;
const sgapp = @import("sokol").app_gfx_glue;
const vec3  = @import("math.zig").Vec3;
const mat4  = @import("math.zig").Mat4;

const max_particles: usize = 512 * 1024;
const num_particles_emitted_per_frame: usize = 10;

const state = struct {
    var pass_action: sg.PassAction = .{};
    var pip: sg.Pipeline = .{};
    var bind: sg.Bindings = .{};
    var ry: f32 = 0.0;
    var cur_num_particles: u32 = 0;
    // view matrix doesn't change
    const view: mat4 = mat4.lookat(.{ .x=0.0, .y=1.5, .z=12.0 }, vec3.zero(), vec3.up());
    // un-initialized particle buffer to not bloat the executable
    var pos: [max_particles]vec3 = undefined;
    var vel: [max_particles]vec3 = undefined;
};

// uniform-block struct with the model-view-projection matrix
const VsParams = packed struct {
    mvp: mat4
};

export fn init() void {
    sg.setup(.{
        .context = sgapp.context()
    });

    // pass action to clear frame buffer to black
    state.pass_action.colors[0] = .{ .action = .CLEAR, .val = .{ 0.0, 0.0, 0.0, 1.0 } };

    // a vertex buffer for the static particle geometry, goes into vertex buffer slot 0
    const r = 0.05;
    const vertices = [_]f32 {
        0.0,  -r, 0.0,       1.0, 0.0, 0.0, 1.0,
          r, 0.0, r,         0.0, 1.0, 0.0, 1.0,
          r, 0.0, -r,        0.0, 0.0, 1.0, 1.0,
         -r, 0.0, -r,        1.0, 1.0, 0.0, 1.0,
         -r, 0.0, r,         0.0, 1.0, 1.0, 1.0,
        0.0,   r, 0.0,       1.0, 0.0, 1.0, 1.0
    };
    state.bind.vertex_buffers[0] = sg.makeBuffer(.{
        .data = sg.asRange(vertices)
    });

    // an index buffer for the static geometry
    const indices = [_]u16 {
        2, 1, 0,    3, 2, 0,    4, 3, 0,    1, 4, 0,
        5, 1, 2,    5, 2, 3,    5, 3, 4,    5, 4, 1
    };
    state.bind.index_buffer = sg.makeBuffer(.{
        .type = .INDEXBUFFER,
        .data = sg.asRange(indices)
    });

    // an empty dynamic vertex buffer for the instancing data, goes in vertex buffer slot 1
    state.bind.vertex_buffers[1] = sg.makeBuffer(.{
        .usage = .STREAM,
        .size = max_particles * @sizeOf(vec3)
    });

    // shader and pipeline object
    var pip_desc: sg.PipelineDesc = .{
        .shader = sg.makeShader(shaderDesc()),
        .index_type = .UINT16,
        .depth_stencil = .{
            .depth_compare_func = .LESS_EQUAL,
            .depth_write_enabled = true,
        },
        .rasterizer = .{
            .cull_mode = .BACK
        }
    };
    // NOTE how the vertex layout is setup for instancing, with the instancing
    // data provided by buffer-slot 1:
    pip_desc.layout.buffers[1].step_func = .PER_INSTANCE;
    pip_desc.layout.attrs[0] = .{ .format = .FLOAT3, .buffer_index = 0 }; // positions
    pip_desc.layout.attrs[1] = .{ .format = .FLOAT4, .buffer_index = 0 }; // colors
    pip_desc.layout.attrs[2] = .{ .format = .FLOAT3, .buffer_index = 1 }; // instance positions

    state.pip = sg.makePipeline(pip_desc);
}

export fn frame() void {
    const frame_time = 1.0 / 60.0;

    // emit new particles
    {
        var i: usize = 0;
        while (i < num_particles_emitted_per_frame): (i += 1) {
            if (state.cur_num_particles < max_particles) {
                state.pos[state.cur_num_particles] = vec3.zero();
                state.vel[state.cur_num_particles] = .{
                    .x = rand(-0.5, 0.5),
                    .y = rand(2.0, 2.5),
                    .z = rand(-0.5, 0.5)
                };
                state.cur_num_particles += 1;
            }
            else {
                break;
            }
        }
    }

    // update particle positions
    {
        var i: usize = 0;
        while (i < max_particles): (i += 1) {
            state.vel[i].y -= 1.0 * frame_time;
            state.pos[i] = vec3.add(state.pos[i], vec3.mul(state.vel[i], frame_time));
            if (state.pos[i].y < -2.0) {
                state.pos[i].y = -1.8;
                state.vel[i].y = -state.vel[i].y;
                state.vel[i] = vec3.mul(state.vel[i], 0.8);
            }
        }
    }

    // update instance data
    sg.updateBuffer(state.bind.vertex_buffers[1], sg.asRange(state.pos[0..state.cur_num_particles]));

    // compute vertex shader parameters (the mvp matrix)
    state.ry += 1.0;
    const vs_params = computeVsParams(1.0, state.ry);

    // and finally draw...
    sg.beginDefaultPass(state.pass_action, sapp.width(), sapp.height());
    sg.applyPipeline(state.pip);
    sg.applyBindings(state.bind);
    sg.applyUniforms(.VS, 0, sg.asRange(vs_params));
    sg.draw(0, 24, @intCast(i32, state.cur_num_particles));
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
        .window_title = "instancing.zig"
    });
}

fn computeVsParams(rx: f32, ry: f32) VsParams {
    const rxm = mat4.rotate(rx, .{ .x=1.0, .y=0.0, .z=0.0 });
    const rym = mat4.rotate(ry, .{ .x=0.0, .y=1.0, .z=0.0 });
    const model = mat4.mul(rxm, rym);
    const aspect = sapp.widthf() / sapp.heightf();
    const proj = mat4.persp(60.0, aspect, 0.01, 50.0);
    return VsParams {
        .mvp = mat4.mul(mat4.mul(proj, state.view), model)
    };
}

fn xorshift32() u32 {
    const static = struct {
        var x: u32 = 0x12345678;
    };
    var x = static.x;
    x ^= x << 13;
    x ^= x >> 17;
    x ^= x << 5;
    static.x = x;
    return x;
}

fn rand(min_val: f32, max_val: f32) f32 {
    return (@intToFloat(f32, xorshift32() & 0xFFFF) / 0x10000) * (max_val - min_val) + min_val;
}

fn shaderDesc() sg.ShaderDesc {
    var desc: sg.ShaderDesc = .{};
    desc.vs.uniform_blocks[0].size = @sizeOf(VsParams);
    switch (sg.queryBackend()) {
        .D3D11 => {
            desc.attrs[0].sem_name = "POSITION";
            desc.attrs[1].sem_name = "COLOR";
            desc.attrs[2].sem_name = "INSTPOS";
            desc.vs.source =
                \\cbuffer params: register(b0) {
                \\  float4x4 mvp;
                \\};
                \\struct vs_in {
                \\  float3 pos: POSITION;
                \\  float4 color: COLOR0;
                \\  float3 inst_pos: INSTPOS;
                \\};
                \\struct vs_out {
                \\  float4 color: COLOR0;
                \\  float4 pos: SV_Position;
                \\};
                \\vs_out main(vs_in inp) {
                \\  vs_out outp;
                \\  outp.pos = mul(mvp, float4(inp.pos + inp.inst_pos, 1.0));
                \\  outp.color = inp.color;
                \\  return outp;
                \\}
            ;
            desc.fs.source =
                \\float4 main(float4 color: COLOR0): SV_Target0 {
                \\  return color;
                \\}
            ;
        },
        .GLCORE33 => {
            desc.vs.uniform_blocks[0].uniforms[0] = .{ .name="mvp", .type=.MAT4 };
            desc.vs.source =
                \\ #version 330
                \\ uniform mat4 mvp;
                \\ layout(location=0) in vec3 position;
                \\ layout(location=1) in vec4 color0;
                \\ layout(location=2) in vec3 instance_pos;
                \\ out vec4 color;
                \\ void main() {
                \\   vec4 pos = vec4(position + instance_pos, 1.0);
                \\   gl_Position = mvp * pos;
                \\   color = color0;
                \\ }
                ;
            desc.fs.source =
                \\ #version 330
                \\ in vec4 color;
                \\ out vec4 frag_color;
                \\ void main() {
                \\   frag_color = color;
                \\ }
                ;
        },
        .METAL_MACOS => {
            desc.vs.source =
                \\ #include <metal_stdlib>
                \\ using namespace metal;
                \\ struct params_t {
                \\   float4x4 mvp;
                \\ };
                \\ struct vs_in {
                \\   float3 pos [[attribute(0)]];
                \\   float4 color [[attribute(1)]];
                \\   float3 instance_pos [[attribute(2)]];
                \\ };
                \\ struct vs_out {
                \\   float4 pos [[position]];
                \\   float4 color;
                \\ };
                \\ vertex vs_out _main(vs_in in [[stage_in]], constant params_t& params [[buffer(0)]]) {
                \\   vs_out out;
                \\   float4 pos = float4(in.pos + in.instance_pos, 1.0);
                \\   out.pos = params.mvp * pos;
                \\   out.color = in.color;
                \\   return out;
                \\ }
                ;
            desc.fs.source =
                \\ #include <metal_stdlib>
                \\ using namespace metal;
                \\ fragment float4 _main(float4 color [[stage_in]]) {
                \\   return color;
                \\ }
                ;
        },
        else => {}
    }
    return desc;
}
