// machine generated, do not edit

//
// sokol_args.h    -- cross-platform key/value arg-parsing for web and native
//
// Project URL: https://github.com/floooh/sokol
//
// Do this:
//     #define SOKOL_IMPL or
//     #define SOKOL_ARGS_IMPL
// before you include this file in *one* C or C++ file to create the
// implementation.
//
// Optionally provide the following defines with your own implementations:
//
// SOKOL_ASSERT(c)     - your own assert macro (default: assert(c))
// SOKOL_ARGS_API_DECL - public function declaration prefix (default: extern)
// SOKOL_API_DECL      - same as SOKOL_ARGS_API_DECL
// SOKOL_API_IMPL      - public function implementation prefix (default: -)
//
// If sokol_args.h is compiled as a DLL, define the following before
// including the declaration or implementation:
//
// SOKOL_DLL
//
// On Windows, SOKOL_DLL will define SOKOL_ARGS_API_DECL as __declspec(dllexport)
// or __declspec(dllimport) as needed.
//
// OVERVIEW
// ========
// sokol_args.h provides a simple unified argument parsing API for WebAssembly and
// native apps.
//
// When running as a WebAssembly app, arguments are taken from the page URL:
//
//     https://floooh.github.io/tiny8bit/kc85.html?type=kc85_3&mod=m022&snapshot=kc85/jungle.kcc
//
// The same arguments provided to a command line app:
//
//     kc85 type=kc85_3 mod=m022 snapshot=kc85/jungle.kcc
//
// You can also use standalone keys without value:
//
//     https://floooh.github.io/tiny8bit/kc85.html?bla&blub
//
// On the command line:
//
//     kc85 bla blub
//
// Such value-less keys are reported as the value being an empty string, but they
// can be tested with `sapp_exists("bla")` or `sapp_boolean("blub")`.
//
// ARGUMENT FORMATTING
// ===================
// On the web platform, arguments must be formatted as a valid URL query string
// with 'percent encoding' used for special characters.
//
// Strings are expected to be UTF-8 encoded (although sokol_args.h doesn't
// contain any special UTF-8 handling). See below on how to obtain
// UTF-8 encoded argc/argv values on Windows when using WinMain() as
// entry point.
//
// On native platforms the following rules must be followed:
//
// Arguments have the general form
//
//     key=value
//
// or
//
//     key
//
// When a key has no value, the value will be assigned an empty string.
//
// Key/value pairs are separated by 'whitespace', valid whitespace
// characters are space and tab.
//
// Whitespace characters in front and after the separating '=' character
// are ignored:
//
//     key = value
//
// ...is the same as
//
//     key=value
//
// The 'key' string must be a simple string without escape sequences or whitespace.
//
// The 'value' string can be quoted, and quoted value strings can contain
// whitespace:
//
//     key = 'single-quoted value'
//     key = "double-quoted value"
//
// Single-quoted value strings can contain double quotes, and vice-versa:
//
//     key = 'single-quoted value "can contain double-quotes"'
//     key = "double-quoted value 'can contain single-quotes'"
//
// Note that correct quoting can be tricky on some shells, since command
// shells may remove quotes, unless they're escaped.
//
// Value strings can contain a small selection of escape sequences:
//
//     \n  - newline
//     \r  - carriage return
//     \t  - tab
//     \\  - escaped backslash
//
// (more escape codes may be added in the future).
//
// CODE EXAMPLE
// ============
//
//     int main(int argc, char* argv[]) {
//         // initialize sokol_args with default parameters
//         sargs_setup(&(sargs_desc){
//             .argc = argc,
//             .argv = argv
//         });
//
//         // check if a key exists...
//         if (sargs_exists("bla")) {
//             ...
//         }
//
//         // get value string for key, if not found, return empty string ""
//         const char* val0 = sargs_value("bla");
//
//         // get value string for key, or default string if key not found
//         const char* val1 = sargs_value_def("bla", "default_value");
//
//         // check if a key matches expected value
//         if (sargs_equals("type", "kc85_4")) {
//             ...
//         }
//
//         // check if a key's value is "true", "yes" or "on" or if this is a standalone key
//         if (sargs_boolean("joystick_enabled")) {
//             ...
//         }
//
//         // iterate over keys and values
//         for (int i = 0; i < sargs_num_args(); i++) {
//             printf("key: %s, value: %s\n", sargs_key_at(i), sargs_value_at(i));
//         }
//
//         // lookup argument index by key string, will return -1 if key
//         // is not found, sargs_key_at() and sargs_value_at() will return
//         // an empty string for invalid indices
//         int index = sargs_find("bla");
//         printf("key: %s, value: %s\n", sargs_key_at(index), sargs_value_at(index));
//
//         // shutdown sokol-args
//         sargs_shutdown();
//     }
//
// WINMAIN AND ARGC / ARGV
// =======================
// On Windows with WinMain() based apps, getting UTF8-encoded command line
// arguments is a bit more complicated:
//
// First call GetCommandLineW(), this returns the entire command line
// as UTF-16 string. Then call CommandLineToArgvW(), this parses the
// command line string into the usual argc/argv format (but in UTF-16).
// Finally convert the UTF-16 strings in argv[] into UTF-8 via
// WideCharToMultiByte().
//
// See the function _sapp_win32_command_line_to_utf8_argv() in sokol_app.h
// for example code how to do this (if you're using sokol_app.h, it will
// already convert the command line arguments to UTF-8 for you of course,
// so you can plug them directly into sokol_app.h).
//
// API DOCUMENTATION
// =================
// void sargs_setup(const sargs_desc* desc)
//     Initialize sokol_args, desc contains the following configuration
//     parameters:
//         int argc        - the main function's argc parameter
//         char** argv     - the main function's argv parameter
//         int max_args    - max number of key/value pairs, default is 16
//         int buf_size    - size of the internal string buffer, default is 16384
//
//     Note that on the web, argc and argv will be ignored and the arguments
//     will be taken from the page URL instead.
//
//     sargs_setup() will allocate 2 memory chunks: one for keeping track
//     of the key/value args of size 'max_args*8', and a string buffer
//     of size 'buf_size'.
//
// void sargs_shutdown(void)
//     Shutdown sokol-args and free any allocated memory.
//
// bool sargs_isvalid(void)
//     Return true between sargs_setup() and sargs_shutdown()
//
// bool sargs_exists(const char* key)
//     Test if an argument exists by its key name.
//
// const char* sargs_value(const char* key)
//     Return value associated with key. Returns an empty string ("") if the
//     key doesn't exist, or if the key doesn't have a value.
//
// const char* sargs_value_def(const char* key, const char* default)
//     Return value associated with key, or the provided default value if the
//     key doesn't exist, or this is a value-less key.
//
// bool sargs_equals(const char* key, const char* val);
//     Return true if the value associated with key matches
//     the 'val' argument.
//
// bool sargs_boolean(const char* key)
//     Return true if the value string of 'key' is one of 'true', 'yes', 'on',
//     or this is a key without value.
//
// int sargs_find(const char* key)
//     Find argument by key name and return its index, or -1 if not found.
//
// int sargs_num_args(void)
//     Return number of key/value pairs.
//
// const char* sargs_key_at(int index)
//     Return the key name of argument at index. Returns empty string if
//     is index is outside range.
//
// const char* sargs_value_at(int index)
//     Return the value of argument at index. Returns empty string
//     if the key at index has no value, or the index is out-of-range.
//
//
// MEMORY ALLOCATION OVERRIDE
// ==========================
// You can override the memory allocation functions at initialization time
// like this:
//
//     void* my_alloc(size_t size, void* user_data) {
//         return malloc(size);
//     }
//
//     void my_free(void* ptr, void* user_data) {
//         free(ptr);
//     }
//
//     ...
//         sargs_setup(&(sargs_desc){
//             // ...
//             .allocator = {
//                 .alloc_fn = my_alloc,
//                 .free_fn = my_free,
//                 .user_data = ...,
//             }
//         });
//     ...
//
// If no overrides are provided, malloc and free will be used.
//
// This only affects memory allocation calls done by sokol_args.h
// itself though, not any allocations in OS libraries.
//
// TODO
// ====
// - parsing errors?
//
// LICENSE
// =======
//
// zlib/libpng license
//
// Copyright (c) 2018 Andre Weissflog
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
/// sargs_allocator
///
/// Used in sargs_desc to provide custom memory-alloc and -free functions
/// to sokol_args.h. If memory management should be overridden, both the
/// alloc_fn and free_fn function must be provided (e.g. it's not valid to
/// override one function but not the other).
pub const Allocator = extern struct {
    alloc_fn: ?*const fn (usize, ?*anyopaque) callconv(.c) ?*anyopaque = null,
    free_fn: ?*const fn (?*anyopaque, ?*anyopaque) callconv(.c) void = null,
    user_data: ?*anyopaque = null,
};

