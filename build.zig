const std = @import("std");
const builtin = @import("builtin");
const Build = std.Build;
const OptimizeMode = std.builtin.OptimizeMode;

pub const SokolBackend = enum {
    auto, // Windows: D3D11, macOS/iOS: Metal, otherwise: GL
    d3d11,
    metal,
    gl,
    gles3,
    wgpu,
};

pub fn build(b: *Build) !void {
    const opt_use_gl = b.option(bool, "gl", "Force OpenGL (default: false)") orelse false;
    const opt_use_gles3 = b.option(bool, "gles3", "Force OpenGL ES3 (default: false)") orelse false;
    const opt_use_wgpu = b.option(bool, "wgpu", "Force WebGPU (default: false, web only)") orelse false;
    const opt_use_x11 = b.option(bool, "x11", "Force X11 (default: true, Linux only)") orelse true;
    const opt_use_wayland = b.option(bool, "wayland", "Force Wayland (default: false, Linux only, not supported in main-line headers)") orelse false;
    const opt_use_egl = b.option(bool, "egl", "Force EGL (default: false, Linux only)") orelse false;
    const opt_with_sokol_imgui = b.option(bool, "with_sokol_imgui", "Add support for sokol_imgui.h bindings") orelse false;
    const opt_sokol_imgui_cprefix = b.option([]const u8, "sokol_imgui_cprefix", "Override Dear ImGui C bindings prefix for sokol_imgui.h (see SOKOL_IMGUI_CPREFIX)");
    const opt_cimgui_header_path = b.option([]const u8, "cimgui_header_path", "Override the Dear ImGui C bindings header name (default: cimgui.h)");
    const sokol_backend: SokolBackend = if (opt_use_gl) .gl else if (opt_use_gles3) .gles3 else if (opt_use_wgpu) .wgpu else .auto;

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const emsdk = b.dependency("emsdk", .{});

    // a module for the actual bindings, and a static link library with the C code
    const mod_sokol = b.addModule("sokol", .{ .root_source_file = b.path("src/sokol/sokol.zig") });
    const lib_sokol = try buildLibSokol(b, .{
        .target = target,
        .optimize = optimize,
        .backend = sokol_backend,
        .use_wayland = opt_use_wayland,
        .use_x11 = opt_use_x11,
        .use_egl = opt_use_egl,
        .with_sokol_imgui = opt_with_sokol_imgui,
        .sokol_imgui_cprefix = opt_sokol_imgui_cprefix,
        .cimgui_header_path = opt_cimgui_header_path,
        .emsdk = emsdk,
    });
    mod_sokol.linkLibrary(lib_sokol);

    // the integrated examples
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
        "vertexpull",
    };
    inline for (examples) |example| {
        try buildExample(b, example, .{
            .target = target,
            .optimize = optimize,
            .backend = sokol_backend,
            .mod_sokol = mod_sokol,
            .emsdk = emsdk,
        });
    }

    // a manually invoked build step to recompile shaders via sokol-shdc
    buildShaders(b, target);
}

