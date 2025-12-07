const std = @import("std");
const builtin = @import("builtin");
const Build = std.Build;
const OptimizeMode = std.builtin.OptimizeMode;

// re-export the shader compiler module for use by upstream projects
pub const shdc = @import("shdc");

const examples = [_]Example{
    .{ .name = "clear" },
    .{ .name = "triangle", .has_shader = true },
    .{ .name = "quad", .has_shader = true },
    .{ .name = "bufferoffsets", .has_shader = true },
    .{ .name = "cube", .has_shader = true },
    .{ .name = "noninterleaved", .has_shader = true },
    .{ .name = "texcube", .has_shader = true },
    .{ .name = "blend", .has_shader = true },
    .{ .name = "offscreen", .has_shader = true },
    .{ .name = "instancing", .has_shader = true },
    .{ .name = "mrt", .has_shader = true },
    .{ .name = "saudio" },
    .{ .name = "sgl" },
    .{ .name = "sgl-context" },
    .{ .name = "sgl-points" },
    .{ .name = "debugtext" },
    .{ .name = "debugtext-print" },
    .{ .name = "debugtext-userfont" },
    .{ .name = "shapes", .has_shader = true },
    .{ .name = "vertexpull", .has_shader = true, .needs_compute = true },
    .{ .name = "instancing-compute", .has_shader = true, .needs_compute = true },
};

pub const SokolBackend = enum {
    auto, // Windows: D3D11, macOS/iOS: Metal, otherwise: GL
    d3d11,
    metal,
    gl,
    gles3,
    wgpu,
    vulkan,
};

pub const TargetPlatform = enum {
    android,
    linux,
    darwin, // macos and ios
    macos,
    ios,
    windows,
    web,
};

pub fn isPlatform(target: std.Target, platform: TargetPlatform) bool {
    return switch (platform) {
        .android => target.abi.isAndroid(),
        .linux => target.os.tag == .linux,
        .darwin => target.os.tag.isDarwin(),
        .macos => target.os.tag == .macos,
        .ios => target.os.tag == .ios,
        .windows => target.os.tag == .windows,
        .web => target.cpu.arch.isWasm(),
    };
}

pub fn build(b: *Build) !void {
    const opt_use_gl = b.option(bool, "gl", "Force OpenGL (default: false)") orelse false;
    const opt_use_gles3 = b.option(bool, "gles3", "Force OpenGL ES3 (default: false)") orelse false;
    const opt_use_wgpu = b.option(bool, "wgpu", "Force WebGPU (default: false, web only)") orelse false;
    const opt_use_vulkan = b.option(bool, "vulkan", "Force Vulkan (default: false)") orelse false;
    const opt_use_x11 = b.option(bool, "x11", "Force X11 (default: true, Linux only)") orelse true;
    const opt_use_wayland = b.option(bool, "wayland", "Force Wayland (default: false, Linux only, not supported in main-line headers)") orelse false;
    const opt_use_egl = b.option(bool, "egl", "Force EGL (default: false, Linux only)") orelse false;
    const opt_with_sokol_imgui = b.option(bool, "with_sokol_imgui", "Add support for sokol_imgui.h bindings") orelse false;
    const opt_with_tracing = b.option(bool, "with_tracing", "Add support for sokol_gfx tracing and debug UI") orelse false;
    const opt_dont_link_system_libs = b.option(bool, "dont_link_system_libs", "Do not link system libraries required by sokol (default: false)") orelse false;
    const opt_sokol_imgui_cprefix = b.option([]const u8, "sokol_imgui_cprefix", "Override Dear ImGui C bindings prefix for sokol_imgui.h (see SOKOL_IMGUI_CPREFIX)");
    const opt_cimgui_header_path = b.option([]const u8, "cimgui_header_path", "Override the Dear ImGui C bindings header name (default: cimgui.h)");
    const opt_dynamic_linkage = b.option(bool, "dynamic_linkage", "Build sokol_clib artifact as dynamic link library.") orelse false;
    const sokol_backend: SokolBackend = if (opt_use_gl) .gl
        else if (opt_use_gles3) .gles3
        else if (opt_use_wgpu) .wgpu
        else if (opt_use_vulkan) .vulkan
        else .auto;

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const emsdk = b.dependency("emsdk", .{});

    // a module for the actual bindings, and a static link library with the C code
    const mod_sokol = b.addModule("sokol", .{ .root_source_file = b.path("src/sokol/sokol.zig") });
    const lib_sokol = try buildLibSokol(b, .{
        .target = target,
        .optimize = optimize,
        .backend = sokol_backend,
        .dynamic_linkage = opt_dynamic_linkage,
        .use_wayland = opt_use_wayland,
        .use_x11 = opt_use_x11,
        .use_egl = opt_use_egl,
        .with_sokol_imgui = opt_with_sokol_imgui or opt_with_tracing,
        .with_tracing = opt_with_tracing,
        .sokol_imgui_cprefix = opt_sokol_imgui_cprefix,
        .cimgui_header_path = opt_cimgui_header_path,
        .emsdk = emsdk,
        .dont_link_system_libs = opt_dont_link_system_libs,
    });
    mod_sokol.linkLibrary(lib_sokol);

    // examples build step
    const examples_step = try buildExamples(b, .{
        .target = target,
        .optimize = optimize,
        .backend = sokol_backend,
        .mod_sokol = mod_sokol,
        .emsdk = emsdk,
    });
    // a manually invoked build step to build auto-docs
    buildDocs(b, target);

    // web server
    buildWebServer(b, optimize, examples_step);
}

