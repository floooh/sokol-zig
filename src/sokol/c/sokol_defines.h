#define SOKOL_ZIG_BINDINGS
#define SOKOL_NO_ENTRY
#if defined(_WIN32)
    #define SOKOL_WIN32_FORCE_MAIN
    #define SOKOL_LOG(msg) OutputDebugStringA(msg)
#endif
// FIXME: macOS Zig HACK without this, some C stdlib headers throw errors
#if defined(__APPLE__)
#include <TargetConditionals.h>
#endif
