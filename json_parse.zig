const std = @import("std");
const main = @import("main.zig");

pub const data = struct {
    daily: struct {
        temperature_2m_max: []f64,
        temperature_2m_min: []f64,
        wind_speed_10m_max: []f64,
        precipitation_probability_max: []f64,
    },
    current: struct {
        temperature_2m: f64,
        precipitation: f64,
        wind_speed_10m: f64,
    },
    current_units: struct {
        temperature_2m: []u8,
        wind_speed_10m: []u8,
        precipitation: []u8,
    },
};
pub const stockConfig =
    \\ {"source":"https://api.open-meteo.com/v1/forecast?latitude=64.1355&longitude=-21.8954&daily=temperature_2m_max,temperature_2m_min,wind_speed_10m_max,precipitation_probability_max&current=temperature_2m,precipitation,wind_speed_10m&timezone=auto"}
;
pub const rawConfig = struct {
    source: []const u8,
};
/// Read raw slice and transform to json
pub fn rawToJSON(comptime T: type, allocator: std.mem.Allocator, raw: []const u8) !std.json.Parsed(T) {
    const parsed = try std.json.parseFromSlice(T, allocator, raw, .{ .ignore_unknown_fields = true });
    return parsed;
}
/// TODO: add dynamically resolve $HOME(ssry for hardcode)
///
/// Check existence of dir and file, if doesn't exist - create with stockConfig
pub fn configuration(allocator: std.mem.Allocator) !std.json.Parsed(rawConfig) {
    const home = try std.process.getEnvVarOwned(allocator, "HOME");
    const path = try std.fs.path.join(allocator, &[_][]const u8{ home, ".config/weazer" });

    std.fs.makeDirAbsolute(path) catch |err| switch (err) {
        error.PathAlreadyExists => {},
        else => return err,
    };
    var dir = try std.fs.openDirAbsolute(path, .{});
    defer dir.close();
    const file = dir.openFile("config.json", .{}) catch |err| switch (err) {
        error.FileNotFound => blk: {
            std.debug.print("config created, or something broken\n", .{});
            const newFile = try dir.createFile("config.json", .{ .read = true });
            try newFile.writeAll(stockConfig);
            try newFile.seekTo(0);
            break :blk newFile;
        },
        else => return err,
    };
    defer file.close();
    const config = try std.fs.File.readToEndAlloc(file, allocator, 1024 * 1024);
    const coordinates = try rawToJSON(rawConfig, allocator, config);
    return coordinates;
}