// build one of the examples
const ExampleOptions = struct {
    target: Build.ResolvedTarget,
    optimize: OptimizeMode,
    backend: SokolBackend,
    mod_sokol: *Build.Module,
    emsdk: *Build.Dependency,
};
fn buildExample(b: *Build, comptime name: []const u8, options: ExampleOptions) !void {
    const main_src = "src/examples/" ++ name ++ ".zig";
    var run: ?*Build.Step.Run = null;
    if (!options.target.result.isWasm()) {
        // for native platforms, build into a regular executable
        const example = b.addExecutable(.{
            .name = name,
            .root_source_file = b.path(main_src),
            .target = options.target,
            .optimize = options.optimize,
        });
        example.root_module.addImport("sokol", options.mod_sokol);
        b.installArtifact(example);
        run = b.addRunArtifact(example);
    } else {
        // for WASM, need to build the Zig code as static library, since linking happens via emcc
        const example = b.addStaticLibrary(.{
            .name = name,
            .root_source_file = b.path(main_src),
            .target = options.target,
            .optimize = options.optimize,
        });
        example.root_module.addImport("sokol", options.mod_sokol);

        // create a special emcc linker run step
        const backend = resolveSokolBackend(options.backend, options.target.result);
        const link_step = try emLinkStep(b, .{
            .lib_main = example,
            .target = options.target,
            .optimize = options.optimize,
            .emsdk = options.emsdk,
            .use_webgpu = backend == .wgpu,
            .use_webgl2 = backend != .wgpu,
            .use_emmalloc = true,
            .use_filesystem = false,
            .shell_file_path = b.path("src/sokol/web/shell.html"),
            .extra_args = &.{"-sSTACK_SIZE=512KB"},
        });
        // ...and a special run step to run the build result via emrun
        run = emRunStep(b, .{ .name = name, .emsdk = options.emsdk });
        run.?.step.dependOn(&link_step.step);
    }
    b.step("run-" ++ name, "Run " ++ name).dependOn(&run.?.step);
}

// helper function to resolve .auto backend based on target platform
pub fn resolveSokolBackend(backend: SokolBackend, target: std.Target) SokolBackend {
    if (backend != .auto) {
        return backend;
    } else if (target.isDarwin()) {
        return .metal;
    } else if (target.os.tag == .windows) {
        return .d3d11;
    } else if (target.isWasm()) {
        return .gles3;
    } else if (target.isAndroid()) {
        return .gles3;
    } else {
        return .gl;
    }
}

