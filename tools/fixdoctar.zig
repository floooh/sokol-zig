//! repackage the autodocs sources.tar to only contain sokol sources
//! (which reduces the size from 13 MBytes to abour 500 KBytes)
const std = @import("std");
const log = std.log;
const Allocator = std.mem.Allocator;

pub fn main() !void {
    var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    // parse args
    const prefix = try arg(arena, "--prefix");
    const input_dir = try arg(arena, "--input");
    const output_path = try arg(arena, "--output");
    log.info("fixdoctar called with:", .{});
    log.info("--prefix: {s}", .{prefix});
    log.info("--input_dir: {s}", .{input_dir});
    log.info("--output_dir: {s}", .{output_path});

    // iterate over sources.tar file, find relevant files and write to output tar file
    const inp_path = try std.fs.path.join(arena, &.{ input_dir, "sources.tar" });
    const inp_file = std.fs.cwd().openFile(inp_path, .{}) catch |err| {
        fatal("failed to open input file '{s}' with {}", .{ inp_path, err });
    };
    defer inp_file.close();
    const outp_file = std.fs.cwd().createFile(output_path, .{}) catch |err| {
        fatal("failed to open output file '{s}' with {}", .{ output_path, err });
    };
    defer outp_file.close();

    var tar_writer = std.tar.writer(outp_file.writer());
    var file_name_buffer: [1024]u8 = undefined;
    var link_name_buffer: [1024]u8 = undefined;
    var iter = std.tar.iterator(inp_file.reader(), .{
        .file_name_buffer = &file_name_buffer,
        .link_name_buffer = &link_name_buffer,
    });
    while (try iter.next()) |tar_item| {
        switch (tar_item.kind) {
            .file => {
                if (std.mem.startsWith(u8, tar_item.name, prefix)) {
                    try tar_writer.writeFileStream(tar_item.name, tar_item.size, tar_item.reader(), .{ .mode = tar_item.mode });
                }
            },
            else => continue,
        }
    }
    log.info("Done.", .{});
    return std.process.cleanExit();
}

fn fatal(comptime fmt: []const u8, args: anytype) noreturn {
    std.log.err(fmt, args);
    std.process.exit(5);
}

fn arg(allocator: Allocator, key: []const u8) ![]const u8 {
    var arg_iter = try std.process.argsWithAllocator(allocator);
    defer arg_iter.deinit();
    while (arg_iter.next()) |cur| {
        if (std.mem.eql(u8, key, cur)) {
            const val = arg_iter.next() orelse fatal("expected arg after {s}", .{key});
            return allocator.dupe(u8, val);
        }
    }
    fatal("expected arg {s}", .{key});
}
