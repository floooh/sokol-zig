#define SOKOL_ZIG_BINDINGS
#define SOKOL_NO_ENTRY

#if defined(SOKOL_ZIG_LOG_HOOK)
    void sokol_zig_log(const char *s);
    #define SOKOL_LOG sokol_zig_log
#else
    #if defined(_WIN32)
        #define SOKOL_WIN32_FORCE_MAIN
        #define SOKOL_LOG(msg) OutputDebugStringA(msg)
    #endif
#endif

#if defined(SOKOL_ZIG_ASSERT_HOOK)
    void sokol_zig_assert(unsigned int c, const char *s);
    #define SOKOL_ASSERT(c) sokol_zig_assert((unsigned int)c, #c)
#endif

// FIXME: macOS Zig HACK without this, some C stdlib headers throw errors
#if defined(__APPLE__)
#include <TargetConditionals.h>
#endif
