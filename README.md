!!! WIP WIP WIP !!!

Experimental auto-generated Zig bindings for the [sokol headers](https://github.com/floooh/sokol).

## BUILD

Use the zig 0.6.0 HEAD version (needs to support ```anytype```)

Currently hardwired to Windows and the sokol-gfx D3D11 backend.

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
```

