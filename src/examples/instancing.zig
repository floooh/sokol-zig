//------------------------------------------------------------------------------
//  instancing.zig
//
//  Demonstrate simple hardware-instancing using a static geometry buffer
//  and a dynamic instance-data buffer.
//------------------------------------------------------------------------------
const sokol = @import("sokol");
const slog  = sokol.log;
const sg    = sokol.gfx;
const sapp  = sokol.app;
const sgapp = sokol.app_gfx_glue;
const vec3  = @import("math.zig").Vec3;
const mat4  = @import("math.zig").Mat4;
const shd   = @import("shaders/instancing.glsl.zig");

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

export fn init() void {
    sg.setup(.{
        .context = sgapp.context(),
        .logger = .{ .func = slog.func },
    });

    // pass action to clear frame buffer to black
    state.pass_action.colors[0] = .{ .load_action = .CLEAR, .clear_value = .{ .r=0, .g=0, .b=0, .a=1 } };

    // a vertex buffer for the static particle geometry, goes into vertex buffer slot 0
    const r = 0.05;
    state.bind.vertex_buffers[0] = sg.makeBuffer(.{
        .data = sg.asRange(&[_]f32{
            0.0,  -r, 0.0,   1.0, 0.0, 0.0, 1.0,
              r, 0.0, r,     0.0, 1.0, 0.0, 1.0,
              r, 0.0, -r,    0.0, 0.0, 1.0, 1.0,
             -r, 0.0, -r,    1.0, 1.0, 0.0, 1.0,
             -r, 0.0, r,     0.0, 1.0, 1.0, 1.0,
            0.0,   r, 0.0,   1.0, 0.0, 1.0, 1.0
        })
    });

    // an index buffer for the static geometry
    state.bind.index_buffer = sg.makeBuffer(.{
        .type = .INDEXBUFFER,
        .data = sg.asRange(&[_]u16{
            2, 1, 0,  3, 2, 0,  4, 3, 0,  1, 4, 0,
            5, 1, 2,  5, 2, 3,  5, 3, 4,  5, 4, 1
        })
    });

    // an empty dynamic vertex buffer for the instancing data, goes in vertex buffer slot 1
    state.bind.vertex_buffers[1] = sg.makeBuffer(.{
        .usage = .STREAM,
        .size = max_particles * @sizeOf(vec3)
    });

    // shader and pipeline object
    var pip_desc: sg.PipelineDesc = .{
        .shader = sg.makeShader(shd.instancingShaderDesc(sg.queryBackend())),
        .index_type = .UINT16,
        .cull_mode = .BACK,
        .depth = .{
            .compare = .LESS_EQUAL,
            .write_enabled = true,
        },
    };
    // NOTE how the vertex layout is setup for instancing, with the instancing
    // data provided by buffer-slot 1:
    pip_desc.layout.buffers[1].step_func = .PER_INSTANCE;
    pip_desc.layout.attrs[shd.ATTR_vs_pos]      = .{ .format = .FLOAT3, .buffer_index = 0 }; // positions
    pip_desc.layout.attrs[shd.ATTR_vs_color0]   = .{ .format = .FLOAT4, .buffer_index = 0 }; // colors
    pip_desc.layout.attrs[shd.ATTR_vs_inst_pos] = .{ .format = .FLOAT3, .buffer_index = 1 }; // instance positions

    state.pip = sg.makePipeline(pip_desc);
}

export fn frame() void {
    const frame_time = @floatCast(f32, sapp.frameDuration());

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
            const vel = &state.vel[i];
            const pos = &state.pos[i];

            vel.y -= 1.0 * frame_time;
            pos.* = vec3.add(pos.*, vec3.mul(vel.*, frame_time));
            if (pos.y < -2.0) {
                pos.y = -1.8;
                vel.y = -vel.y;
                vel.* = vec3.mul(vel.*, 0.8);
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
    sg.applyUniforms(.VS, shd.SLOT_vs_params, sg.asRange(&vs_params));
    sg.draw(0, 24, state.cur_num_particles);
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
        .icon = .{ .sokol_default = true, },
        .window_title = "instancing.zig",
        .logger = .{ .func = slog.func },
    });
}

fn computeVsParams(rx: f32, ry: f32) shd.VsParams {
    const rxm = mat4.rotate(rx, .{ .x=1.0, .y=0.0, .z=0.0 });
    const rym = mat4.rotate(ry, .{ .x=0.0, .y=1.0, .z=0.0 });
    const model = mat4.mul(rxm, rym);
    const aspect = sapp.widthf() / sapp.heightf();
    const proj = mat4.persp(60.0, aspect, 0.01, 50.0);
    return shd.VsParams {
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
