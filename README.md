!!! WIP WIP WIP !!!

Experimental auto-generated Zig bindings for the [sokol headers](https://github.com/floooh/sokol).

## BUILD

Use the zig 0.6.0 HEAD version (the 0.6.0 release is too old)

Currently Windows and Linux is supported (not yet macOS).

On Linux install the following packages: libglu1-mesa-dev, mesa-common-dev, xorg-dev, libasound-dev

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
```

