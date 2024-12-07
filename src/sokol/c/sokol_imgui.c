#if defined(IMPL)
#define SOKOL_IMGUI_IMPL
// FIXME: no longer needed with dear_bindings, remove after transition period
#define CIMGUI_DEFINE_ENUMS_AND_STRUCTS
#include "cimgui.h"
#endif
#include "sokol_defines.h"
#include "sokol_app.h"
#include "sokol_gfx.h"
#include "sokol_imgui.h"
