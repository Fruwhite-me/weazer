const std = @import("std");

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

pub fn rawToJSON(allocator: std.mem.Allocator, raw_data: []const u8) !std.json.Parsed(data) {
    const parsed = try std.json.parseFromSlice(data, allocator, raw_data, .{ .ignore_unknown_fields = true });
    return parsed;
}
