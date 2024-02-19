// machine generated, do not edit

const builtin = @import("builtin");
const sg = @import("gfx.zig");

// helper function to convert a C string to a Zig string slice
fn cStrToZig(c_str: [*c]const u8) [:0]const u8 {
    return @import("std").mem.span(c_str);
}
pub extern fn sglue_environment() sg.Environment;
pub fn environment() sg.Environment {
    return sglue_environment();
}
pub extern fn sglue_swapchain() sg.Swapchain;
pub fn swapchain() sg.Swapchain {
    return sglue_swapchain();
}
