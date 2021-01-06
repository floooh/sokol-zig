const bld = @import("std").build;
const mem = @import("std").mem;
const zig = @import("std").zig;

// macOS helper function to add SDK search paths
fn macosAddSdkDirs(b: *bld.Builder, step: *bld.LibExeObjStep) !void {
    const sdk_dir = try zig.system.getSDKPath(b.allocator);
    const framework_dir = try mem.concat(b.allocator, u8, &[_][]const u8 { sdk_dir, "/System/Library/Frameworks" });
    const usrinclude_dir = try mem.concat(b.allocator, u8, &[_][]const u8 { sdk_dir, "/usr/include"});
    step.addFrameworkDir(framework_dir);
    step.addIncludeDir(usrinclude_dir);
}

// build sokol into a static library
pub fn buildSokol(b: *bld.Builder, comptime prefix_path: []const u8) *bld.LibExeObjStep {
    const lib = b.addStaticLibrary("sokol", null);
    lib.linkLibC();
    lib.setBuildMode(b.standardReleaseOptions());
    if (prefix_path.len > 0) lib.addIncludeDir(prefix_path ++ "src/sokol/");
    if (lib.target.isDarwin()) {
        macosAddSdkDirs(b, lib) catch unreachable;
        lib.addCSourceFile(prefix_path ++ "src/sokol/sokol.c", &[_][]const u8{"-ObjC"});
        lib.linkFramework("MetalKit");
        lib.linkFramework("Metal");
        lib.linkFramework("Cocoa");
        lib.linkFramework("QuartzCore");
        lib.linkFramework("AudioToolbox");
    } else {
        lib.addCSourceFile(prefix_path ++ "src/sokol/sokol.c", &[_][]const u8{});
        if (lib.target.isLinux()) {
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
fn buildExample(b: *bld.Builder, sokol: *bld.LibExeObjStep, comptime name: []const u8) void {
    const e = b.addExecutable(name, "src/examples/" ++ name ++ ".zig");
    e.linkLibrary(sokol);
    e.setBuildMode(b.standardReleaseOptions());
    e.addPackagePath("sokol", "src/sokol/sokol.zig");
    e.install();
    b.step("run-" ++ name, "Run " ++ name).dependOn(&e.run().step);
}

pub fn build(b: *bld.Builder) void {
    const sokol = buildSokol(b, "");
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