pub const Desc = extern struct {
    argc: i32 = 0,
    argv: [*c][*c]u8 = null,
    max_args: i32 = 0,
    buf_size: i32 = 0,
    allocator: Allocator = .{},
};

/// setup sokol-args
extern fn sargs_setup([*c]const Desc) void;

/// setup sokol-args
pub fn setup(desc: Desc) void {
    sargs_setup(&desc);
}

/// shutdown sokol-args
extern fn sargs_shutdown() void;

/// shutdown sokol-args
pub fn shutdown() void {
    sargs_shutdown();
}

/// true between sargs_setup() and sargs_shutdown()
extern fn sargs_isvalid() bool;

/// true between sargs_setup() and sargs_shutdown()
pub fn isvalid() bool {
    return sargs_isvalid();
}

/// test if an argument exists by key name
extern fn sargs_exists([*c]const u8) bool;

/// test if an argument exists by key name
pub fn exists(key: [:0]const u8) bool {
    return sargs_exists(@ptrCast(key));
}

/// get value by key name, return empty string if key doesn't exist or an existing key has no value
extern fn sargs_value([*c]const u8) [*c]const u8;

/// get value by key name, return empty string if key doesn't exist or an existing key has no value
pub fn value(key: [:0]const u8) [:0]const u8 {
    return cStrToZig(sargs_value(@ptrCast(key)));
}

