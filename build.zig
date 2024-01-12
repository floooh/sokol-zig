const std = @import("std");
const builtin = @import("builtin");
const Build = std.Build;
const CompileStep = Build.Step.Compile;
const RunStep = Build.Step.Run;
const Module = Build.Module;
const ResolvedTarget = Build.ResolvedTarget;
const OptimizeMode = std.builtin.OptimizeMode;

pub const Backend = enum {
    auto, // Windows: D3D11, macOS/iOS: Metal, otherwise: GL
    d3d11,
    metal,
    gl,
    gles3,
    wgpu,
};

pub const LibSokolOptions = struct {
    target: ResolvedTarget,
    optimize: OptimizeMode,
    build_root: ?[]const u8 = null,
    backend: Backend = .auto,
    force_egl: bool = false,
    enable_x11: bool = true,
    enable_wayland: bool = false,
    sysroot: ?[]const u8 = null,
    emsdk: ?*Build.Dependency = null,

    fn emsdkPath(self: LibSokolOptions, b: *Build) ?[]const u8 {
        if (self.emsdk) |dep|
            return dep.path("").getPath(b);
        return null;
    }
};

pub fn build(b: *Build) void {
    const force_gl = b.option(bool, "gl", "Force GL backend") orelse false;
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod_sokol = b.addModule("sokol", .{ .root_source_file = .{ .path = "src/sokol/sokol.zig" } });

    const lib_sokol = buildLibSokol(b, .{
        .target = target,
        .optimize = optimize,
        .emsdk = b.dependency("emsdk", .{}),
        .backend = if (force_gl) .gl else .auto,
        .enable_wayland = b.option(bool, "wayland", "Compile with wayland-support (default: false)") orelse false,
        .enable_x11 = b.option(bool, "x11", "Compile with x11-support (default: true)") orelse true,
        .force_egl = b.option(bool, "egl", "Use EGL instead of GLX if possible (default: false)") orelse false,
    }) catch |err| {
        std.log.err("buildLibSokol return with error {}", .{err});
        return;
    };

    const examples = .{
        "clear",
        "triangle",
        "quad",
        "bufferoffsets",
        "cube",
        "noninterleaved",
        "texcube",
        "blend",
        "offscreen",
        "instancing",
        "mrt",
        "saudio",
        "sgl",
        "sgl-context",
        "sgl-points",
        "debugtext",
        "debugtext-print",
        "debugtext-userfont",
        "shapes",
    };
    inline for (examples) |example| {
        buildExample(b, example, .{
            .target = target,
            .optimize = optimize,
            .lib_sokol = lib_sokol,
            .mod_sokol = mod_sokol,
            .emsdk = b.dependency("emsdk", .{}),
        });
    }
    buildShaders(b);
}

const ExampleOptions = struct {
    target: ResolvedTarget,
    optimize: OptimizeMode,
    lib_sokol: *CompileStep,
    mod_sokol: *Module,
    emsdk: ?*Build.Dependency = null,

    fn emsdkPath(self: ExampleOptions, b: *Build) ?[]const u8 {
        if (self.emsdk) |dep|
            return dep.path("").getPath(b);
        return null;
    }
};

