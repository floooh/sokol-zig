const Builder = @import("std").build.Builder;

pub fn target(b: *Builder, comptime name: []const u8, source: []const u8) void {
    const mode = b.standardReleaseOptions();
    const e = b.addExecutable(name, source);
    e.addPackagePath("sokol", "src/sokol/sokol.zig");
    e.linkSystemLibrary("c");
    e.setBuildMode(mode);
    e.addCSourceFile("src/sokol/sokol.c", &[_][]const u8{""});
    e.install();
    b.step("run-" ++ name, "Run " ++ name).dependOn(&e.run().step);
}

pub fn build(b: *Builder) void {
    target(b, "clear", "src/examples/clear.zig");
    target(b, "triangle", "src/examples/triangle.zig");
}
