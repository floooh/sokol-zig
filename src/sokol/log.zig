// machine generated, do not edit

//
// sokol_log.h -- common logging callback for sokol headers
//
// Project URL: https://github.com/floooh/sokol
//
// Example code: https://github.com/floooh/sokol-samples
//
// Do this:
//     #define SOKOL_IMPL or
//     #define SOKOL_LOG_IMPL
// before you include this file in *one* C or C++ file to create the
// implementation.
//
// Optionally provide the following defines when building the implementation:
//
// SOKOL_ASSERT(c)             - your own assert macro (default: assert(c))
// SOKOL_UNREACHABLE()         - a guard macro for unreachable code (default: assert(false))
// SOKOL_LOG_API_DECL          - public function declaration prefix (default: extern)
// SOKOL_API_DECL              - same as SOKOL_GFX_API_DECL
// SOKOL_API_IMPL              - public function implementation prefix (default: -)
//
// Optionally define the following for verbose output:
//
// SOKOL_DEBUG         - by default this is defined if _DEBUG is defined
//
//
// OVERVIEW
// ========
// sokol_log.h provides a default logging callback for other sokol headers.
//
// To use the default log callback, just include sokol_log.h and provide
// a function pointer to the 'slog_func' function when setting up the
// sokol library:
//
// For instance with sokol_audio.h:
//
//     #include "sokol_log.h"
//     ...
//     saudio_setup(&(saudio_desc){ .logger.func = slog_func });
//
// Logging output goes to stderr and/or a platform specific logging subsystem
// (which means that in some scenarios you might see logging messages duplicated):
//
//     - Windows: stderr + OutputDebugStringA()
//     - macOS/iOS/Linux: stderr + syslog()
//     - Emscripten: console.info()/warn()/error()
//     - Android: __android_log_write()
//
// On Windows with sokol_app.h also note the runtime config items to make
// stdout/stderr output visible on the console for WinMain() applications
// via sapp_desc.win32_console_attach or sapp_desc.win32_console_create,
// however when running in a debugger on Windows, the logging output should
// show up on the debug output UI panel.
//
// In debug mode, a log message might look like this:
//
//     [sspine][error][id:12] /Users/floh/projects/sokol/util/sokol_spine.h:3472:0:
//         SKELETON_DESC_NO_ATLAS: no atlas object provided in sspine_skeleton_desc.atlas
//
// The source path and line number is formatted like compiler errors, in some IDEs (like VSCode)
// such error messages are clickable.
//
// In release mode, logging is less verbose as to not bloat the executable with string data, but you still get
// enough information to identify the type and location of an error:
//
//     [sspine][error][id:12][line:3472]
//
// RULES FOR WRITING YOUR OWN LOGGING FUNCTION
// ===========================================
// - must be re-entrant because it might be called from different threads
// - must treat **all** provided string pointers as optional (can be null)
// - don't store the string pointers, copy the string data instead
// - must not return for log level panic
//
// LICENSE
// =======
// zlib/libpng license
//
// Copyright (c) 2023 Andre Weissflog
//
// This software is provided 'as-is', without any express or implied warranty.
// In no event will the authors be held liable for any damages arising from the
// use of this software.
//
// Permission is granted to anyone to use this software for any purpose,
// including commercial applications, and to alter it and redistribute it
// freely, subject to the following restrictions:
//
//     1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software in a
//     product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//
//     2. Altered source versions must be plainly marked as such, and must not
//     be misrepresented as being the original software.
//
//     3. This notice may not be removed or altered from any source
//     distribution.

const builtin = @import("builtin");

// helper function to convert a C string to a Zig string slice
fn cStrToZig(c_str: [*c]const u8) [:0]const u8 {
    return @import("std").mem.span(c_str);
}
/// Plug this function into the 'logger.func' struct item when initializing any of the sokol
/// headers. For instance for sokol_audio.h it would look like this:
///
/// saudio_setup(&(saudio_desc){
///     .logger = {
///         .func = slog_func
///     }
/// });
pub extern fn slog_func([*c]const u8, u32, u32, [*c]const u8, u32, [*c]const u8, ?*anyopaque) void;

/// Plug this function into the 'logger.func' struct item when initializing any of the sokol
/// headers. For instance for sokol_audio.h it would look like this:
///
/// saudio_setup(&(saudio_desc){
///     .logger = {
///         .func = slog_func
///     }
/// });
pub const func = slog_func;
