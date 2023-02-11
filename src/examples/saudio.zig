//------------------------------------------------------------------------------
//  saudio.zig
//  Test sokol-audio zig bindings
//------------------------------------------------------------------------------
const sokol  = @import("sokol");
const slog   = sokol.log;
const sg     = sokol.gfx;
const sapp   = sokol.app;
const saudio = sokol.audio;
const sgapp  = sokol.app_gfx_glue;

const NumSamples = 32;

const state = struct {
    var pass_action: sg.PassAction = .{};
    var even_odd: u32 = 0;
    var sample_pos: usize = 0;
    var samples: [NumSamples]f32 = undefined;
};

export fn init() void {
    sg.setup(.{
        .context = sgapp.context(),
        .logger = .{ .func = slog.func },
    });
    saudio.setup(.{
        .logger = .{ .func = slog.func },
    });
    state.pass_action.colors[0] = .{ .action=.CLEAR, .value = .{ .r=1, .g=0.5, .b=0, .a=1 }};
}

export fn frame() void {
    const num_frames = saudio.expect();
    var i: i32 = 0;
    while (i < num_frames): ({ i += 1; state.even_odd += 1; state.sample_pos += 1; }) {
        if (state.sample_pos == NumSamples) {
            state.sample_pos = 0;
            _ = saudio.push(&(state.samples[0]), NumSamples);
        }
        state.samples[state.sample_pos] = if (0 != (state.even_odd & 0x20)) 0.1 else -0.1;
    }

    sg.beginDefaultPass(state.pass_action, sapp.width(), sapp.height());
    sg.endPass();
    sg.commit();
}

export fn cleanup() void {
    saudio.shutdown();
    sg.shutdown();
}

pub fn main() void {
    sapp.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .width = 640,
        .height = 480,
        .icon = .{ .sokol_default = true },
        .window_title = "saudio.zig",
        .logger = .{ .func = slog.func },
    });
}
