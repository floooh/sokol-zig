const bld = @import("std").build;
const mem = @import("std").mem;

// build sokol into a static library
pub fn buildSokol(b: *bld.Builder, comptime prefix_path: []const u8) *bld.LibExeObjStep {
    const lib = b.addStaticLibrary("sokol", null);
    lib.linkLibC();
    lib.setBuildMode(b.standardReleaseOptions());
    const sokol_path = prefix_path ++ "src/sokol/c/";
    const csources = [_][]const u8 {
        "sokol_app.c",
        "sokol_gfx.c",
        "sokol_time.c",
        "sokol_audio.c",
        "sokol_gl.c",
        "sokol_debugtext.c",
        "sokol_shape.c",
    };
    if (lib.target.isDarwin()) {
        b.env_map.put("ZIG_SYSTEM_LINKER_HACK", "1") catch unreachable;
        inline for (csources) |csrc| {
            lib.addCSourceFile(sokol_path ++ csrc, &[_][]const u8{"-ObjC", "-DIMPL"});
        }
        lib.linkFramework("MetalKit");
        lib.linkFramework("Metal");
        lib.linkFramework("Cocoa");
        lib.linkFramework("QuartzCore");
        lib.linkFramework("AudioToolbox");
    } else {
        inline for (csources) |csrc| {
            lib.addCSourceFile(sokol_path ++ csrc, &[_][]const u8{"-DIMPL"});
        }
        if (lib.target.isLinux()) {
            lib.linkSystemLibrary("X11");
            lib.linkSystemLibrary("Xi");
            lib.linkSystemLibrary("Xcursor");
            lib.linkSystemLibrary("GL");
            lib.linkSystemLibrary("asound");
        }
        else if (lib.target.isWindows()) {
            lib.linkSystemLibrary("kernel32");
            lib.linkSystemLibrary("user32");
            lib.linkSystemLibrary("ole32");
            lib.linkSystemLibrary("d3d11");
            lib.linkSystemLibrary("dxguid");
            lib.linkSystemLibrary("dxgi");
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
    buildExample(b, sokol, "sgl");
    buildExample(b, sokol, "debugtext");
    buildExample(b, sokol, "debugtext-print");
    buildExample(b, sokol, "debugtext-userfont");
    buildExample(b, sokol, "shapes");
}
