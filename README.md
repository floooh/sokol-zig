Auto-generated Zig bindings for the [sokol headers](https://github.com/floooh/sokol).

Tested with zig 0.7.1

For the current zig HEAD version (0.8.0), switch to branch ```zig-0.8.0``` instead.

WIP, because not all sokol-headers have been added yet.

Related projects:

- [pacman.zig](https://github.com/floooh/pacman.zig)

## BUILD

On Linux install the following packages: libglu1-mesa-dev, mesa-common-dev, xorg-dev, libasound-dev

```sh
# on macOS only:
> export ZIG_SYSTEM_LINKER_HACK=1
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
> zig build run-debugtext
> zig build run-debugtext-print
> zig build run-debugtext-userfont
> zig build run-shapes
```

