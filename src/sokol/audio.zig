// machine generated, do not edit

//
// sokol_audio.h -- cross-platform audio-streaming API
//
// Project URL: https://github.com/floooh/sokol
//
// Do this:
//     #define SOKOL_IMPL or
//     #define SOKOL_AUDIO_IMPL
// before you include this file in *one* C or C++ file to create the
// implementation.
//
// Optionally provide the following defines with your own implementations:
//
// SOKOL_DUMMY_BACKEND - use a dummy backend
// SOKOL_ASSERT(c)     - your own assert macro (default: assert(c))
// SOKOL_AUDIO_API_DECL- public function declaration prefix (default: extern)
// SOKOL_API_DECL      - same as SOKOL_AUDIO_API_DECL
// SOKOL_API_IMPL      - public function implementation prefix (default: -)
//
// SAUDIO_RING_MAX_SLOTS           - max number of slots in the push-audio ring buffer (default 1024)
// SAUDIO_OSX_USE_SYSTEM_HEADERS   - define this to force inclusion of system headers on
//                                   macOS instead of using embedded CoreAudio declarations
//
// If sokol_audio.h is compiled as a DLL, define the following before
// including the declaration or implementation:
//
// SOKOL_DLL
//
// On Windows, SOKOL_DLL will define SOKOL_AUDIO_API_DECL as __declspec(dllexport)
// or __declspec(dllimport) as needed.
//
// Link with the following libraries:
//
// - on macOS: AudioToolbox
// - on iOS: AudioToolbox, AVFoundation
// - on FreeBSD: asound
// - on Linux: asound
// - on Android: aaudio
// - on Windows with MSVC or Clang toolchain: no action needed, libs are defined in-source via pragma-comment-lib
// - on Windows with MINGW/MSYS2 gcc: compile with '-mwin32' and link with -lole32
// - on Vita: SceAudio
//
// FEATURE OVERVIEW
// ================
// You provide a mono- or stereo-stream of 32-bit float samples, which
// Sokol Audio feeds into platform-specific audio backends:
//
// - Windows: WASAPI
// - Linux: ALSA
// - FreeBSD: ALSA
// - macOS: CoreAudio
// - iOS: CoreAudio+AVAudioSession
// - emscripten: WebAudio with ScriptProcessorNode
// - Android: AAudio
// - Vita: SceAudio
//
// Sokol Audio will not do any buffer mixing or volume control, if you have
// multiple independent input streams of sample data you need to perform the
// mixing yourself before forwarding the data to Sokol Audio.
//
// There are two mutually exclusive ways to provide the sample data:
//
// 1. Callback model: You provide a callback function, which will be called
//    when Sokol Audio needs new samples. On all platforms except emscripten,
//    this function is called from a separate thread.
// 2. Push model: Your code pushes small blocks of sample data from your
//    main loop or a thread you created. The pushed data is stored in
//    a ring buffer where it is pulled by the backend code when
//    needed.
//
// The callback model is preferred because it is the most direct way to
// feed sample data into the audio backends and also has less moving parts
// (there is no ring buffer between your code and the audio backend).
//
// Sometimes it is not possible to generate the audio stream directly in a
// callback function running in a separate thread, for such cases Sokol Audio
// provides the push-model as a convenience.
//
// SOKOL AUDIO, SOLOUD AND MINIAUDIO
// =================================
// The WASAPI, ALSA and CoreAudio backend code has been taken from the
// SoLoud library (with some modifications, so any bugs in there are most
// likely my fault). If you need a more fully-featured audio solution, check
// out SoLoud, it's excellent:
//
//     https://github.com/jarikomppa/soloud
//
// Another alternative which feature-wise is somewhere inbetween SoLoud and
// sokol-audio might be MiniAudio:
//
//     https://github.com/mackron/miniaudio
//
// GLOSSARY
// ========
// - stream buffer:
//     The internal audio data buffer, usually provided by the backend API. The
//     size of the stream buffer defines the base latency, smaller buffers have
//     lower latency but may cause audio glitches. Bigger buffers reduce or
//     eliminate glitches, but have a higher base latency.
//
// - stream callback:
//     Optional callback function which is called by Sokol Audio when it
//     needs new samples. On Windows, macOS/iOS and Linux, this is called in
//     a separate thread, on WebAudio, this is called per-frame in the
//     browser thread.
//
// - channel:
//     A discrete track of audio data, currently 1-channel (mono) and
//     2-channel (stereo) is supported and tested.
//
// - sample:
//     The magnitude of an audio signal on one channel at a given time. In
//     Sokol Audio, samples are 32-bit float numbers in the range -1.0 to
//     +1.0.
//
// - frame:
//     The tightly packed set of samples for all channels at a given time.
//     For mono 1 frame is 1 sample. For stereo, 1 frame is 2 samples.
//
// - packet:
//     In Sokol Audio, a small chunk of audio data that is moved from the
//     main thread to the audio streaming thread in order to decouple the
//     rate at which the main thread provides new audio data, and the
//     streaming thread consuming audio data.
//
// WORKING WITH SOKOL AUDIO
// ========================
// First call saudio_setup() with your preferred audio playback options.
// In most cases you can stick with the default values, these provide
// a good balance between low-latency and glitch-free playback
// on all audio backends.
//
// You should always provide a logging callback to be aware of any
// warnings and errors. The easiest way is to use sokol_log.h for this:
//
//     #include "sokol_log.h"
//     // ...
//     saudio_setup(&(saudio_desc){
//         .logger = {
//             .func = slog_func,
//         }
//     });
//
// If you want to use the callback-model, you need to provide a stream
// callback function either in saudio_desc.stream_cb or saudio_desc.stream_userdata_cb,
// otherwise keep both function pointers zero-initialized.
//
// Use push model and default playback parameters:
//
//     saudio_setup(&(saudio_desc){ .logger.func = slog_func });
//
// Use stream callback model and default playback parameters:
//
//     saudio_setup(&(saudio_desc){
//         .stream_cb = my_stream_callback
//         .logger.func = slog_func,
//     });
//
// The standard stream callback doesn't have a user data argument, if you want
// that, use the alternative stream_userdata_cb and also set the user_data pointer:
//
//     saudio_setup(&(saudio_desc){
//         .stream_userdata_cb = my_stream_callback,
//         .user_data = &my_data
//         .logger.func = slog_func,
//     });
//
// The following playback parameters can be provided through the
// saudio_desc struct:
//
// General parameters (both for stream-callback and push-model):
//
//     int sample_rate     -- the sample rate in Hz, default: 44100
//     int num_channels    -- number of channels, default: 1 (mono)
//     int buffer_frames   -- number of frames in streaming buffer, default: 2048
//
// The stream callback prototype (either with or without userdata):
//
//     void (*stream_cb)(float* buffer, int num_frames, int num_channels)
//     void (*stream_userdata_cb)(float* buffer, int num_frames, int num_channels, void* user_data)
//         Function pointer to the user-provide stream callback.
//
// Push-model parameters:
//
//     int packet_frames   -- number of frames in a packet, default: 128
//     int num_packets     -- number of packets in ring buffer, default: 64
//
// The sample_rate and num_channels parameters are only hints for the audio
// backend, it isn't guaranteed that those are the values used for actual
// playback.
//
// To get the actual parameters, call the following functions after
// saudio_setup():
//
//     int saudio_sample_rate(void)
//     int saudio_channels(void);
//
// It's unlikely that the number of channels will be different than requested,
// but a different sample rate isn't uncommon.
//
// (NOTE: there's an yet unsolved issue when an audio backend might switch
// to a different sample rate when switching output devices, for instance
// plugging in a bluetooth headset, this case is currently not handled in
// Sokol Audio).
//
// You can check if audio initialization was successful with
// saudio_isvalid(). If backend initialization failed for some reason
// (for instance when there's no audio device in the machine), this
// will return false. Not checking for success won't do any harm, all
// Sokol Audio function will silently fail when called after initialization
// has failed, so apart from missing audio output, nothing bad will happen.
//
// Before your application exits, you should call
//
//     saudio_shutdown();
//
// This stops the audio thread (on Linux, Windows and macOS/iOS) and
// properly shuts down the audio backend.
//
// THE STREAM CALLBACK MODEL
// =========================
// To use Sokol Audio in stream-callback-mode, provide a callback function
// like this in the saudio_desc struct when calling saudio_setup():
//
// void stream_cb(float* buffer, int num_frames, int num_channels) {
//     ...
// }
//
// Or the alternative version with a user-data argument:
//
// void stream_userdata_cb(float* buffer, int num_frames, int num_channels, void* user_data) {
//     my_data_t* my_data = (my_data_t*) user_data;
//     ...
// }
//
// The job of the callback function is to fill the *buffer* with 32-bit
// float sample values.
//
// To output silence, fill the buffer with zeros:
//
//     void stream_cb(float* buffer, int num_frames, int num_channels) {
//         const int num_samples = num_frames * num_channels;
//         for (int i = 0; i < num_samples; i++) {
//             buffer[i] = 0.0f;
//         }
//     }
//
// For stereo output (num_channels == 2), the samples for the left
// and right channel are interleaved:
//
//     void stream_cb(float* buffer, int num_frames, int num_channels) {
//         assert(2 == num_channels);
//         for (int i = 0; i < num_frames; i++) {
//             buffer[2*i + 0] = ...;  // left channel
//             buffer[2*i + 1] = ...;  // right channel
//         }
//     }
//
// Please keep in mind that the stream callback function is running in a
// separate thread, if you need to share data with the main thread you need
// to take care yourself to make the access to the shared data thread-safe!
//
// THE PUSH MODEL
// ==============
// To use the push-model for providing audio data, simply don't set (keep
// zero-initialized) the stream_cb field in the saudio_desc struct when
// calling saudio_setup().
//
// To provide sample data with the push model, call the saudio_push()
// function at regular intervals (for instance once per frame). You can
// call the saudio_expect() function to ask Sokol Audio how much room is
// in the ring buffer, but if you provide a continuous stream of data
// at the right sample rate, saudio_expect() isn't required (it's a simple
// way to sync/throttle your sample generation code with the playback
// rate though).
//
// With saudio_push() you may need to maintain your own intermediate sample
// buffer, since pushing individual sample values isn't very efficient.
// The following example is from the MOD player sample in
// sokol-samples (https://github.com/floooh/sokol-samples):
//
//     const int num_frames = saudio_expect();
//     if (num_frames > 0) {
//         const int num_samples = num_frames * saudio_channels();
//         read_samples(flt_buf, num_samples);
//         saudio_push(flt_buf, num_frames);
//     }
//
// Another option is to ignore saudio_expect(), and just push samples as they
// are generated in small batches. In this case you *need* to generate the
// samples at the right sample rate:
//
// The following example is taken from the Tiny Emulators project
// (https://github.com/floooh/chips-test), this is for mono playback,
// so (num_samples == num_frames):
//
//     // tick the sound generator
//     if (ay38910_tick(&sys->psg)) {
//         // new sample is ready
//         sys->sample_buffer[sys->sample_pos++] = sys->psg.sample;
//         if (sys->sample_pos == sys->num_samples) {
//             // new sample packet is ready
//             saudio_push(sys->sample_buffer, sys->num_samples);
//             sys->sample_pos = 0;
//         }
//     }
//
// THE WEBAUDIO BACKEND
// ====================
// The WebAudio backend is currently using a ScriptProcessorNode callback to
// feed the sample data into WebAudio. ScriptProcessorNode has been
// deprecated for a while because it is running from the main thread, with
// the default initialization parameters it works 'pretty well' though.
// Ultimately Sokol Audio will use Audio Worklets, but this requires a few
// more things to fall into place (Audio Worklets implemented everywhere,
// SharedArrayBuffers enabled again, and I need to figure out a 'low-cost'
// solution in terms of implementation effort, since Audio Worklets are
// a lot more complex than ScriptProcessorNode if the audio data needs to come
// from the main thread).
//
// The WebAudio backend is automatically selected when compiling for
// emscripten (__EMSCRIPTEN__ define exists).
//
// https://developers.google.com/web/updates/2017/12/audio-worklet
// https://developers.google.com/web/updates/2018/06/audio-worklet-design-pattern
//
// "Blob URLs": https://www.html5rocks.com/en/tutorials/workers/basics/
//
// Also see: https://blog.paul.cx/post/a-wait-free-spsc-ringbuffer-for-the-web/
//
// THE COREAUDIO BACKEND
// =====================
// The CoreAudio backend is selected on macOS and iOS (__APPLE__ is defined).
// Since the CoreAudio API is implemented in C (not Objective-C) on macOS the
// implementation part of Sokol Audio can be included into a C source file.
//
// However on iOS, Sokol Audio must be compiled as Objective-C due to it's
// reliance on the AVAudioSession object. The iOS code path support both
// being compiled with or without ARC (Automatic Reference Counting).
//
// For thread synchronisation, the CoreAudio backend will use the
// pthread_mutex_* functions.
//
// The incoming floating point samples will be directly forwarded to
// CoreAudio without further conversion.
//
// macOS and iOS applications that use Sokol Audio need to link with
// the AudioToolbox framework.
//
// THE WASAPI BACKEND
// ==================
// The WASAPI backend is automatically selected when compiling on Windows
// (_WIN32 is defined).
//
// For thread synchronisation a Win32 critical section is used.
//
// WASAPI may use a different size for its own streaming buffer then requested,
// so the base latency may be slightly bigger. The current backend implementation
// converts the incoming floating point sample values to signed 16-bit
// integers.
//
// The required Windows system DLLs are linked with #pragma comment(lib, ...),
// so you shouldn't need to add additional linker libs in the build process
// (otherwise this is a bug which should be fixed in sokol_audio.h).
//
// THE ALSA BACKEND
// ================
// The ALSA backend is automatically selected when compiling on Linux
// ('linux' is defined).
//
// For thread synchronisation, the pthread_mutex_* functions are used.
//
// Samples are directly forwarded to ALSA in 32-bit float format, no
// further conversion is taking place.
//
// You need to link with the 'asound' library, and the <alsa/asoundlib.h>
// header must be present (usually both are installed with some sort
// of ALSA development package).
//
// THE VITA BACKEND
// ================
// The VITA backend is automatically selected when compiling with vitasdk
// ('PSP2_SDK_VERSION' is defined).
//
// For thread synchronisation, the pthread_mutex_* functions are used.
//
// Samples are converted from float to short (uint16_t) to maintain
// all the same interface/api as other platforms.
//
// You may use any supported sample rate you wish, but all audio MUST
// match the same sample rate you choose.
//
// This uses the "BGM" port to allow selecting the sample rate ("Main"
// port is restricted to 48000 only).
//
// You need to link with the 'SceAudio' library, and the <psp2/audioout.h>
// header must be present (usually both are installed with the vitasdk).
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
//         saudio_setup(&(saudio_desc){
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
// This only affects memory allocation calls done by sokol_audio.h
// itself though, not any allocations in OS libraries.
//
// Memory allocation will only happen on the same thread where saudio_setup()
// was called, so you don't need to worry about thread-safety.
//
//
// ERROR REPORTING AND LOGGING
// ===========================
// To get any logging information at all you need to provide a logging callback in the setup call
// the easiest way is to use sokol_log.h:
//
//     #include "sokol_log.h"
//
//     saudio_setup(&(saudio_desc){ .logger.func = slog_func });
//
// To override logging with your own callback, first write a logging function like this:
//
//     void my_log(const char* tag,                // e.g. 'saudio'
//                 uint32_t log_level,             // 0=panic, 1=error, 2=warn, 3=info
//                 uint32_t log_item_id,           // SAUDIO_LOGITEM_*
//                 const char* message_or_null,    // a message string, may be nullptr in release mode
//                 uint32_t line_nr,               // line number in sokol_audio.h
//                 const char* filename_or_null,   // source filename, may be nullptr in release mode
//                 void* user_data)
//     {
//         ...
//     }
//
// ...and then setup sokol-audio like this:
//
//     saudio_setup(&(saudio_desc){
//         .logger = {
//             .func = my_log,
//             .user_data = my_user_data,
//         }
//     });
//
// The provided logging function must be reentrant (e.g. be callable from
// different threads).
//
// If you don't want to provide your own custom logger it is highly recommended to use
// the standard logger in sokol_log.h instead, otherwise you won't see any warnings or
// errors.
//
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
pub const LogItem = enum(i32) {
    OK,
    MALLOC_FAILED,
    ALSA_SND_PCM_OPEN_FAILED,
    ALSA_FLOAT_SAMPLES_NOT_SUPPORTED,
    ALSA_REQUESTED_BUFFER_SIZE_NOT_SUPPORTED,
    ALSA_REQUESTED_CHANNEL_COUNT_NOT_SUPPORTED,
    ALSA_SND_PCM_HW_PARAMS_SET_RATE_NEAR_FAILED,
    ALSA_SND_PCM_HW_PARAMS_FAILED,
    ALSA_PTHREAD_CREATE_FAILED,
    WASAPI_CREATE_EVENT_FAILED,
    WASAPI_CREATE_DEVICE_ENUMERATOR_FAILED,
    WASAPI_GET_DEFAULT_AUDIO_ENDPOINT_FAILED,
    WASAPI_DEVICE_ACTIVATE_FAILED,
    WASAPI_AUDIO_CLIENT_INITIALIZE_FAILED,
    WASAPI_AUDIO_CLIENT_GET_BUFFER_SIZE_FAILED,
    WASAPI_AUDIO_CLIENT_GET_SERVICE_FAILED,
    WASAPI_AUDIO_CLIENT_SET_EVENT_HANDLE_FAILED,
    WASAPI_CREATE_THREAD_FAILED,
    AAUDIO_STREAMBUILDER_OPEN_STREAM_FAILED,
    AAUDIO_PTHREAD_CREATE_FAILED,
    AAUDIO_RESTARTING_STREAM_AFTER_ERROR,
    USING_AAUDIO_BACKEND,
    AAUDIO_CREATE_STREAMBUILDER_FAILED,
    COREAUDIO_NEW_OUTPUT_FAILED,
    COREAUDIO_ALLOCATE_BUFFER_FAILED,
    COREAUDIO_START_FAILED,
    BACKEND_BUFFER_SIZE_ISNT_MULTIPLE_OF_PACKET_SIZE,
    VITA_SCEAUDIO_OPEN_FAILED,
    VITA_PTHREAD_CREATE_FAILED,
};

