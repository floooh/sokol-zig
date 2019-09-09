const std = @import("std");
const Builder = std.build.Builder;
const warn = std.debug.warn;
const assert = std.debug.assert;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("bla", "src/main.zig");
    exe.setBuildMode(mode);
    exe.addIncludeDir("src");
    exe.addFrameworkDir("/Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks");
    exe.linkFramework("Foundation");
    exe.linkFramework("Cocoa");
    exe.linkFramework("Quartz");
    exe.linkFramework("Metal");
    exe.linkFramework("MetalKit");
    exe.enableSystemLinkerHack();
    const c_args = [_][]const u8{
        "-ObjC",
        "-fobjc-arc",
    };
    exe.addCSourceFile("src/sokol.c", c_args);
    
    const run_cmd = exe.run();

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    b.default_step.dependOn(&exe.step);
    b.installArtifact(exe);
}
