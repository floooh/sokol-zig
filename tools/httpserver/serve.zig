const std = @import("std");
const StaticHttpFileServer = @import("StaticHttpFileServer");

var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};

pub fn main() !void {
    var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();
    const gpa = general_purpose_allocator.allocator();

    const args = try std.process.argsAlloc(arena);

    var listen_port: u16 = 0;
    var opt_root_dir_path: ?[]const u8 = null;

    {
        var i: usize = 1;
        while (i < args.len) : (i += 1) {
            const arg = args[i];
            if (std.mem.startsWith(u8, arg, "-")) {
                if (std.mem.eql(u8, arg, "-p")) {
                    i += 1;
                    if (i >= args.len) fatal("expected arg after '{s}'", .{arg});
                    listen_port = std.fmt.parseInt(u16, args[i], 10) catch |err| {
                        fatal("unable to parse port '{s}': {s}", .{ args[i], @errorName(err) });
                    };
                } else {
                    fatal("unrecognized argument: '{s}'", .{arg});
                }
            } else if (opt_root_dir_path == null) {
                opt_root_dir_path = arg;
            } else {
                fatal("unexpected positional argument: '{s}'", .{arg});
            }
        }
    }

    const root_dir_path = opt_root_dir_path orelse fatal("missing root dir path", .{});

    var root_dir = std.fs.cwd().openDir(root_dir_path, .{ .iterate = true }) catch |err|
        fatal("unable to open directory '{s}': {s}", .{ root_dir_path, @errorName(err) });
    defer root_dir.close();

    const aliases:[2]StaticHttpFileServer.Options.Alias = .{
        .{ .request_path = "/", .file_path = "/index.html" },
        .{ .request_path = "404", .file_path = "/index.html" },
    };

    var etag_buf:[32]u8 = undefined;

    var static_http_file_server = try StaticHttpFileServer.init(.{
        .allocator = gpa,
        .root_dir = root_dir,
        .aliases = &aliases,
        .etag = try std.fmt.bufPrint(&etag_buf, "{d}", .{std.time.nanoTimestamp()}),
    });
    defer static_http_file_server.deinit(gpa);

    const address = try std.net.Address.parseIp("127.0.0.1", listen_port);
    var http_server = try address.listen(.{
        .reuse_address = true,
    });
    const port = http_server.listen_address.in.getPort();
    std.debug.print("Listening at http://127.0.0.1:{d}/\n", .{port});

    var read_buffer: [8000]u8 = undefined;
    var write_buffer: [8000]u8 = undefined;
    accept: while (true) {
        var connection = try http_server.accept();
        defer connection.stream.close();

        var reader = connection.stream.reader(&read_buffer);
        var writer = connection.stream.writer(&write_buffer);

        var server = std.http.Server.init(reader.interface(), &writer.interface);
        while (server.reader.state == .ready) {
            var request = server.receiveHead() catch |err| {
                std.debug.print("error: {s}\n", .{@errorName(err)});
                continue :accept;
            };
            try static_http_file_server.serve(&request);
            continue :accept;   // force reset after each request
        }
    }
}

fn fatal(comptime format: []const u8, args: anytype) noreturn {
    std.debug.print(format ++ "\n", args);
    std.process.exit(1);
}
