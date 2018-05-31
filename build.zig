const Builder = @import("std").build.Builder;
const builtin = @import("builtin");

pub fn build(b: &Builder) void {
    const mode = b.standardReleaseOptions();
    const windows = b.option(bool, "windows", "create windows build") ?? false;

    var sokol_gfx = b.addCObject("sokol_gfx", "src/sokol.c");
    var flext_gl = b.addCObject("flext_gl", "src/flextGL.c");
    var exe = b.addExecutable("sokol", "src/main.zig");
    b.addCIncludePath("src");
    exe.setBuildMode(mode);

    if (windows) {
        exe.setTarget(builtin.Arch.x86_64, builtin.Os.windows, builtin.Environ.gnu);
    }

    exe.linkSystemLibrary("c");
    exe.linkSystemLibrary("m");
    exe.linkSystemLibrary("glfw");

    b.default_step.dependOn(&flext_gl.step);
    b.default_step.dependOn(&sokol_gfx.step);
    b.default_step.dependOn(&exe.step);

    b.installArtifact(exe);

    const play = b.step("play", "Play the game");
    const run = b.addCommand(".", b.env_map,
        [][]const u8{exe.getOutputPath(), });
    play.dependOn(&run.step);
    run.step.dependOn(&exe.step);
}
