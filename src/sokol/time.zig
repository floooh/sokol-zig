// machine generated, do not edit

//
// sokol_time.h    -- simple cross-platform time measurement
//
// Project URL: https://github.com/floooh/sokol
//
// Do this:
//     #define SOKOL_IMPL or
//     #define SOKOL_TIME_IMPL
// before you include this file in *one* C or C++ file to create the
// implementation.
//
// Optionally provide the following defines with your own implementations:
// SOKOL_ASSERT(c)     - your own assert macro (default: assert(c))
// SOKOL_TIME_API_DECL - public function declaration prefix (default: extern)
// SOKOL_API_DECL      - same as SOKOL_TIME_API_DECL
// SOKOL_API_IMPL      - public function implementation prefix (default: -)
//
// If sokol_time.h is compiled as a DLL, define the following before
// including the declaration or implementation:
//
// SOKOL_DLL
//
// On Windows, SOKOL_DLL will define SOKOL_TIME_API_DECL as __declspec(dllexport)
// or __declspec(dllimport) as needed.
//
// void stm_setup();
//     Call once before any other functions to initialize sokol_time
//     (this calls for instance QueryPerformanceFrequency on Windows)
//
// uint64_t stm_now();
//     Get current point in time in unspecified 'ticks'. The value that
//     is returned has no relation to the 'wall-clock' time and is
//     not in a specific time unit, it is only useful to compute
//     time differences.
//
// uint64_t stm_diff(uint64_t new, uint64_t old);
//     Computes the time difference between new and old. This will always
//     return a positive, non-zero value.
//
// uint64_t stm_since(uint64_t start);
//     Takes the current time, and returns the elapsed time since start
//     (this is a shortcut for "stm_diff(stm_now(), start)")
//
// uint64_t stm_laptime(uint64_t* last_time);
//     This is useful for measuring frame time and other recurring
//     events. It takes the current time, returns the time difference
//     to the value in last_time, and stores the current time in
//     last_time for the next call. If the value in last_time is 0,
//     the return value will be zero (this usually happens on the
//     very first call).
//
// uint64_t stm_round_to_common_refresh_rate(uint64_t duration)
//     This oddly named function takes a measured frame time and
//     returns the closest "nearby" common display refresh rate frame duration
//     in ticks. If the input duration isn't close to any common display
//     refresh rate, the input duration will be returned unchanged as a fallback.
//     The main purpose of this function is to remove jitter/inaccuracies from
//     measured frame times, and instead use the display refresh rate as
//     frame duration.
//     NOTE: for more robust frame timing, consider using the
//     sokol_app.h function sapp_frame_duration()
//
// Use the following functions to convert a duration in ticks into
// useful time units:
//
// double stm_sec(uint64_t ticks);
// double stm_ms(uint64_t ticks);
// double stm_us(uint64_t ticks);
// double stm_ns(uint64_t ticks);
//     Converts a tick value into seconds, milliseconds, microseconds
//     or nanoseconds. Note that not all platforms will have nanosecond
//     or even microsecond precision.
//
// Uses the following time measurement functions under the hood:
//
// Windows:        QueryPerformanceFrequency() / QueryPerformanceCounter()
// MacOS/iOS:      mach_absolute_time()
// emscripten:     emscripten_get_now()
// Linux+others:   clock_gettime(CLOCK_MONOTONIC)
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
extern fn stm_setup() void;

pub fn setup() void {
    stm_setup();
}

extern fn stm_now() u64;

pub fn now() u64 {
    return stm_now();
}

extern fn stm_diff(u64, u64) u64;

pub fn diff(new_ticks: u64, old_ticks: u64) u64 {
    return stm_diff(new_ticks, old_ticks);
}

extern fn stm_since(u64) u64;

pub fn since(start_ticks: u64) u64 {
    return stm_since(start_ticks);
}

extern fn stm_laptime([*c]u64) u64;

pub fn laptime(last_time: *u64) u64 {
    return stm_laptime(last_time);
}

extern fn stm_round_to_common_refresh_rate(u64) u64;

pub fn roundToCommonRefreshRate(frame_ticks: u64) u64 {
    return stm_round_to_common_refresh_rate(frame_ticks);
}

extern fn stm_sec(u64) f64;

pub fn sec(ticks: u64) f64 {
    return stm_sec(ticks);
}

extern fn stm_ms(u64) f64;

pub fn ms(ticks: u64) f64 {
    return stm_ms(ticks);
}

extern fn stm_us(u64) f64;

pub fn us(ticks: u64) f64 {
    return stm_us(ticks);
}

extern fn stm_ns(u64) f64;

pub fn ns(ticks: u64) f64 {
    return stm_ns(ticks);
}

