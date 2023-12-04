[![build](https://github.com/floooh/sokol-zig/actions/workflows/main.yml/badge.svg)](https://github.com/floooh/sokol-zig/actions/workflows/main.yml)

Auto-generated Zig bindings for the [sokol headers](https://github.com/floooh/sokol).

For Zig version 0.11.0

Related projects:

- [pacman.zig](https://github.com/floooh/pacman.zig)
- [kc85.zig](https://github.com/floooh/kc85.zig)

> NOTE: for experimental package manager support see the branch [package](https://github.com/floooh/sokol-zig/tree/package),
> and as example for how to integrate sokol-zig as package the [pacman.zig branch sokol-package](https://github.com/floooh/pacman.zig/tree/sokol-package)

## BUILD

Supported platforms are: Windows, macOS, Linux (with X11)

On Linux install the following packages: libglu1-mesa-dev, mesa-common-dev, xorg-dev, libasound-dev
(or generally: the dev packages required for X11, GL and ALSA development)

```sh
# just build:
> zig build
# build and run samples:
> zig build run-clear
> zig build run-triangle
> zig build run-quad
> zig build run-bufferoffsets
> zig build run-cube
> zig build run-noninterleaved
> zig build run-texcube
> zig build run-offscreen
> zig build run-instancing
> zig build run-mrt
> zig build run-saudio
> zig build run-sgl
> zig build run-sgl-context
> zig build run-sgl-points
> zig build run-debugtext
> zig build run-debugtext-print
> zig build run-debugtext-userfont
> zig build run-shapes
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

## Use with the Zig package manager

Add a build.zig.zon file to your project:

```zig
.{
    .name = "xxx",
    .version = "0.1.0",
    .dependencies = .{
        .sokol = .{
            .url = "https://github.com/floooh/sokol-zig/archive/[commit-sha].tar.gz",
            .hash = "[content-hash]",
        },
    },
}
```

For the `[commit-sha]` just pick the latest from here: https://github.com/floooh/sokol-zig/commits/master

To find out the `[content-hash]`, just omit the `.hash` line, and run `zig build`, this will then output
the expected hash on the terminal. Copy-paste this into the build.zig.zon file.

Next in your build.zig file, get a Dependency object like this:

```zig
    const dep_sokol = b.dependency("sokol", .{
        .target = target,
        .optimize = optimize,
        // optionally more options like `.gl: true`
    });
```

This dependency contains one module and one static-library artifact which can be added
to your executable CompileStep like this:

```zig
    const exe = b.addExecutable(.{
        .name = "pacman",
        .target = target,
        .optimize = optimize,
        .root_source_file = .{ .path = "src/pacman.zig" },
    });
    exe.addModule("sokol", dep_sokol.module("sokol"));
    exe.linkLibrary(dep_sokol.artifact("sokol"));
    b.installArtifact(exe);
```
