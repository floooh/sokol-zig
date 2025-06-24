## CHANGELOG

> NOTE: this changelog is only for changes to the sokol-zig 'scaffolding', e.g. changes to build.zig,
to the example code or the supported Zig version. For actual Sokol header changes, see the
[sokol changelog](https://github.com/floooh/sokol/blob/master/CHANGELOG.md).

### 24-Jun-2025

Shader compilation via sokol-shdc is now more flexible. See the new readme section
`Shader compilation`, and this PR: https://github.com/floooh/sokol-tools-bin/pull/11

### 27-Apr-2025

The sokol C library can now be built as dynamic link library via `-Ddynamic_linkage`.
See PR https://github.com/floooh/sokol-zig/pull/116 for details. Many thanks to
@remzisenel for the PR!

### 29-Mar-2025

Added a new build option `dont_link_system_libs`. When this is provided, upstream
projects need to take care of linking the correct system libraries required
by the sokol headers themselves (see issue https://github.com/floooh/sokol-zig/issues/109 for details).

### 23-Mar-2025

Change the sokol-shdc dependency from lazy to static. Using a lazy dependency
turned out to be too much hassle to invoke the shader compiler from
upstream projects (those shouldn't import their own sokol-shdc dependency
because the sokol-shdc sub-dependency of the sokol-zig dependency will always
point to the matching sokol-shdc version). See the [pacman.zig/build.zig](https://github.com/floooh/pacman.zig/blob/main/build.zig)
for an example of how to run the shader compiler from an upstream project.

Also, when building the examples, the shaders will be automatically recompiled
when needed.

### 22-Mar-2025

The sokol-shdc shader compiler is now integrated as a (lazy) Zig package dependency,
and a build.zig.zon and build.zig (with helper code to invoke the shader compiler)
has been added to the [sokol-tools-bin repository](https://github.com/floooh/sokol-tools-bin).

Recompiling the example shaders is now done as part of the `examples` build step
like this:

```
zig build examples -Dshaders
```

The `-Dshaders` will trigger pulling the lazy sokol-shdc binaries dependency.

### 21-Mar-2025

Some build.zig and package structure cleanup:

- the examples are no longer part of the build.zig.zon package
- examples are no longer automatically built on `zig build`, instead
  use `zig build examples`
- ...a minor breaking change for the Emscripten linker step: this also
  no longer attaches itself automatically to the `install` step, e.g. just
  running `zig build` will not automatically run the Emscripten linker steps.
  Instead use the result of `emLinkStep()` to setup the standard install dependencies
  yourself like this:
  ```zig
    const link_step = try sokol.emLinkStep(b, .{ ... });
    b.getInstallStep().dependOn(&link_step.step);
  ```
  Also see the updated example build.zig code in the readme.
- build.zig: remove zig 0.13.x vs 0.14.x compatibility hacks

### 08-Dec-2024

The sokol_imgui.h compilation is now more configurable by allowing to override
the cimgui.h header path (default: `cimgui.h`) and the C API function prefix
(default: `ig`), see the [sokol-zig-imgui-sample/build.zig](https://github.com/floooh/sokol-zig-imgui-sample/blob/main/build.zig)
for an example.

> Narrator: this didn't quite work out because the idea was to remove the prefix
alltogether for the TranslateC-generated Zig bindings, but then some Dear ImGui
functions collide with Win32 OS functions (Set/GetCursorPos and SetWindowPos).

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