// helper function to resolve .auto backend based on target platform
pub fn resolveSokolBackend(backend: SokolBackend, target: std.Target) SokolBackend {
    if (backend != .auto) {
        return backend;
    } else if (isPlatform(target, .darwin)) {
        return .metal;
    } else if (isPlatform(target, .windows)) {
        return .d3d11;
    } else if (isPlatform(target, .web)) {
        return .gles3;
    } else if (isPlatform(target, .android)) {
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
    dynamic_linkage: bool = false,
    use_wayland: bool = false,
    emsdk: ?*Build.Dependency = null,
    with_sokol_imgui: bool = false,
    with_tracing: bool = false,
    sokol_imgui_cprefix: ?[]const u8 = null,
    cimgui_header_path: ?[]const u8 = null,
    dont_link_system_libs: bool = true,
};
pub fn buildLibSokol(b: *Build, options: LibSokolOptions) !*Build.Step.Compile {
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
    const mod = b.addModule("mod_sokol_clib", .{
        .target = options.target,
        .optimize = options.optimize,
        .link_libc = true,
    });
    const mod_target = options.target.result;
    const backend = resolveSokolBackend(options.backend, mod_target);
    const lib = b.addLibrary(.{
        .name = "sokol_clib",
        .linkage = if (options.dynamic_linkage) .dynamic else .static,
        .root_module = mod,
    });
    if (isPlatform(mod_target, .web)) {
        const emsdk = options.emsdk orelse {
            std.log.err("Must provide emsdk dependency when building for web (LibSokolOptions.emsdk)", .{});
            return error.EmscriptenSdkDepenencyExpected;
        };
        // make sure we're building for the wasm32-emscripten target, not wasm32-freestanding
        if (mod_target.os.tag != .emscripten) {
            std.log.err("Please build with 'zig build -Dtarget=wasm32-emscripten", .{});
            return error.TargetWasm32EmscriptenExpected;
        }
        const opt_emsdk_setup_step = try emSdkSetupStep(b, emsdk);

        // for WebGPU, need to run embuilder for `emdawnwebgpu` after emsdk setup and before C library build
        if (options.backend == .wgpu) {
            const embuilder_step = emBuilderStep(b, .{
                .port_name = "emdawnwebgpu",
                .emsdk = emsdk,
            });
            if (opt_emsdk_setup_step) |emsdk_setup_step| {
                embuilder_step.step.dependOn(&emsdk_setup_step.step);
            }
            lib.step.dependOn(&embuilder_step.step);
            // need to add include path to find emdawnwebgpu <webgpu/webgpu.h> before Emscripten SDK webgpu.h
            mod.addSystemIncludePath(emSdkLazyPath(b, emsdk, &.{ "upstream", "emscripten", "cache", "ports", "emdawnwebgpu", "emdawnwebgpu_pkg", "webgpu", "include" }));
        } else {
            if (opt_emsdk_setup_step) |emsdk_setup_step| {
                lib.step.dependOn(&emsdk_setup_step.step);
            }
        }

        // add the Emscripten system include seach path
        mod.addSystemIncludePath(emSdkLazyPath(b, emsdk, &.{ "upstream", "emscripten", "cache", "sysroot", "include" }));
    }

    // resolve .auto backend into specific backend by platform
    var cflags_buf: [64][]const u8 = undefined;
    var cflags = std.ArrayListUnmanaged([]const u8).initBuffer(&cflags_buf);

    try cflags.appendBounded("-DIMPL");
    if (options.with_tracing) {
        try cflags.appendBounded("-DSOKOL_TRACE_HOOKS");
    }
    if (options.optimize != .Debug) {
        try cflags.appendBounded("-DNDEBUG");
    }
    switch (backend) {
        .d3d11 => try cflags.appendBounded("-DSOKOL_D3D11"),
        .metal => try cflags.appendBounded("-DSOKOL_METAL"),
        .gl => try cflags.appendBounded("-DSOKOL_GLCORE"),
        .gles3 => try cflags.appendBounded("-DSOKOL_GLES3"),
        .wgpu => try cflags.appendBounded("-DSOKOL_WGPU"),
        .vulkan => try cflags.appendBounded("-DSOKOL_VULKAN"),
        else => @panic("unknown sokol backend"),
    }

    // platform specific compile and link options
    const link_system_libs = !options.dont_link_system_libs;
    if (isPlatform(mod_target, .darwin)) {
        try cflags.appendBounded("-ObjC");
        if (link_system_libs) {
            mod.linkFramework("Foundation", .{});
            mod.linkFramework("AudioToolbox", .{});
            if (.metal == backend) {
                mod.linkFramework("MetalKit", .{});
                mod.linkFramework("Metal", .{});
            }
            if (mod_target.os.tag == .ios) {
                mod.linkFramework("UIKit", .{});
                mod.linkFramework("AVFoundation", .{});
                if (.gl == backend) {
                    mod.linkFramework("OpenGLES", .{});
                    mod.linkFramework("GLKit", .{});
                }
            } else if (mod_target.os.tag == .macos) {
                mod.linkFramework("Cocoa", .{});
                mod.linkFramework("QuartzCore", .{});
                if (.gl == backend) {
                    mod.linkFramework("OpenGL", .{});
                }
            }
        }
    } else if (isPlatform(mod_target, .android)) {
        if (.gles3 != backend) {
            @panic("For android targets, you must have backend set to GLES3");
        }
        if (link_system_libs) {
            mod.linkSystemLibrary("GLESv3", .{});
            mod.linkSystemLibrary("EGL", .{});
            mod.linkSystemLibrary("android", .{});
            mod.linkSystemLibrary("log", .{});
        }
    } else if (isPlatform(mod_target, .linux)) {
        if (options.use_egl) try cflags.appendBounded("-DSOKOL_FORCE_EGL");
        if (!options.use_x11) try cflags.appendBounded("-DSOKOL_DISABLE_X11");
        if (!options.use_wayland) try cflags.appendBounded("-DSOKOL_DISABLE_WAYLAND");
        const link_egl = options.use_egl or options.use_wayland;
        if (link_system_libs) {
            mod.linkSystemLibrary("asound", .{});
            if (.vulkan == backend) {
                mod.linkSystemLibrary("vulkan", .{});
            } else {
                mod.linkSystemLibrary("GL", .{});
            }
            if (options.use_x11) {
                mod.linkSystemLibrary("X11", .{});
                mod.linkSystemLibrary("Xi", .{});
                mod.linkSystemLibrary("Xcursor", .{});
            }
            if (options.use_wayland) {
                mod.linkSystemLibrary("wayland-client", .{});
                mod.linkSystemLibrary("wayland-cursor", .{});
                mod.linkSystemLibrary("wayland-egl", .{});
                mod.linkSystemLibrary("xkbcommon", .{});
            }
            if (link_egl) {
                mod.linkSystemLibrary("EGL", .{});
            }
        }
    } else if (isPlatform(mod_target, .windows)) {
        if (link_system_libs) {
            mod.linkSystemLibrary("kernel32", .{});
            mod.linkSystemLibrary("user32", .{});
            mod.linkSystemLibrary("gdi32", .{});
            mod.linkSystemLibrary("ole32", .{});
            if (.d3d11 == backend) {
                mod.linkSystemLibrary("d3d11", .{});
                mod.linkSystemLibrary("dxgi", .{});
            }
        }
    } else if (isPlatform(mod_target, .web)) {
        try cflags.appendBounded("-fno-sanitize=undefined");
    }

    // finally add the C source files
    inline for (csources) |csrc| {
        mod.addCSourceFile(.{
            .file = b.path(csrc_root ++ csrc),
            .flags = cflags.items,
        });
    }

    // optional Dear ImGui support, the called is required to also
    // add the cimgui include path to the returned compile step
    if (options.with_sokol_imgui) {
        if (options.sokol_imgui_cprefix) |cprefix| {
            try cflags.appendBounded(b.fmt("-DSOKOL_IMGUI_CPREFIX={s}", .{cprefix}));
        }
        if (options.cimgui_header_path) |cimgui_header_path| {
            try cflags.appendBounded(b.fmt("-DCIMGUI_HEADER_PATH=\"{s}\"", .{cimgui_header_path}));
        }
        mod.addCSourceFile(.{
            .file = b.path(csrc_root ++ "sokol_imgui.c"),
            .flags = cflags.items,
        });

        if (options.with_tracing) {
            mod.addCSourceFile(.{
                .file = b.path(csrc_root ++ "sokol_gfx_imgui.c"),
                .flags = cflags.items,
            });
        }
    }

    // make sokol headers available to users of `sokol_clib` via `#include "sokol/sokol_gfx.h"
    lib.installHeadersDirectory(b.path("src/sokol/c"), "sokol", .{});

    // installArtifact allows us to find the lib_sokol compile step when
    // sokol is used as package manager dependency via 'dep_sokol.artifact("sokol_clib")'
    b.installArtifact(lib);

    return lib;
}

//== EMSCRIPTEN INTEGRATION ============================================================================================

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
    const emcc_path = emTool(b, options.emsdk, "emcc").getPath(b);
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
        emcc.addArg("--use-port=emdawnwebgpu");
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
    for (options.lib_main.getCompileDependencies(false)) |item| {
        if (item.kind == .lib) {
            emcc.addArtifactArg(item);
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
    return install;
}

// build a run step which uses the emsdk emrun command to run a build target in the browser
// NOTE: ideally this would go into a separate emsdk-zig package
pub const EmRunOptions = struct {
    name: []const u8,
    emsdk: *Build.Dependency,
};
pub fn emRunStep(b: *Build, options: EmRunOptions) *Build.Step.Run {
    const emrun_path = emTool(b, options.emsdk, "emrun").getPath(b);
    const emrun = b.addSystemCommand(&.{ emrun_path, b.fmt("{s}/web/{s}.html", .{ b.install_path, options.name }) });
    return emrun;
}

// build a system command step which runs the `embuilder command`
pub const EmBuilderOptions = struct {
    port_name: []const u8,
    lto: bool = false,
    pic: bool = false,
    force: bool = false,
    emsdk: *Build.Dependency,
};
pub fn emBuilderStep(b: *Build, options: EmBuilderOptions) *Build.Step.Run {
    const embuilder_path = emTool(b, options.emsdk, "embuilder").getPath(b);
    const embuilder = b.addSystemCommand(&.{embuilder_path});
    if (options.lto) {
        embuilder.addArg("--lto");
    }
    if (options.pic) {
        embuilder.addArg("--pic");
    }
    if (options.force) {
        embuilder.addArg("--force");
    }
    embuilder.addArgs(&.{ "build", options.port_name });
    return embuilder;
}

// helper function to build a LazyPath from the emsdk root and provided path components
fn emSdkLazyPath(b: *Build, emsdk: *Build.Dependency, sub_paths: []const []const u8) Build.LazyPath {
    return emsdk.path(b.pathJoin(sub_paths));
}

// helper function to get Emscripten SDK tool path
pub fn emTool(b: *Build, emsdk: *Build.Dependency, tool: []const u8) Build.LazyPath {
    return emSdkLazyPath(b, emsdk, &.{ "upstream", "emscripten", tool });
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
    const dot_emsc_exists = !std.meta.isError(std.fs.cwd().access(dot_emsc_path, .{}));
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

fn buildWebServer(b: *Build, optimize: OptimizeMode, examples_step:*Build.Step) void {
    const hosttarget = b.graph.host;

    const serve_exe = b.addExecutable(.{
        .name = "serve",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/httpserver/serve.zig"),
            .target = hosttarget,
            .optimize = optimize,
        }),
    });

    const mod_server = b.addModule("StaticHttpFileServer", .{
        .root_source_file = b.path("tools/httpserver/root.zig"),
        .target = hosttarget,
        .optimize = optimize,
    });

    mod_server.addImport("mime", b.dependency("mime", .{
        .target = hosttarget,
        .optimize = optimize,
    }).module("mime"));

    serve_exe.root_module.addImport("StaticHttpFileServer", mod_server);

    const run_serve_exe = b.addRunArtifact(serve_exe);
    run_serve_exe.addArgs(&.{"zig-out/web", "-p", "8000"});

    const serve_step = b.step("serve-wasm", "Serve wasm examples");
    serve_step.dependOn(&run_serve_exe.step);
    serve_step.dependOn(examples_step);
}

//== DOCUMENTATION =====================================================================================================
fn buildDocs(b: *Build, target: Build.ResolvedTarget) void {
    const lib = b.addLibrary(.{
        .name = "sokol",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/sokol/sokol.zig"),
            .target = target,
            .optimize = .Debug,
        }),
    });
    // need to invoke an external tool to inject custom functionality into a build step:
    const tool = b.addExecutable(.{
        .name = "fixdoctar",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/fixdoctar.zig"),
            .target = b.graph.host,
        }),
    });
    const tool_step = b.addRunArtifact(tool);
    tool_step.addArgs(&.{ "--prefix", "sokol", "--input" });
    tool_step.addDirectoryArg(lib.getEmittedDocs());
    tool_step.addArg("--output");
    const sources_tar = tool_step.addOutputFileArg("sources.tar");
    tool_step.step.dependOn(&lib.step);

    // install doc-gen output and the smaller sources.tar on top
    const install_docs = b.addInstallDirectory(.{
        .source_dir = lib.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "docs",
    });
    install_docs.step.dependOn(&tool_step.step);
    const overwrite_sources_tar = b.addInstallFile(sources_tar, "docs/sources.tar");
    overwrite_sources_tar.step.dependOn(&install_docs.step);

    const doc_step = b.step("docs", "Build documentation");
    doc_step.dependOn(&overwrite_sources_tar.step);
}

