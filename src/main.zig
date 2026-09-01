const std = @import("std");
const request = @import("request.zig");
const parse = @import("json_parse.zig");
const out = @import("output.zig");
const config = @import("config.zig");
const flags = @import("flags.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const stderr = std.io.getStdErr().writer();
    const stdout = std.io.getStdOut().writer();

    const flag = flags.parseArg(allocator) catch |err| switch (err) {
        error.InputNothing => {
            try stderr.print("your input in lat/lon empty \n", .{});
            std.process.exit(1);
        },
        error.UnknownKey => {
            try stderr.print("Unknown key \n", .{});
            std.process.exit(1);
        },
        error.OutOfMemory => {
            try stderr.print("OOM \n", .{});
            std.process.exit(1);
        },
        error.OneArg => {
            try stderr.print("You input only one argument, input another \n", .{});
            std.process.exit(1);
        },
        error.Help => {
            try stdout.print("help placeholder \n", .{});
            std.process.exit(0);
        },
    };
    const confJson = config.configuration(allocator) catch |err| switch (err) {
        error.NoHome => {
            try stderr.print("You don't have $HOME variable set \n", .{});
            std.process.exit(1);
        },
        error.SyntaxMalformed => {
            try stderr.print("Syntax in config is malformed \n", .{});
            std.process.exit(1);
        },
        error.SyntaxMissing => {
            try stderr.print("Missing 'source' field in config  \n", .{});
            std.process.exit(1);
        },
        error.Impossible => {
            try stderr.print("Strange error \n", .{});
            std.process.exit(1);
        },
        error.OutOfMemory => {
            try stderr.print("OOM, how? \n", .{});
            std.process.exit(1);
        },
        else => {
            try stderr.print("Unexpected error {any} \n", .{err});
            std.process.exit(1);
        },
    };
    var url: []const u8 = undefined;
    if (flag.lat != null and flag.lon != null) {
        url = try config.url(allocator, flag.lat.?, flag.lon.?);
    } else {
        url = confJson.value.source;
    }
    const raw_data = request.getRequest(allocator, url) catch |err| switch (err) {
        error.InternetError => {
            try stderr.print("You are offline \n", .{});
            std.process.exit(1);
        },
        error.UrlMalformed => {
            try stderr.print("Check your url, maybe it has some extra space? \n", .{});
            std.process.exit(1);
        },
        error.TlsError => {
            try stderr.print("TLS error \n", .{});
            std.process.exit(1);
        },
        error.SourceIsDown => {
            try stderr.print("Something wrong with OpenMeteo \n", .{});
            std.process.exit(1);
        },
        error.OutOfMemory => {
            try stderr.print("OOM, how? \n", .{});
            std.process.exit(1);
        },
        else => {
            try stderr.print("Unexpected error:\n {any} \n", .{err});
            std.process.exit(1);
        },
    };
    const layout = confJson.value.layout;
    const json = try parse.rawToJSON(parse.data, allocator, raw_data);
    try out.output(json.value, layout);
}
