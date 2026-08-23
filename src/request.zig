const std = @import("std");

pub fn getRequest(allocator: std.mem.Allocator, url: []const u8) ![]u8 {
    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();
    var weather_json = std.ArrayList(u8).init(allocator);
    errdefer weather_json.deinit();
    _ = try client.fetch(.{
        .location = .{ .uri = try std.Uri.parse(url) },
        .response_storage = .{ .dynamic = &weather_json },
    });
    return weather_json.toOwnedSlice();
}
