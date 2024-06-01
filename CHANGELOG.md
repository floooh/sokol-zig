## CHANGELOG

> NOTE: this changelog is only for changes to the sokol-zig 'scaffolding', e.g. changes to build.zig,
to the example code or the supported Zig version. For actual Sokol header changes, see the
[sokol changelog](https://github.com/floooh/sokol/blob/master/CHANGELOG.md).

### 01-Jun-2024

- added bindings for sokol_imgui.h (please read the section `## Dear ImGui support`
  in the readme, and also check out this [example project](https://github.com/floooh/sokol-zig-imgui-sample))
- the sokol C library name has been renamed from `sokol` to `sokol_clib`, and
  is now exposed to the outside world via `installArtifact()` (this allows a user of
  the sokol dependency to lookup the CompileStep for the sokol C library via
  `dep_sokol.artifact("sokol_clib"))` which is important to inject a cimgui
  header search path (e.g. via `dep_sokol.artifact("sokol_clib").addIncludePath(cimgui_root);`)

### 20-Apr-2024

- update the emsdk dependency to 3.1.57
- some minor build.zig code cleanup
- test with Zig 0.12.0 release

### 29-Feb-2024

**BREAKING CHANGES**

- The examples have been updated for the 'render pass cleanup' in sokol-gfx, please
  see the [sokol changelog](https://github.com/floooh/sokol/blob/master/CHANGELOG.md)
  for details!

### 17-Jan-2024

- Switched the master branch to support the Zig nightly versions, this is different from before
  where the master branch worked against the last stable Zig version. Previous stable Zig versions
  will be supported in 'archival branches' which remain frozen in time.
- Fixed the build.zig for the latest API changes in zig-0.12.0 and also did a general code cleanup.
- Switched over to use sokol-zig exclusively as package via the Zig package manager. The old
  way of integrating the bindings as git submodule is no longer supported.
- Integrate with the Emscripten SDK which enables straightforward support for building
  Zig WebGL/WebGPU applications that run in web browsers (see README for details).
  The way the Emscripten SDK is integrated isn't the 'final form' form though. Eventually
  I want to move the Emscripten stuff into a separate `emsdk-zig` package, and rewrite the
  linker integration to be more 'Zig build system idiomatic'.

Most of the work was done by @kassane, many thanks!

Relevant PRs: https://github.com/floooh/sokol-zig/pull/50, https://github.com/floooh/sokol-zig/pull/51.