// build the sokol C headers into a static library
pub const LibSokolOptions = struct {
    target: Build.ResolvedTarget,
    optimize: OptimizeMode,
    backend: SokolBackend = .auto,
    use_egl: bool = false,
    use_x11: bool = true,
    use_wayland: bool = false,
    emsdk: ?*Build.Dependency = null,
    with_sokol_imgui: bool = false,
    sokol_imgui_cprefix: ?[]const u8 = null,
    cimgui_header_path: ?[]const u8 = null,
};
pub fn buildLibSokol(b: *Build, options: LibSokolOptions) !*Build.Step.Compile {
    const lib = b.addStaticLibrary(.{
        .name = "sokol_clib",
        .target = options.target,
        .optimize = options.optimize,
        .link_libc = true,
    });

    // installArtifact allows us to find the lib_sokol compile step when
    // sokol is used as package manager dependency via 'dep_sokol.artifact("sokol_clib")'
    b.installArtifact(lib);

    if (options.target.result.isWasm()) {
        // make sure we're building for the wasm32-emscripten target, not wasm32-freestanding
        if (lib.rootModuleTarget().os.tag != .emscripten) {
            std.log.err("Please build with 'zig build -Dtarget=wasm32-emscripten", .{});
            return error.Wasm32EmscriptenExpected;
        }
        // one-time setup of Emscripten SDK
        if (try emSdkSetupStep(b, options.emsdk.?)) |emsdk_setup| {
            lib.step.dependOn(&emsdk_setup.step);
        }
        // add the Emscripten system include seach path
        lib.addSystemIncludePath(emSdkLazyPath(b, options.emsdk.?, &.{ "upstream", "emscripten", "cache", "sysroot", "include" }));
    }

    // resolve .auto backend into specific backend by platform
    var cflags = try std.BoundedArray([]const u8, 64).init(0);
    try cflags.append("-DIMPL");
    const backend = resolveSokolBackend(options.backend, lib.rootModuleTarget());
    switch (backend) {
        .d3d11 => try cflags.append("-DSOKOL_D3D11"),
        .metal => try cflags.append("-DSOKOL_METAL"),
        .gl => try cflags.append("-DSOKOL_GLCORE"),
        .gles3 => try cflags.append("-DSOKOL_GLES3"),
        .wgpu => try cflags.append("-DSOKOL_WGPU"),
        else => @panic("unknown sokol backend"),
    }

    // platform specific compile and link options
    if (lib.rootModuleTarget().isDarwin()) {
        try cflags.append("-ObjC");
        lib.linkFramework("Foundation");
        lib.linkFramework("AudioToolbox");
        if (.metal == backend) {
            lib.linkFramework("MetalKit");
            lib.linkFramework("Metal");
        }
        if (lib.rootModuleTarget().os.tag == .ios) {
            lib.linkFramework("UIKit");
            lib.linkFramework("AVFoundation");
            if (.gl == backend) {
                lib.linkFramework("OpenGLES");
                lib.linkFramework("GLKit");
            }
        } else if (lib.rootModuleTarget().os.tag == .macos) {
            lib.linkFramework("Cocoa");
            lib.linkFramework("QuartzCore");
            if (.gl == backend) {
                lib.linkFramework("OpenGL");
            }
        }
    } else if (lib.rootModuleTarget().isAndroid()) {
        if (.gles3 != backend) {
            @panic("For android targets, you must have backend set to GLES3");
        }
        lib.linkSystemLibrary("GLESv3");
        lib.linkSystemLibrary("EGL");
        lib.linkSystemLibrary("android");
        lib.linkSystemLibrary("log");
    } else if (lib.rootModuleTarget().os.tag == .linux) {
        if (options.use_egl) try cflags.append("-DSOKOL_FORCE_EGL");
        if (!options.use_x11) try cflags.append("-DSOKOL_DISABLE_X11");
        if (!options.use_wayland) try cflags.append("-DSOKOL_DISABLE_WAYLAND");
        const link_egl = options.use_egl or options.use_wayland;
        lib.linkSystemLibrary("asound");
        lib.linkSystemLibrary("GL");
        if (options.use_x11) {
            lib.linkSystemLibrary("X11");
            lib.linkSystemLibrary("Xi");
            lib.linkSystemLibrary("Xcursor");
        }
        if (options.use_wayland) {
            lib.linkSystemLibrary("wayland-client");
            lib.linkSystemLibrary("wayland-cursor");
            lib.linkSystemLibrary("wayland-egl");
            lib.linkSystemLibrary("xkbcommon");
        }
        if (link_egl) {
            lib.linkSystemLibrary("EGL");
        }
    } else if (lib.rootModuleTarget().os.tag == .windows) {
        lib.linkSystemLibrary("kernel32");
        lib.linkSystemLibrary("user32");
        lib.linkSystemLibrary("gdi32");
        lib.linkSystemLibrary("ole32");
        if (.d3d11 == backend) {
            lib.linkSystemLibrary("d3d11");
            lib.linkSystemLibrary("dxgi");
        }
    }

    // finally add the C source files
    const csrc_root = "src/sokol/c/";
    const csources = [_][]const u8{
        "sokol_log.c",
        "sokol_app.c",
        "sokol_gfx.c",
        "sokol_time.c",
        "sokol_audio.c",
        "sokol_gl.c",
        "sokol_debugtext.c",
        "sokol_shape.c",
        "sokol_glue.c",
        "sokol_fetch.c",
    };
    inline for (csources) |csrc| {
        lib.addCSourceFile(.{
            .file = b.path(csrc_root ++ csrc),
            .flags = cflags.slice(),
        });
    }

    // optional Dear ImGui support, the called is required to also
    // add the cimgui include path to the returned compile step
    if (options.with_sokol_imgui) {
        if (options.sokol_imgui_cprefix) |cprefix| {
            try cflags.append(b.fmt("-DSOKOL_IMGUI_CPREFIX={s}", .{cprefix}));
        }
        if (options.cimgui_header_path) |cimgui_header_path| {
            try cflags.append(b.fmt("-DCIMGUI_HEADER_PATH=\"{s}\"", .{cimgui_header_path}));
        }
        lib.addCSourceFile(.{
            .file = b.path(csrc_root ++ "sokol_imgui.c"),
            .flags = cflags.slice(),
        });
    }
    return lib;
}

