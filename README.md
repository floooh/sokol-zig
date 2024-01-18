[![build](https://github.com/floooh/sokol-zig/actions/workflows/main.yml/badge.svg)](https://github.com/floooh/sokol-zig/actions/workflows/main.yml)

Auto-generated Zig bindings for the [sokol headers](https://github.com/floooh/sokol).

For Zig version 0.12.0-dev.

In case of breaking changes in Zig, the bindings might fall behind. Please don't hesitate to
ping me via a Github issue, or even better, provide a PR :)

Support for previous stable Zig versions is in branches (e.g. `zig-0.11.0`), those versions are 'frozen in time' though.

Related projects:

- [pacman.zig](https://github.com/floooh/pacman.zig)
- [kc85.zig](https://github.com/floooh/kc85.zig)

## Building the samples

Supported platforms are: Windows, macOS, Linux (with X11) and web

On Linux install the following packages: libglu1-mesa-dev, mesa-common-dev, xorg-dev, libasound-dev
(or generally: the dev packages required for X11, GL and ALSA development)

To build the platform-native samples:

```sh
# just build:
zig build
# build and run samples:
zig build run-clear
zig build run-triangle
zig build run-quad
zig build run-bufferoffsets
zig build run-cube
zig build run-noninterleaved
zig build run-texcube
zig build run-offscreen
zig build run-instancing
zig build run-mrt
zig build run-saudio
zig build run-sgl
zig build run-sgl-context
zig build run-sgl-points
zig build run-debugtext
zig build run-debugtext-print
zig build run-debugtext-userfont
zig build run-shapes
```

(also run ```zig build --help``` to inspect the build targets)

By default, the backend 3D API will be selected based on the target platform:

- macOS: Metal
- Windows: D3D11
- Linux: GL

To force the GL backend on macOS or Windows, build with ```-Dgl=true```:

```
> zig build -Dgl=true run-clear
```

The ```clear``` sample prints the selected backend to the terminal:

```
sokol-zig ➤ zig build -Dgl=true run-clear
Backend: .sokol.gfx.Backend.GLCORE33
```

For the web-samples, run:

```sh
zig build -Dtarget=wasm32-emscripten
# or to build and run one of the samples
zig build run-clear -Dtarget=wasm32-emscripten
...
```

When building with target `wasm32-emscripten` for the first time, the build script will
install and activate the Emscripten SDK into the Zig package cache for the latest SDK
version. There is currently no build system functionality to update or delete the Emscripten SDK
after this first install. The current workaround is to delete the global Zig cache
(run `zig env` to see where the Zig cache resides).

Improving the Emscripten SDK integration with the Zig build system is planned for the future.


## How to integrate sokol-zig into your project

Add a build.zig.zon file to your project which has at least a `.sokol` dependency:

```zig
.{
    .name = "my_project",
    .version = "0.1.0",
    .paths = .{
        "src"
        "build.zig",
        "build.zig.zon",
    },
    .dependencies = .{
        .sokol = .{
            .url = "git+https://github.com/floooh/sokol-zig.git#[commit-hash]",
            .hash = "[content-hash]",
        },
    },
}
```

For the `[commit-sha]` just pick the latest from here: https://github.com/floooh/sokol-zig/commits/master

To find out the `[content-hash]`, just omit the `.hash` line, and run `zig build`, this will then output
the expected hash on the terminal. Copy-paste this into the build.zig.zon file.

For a native-only project, a `build.zig` file looks entirely vanilla:

```zig
const std = @import("std");
const Build = std.Build;
const OptimizeMode = std.builtin.OptimizeMode;

pub fn build(b: *Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const dep_sokol = b.dependency("sokol", .{
        .target = target,
        .optimize = optimize,
    });
   const hello = b.addExecutable(.{
        .name = "hello",
        .target = target,
        .optimize = optimize,
        .root_source_file = .{ .path = "src/hello.zig" },
    });
    hello.root_module.addImport("sokol", dep_sokol.module("sokol"));
    b.installArtifact(hello);
    const run = b.addRunArtifact(hello);
    b.step("run", "Run hello").dependOn(&run.step);
}
```

If you also want to run on the web via `-Dtarget=wasm32-emscripten`, the web platform
build must look special, because Emscripten must be used for linking, and to run
the build result in a browser, a special run step must be created.

Such a 'hybrid' build script might look like this (copied straight from [pacman.zig](https://github.com/floooh/pacman.zig)):

```zig
const std = @import("std");
const Build = std.Build;
const OptimizeMode = std.builtin.OptimizeMode;
const sokol = @import("sokol");

pub fn build(b: *Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const dep_sokol = b.dependency("sokol", .{
        .target = target,
        .optimize = optimize,
    });

    // special case handling for native vs web build
    if (target.result.isWasm()) {
        try buildWeb(b, target, optimize, dep_sokol);
    } else {
        try buildNative(b, target, optimize, dep_sokol);
    }
}

// this is the regular build for all native platforms, nothing surprising here
fn buildNative(b: *Build, target: Build.ResolvedTarget, optimize: OptimizeMode, dep_sokol: *Build.Dependency) !void {
    const pacman = b.addExecutable(.{
        .name = "pacman",
        .target = target,
        .optimize = optimize,
        .root_source_file = .{ .path = "src/pacman.zig" },
    });
    pacman.root_module.addImport("sokol", dep_sokol.module("sokol"));
    b.installArtifact(pacman);
    const run = b.addRunArtifact(pacman);
    b.step("run", "Run pacman").dependOn(&run.step);
}

// for web builds, the Zig code needs to be built into a library and linked with the Emscripten linker
fn buildWeb(b: *Build, target: Build.ResolvedTarget, optimize: OptimizeMode, dep_sokol: *Build.Dependency) !void {
    const pacman = b.addStaticLibrary(.{
        .name = "pacman",
        .target = target,
        .optimize = optimize,
        .root_source_file = .{ .path = "src/pacman.zig" },
    });
    pacman.root_module.addImport("sokol", dep_sokol.module("sokol"));

    // create a build step which invokes the Emscripten linker
    const emsdk = dep_sokol.builder.dependency("emsdk", .{});
    const link_step = try sokol.emLinkStep(b, .{
        .lib_main = pacman,
        .target = target,
        .optimize = optimize,
        .emsdk = emsdk,
        .use_webgl2 = true,
        .use_emmalloc = true,
        .use_filesystem = false,
        .shell_file_path = dep_sokol.path("src/sokol/web/shell.html").getPath(b),
    });
    // ...and a special run step to start the web build output via 'emrun'
    const run = sokol.emRunStep(b, .{ .name = "pacman", .emsdk = emsdk });
    run.step.dependOn(&link_step.step);
    b.step("run", "Run pacman").dependOn(&run.step);
}
```

## wasm32-emscripten caveats

This list might grow longer over time!

- Zig allocators use the `@returnAddress` builtin, which isn't supported in the Emscripten
  runtime out of the box (you'll get a runtime error in the browser's Javascript console
  looking like this: `Cannot use convertFrameToPC (needed by __builtin_return_address) without -sUSE_OFFSET_CONVERTER`.
  To make it work, do as the error message says, to add the `-sUSE_OFFSET_CONVERTER` arg to the
  Emscripten linker step in your `build.zig` file:

  ```zig
      const link_step = try sokol.emLinkStep(b, .{
        // ...other settings here
        .extra_args = &.{"-sUSE_OFFSET_CONVERTER=1"},
    });
  ```

  Also see the [kc85.zig build.zig](https://github.com/floooh/kc85.zig/blob/main/build.zig) as example!

- the Zig stdlib only has limited support for the `wasm32-emscripten`
  target, for instance using `std.fs` functions will most likely fail
  to compile (the sokol-zig bindings might add more sokol headers
  in the future to fill some of the gaps)
