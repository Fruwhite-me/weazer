const std = @import("std");
const io = std.io;
const request = @import("request.zig");
const parce = @import("json_parse.zig");

pub fn main() !void {
    // Here allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // Here app take url and fetch data from server
    const urlJson = try parce.configuration(allocator);
    const url = urlJson.value.source;
    const raw_data = try request.getRequest(allocator, url);

    //here defined variables
    const json = try parce.rawToJSON(parce.data, allocator, raw_data);
    const weather = json.value;
    const stdout = std.io.getStdOut().writer();
    const temperature_now = weather.current.temperature_2m;
    const temperature_units = weather.current_units.temperature_2m;
    const precipitation_now = weather.current.precipitation;
    const precipitation_units = weather.current_units.precipitation;
    const wind_now = weather.current.wind_speed_10m;
    const wind_units = weather.current_units.wind_speed_10m;

    // Finally output
    try stdout.print("Weather: \n", .{});
    try stdout.print("\n", .{});
    try stdout.print("current: \n", .{});
    try stdout.print("temperature: {d:.1} {s} \n", .{ temperature_now, temperature_units });
    try stdout.print("precipitation: {d:.1} {s} \n", .{ precipitation_now, precipitation_units });
    try stdout.print("wind: {d:.1} {s} \n", .{ wind_now, wind_units });
}