/// saudio_logger
///
/// Used in saudio_desc to provide a custom logging and error reporting
/// callback to sokol-audio.
pub const Logger = extern struct {
    func: ?*const fn ([*c]const u8, u32, u32, [*c]const u8, u32, [*c]const u8, ?*anyopaque) callconv(.c) void = null,
    user_data: ?*anyopaque = null,
};

/// saudio_allocator
///
/// Used in saudio_desc to provide custom memory-alloc and -free functions
/// to sokol_audio.h. If memory management should be overridden, both the
/// alloc_fn and free_fn function must be provided (e.g. it's not valid to
/// override one function but not the other).
pub const Allocator = extern struct {
    alloc_fn: ?*const fn (usize, ?*anyopaque) callconv(.c) ?*anyopaque = null,
    free_fn: ?*const fn (?*anyopaque, ?*anyopaque) callconv(.c) void = null,
    user_data: ?*anyopaque = null,
};

pub const Desc = extern struct {
    sample_rate: i32 = 0,
    num_channels: i32 = 0,
    buffer_frames: i32 = 0,
    packet_frames: i32 = 0,
    num_packets: i32 = 0,
    stream_cb: ?*const fn ([*c]f32, i32, i32) callconv(.c) void = null,
    stream_userdata_cb: ?*const fn ([*c]f32, i32, i32, ?*anyopaque) callconv(.c) void = null,
    user_data: ?*anyopaque = null,
    allocator: Allocator = .{},
    logger: Logger = .{},
};