// for wasm32-emscripten, need to run the Emscripten linker from the Emscripten SDK
// NOTE: ideally this would go into a separate emsdk-zig package
pub const EmLinkOptions = struct {
    target: Build.ResolvedTarget,
    optimize: OptimizeMode,
    lib_main: *Build.Step.Compile, // the actual Zig code must be compiled to a static link library
    emsdk: *Build.Dependency,
    release_use_closure: bool = true,
    release_use_lto: bool = true,
    use_webgpu: bool = false,
    use_webgl2: bool = false,
    use_emmalloc: bool = false,
    use_filesystem: bool = true,
    shell_file_path: ?Build.LazyPath,
    extra_args: []const []const u8 = &.{},
};
pub fn emLinkStep(b: *Build, options: EmLinkOptions) !*Build.Step.InstallDir {
    const emcc_path = emSdkLazyPath(b, options.emsdk, &.{ "upstream", "emscripten", "emcc" }).getPath(b);
    const emcc = b.addSystemCommand(&.{emcc_path});
    emcc.setName("emcc"); // hide emcc path
    if (options.optimize == .Debug) {
        emcc.addArgs(&.{ "-Og", "-sSAFE_HEAP=1", "-sSTACK_OVERFLOW_CHECK=1" });
    } else {
        emcc.addArg("-sASSERTIONS=0");
        if (options.optimize == .ReleaseSmall) {
            emcc.addArg("-Oz");
        } else {
            emcc.addArg("-O3");
        }
        if (options.release_use_lto) {
            emcc.addArg("-flto");
        }
        if (options.release_use_closure) {
            emcc.addArgs(&.{ "--closure", "1" });
        }
    }
    if (options.use_webgpu) {
        emcc.addArg("-sUSE_WEBGPU=1");
    }
    if (options.use_webgl2) {
        emcc.addArg("-sUSE_WEBGL2=1");
    }
    if (!options.use_filesystem) {
        emcc.addArg("-sNO_FILESYSTEM=1");
    }
    if (options.use_emmalloc) {
        emcc.addArg("-sMALLOC='emmalloc'");
    }
    if (options.shell_file_path) |shell_file_path| {
        emcc.addPrefixedFileArg("--shell-file=", shell_file_path);
    }
    for (options.extra_args) |arg| {
        emcc.addArg(arg);
    }

    // add the main lib, and then scan for library dependencies and add those too
    emcc.addArtifactArg(options.lib_main);

    // TODO: This is hack to support master and 0.13.0 zig versions. Remove after 0.14.0.
    if (builtin.zig_version.major == 0 and builtin.zig_version.minor < 14) {
        // FIXME: old version, remove after 0.14
        var it = options.lib_main.root_module.iterateDependencies(options.lib_main, false);
        while (it.next()) |item| {
            for (item.module.link_objects.items) |link_object| {
                switch (link_object) {
                    .other_step => |compile_step| {
                        switch (compile_step.kind) {
                            .lib => {
                                emcc.addArtifactArg(compile_step);
                            },
                            else => {},
                        }
                    },
                    else => {},
                }
            }
        }
    } else {
        const it = options.lib_main.getCompileDependencies(false);
        for (it) |item| {
            for (item.root_module.link_objects.items) |link_object| {
                switch (link_object) {
                    .other_step => |compile_step| {
                        switch (compile_step.kind) {
                            .lib => {
                                emcc.addArtifactArg(compile_step);
                            },
                            else => {},
                        }
                    },
                    else => {},
                }
            }
        }
    }
    emcc.addArg("-o");
    const out_file = emcc.addOutputFileArg(b.fmt("{s}.html", .{options.lib_main.name}));

    // the emcc linker creates 3 output files (.html, .wasm and .js)
    const install = b.addInstallDirectory(.{
        .source_dir = out_file.dirname(),
        .install_dir = .prefix,
        .install_subdir = "web",
    });
    install.step.dependOn(&emcc.step);

    // get the emcc step to run on 'zig build'
    b.getInstallStep().dependOn(&install.step);
    return install;
}

