const std = @import("std");
const request = @import("request.zig");
const parce = @import("json_parce.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const url = ("https://api.open-meteo.com/v1/forecast?latitude=64.1355&longitude=-21.8954&daily=temperature_2m_max,temperature_2m_min,wind_speed_10m_max,precipitation_probability_max&current=temperature_2m,precipitation,wind_speed_10m&timezone=auto");
    const raw_data = try request.getRequest(allocator, url);
    const json = try parce.rawToJSON(allocator, raw_data);
    const weather = json.value;
    const temperature_now = weather.current.temperature_2m;
    const precipitation_now = weather.current.precipitation;
    const wind_now = weather.current.wind_speed_10m;

    std.debug.print("Weather: \n", .{});
    std.debug.print("\n", .{});
    std.debug.print("current: \n", .{});
    std.debug.print("temperature: {d:.1} \n", .{temperature_now});
    std.debug.print("precipitation: {d:.1} \n", .{precipitation_now});
    std.debug.print("wind: {d:.1} \n", .{wind_now});
}
