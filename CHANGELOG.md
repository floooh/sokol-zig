## CHANGELOG

> NOTE: this changelog is only for changes to the sokol-zig 'scaffolding', e.g. changes to build.zig,
to the example code or the supported Zig version. For actual Sokol header changes, see the
[sokol changelog](https://github.com/floooh/sokol/blob/master/CHANGELOG.md).

### 08-Dec-2024

The sokol_imgui.h compilation is now more configurable by allowing to override
the cimgui.h header path (default: `cimgui.h`) and the C API function prefix
(default: `ig`), see the [sokol-zig-imgui-sample/build.zig](https://github.com/floooh/sokol-zig-imgui-sample/blob/main/build.zig)
for an example.

### 07-Dec-2024

Some build.zig.zon cleanup:

- change name from `sokol-zig` to `sokol`
- remove readme and changelog from `.paths`
- update emsdk dependency to emsdk 3.1.73

### 31-Aug-2024

Fix for a [breaking naming convention change](https://github.com/ziglang/zig/commit/0fe3fd01ddc2cd49c6a2b939577d16b9d2c65ea9)
in Zig's `builtin.Type`. Since only a small code area in the bindings is affected (the `asRange` helper
function) I decided to implement a fix that works both for zig 0.13.0 and the current
HEAD version.

E.g. if you're on Zig 0.13.0, you can safely update and if you are on the Zig HEAD
version you definitely need to update.

More details in PR: https://github.com/floooh/sokol/pull/1100

### 23-Aug-2024

Important change for WASM/web builds: Merged PR #77, this changes the
Emscripten link step option `.shell_file_path` from an absolute path string to
a Zig build system `LazyPath`. This requires a small change in build.zig
when creating the Emscripten link step via `emLinkStep()`. See the
updated code example in the readme for details (just remove a `.getPath(b)`).

### 03-Jun-2024

- the Emscripten SDK dependency has been updated to 3.1.61
- the Emscripten specific parts of build.zig have been updated to be more
  'idiomatic' now. This also has the nice side effect that the dirty check for
  the Emscripten linker step now works as expected (e.g. the step will do
  nothing if the output is uptodate)

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
