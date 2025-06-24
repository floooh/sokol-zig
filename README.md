[![build](https://github.com/floooh/sokol-zig/actions/workflows/main.yml/badge.svg)](https://github.com/floooh/sokol-zig/actions/workflows/main.yml)[![Docs](https://github.com/floooh/sokol-zig/actions/workflows/docs.yml/badge.svg)](https://github.com/floooh/sokol-zig/actions/workflows/docs.yml)

Auto-generated Zig bindings for the [sokol headers](https://github.com/floooh/sokol).

[Auto-generated docs](https://floooh.github.io/sokol-zig-docs) (wip)

For Zig version 0.14.0+

In case of breaking changes in Zig, the bindings might fall behind. Please don't hesitate to
ping me via a Github issue, or even better, provide a PR :)

Support for stable Zig versions is in branches (e.g. `zig-0.12.0`), those versions are 'frozen in time' though.

Related projects:

- [pacman.zig](https://github.com/floooh/pacman.zig)
- [chipz emulators](https://github.com/floooh/chipz)
- [Dear ImGui sample project](https://github.com/floooh/sokol-zig-imgui-sample)

## Building the samples

Supported platforms are: Windows, macOS, Linux (with X11) and web

On Linux install the following packages: libglu1-mesa-dev, mesa-common-dev, xorg-dev, libasound-dev
(or generally: the dev packages required for X11, GL and ALSA development)

To build the platform-native samples:

```sh
# build all examples:
zig build examples
# build and run individual examples
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

(also run ```zig build -l``` to get a list of build targets)

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
zig build examples -Dtarget=wasm32-emscripten
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
        "src",
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

The easiest way to populate or update the `sokol` dependency is to run this on the cmdline:

```
zig fetch --save=sokol git+https://github.com/floooh/sokol-zig.git
```

This will automatically use the latest sokol-zig commit.

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
        .root_source_file = b.path("src/hello.zig"),
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
    if (target.result.cpu.arch.isWasm()) {
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
        .root_source_file = b.path("src/pacman.zig"),
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
        .root_source_file = b.path("src/pacman.zig"),
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
        .shell_file_path = dep_sokol.path("src/sokol/web/shell.html"),
    });
    // attach Emscripten linker output to default install step
    b.getInstallStep().dependOn(&link_step.step);
    // ...and a special run step to start the web build output via 'emrun'
    const run = sokol.emRunStep(b, .{ .name = "pacman", .emsdk = emsdk });
    run.step.dependOn(&link_step.step);
    b.step("run", "Run pacman").dependOn(&run.step);
}
```

## Shader compilation

sokol-zig comes with builtin `sokol-shdc` support and offers two ways to
integrate shader compilation into the build process:

1. Compile the shader source file into a Zig source file within the
   project's source directory, which is then directly imported.
2. Compile the shader source file into a Zig module, with the module
   source file existing only in the Zig cache.

For both cases, you need to import the sokol dependency in your
project's build.zig:

```zig
const sokol = @import("sokol");
```

...you'll also need the sokol and shdc dependencies:

```zig
    const dep_sokol = b.dependency("sokol", .{
        .target = target,
        .optimize = optimize,
    });
    const dep_shdc = dep_sokol.builder.dependency("shdc", .{});
```

### Option 1: compile shader source into a Zig source file

```zig
    // call shdc.createSourceFile() helper function, this returns a `!*Build.Step`:
    const shdc_step = try sokol.shdc.createSourceFile(b, .{
        .shdc_dep = dep_shdc,
        .input = "src/shader.glsl",
        .output = "src/shader.zig",
        .slang = .{ .hlsl5 = true, ... },
    });

    // add the shader compilation step as dependency to the build step
    // which requires the generated Zig source file
    exe_step.step.dependOn(shdc_step);
```

...and then import the shader as Zig source file in your application code:

```zig
const shd = @import("shader.zig");
```

### Option 2: compile shader source into a Zig module

```zig
    // call shdc.createModule() helper function, this returns a `!*Build.Module`:
    const shd_mod = try sokol.shdc.createModule(b, "shader", dep_sokol, .{
        .shdc_dep = dep_shdc,
        .input = "src/shader.glsl",
        .output = "shader.zig",
        .slang = .{ .hlsl5 = true, ... },
    });

    // add the module as import to the module which imports the shader:
    const main_mod = b.createModule(.{
        .root_source_file = "src/main.zig",
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "sokol", .module = dep_sokol.module("sokol") },
            .{ .name = "shader", .module = shd_mod },
        }
    });
```

Then in your `main.zig`, import the shader module:

```zig
const shd = @import("shader");
```

## Using sokol headers in C code

The sokol-zig build.zig exposes a C library artifact called `sokol_clib`.

You can lookup the build step for this library via:

```zig
    const dep_sokol = b.dependency("sokol", .{
        .target = target,
        .optimize = optimize,
    });
    const sokol_clib = dep_sokol.artifact("sokol_clib");
```

...once you have that library artifact, 'link' it to your compile step which contains
your own C code:

```zig
    const my_clib = ...;
    my_clib.linkLibrary(sokol_clib);
```

This makes the Sokol C headers available to your C code in a `sokol/` subdirectory:

```c
#include "sokol/sokol_app.h"
#include "sokol/sokol_gfx.h"
// etc...
```

Keep in mind that the implementation is already provided in the `sokol_clib`
static link library (e.g. don't try to build the Sokol implementations yourself
via the `SOKOL_IMPL` macro).


## wasm32-emscripten caveats

- Zig allocators use the `@returnAddress` builtin, which isn't supported in the Emscripten
  runtime out of the box (you'll get a runtime error in the browser's Javascript console
  looking like this: `Cannot use convertFrameToPC (needed by __builtin_return_address) without -sUSE_OFFSET_CONVERTER`.
  To link with `-sUSE_OFFSET_CONVERTER`, simply set the `.use_offset_converter` option
  in the Emscripten linker step in your build.zig:

  ```zig
      const link_step = try sokol.emLinkStep(b, .{
        // ...other settings here
        .use_offset_converter = true,
    });
  ```

- the Zig stdlib only has limited support for the `wasm32-emscripten`
  target, for instance using `std.fs` functions will most likely fail
  to compile (the sokol-zig bindings might add more sokol headers
  in the future to fill some of the gaps)

## Dear ImGui support

The sokol-zig bindings come with sokol_imgui.h (exposed as the Zig package
`sokol.imgui`), but integration into a project's build.zig requires some extra
steps, mainly because I didn't want to add a
[cimgui](https://github.com/cimgui/cimgui) dependency to the sokol-zig package
(especially since cimgui uses git submodule which are not supported by the Zig
package manager).

The main steps to create Dear ImGui apps with sokol-zig are:

1. 'bring your own cimgui'
2. tell the sokol dependency that it needs to include sokol_imgui.h into
  the compiled C library:
    ```zig
    const dep_sokol = b.dependency("sokol", .{
        .target = target,
        .optimize = optimize,
        .with_sokol_imgui = true,
    });
    ```
3. inject the path to the cimgui directory into the sokol dependency so
  that C compilation works (this needs to find the `cimgui.h` header)

    ```zig
    dep_sokol.artifact("sokol_clib").addIncludePath(cimgui_root);
    ```

Also see the following example project:

https://github.com/floooh/sokol-zig-imgui-sample/
