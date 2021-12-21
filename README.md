Auto-generated Zig bindings for the [sokol headers](https://github.com/floooh/sokol).

For Zig version 0.9.0 (current 0.10.0 dev version should also work)

If you're on an older Zig version, check the following branches (note that these
also contain older versions of the Sokol C headers):

- zig-0.8.1
- zig-0.8.0
- zig-0.7.1
- ...(to be continued)

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
