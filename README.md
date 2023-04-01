[![build](https://github.com/floooh/sokol-zig/actions/workflows/main.yml/badge.svg)](https://github.com/floooh/sokol-zig/actions/workflows/main.yml)

Auto-generated Zig bindings for the [sokol headers](https://github.com/floooh/sokol).

For Zig version 0.10.0

If you're on the current dev version, check the branch:

- zig-0.11.0

If you're on an older Zig version, check the following branches (note that these
also contain older versions of the Sokol C headers):

- zig-0.9.1
- zig-0.8.1
- zig-0.8.0
- zig-0.7.1

Related projects:

- [pacman.zig](https://github.com/floooh/pacman.zig)
- [kc85.zig](https://github.com/floooh/kc85.zig)

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

## Use as Library

Clone this repo into your project via ``git submodule add https://github.com/floooh/sokol-zig.git`` (for this example into a folder called ``lib`` within your project).

Add to your ``build.zig``:
```zig
const sokol = @import("lib/sokol-zig/build.zig");

// ...
// pub fn build(b: *std.build.Builder) void {
// ...

const sokol_build = sokol.buildSokol(b, target, mode, .{}, "lib/sokol-zig/");

// ...
// const exe = b.addExecutable("demo", "src/main.zig");
// ...

exe.addPackagePath("sokol", "lib/sokol-zig/src/sokol/sokol.zig");
exe.linkLibrary(sokol_build);
```
