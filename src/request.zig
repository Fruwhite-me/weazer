const std = @import("std");

pub fn getRequest(allocator: std.mem.Allocator, url: []const u8) ![]u8 {
    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();
    var weatherJson = std.ArrayList(u8).init(allocator);
    errdefer weatherJson.deinit();

    const res = client.fetch(.{
        .location = .{
            .uri = std.Uri.parse(url) catch |err| switch (err) {
                error.UnexpectedCharacter => return error.UrlMalformed,
                else => return err,
            },
        },
        .response_storage = .{ .dynamic = &weatherJson },
    }) catch |err| switch (err) {
        error.OutOfMemory => return error.OutOfMemory,
        error.UnknownHostName, error.TemporaryNameServerFailure, error.NameServerFailure => return error.InternetError,
        error.TlsInitializationFailed, error.CertificateBundleLoadFailure, error.TlsFailure, error.TlsAlert => return error.TlsError,
        else => return err,
    };
    if (res.status != .ok) {
        return error.SourceIsDown;
    }
    return try weatherJson.toOwnedSlice();
}