// build sokol into a static library
pub fn buildLibSokol(b: *Build, options: LibSokolOptions) !*CompileStep {
    const is_wasm = options.target.result.isWasm();
    var config = options;

    const lib = b.addStaticLibrary(.{
        .name = "sokol",
        .target = options.target,
        .optimize = options.optimize,
        .link_libc = true,
    });
    if (is_wasm) {
        // need to add Emscripten SDK include path (system or package)
        if (b.sysroot) |sysroot| {
            config.sysroot = sysroot;
        } else if (options.emsdkPath(b)) |path| {
            config.sysroot = b.pathJoin(&.{ path, "upstream", "emscripten", "cache", "sysroot" });
            var cmds = std.ArrayList([]const u8).init(b.allocator);
            defer cmds.deinit();

            if (lib.rootModuleTarget().os.tag == .windows)
                try cmds.append(b.pathJoin(&.{ path, "emsdk.bat" }))
            else {
                try cmds.append("bash"); // or try chmod
                try cmds.append(b.pathJoin(&.{ path, "emsdk" }));
            }

            var emsdk_run = b.addSystemCommand(cmds.items);
            emsdk_run.addArgs(&.{ "install", "latest" });
            var emsdk_active = b.addSystemCommand(cmds.items);
            emsdk_active.addArgs(&.{ "activate", "latest" });
            _ = emsdk_active.captureStdOut(); // hide emsdk_env output

            emsdk_active.step.dependOn(&emsdk_run.step);
            lib.step.dependOn(&emsdk_active.step);
        } else {
            std.log.err("Must provide Emscripten sysroot via '--sysroot [path/to/emsdk]/upstream/emscripten/cache/sysroot'", .{});
            return error.Wasm32SysRootExpected;
        }
        const include_path = b.pathJoin(&.{ config.sysroot.?, "include" });
        lib.addSystemIncludePath(.{ .path = include_path }); // isystem
    }
    var sokol_path: []const u8 = "src/sokol/c";
    if (options.build_root) |build_root| {
        sokol_path = b.fmt("{s}/src/sokol/c", .{build_root});
    }
    const csources = [_][]const u8{
        "sokol_log.c",
        "sokol_app.c",
        "sokol_gfx.c",
        "sokol_time.c",
        "sokol_audio.c",
        "sokol_gl.c",
        "sokol_debugtext.c",
        "sokol_shape.c",
    };
    var _backend = options.backend;
    if (_backend == .auto) {
        if (lib.rootModuleTarget().isDarwin()) {
            _backend = .metal;
        } else if (lib.rootModuleTarget().os.tag == .windows) {
            _backend = .d3d11;
        } else if (lib.rootModuleTarget().isWasm()) {
            _backend = .gles3;
        } else if (lib.rootModuleTarget().isAndroid()) {
            _backend = .gles3;
        } else {
            _backend = .gl;
        }
    }
    const backend_option = switch (_backend) {
        .d3d11 => "-DSOKOL_D3D11",
        .metal => "-DSOKOL_METAL",
        .gl => "-DSOKOL_GLCORE33",
        .gles3 => "-DSOKOL_GLES3",
        .wgpu => "-DSOKOL_WGPU",
        else => unreachable,
    };

    if (lib.rootModuleTarget().isDarwin()) {
        for (csources) |csrc| {
            lib.addCSourceFile(.{
                .file = .{ .path = b.fmt("{s}/{s}", .{ sokol_path, csrc }) },
                .flags = &[_][]const u8{ "-ObjC", "-DIMPL", backend_option },
            });
        }
        lib.linkFramework("Foundation");
        lib.linkFramework("AudioToolbox");
        if (.metal == _backend) {
            lib.linkFramework("MetalKit");
            lib.linkFramework("Metal");
        }
        if (lib.rootModuleTarget().os.tag == .ios) {
            lib.linkFramework("UIKit");
            lib.linkFramework("AVFoundation");
            if (.gl == _backend) {
                lib.linkFramework("OpenGLES");
                lib.linkFramework("GLKit");
            }
        } else if (lib.rootModuleTarget().os.tag == .macos) {
            lib.linkFramework("Cocoa");
            lib.linkFramework("QuartzCore");
            if (.gl == _backend) {
                lib.linkFramework("OpenGL");
            }
        }
    } else if (lib.rootModuleTarget().isAndroid()) {
        if (.gles3 != _backend) {
            @panic("For android targets, you must have backend set to GLES3");
        }
        for (csources) |csrc| {
            lib.addCSourceFile(.{
                .file = .{ .path = b.fmt("{s}/{s}", .{ sokol_path, csrc }) },
                .flags = &[_][]const u8{ "-DIMPL", backend_option },
            });
        }
        lib.linkSystemLibrary("GLESv3");
        lib.linkSystemLibrary("EGL");
        lib.linkSystemLibrary("android");
        lib.linkSystemLibrary("log");
    } else if (lib.rootModuleTarget().os.tag == .linux) {
        const egl_flag = if (options.force_egl) "-DSOKOL_FORCE_EGL " else "";
        const x11_flag = if (!options.enable_x11) "-DSOKOL_DISABLE_X11 " else "";
        const wayland_flag = if (!options.enable_wayland) "-DSOKOL_DISABLE_WAYLAND" else "";
        const link_egl = options.force_egl or options.enable_wayland;
        for (csources) |csrc| {
            lib.addCSourceFile(.{
                .file = .{ .path = b.fmt("{s}/{s}", .{ sokol_path, csrc }) },
                .flags = &[_][]const u8{ "-DIMPL", backend_option, egl_flag, x11_flag, wayland_flag },
            });
        }
        lib.linkSystemLibrary("asound");
        lib.linkSystemLibrary("GL");
        if (options.enable_x11) {
            lib.linkSystemLibrary("X11");
            lib.linkSystemLibrary("Xi");
            lib.linkSystemLibrary("Xcursor");
        }
        if (options.enable_wayland) {
            lib.linkSystemLibrary("wayland-client");
            lib.linkSystemLibrary("wayland-cursor");
            lib.linkSystemLibrary("wayland-egl");
            lib.linkSystemLibrary("xkbcommon");
        }
        if (link_egl) {
            lib.linkSystemLibrary("egl");
        }
    } else if (lib.rootModuleTarget().os.tag == .windows) {
        for (csources) |csrc| {
            lib.addCSourceFile(.{
                .file = .{ .path = b.fmt("{s}/{s}", .{ sokol_path, csrc }) },
                .flags = &[_][]const u8{ "-DIMPL", backend_option },
            });
        }
        lib.linkSystemLibrary("kernel32");
        lib.linkSystemLibrary("user32");
        lib.linkSystemLibrary("gdi32");
        lib.linkSystemLibrary("ole32");
        if (.d3d11 == _backend) {
            lib.linkSystemLibrary("d3d11");
            lib.linkSystemLibrary("dxgi");
        }
    } else {
        for (csources) |csrc| {
            lib.addCSourceFile(.{
                .file = .{ .path = b.fmt("{s}/{s}", .{ sokol_path, csrc }) },
                .flags = &[_][]const u8{ "-DIMPL", backend_option },
            });
        }
    }
    return lib;
}