/// setup sokol-audio
extern fn saudio_setup([*c]const Desc) void;

/// setup sokol-audio
pub fn setup(desc: Desc) void {
    saudio_setup(&desc);
}

/// shutdown sokol-audio
extern fn saudio_shutdown() void;

/// shutdown sokol-audio
pub fn shutdown() void {
    saudio_shutdown();
}

/// true after setup if audio backend was successfully initialized
extern fn saudio_isvalid() bool;

/// true after setup if audio backend was successfully initialized
pub fn isvalid() bool {
    return saudio_isvalid();
}

/// return the saudio_desc.user_data pointer
extern fn saudio_userdata() ?*anyopaque;

/// return the saudio_desc.user_data pointer
pub fn userdata() ?*anyopaque {
    return saudio_userdata();
}

/// return a copy of the original saudio_desc struct
extern fn saudio_query_desc() Desc;

/// return a copy of the original saudio_desc struct
pub fn queryDesc() Desc {
    return saudio_query_desc();
}

/// actual sample rate
extern fn saudio_sample_rate() i32;

/// actual sample rate
pub fn sampleRate() i32 {
    return saudio_sample_rate();
}

/// return actual backend buffer size in number of frames
extern fn saudio_buffer_frames() i32;

/// return actual backend buffer size in number of frames
pub fn bufferFrames() i32 {
    return saudio_buffer_frames();
}

/// actual number of channels
extern fn saudio_channels() i32;

/// actual number of channels
pub fn channels() i32 {
    return saudio_channels();
}

/// return true if audio context is currently suspended (only in WebAudio backend, all other backends return false)
extern fn saudio_suspended() bool;

/// return true if audio context is currently suspended (only in WebAudio backend, all other backends return false)
pub fn suspended() bool {
    return saudio_suspended();
}

/// get current number of frames to fill packet queue
extern fn saudio_expect() i32;

/// get current number of frames to fill packet queue
pub fn expect() i32 {
    return saudio_expect();
}

/// push sample frames from main thread, returns number of frames actually pushed
extern fn saudio_push([*c]const f32, i32) i32;

/// push sample frames from main thread, returns number of frames actually pushed
pub fn push(frames: *const f32, num_frames: i32) i32 {
    return saudio_push(frames, num_frames);
}

