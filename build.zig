const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("sokol-zig", "src/main.zig");
    exe.addObjectFile("src/sokol/sokol.o");
    exe.addIncludeDir("src/sokol");
    exe.linkSystemLibrary("c");
    exe.linkSystemLibrary("GL");
    exe.linkSystemLibrary("X11");
    exe.linkSystemLibrary("m");
    exe.linkSystemLibrary("dl");
    exe.linkSystemLibrary("asound");
    exe.setBuildMode(mode);

    const run_cmd = exe.run();

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    b.default_step.dependOn(&exe.step);
    b.installArtifact(exe);
}
