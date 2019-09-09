const std = @import("std");
const builtin = @import("builtin");
const Builder = std.build.Builder;
const warn = std.debug.warn;
const assert = std.debug.assert;

// a global allocator for string stuff
var str_buf: [4096]u8 = undefined;
const allocator = &std.heap.FixedBufferAllocator.init(&str_buf).allocator;    

// helper function to get SDK path on Mac
fn macos_frameworks_dir(b: *Builder) ![]u8 {
    var str = try b.exec([_][] const u8 { "xcrun", "--show-sdk-path"});
    const strip_newline = std.mem.lastIndexOf(u8, str, "\n");
    if (strip_newline) |index| {
        str = str[0..index];
    }
    const frameworks_dir = try std.mem.concat(allocator, u8, [_][]const u8 {str, "/System/Library/Frameworks"});
    return frameworks_dir;
}

pub fn build(b: *Builder) !void {
    
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("clear", "src/main.zig");

    exe.setBuildMode(mode);
    exe.addIncludeDir("src");
    if (builtin.os == .macosx) {
        exe.addCSourceFile("src/sokol.c", [_][]const u8{ "-ObjC", "-fobjc-arc"});
        const frameworks_dir = try macos_frameworks_dir(b);
        exe.addFrameworkDir(frameworks_dir);
        exe.linkFramework("Foundation");
        exe.linkFramework("Cocoa");
        exe.linkFramework("Quartz");
        exe.linkFramework("Metal");
        exe.linkFramework("MetalKit");
        exe.enableSystemLinkerHack();
    }
    
    const run_cmd = exe.run();

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    b.default_step.dependOn(&exe.step);
    b.installArtifact(exe);
}