// build one of the example exes
fn buildExample(b: *Build, comptime name: []const u8, options: ExampleOptions) void {
    const e = if (options.target.result.isWasm()) b.addStaticLibrary(.{
        .name = name,
        .root_source_file = .{ .path = "src/examples/" ++ name ++ ".zig" },
        .target = options.target,
        .optimize = options.optimize,
    }) else b.addExecutable(.{
        .name = name,
        .root_source_file = .{ .path = "src/examples/" ++ name ++ ".zig" },
        .target = options.target,
        .optimize = options.optimize,
    });
    e.linkLibrary(options.lib_sokol);
    e.root_module.addImport("sokol", options.mod_sokol);
    var run: ?*RunStep = null;
    if (e.rootModuleTarget().isWasm()) {
        run = buildWasm(b, e, options) catch |err| @panic(@errorName(err));
    } else {
        b.installArtifact(e);
        run = b.addRunArtifact(e);
    }
    b.step("run-" ++ name, "Run " ++ name).dependOn(&run.?.step);
}

// a separate step to compile shaders, expects the shader compiler in ../sokol-tools-bin/
// TODO: install sokol-shdc via package manager
fn buildShaders(b: *Build) void {
    const sokol_tools_bin_dir = "../sokol-tools-bin/bin/";
    const shaders_dir = "src/examples/shaders/";
    const shaders = .{
        "bufferoffsets.glsl",
        "cube.glsl",
        "instancing.glsl",
        "mrt.glsl",
        "noninterleaved.glsl",
        "offscreen.glsl",
        "quad.glsl",
        "shapes.glsl",
        "texcube.glsl",
        "blend.glsl",
    };
    const optional_shdc: ?[:0]const u8 = comptime switch (builtin.os.tag) {
        .windows => "win32/sokol-shdc.exe",
        .linux => "linux/sokol-shdc",
        .macos => if (builtin.cpu.arch.isX86()) "osx/sokol-shdc" else "osx_arm64/sokol-shdc",
        else => null,
    };
    if (optional_shdc == null) {
        std.log.warn("unsupported host platform, skipping shader compiler step", .{});
        return;
    }
    const shdc_path = sokol_tools_bin_dir ++ optional_shdc.?;
    const shdc_step = b.step("shaders", "Compile shaders (needs ../sokol-tools-bin)");
    inline for (shaders) |shader| {
        const cmd = b.addSystemCommand(&.{
            shdc_path,
            "-i",
            shaders_dir ++ shader,
            "-o",
            shaders_dir ++ shader ++ ".zig",
            "-l",
            "glsl330:metal_macos:hlsl4:glsl300es:wgsl",
            "-f",
            "sokol_zig",
        });
        shdc_step.dependOn(&cmd.step);
    }
}

