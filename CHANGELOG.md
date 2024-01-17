## CHANGELOG

> NOTE: this changelog is only for changes to the sokol-zig 'scaffolding', e.g. changes to build.zig,
to the example code or the supported Zig version. For actual Sokol header changes, see the
[sokol changelog](https://github.com/floooh/sokol/blob/master/CHANGELOG.md).

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