//=== EXAMPLES =========================================================================================================
const Example = struct {
    name: []const u8,
    has_shader: bool = false,
    needs_compute: bool = false,
};

const ExampleOptions = struct {
    target: Build.ResolvedTarget,
    optimize: OptimizeMode,
    backend: SokolBackend,
    mod_sokol: *Build.Module,
    emsdk: *Build.Dependency,
};

// build all examples
fn buildExamples(b: *Build, options: ExampleOptions) !*Build.Step {
    // a top level build step for all examples
    const examples_step = b.step("examples", "Build all examples");

    inline for (examples) |example| {
        try buildExample(b, example, examples_step, options);
    }

    if (isPlatform(options.target.result, .web)) {
        var buf: [256 * examples.len]u8 = undefined;
        var str_writer = std.Io.Writer.fixed(&buf);

        _ = try str_writer.print("<html><h1>Examples</h1><body><ul>", .{});
        inline for (examples) |example| {
            _ = try str_writer.print("<li><a href=\"{s}.html\">{s}</a></li>\n", .{example.name, example.name});
        }
        _ = try str_writer.print("</ul></body></html>", .{});

        const wf = b.addWriteFile("index.html", str_writer.buffered());
        const index = b.addInstallFile(wf.getDirectory().path(b, "index.html"), "web/index.html");
        examples_step.dependOn(&index.step);
    }
    return examples_step;
}