// build a run step which uses the emsdk emrun command to run a build target in the browser
// NOTE: ideally this would go into a separate emsdk-zig package
pub const EmRunOptions = struct {
    name: []const u8,
    emsdk: *Build.Dependency,
};
pub fn emRunStep(b: *Build, options: EmRunOptions) *Build.Step.Run {
    const emrun_path = b.findProgram(&.{"emrun"}, &.{}) catch emSdkLazyPath(b, options.emsdk, &.{ "upstream", "emscripten", "emrun" }).getPath(b);
    const emrun = b.addSystemCommand(&.{ emrun_path, b.fmt("{s}/web/{s}.html", .{ b.install_path, options.name }) });
    return emrun;
}

// helper function to build a LazyPath from the emsdk root and provided path components
fn emSdkLazyPath(b: *Build, emsdk: *Build.Dependency, subPaths: []const []const u8) Build.LazyPath {
    return emsdk.path(b.pathJoin(subPaths));
}

fn createEmsdkStep(b: *Build, emsdk: *Build.Dependency) *Build.Step.Run {
    if (builtin.os.tag == .windows) {
        return b.addSystemCommand(&.{emSdkLazyPath(b, emsdk, &.{"emsdk.bat"}).getPath(b)});
    } else {
        const step = b.addSystemCommand(&.{"bash"});
        step.addArg(emSdkLazyPath(b, emsdk, &.{"emsdk"}).getPath(b));
        return step;
    }
}

// One-time setup of the Emscripten SDK (runs 'emsdk install + activate'). If the
// SDK had to be setup, a run step will be returned which should be added
// as dependency to the sokol library (since this needs the emsdk in place),
// if the emsdk was already setup, null will be returned.
// NOTE: ideally this would go into a separate emsdk-zig package
// NOTE 2: the file exists check is a bit hacky, it would be cleaner
// to build an on-the-fly helper tool which takes care of the SDK
// setup and just does nothing if it already happened
// NOTE 3: this code works just fine when the SDK version is updated in build.zig.zon
// since this will be cloned into a new zig cache directory which doesn't have
// an .emscripten file yet until the one-time setup.
fn emSdkSetupStep(b: *Build, emsdk: *Build.Dependency) !?*Build.Step.Run {
    const dot_emsc_path = emSdkLazyPath(b, emsdk, &.{".emscripten"}).getPath(b);
    const dot_emsc_exists = !std.meta.isError(std.fs.accessAbsolute(dot_emsc_path, .{}));
    if (!dot_emsc_exists) {
        const emsdk_install = createEmsdkStep(b, emsdk);
        emsdk_install.addArgs(&.{ "install", "latest" });
        const emsdk_activate = createEmsdkStep(b, emsdk);
        emsdk_activate.addArgs(&.{ "activate", "latest" });
        emsdk_activate.step.dependOn(&emsdk_install.step);
        return emsdk_activate;
    } else {
        return null;
    }
}

// a separate step to compile shaders, expects the shader compiler in ../sokol-tools-bin/
// TODO: install sokol-shdc via package manager
fn buildShaders(b: *Build, target: Build.ResolvedTarget) void {
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
        "vertexpull.glsl",
        "triangle.glsl",
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
    const glsl = if (target.result.isDarwin()) "glsl410" else "glsl430";
    const slang = glsl ++ ":metal_macos:hlsl5:glsl300es:wgsl";
    inline for (shaders) |shader| {
        const cmd = b.addSystemCommand(&.{
            shdc_path,
            "-i",
            shaders_dir ++ shader,
            "-o",
            shaders_dir ++ shader ++ ".zig",
            "-l",
            slang,
            "-f",
            "sokol_zig",
            "--reflection",
        });
        shdc_step.dependOn(&cmd.step);
    }
}
