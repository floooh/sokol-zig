#define SOKOL_IMPL
#define SOKOL_NO_ENTRY
#if defined(_WIN32)
    #define SOKOL_D3D11
#else
    #define SOKOL_GLCORE33
#endif
#include "sokol_app.h"
#include "sokol_gfx.h"
