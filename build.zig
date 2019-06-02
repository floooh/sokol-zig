const std = @import("std");
const Builder = std.build.Builder;
const warn = std.debug.warn;

pub fn build(b: *Builder) void {

    const mode = b.standardReleaseOptions();
    // this doesn't work with "addCSourceFile" since this doesn't
    // find macOS SDK framework headers (for Metal, Cocoa, etc...)
    const sokol = b.addSystemCommand([][]const u8{
        "clang",
        "src/sokol.c",
        "-march=native",
        "-fstack-protector-strong",
        "--param", "ssp-buffer-size=4",
        "-fno-omit-frame-pointer", "-fPIC",
        "-ObjC", "-fobjc-arc",
        "-c", "-o", "zig-cache/sokol.o"
    });

    // linking with macOS frameworks doesn't appear to work, instead
    // need to run "zig build --verbose-link", and then copy the dumped 'lld'
    // command line and instead execute something like this:
    //
    // clang -o bla /Users/floh/scratch/zig-cache/sokol.o /Users/floh/scratch/bla/zig-cache/o/0NRn8fMmujQTpEoeqSKk0UzKAQ8UFg4-Nh3nFQ-0OxkXw4Wg44YnU1VGqKaKktuc/bla.o "/Users/floh/Library/Application Support/zig/stage1/o/WpKTcY2QXg4ksdKomoDb-vJNiQ7LdlAGR-60t8qtMcStE_YnusnviFKJ8StS6FB6/libcompiler_rt.a" -lSystem -framework MetalKit -framework Foundation -framework Cocoa -framework Metal -framework Quartz
    //
    const exe = b.addExecutable("bla", "src/main.zig");
    exe.addObjectFile("zig-cache/sokol.o");
    exe.setBuildMode(mode);
    exe.addIncludeDir("src");
    exe.linkFramework("Foundation");
    exe.linkFramework("Cocoa");
    exe.linkFramework("Quartz");
    exe.linkFramework("Metal");
    exe.linkFramework("MetalKit");
    exe.step.dependOn(&sokol.step);
    
    const run_cmd = exe.run();

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    b.default_step.dependOn(&exe.step);
    b.installArtifact(exe);
}
