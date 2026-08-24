const std = @import("std");

pub fn getRequest(allocator: std.mem.Allocator, url: []const u8) ![]u8 {
    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();
    var weatherJson = std.ArrayList(u8).init(allocator);
    errdefer weatherJson.deinit();

    _ = client.fetch(.{
        .location = .{ .uri = try std.Uri.parse(url) },
        .response_storage = .{ .dynamic = &weatherJson },
    }) catch |err| switch (err) {
        error.OutOfMemory => {
            std.debug.print("OutOfMemory, how?? \n", .{});
            std.process.exit(1);
        },
        error.UnknownHostName, error.TemporaryNameServerFailure, error.NameServerFailure => {
            std.debug.print("Check internet connection \n", .{});
            std.process.exit(1);
        },
        error.TlsInitializationFailed, error.CertificateBundleLoadFailure, error.TlsFailure, error.TlsAlert => {
            std.debug.print("TLS error \n", .{});
            std.process.exit(1);
        },
        else => {
            std.debug.print("strange error \n {any} \n", .{err});
            std.process.exit(1);
        },
    };
    return try weatherJson.toOwnedSlice();
}