// build one of the examples
fn buildExample(b: *Build, example: Example, examples_step: *Build.Step, options: ExampleOptions) !void {
    const mod = b.createModule(.{
        .root_source_file = b.path(b.fmt("examples/{s}.zig", .{example.name})),
        .target = options.target,
        .optimize = options.optimize,
        .imports = &.{
            .{ .name = "sokol", .module = options.mod_sokol },
        },
    });

    // optionally build shader
    const opt_shd_step = try buildExampleShader(b, example);

    var run: *Build.Step.Run = undefined;
    if (!isPlatform(options.target.result, .web)) {
        // for native platforms, build into a regular executable
        const example_step = b.addExecutable(.{
            .name = example.name,
            .root_module = mod,
        });
        if (opt_shd_step) |shd_step| {
            example_step.step.dependOn(shd_step);
        }
        examples_step.dependOn(&b.addInstallArtifact(example_step, .{}).step);
        run = b.addRunArtifact(example_step);
    } else {
        // for WASM, need to build the Zig code as static library, since linking happens via emcc
        const example_step = b.addLibrary(.{
            .name = example.name,
            .root_module = mod,
        });
        if (opt_shd_step) |shd_step| {
            example_step.step.dependOn(shd_step);
        }

        // create a special emcc linker run step
        const backend = resolveSokolBackend(options.backend, options.target.result);
        const link_step = try emLinkStep(b, .{
            .lib_main = example_step,
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
        examples_step.dependOn(&link_step.step);

        // a special run step to run the build result via emrun
        run = emRunStep(b, .{ .name = example.name, .emsdk = options.emsdk });
        run.step.dependOn(&link_step.step);
    }
    b.step(b.fmt("run-{s}", .{example.name}), b.fmt("Run {s}", .{example.name})).dependOn(&run.step);
}

fn buildExampleShader(b: *Build, example: Example) !?*Build.Step {
    if (!example.has_shader) {
        return null;
    }
    const shaders_dir = "examples/shaders/";
    return shdc.createSourceFile(b, .{
        .shdc_dep = b.dependency("shdc", .{}),
        .input = b.fmt("{s}{s}.glsl", .{ shaders_dir, example.name }),
        .output = b.fmt("{s}{s}.glsl.zig", .{ shaders_dir, example.name }),
        .slang = .{
            .glsl430 = example.needs_compute,
            .glsl410 = !example.needs_compute,
            .glsl310es = example.needs_compute,
            .glsl300es = !example.needs_compute,
            .metal_macos = true,
            .hlsl5 = true,
            .wgsl = true,
            .spirv_vk = true,
        },
        .reflection = true,
    });
}
