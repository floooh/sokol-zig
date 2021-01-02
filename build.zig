const Builder = @import("std").build.Builder;
const LibExeObjStep = @import("std").build.LibExeObjStep;
const builtin = @import("std").builtin;
const mem = @import("std").mem;

// macOS helper function to add SDK search paths
fn macosAddSdkDirs(b: *Builder, step: *LibExeObjStep) !void {
    var sdk_dir = try b.exec(&[_][]const u8 { "xcrun", "--show-sdk-path" });
    const newline_index = mem.lastIndexOf(u8, sdk_dir, "\n");
    if (newline_index) |idx| {
        sdk_dir = sdk_dir[0..idx];
    }
    const framework_dir = try mem.concat(b.allocator, u8, &[_][]const u8 { sdk_dir, "/System/Library/Frameworks" });
    const usrinclude_dir = try mem.concat(b.allocator, u8, &[_][]const u8 { sdk_dir, "/usr/include"});
    step.addFrameworkDir(framework_dir);
    step.addIncludeDir(usrinclude_dir);
}

// build sokol into a static library
fn buildSokol(b: *Builder) *LibExeObjStep {
    const lib = b.addStaticLibrary("sokol", null);
    lib.setBuildMode(b.standardReleaseOptions());
    if (builtin.os.tag == .macos) {
        macosAddSdkDirs(b, lib) catch unreachable;
        lib.addCSourceFile("src/sokol/sokol.c", &[_][]const u8 { "-ObjC" });
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
