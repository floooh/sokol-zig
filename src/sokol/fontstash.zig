// machine generated, do not edit

const builtin = @import("builtin");
const sg = @import("gfx.zig");

// helper function to convert a C string to a Zig string slice
fn cStrToZig(c_str: [*c]const u8) [:0]const u8 {
    return @import("std").mem.span(c_str);
}
pub const Allocator = extern struct {
    alloc_fn: ?*const fn (usize, ?*anyopaque) callconv(.C) ?*anyopaque = null,
    free_fn: ?*const fn (?*anyopaque, ?*anyopaque) callconv(.C) void = null,
    user_data: ?*anyopaque = null,
};
pub const Desc = extern struct {
    width: i32 = 0,
    height: i32 = 0,
    allocator: Allocator = .{},
};
pub extern fn sfons_create([*c]const Desc) ?*anyopaque;
pub fn create(desc: Desc) ?*anyopaque {
    return sfons_create(&desc);
}
pub extern fn sfons_destroy(?*anyopaque) void;
pub fn destroy(ctx: ?*anyopaque) void {
    sfons_destroy(ctx);
}
pub extern fn sfons_flush(?*anyopaque) void;
pub fn flush(ctx: ?*anyopaque) void {
    sfons_flush(ctx);
}
pub extern fn sfons_rgba(u8, u8, u8, u8) u32;
pub fn rgba(r: u8, g: u8, b: u8, a: u8) u32 {
    return sfons_rgba(r, g, b, a);
}
