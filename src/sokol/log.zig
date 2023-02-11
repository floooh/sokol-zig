// machine generated, do not edit

const builtin = @import("builtin");

// helper function to convert a C string to a Zig string slice
fn cStrToZig(c_str: [*c]const u8) [:0]const u8 {
  return @import("std").mem.span(c_str);
}
pub extern fn slog_func([*c]const u8, u32, u32, [*c]const u8, u32, [*c]const u8, ?*anyopaque) void;
pub const func = slog_func;