fn buildWasm(b: *Build, example: *CompileStep, options: ExampleOptions) !*RunStep {
    // system path or package path
    const emcc_path = b.findProgram(&.{"emcc"}, &.{}) catch b.pathJoin(&.{ options.emsdkPath(b).?, "upstream", "emscripten", "emcc" });
    const emrun_path = b.findProgram(&.{"emrun"}, &.{}) catch b.pathJoin(&.{ options.emsdkPath(b).?, "upstream", "emscripten", "emrun" });

    if (options.lib_sokol.rootModuleTarget().os.tag != .emscripten) {
        std.log.err("Please build with 'zig build -Dtarget=wasm32-emscripten", .{});
        return error.Wasm32EmscriptenExpected;
    }

    // Make web content path
    try std.fs.cwd().makePath(b.fmt("{s}/web", .{b.install_path}));

    var emcc_cmd = std.ArrayList([]const u8).init(b.allocator);
    defer emcc_cmd.deinit();

    try emcc_cmd.append(emcc_path);
    if (options.optimize != .Debug)
        try emcc_cmd.append("-Oz")
    else
        try emcc_cmd.append("-Og");
    try emcc_cmd.append("--closure");
    try emcc_cmd.append("1");
    try emcc_cmd.append(b.fmt("-o{s}/web/{s}.html", .{ b.install_path, example.name }));
    try emcc_cmd.append("-sNO_FILESYSTEM=1");
    try emcc_cmd.append("-sMALLOC='emmalloc'");
    try emcc_cmd.append("-sASSERTIONS=0");
    try emcc_cmd.append("-sERROR_ON_UNDEFINED_SYMBOLS=0");
    try emcc_cmd.append("--shell-file=src/sokol/web/shell.html");

    // TODO: fix undefined references
    // switch (options.backend) {
    //     .wgpu => {
    // try emcc_cmd.append("-sUSE_WEBGPU=1");
    // },
    // else => {
    try emcc_cmd.append("-sUSE_WEBGL2=1");
    //     },
    // }

    const emcc = b.addSystemCommand(emcc_cmd.items);
    emcc.setName("emcc"); // hide emcc path

    // get artifacts from zig-cache, no need zig-out
    emcc.addArtifactArg(options.lib_sokol);
    emcc.addArtifactArg(example);

    // get the emcc step to run on 'zig build'
    b.getInstallStep().dependOn(&emcc.step);

    // a seperate run step using emrun
    const emrun = b.addSystemCommand(&.{ emrun_path, b.fmt("{s}/web/{s}.html", .{ b.install_path, example.name }) });
    emrun.step.dependOn(&emcc.step);
    return emrun;
}