/// get value by key name, return provided default if key doesn't exist or has no value
extern fn sargs_value_def([*c]const u8, [*c]const u8) [*c]const u8;

/// get value by key name, return provided default if key doesn't exist or has no value
pub fn valueDef(key: [:0]const u8, def: [:0]const u8) [:0]const u8 {
    return cStrToZig(sargs_value_def(@ptrCast(key), @ptrCast(def)));
}

/// return true if val arg matches the value associated with key
extern fn sargs_equals([*c]const u8, [*c]const u8) bool;

/// return true if val arg matches the value associated with key
pub fn equals(key: [:0]const u8, val: [:0]const u8) bool {
    return sargs_equals(@ptrCast(key), @ptrCast(val));
}

/// return true if key's value is "true", "yes", "on" or an existing key has no value
extern fn sargs_boolean([*c]const u8) bool;

/// return true if key's value is "true", "yes", "on" or an existing key has no value
pub fn boolean(key: [:0]const u8) bool {
    return sargs_boolean(@ptrCast(key));
}

/// get index of arg by key name, return -1 if not exists
extern fn sargs_find([*c]const u8) i32;

/// get index of arg by key name, return -1 if not exists
pub fn find(key: [:0]const u8) i32 {
    return sargs_find(@ptrCast(key));
}

/// get number of parsed arguments
extern fn sargs_num_args() i32;

/// get number of parsed arguments
pub fn numArgs() i32 {
    return sargs_num_args();
}

/// get key name of argument at index, or empty string
extern fn sargs_key_at(i32) [*c]const u8;

/// get key name of argument at index, or empty string
pub fn keyAt(index: i32) [:0]const u8 {
    return cStrToZig(sargs_key_at(index));
}

/// get value string of argument at index, or empty string
extern fn sargs_value_at(i32) [*c]const u8;

/// get value string of argument at index, or empty string
pub fn valueAt(index: i32) [:0]const u8 {
    return cStrToZig(sargs_value_at(index));
}

