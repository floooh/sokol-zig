const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("sokol-zig", "src/main.zig");
//    exe.addObjectFile("sokol/sokol.o");
//    exe.addCSourceFile("sokol/sokol.m", [][]const u8{"-fobjc-arc"});
//    exe.linkFramework("Metal");
//    exe.linkFramework("Quartz");
    exe.setBuildMode(mode);

    const run_cmd = exe.run();

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    b.default_step.dependOn(&exe.step);
    b.installArtifact(exe);
}
