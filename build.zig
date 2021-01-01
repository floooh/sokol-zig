const Builder = @import("std").build.Builder;
const LibExeObjStep = @import("std").build.LibExeObjStep;
const builtin = @import("std").builtin;

// build sokol into a static library
fn buildSokol(b: *Builder) *LibExeObjStep {
    const lib = b.addStaticLibrary("sokol", null);
    lib.setBuildMode(b.standardReleaseOptions());
    if (builtin.os.tag == .macos) {
        // need to use the system clang compiler on macOS because Zig's
        // compiler doesn't support ObjC
        const clangCmd = &[_][]const u8 { "clang", "-x", "objective-c", "-c", "src/sokol/sokol.c", "-Os", "-o", "zig-cache/sokol.o"};
        lib.step.dependOn(&b.addSystemCommand(clangCmd).step);
        lib.addObjectFile("zig-cache/sokol.o");
        lib.linkFramework("MetalKit");
        lib.linkFramework("Metal");
        lib.linkFramework("Cocoa");
        lib.linkFramework("QuartzCore");
        lib.linkFramework("AudioToolbox");
    }
    else {
        lib.addCSourceFile("src/sokol/sokol.c", &[_][]const u8{});
        lib.linkSystemLibrary("c");
        if (builtin.os.tag == .linux) {
            lib.linkSystemLibrary("X11");
            lib.linkSystemLibrary("Xi");
            lib.linkSystemLibrary("Xcursor");
            lib.linkSystemLibrary("GL");
            lib.linkSystemLibrary("asound");
        }
    }
    return lib;
}

// build one of the example exes
fn buildExample(b: *Builder, sokol: *LibExeObjStep, comptime name: []const u8) void {
    const e = b.addExecutable(name, "src/examples/" ++ name ++ ".zig");
    e.linkLibrary(sokol);
    e.setBuildMode(b.standardReleaseOptions());
    e.addPackagePath("sokol", "src/sokol/sokol.zig");
    e.install();
    b.step("run-" ++ name, "Run " ++ name).dependOn(&e.run().step);
}

pub fn build(b: *Builder) void {
    const sokol = buildSokol(b);
    buildExample(b, sokol, "clear");
    buildExample(b, sokol, "triangle");
    buildExample(b, sokol, "quad");
    buildExample(b, sokol, "bufferoffsets");
    buildExample(b, sokol, "cube");
    buildExample(b, sokol, "noninterleaved");
    buildExample(b, sokol, "texcube");
    buildExample(b, sokol, "offscreen");
    buildExample(b, sokol, "instancing");
    buildExample(b, sokol, "mrt");
    buildExample(b, sokol, "saudio");
}
