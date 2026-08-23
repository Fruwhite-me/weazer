const std = @import("std");

pub fn getRequest(allocator: std.mem.Allocator, url: []const u8) ![]u8 {
    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();
    var weatherJson = std.ArrayList(u8).init(allocator);
    errdefer weatherJson.deinit();

    const res = try client.fetch(.{
        .location = .{ .uri = try std.Uri.parse(url) },
        .response_storage = .{ .dynamic = &weatherJson },
    });
    if (res.status != .ok) {
        return error.NetworkError;
    } else {
        return weatherJson.toOwnedSlice();
    }
}
