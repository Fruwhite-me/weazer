const std = @import("std");

/// Data we take from Openmeteo(or you can input in "source" other source, but doesn't tested)
pub const data = struct {
    daily: ?struct {
        temperature_2m_max: ?[]f64,
        temperature_2m_min: ?[]f64,
        wind_speed_10m_max: ?[]f64,
        precipitation_probability_max: ?[]f64,
    } = null,
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
///
pub fn rawToJSON(comptime T: type, allocator: std.mem.Allocator, raw: []const u8) !std.json.Parsed(T) {
    const parsed = try std.json.parseFromSlice(T, allocator, raw, .{ .ignore_unknown_fields = true });
    return parsed;
}
