const Builder = @import("std").build.Builder;
const builtin = @import("std").builtin;

pub fn example(b: *Builder, comptime name: []const u8) void {
    const mode = b.standardReleaseOptions();
    const e = b.addExecutable(name, "src/examples/" ++ name ++ ".zig");
    if (builtin.os.tag == .linux) {
        e.linkSystemLibrary("X11");
        e.linkSystemLibrary("Xi");
        e.linkSystemLibrary("Xcursor");
        e.linkSystemLibrary("GL");
    }
    e.setBuildMode(b.standardReleaseOptions());
    e.addPackagePath("sokol", "src/sokol/sokol.zig");
    e.addCSourceFile("src/sokol/sokol.c", &[_][]const u8{});
    e.linkSystemLibrary("c");
    e.install();
    b.step("run-" ++ name, "Run " ++ name).dependOn(&e.run().step);
}

pub fn build(b: *Builder) void {
    example(b, "clear");
    example(b, "triangle");
    example(b, "quad");
    example(b, "bufferoffsets");
    example(b, "cube");
    example(b, "noninterleaved");
    example(b, "texcube");
    example(b, "offscreen");
    example(b, "instancing");
    example(b, "mrt");
}
