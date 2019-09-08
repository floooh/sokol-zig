const std = @import("std");
const Builder = std.build.Builder;
const warn = std.debug.warn;
const assert = std.debug.assert;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    // this doesn't work with "addCSourceFile" since this doesn't
    // find macOS SDK framework headers (for Metal, Cocoa, etc...)
    const sokol = b.addSystemCommand([_][]const u8{
        "clang",
        "src/sokol.c",
        "-march=native",
        "-fstack-protector-strong",
        "--param", "ssp-buffer-size=4",
        "-fno-omit-frame-pointer", "-fPIC",
        "-ObjC", "-fobjc-arc",
        "-c", "-o", "zig-cache/sokol.o"
    });

    const exe = b.addExecutable("bla", "src/main.zig");
    exe.addObjectFile("zig-cache/sokol.o");
    exe.setBuildMode(mode);
    exe.addIncludeDir("src");
    exe.linkFramework("Foundation");
    exe.linkFramework("Cocoa");
    exe.linkFramework("Quartz");
    exe.linkFramework("Metal");
    exe.linkFramework("MetalKit");
    exe.enableSystemLinkerHack();
    exe.step.dependOn(&sokol.step);
    
    const run_cmd = exe.run();

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    b.default_step.dependOn(&exe.step);
    b.installArtifact(exe);
}
