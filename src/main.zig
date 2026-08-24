const std = @import("std");
const request = @import("request.zig");
const parse = @import("json_parse.zig");
const out = @import("output.zig");
const config = @import("config.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const confJson = config.configuration(allocator) catch |err| switch (err) {
        error.NoHome => {
            std.debug.print("You don't have $HOME variable set \n", .{});
            std.process.exit(1);
        },
        error.SyntaxMalformed => {
            std.debug.print("Syntax in config is malformed \n", .{});
            std.process.exit(1);
        },
        error.SyntaxMissing => {
            std.debug.print("Missing 'source' field in config  \n", .{});
            std.process.exit(1);
        },
        error.Imposible => {
            std.debug.print("Strange error \n", .{});
            std.process.exit(1);
        },
        error.OutOfMemory => {
            std.debug.print("OOM, how? \n", .{});
            std.process.exit(1);
        },
        else => {
            std.debug.print("Unexpected error {any} \n", .{err});
            std.process.exit(1);
        },
    };

    const url = confJson.value.source;
    const raw_data = request.getRequest(allocator, url) catch |err| switch (err) {
        error.InternetError => {
            std.debug.print("You are offline \n", .{});
            std.process.exit(1);
        },
        error.UrlMalformed => {
            std.debug.print("Check your url, maybe it has some extra space? \n", .{});
            std.process.exit(1);
        },
        error.TlsError => {
            std.debug.print("TLS error \n", .{});
            std.process.exit(1);
        },
        error.SourceIsDown => {
            std.debug.print("Something wrong with OpenMeteo \n", .{});
            std.process.exit(1);
        },
        error.OutOfMemory => {
            std.debug.print("OOM, how? \n", .{});
            std.process.exit(1);
        },
        else => {
            std.debug.print("Unexpected error:\n {any} \n", .{err});
            std.process.exit(1);
        },
    };

    const json = try parse.rawToJSON(parse.data, allocator, raw_data);
    try out.output(json.value);
}
