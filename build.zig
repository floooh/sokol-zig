const std = @import("std");
const Builder = std.build.Builder;
const warn = std.debug.warn;
const assert = std.debug.assert;

// same as Builder.exec() but captures stderr instead of stdout
fn exec_stderr(b: *Builder, argv: []const []const u8) ![]u8 {
    assert(argv.len != 0);

    const max_output_size = 100 * 1024;
    const child = try std.ChildProcess.init(argv, b.allocator);
    defer child.deinit();

    child.stdin_behavior = .Ignore;
    child.stdout_behavior = .Ignore;
    child.stderr_behavior = .Pipe;

    try child.spawn();

    var stderr = std.Buffer.initNull(b.allocator);
    defer std.Buffer.deinit(&stderr);

    var stderr_file_in_stream = child.stderr.?.inStream();
    try stderr_file_in_stream.stream.readAllBuffer(&stderr, max_output_size);

    const term = child.wait() catch |err| std.debug.panic("unable to spawn {}: {}", argv[0], err);
    switch (term) {
        .Exited => |code| {
            if (code != 0) {
                std.debug.panic("exec failed");
            }
            return stderr.toOwnedSlice();
        },
        else => {
            std.debug.panic("exec failed");
        },
    }
    return stderr.toOwnedSlice();
}    

// extract macOS system header search paths by inspecting clang output
fn get_macos_header_search_paths(b: *Builder) anyerror![]const [] const u8 {
    const outp = try exec_stderr(b, [][] const u8 { "clang", "-E", "-Wp,-v", "-xc", "/dev/null" });
    var it = std.mem.tokenize(outp, "\n");
    var capture = false;
    var i: i32 = 0;
    var path_list = std.ArrayList([]const u8).init(std.debug.global_allocator);
    defer path_list.deinit();
    while (it.next()) |item| : (i += 1) {
        if (std.mem.eql(u8, item, "#include <...> search starts here:")) {
            capture = true;
        }
        else if (std.mem.eql(u8, item, "End of search list.")) {
            capture = false;
        }
        else if (capture) {
            const strip_index = std.mem.lastIndexOf(u8, item, " (framework directory)");
            const trimmed = if (strip_index) |index| item[0..index] else item;
            try path_list.append(trimmed);
        }
    }
    return path_list.toOwnedSlice();
}

pub fn build_c_args(b: *Builder) anyerror![]const []const u8 {
    var c_args = std.ArrayList([]const u8).init(std.debug.global_allocator);
    defer c_args.deinit();
    try c_args.append("-ObjC");
    try c_args.append("-fobjc-arc");
    const hdr_paths = try get_macos_header_search_paths(b);
    for (hdr_paths) |path| {
        warn("adding system header: {}\n", path);
        try c_args.append("-isystem");
        try c_args.append(path);
    }
    return c_args.toOwnedSlice();
}

pub fn build(b: *Builder) void {
//    const c_args = build_c_args(b) catch unreachable;
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

    // Linking with macOS frameworks doesn't appear to work, instead
    // need to run "zig build --verbose-link", and then copy the dumped 'lld'
    // command line and replace 'lld' with 'ld', and put apostrophes around
    // paths with spaces, for instance:
    //
    // ld -demangle -dynamic -arch x86_64 -macosx_version_min 10.14.0 -sdk_version 10.14.0 -pie -o bla /Users/floh/projects/sokol-zig/zig-cache/sokol.o /Users/floh/projects/sokol-zig/zig-cache/o/7m3moWa90u-ryMknat2mGa2XM7lH5CznZ6Xd_ceJjz59yV0uTEHiRvl68jfLIK4d/bla.o "/Users/floh/Library/Application Support/zig/stage1/o/WpKTcY2QXg4ksdKomoDb-vJNiQ7LdlAGR-60t8qtMcStE_YnusnviFKJ8StS6FB6/libcompiler_rt.a" -lSystem -framework MetalKit -framework Foundation -framework Cocoa -framework Metal -framework Quartz
    //
    const exe = b.addExecutable("bla", "src/main.zig");
    exe.addObjectFile("zig-cache/sokol.o");
    //exe.addCSourceFile("src/sokol.c", c_args);
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
