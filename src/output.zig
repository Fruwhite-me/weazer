const std = @import("std");
const parse = @import("json_parse.zig").data;
const stdout = std.io.getStdOut().writer();
const width = 25; // temp

pub fn output(weather: parse, layoutConf: []const []const u8) !void {
    const temperature_now = weather.current.temperature_2m;
    const temperature_units = weather.current_units.temperature_2m;
    const precipitation_now = weather.current.precipitation;
    const precipitation_units = weather.current_units.precipitation;
    const wind_now = weather.current.wind_speed_10m;
    const wind_units = weather.current_units.wind_speed_10m;

    const widget = enum {
        high_border,
        title,
        separator,
        current_temp,
        current_precipitation,
        current_wind,
        low_border,
    };

    for (layoutConf) |raw| {
        const item = std.meta.stringToEnum(widget, raw) orelse continue;
        switch (item) {
            .high_border => try stdout.print("┌--------------------------┐\n", .{}),
            .title => try stdout.print("|Weather                   |\n", .{}),
            .separator => try stdout.print("|--------------------------|\n", .{}),
            .current_temp => try preparedLine(color.red, "temperature", temperature_now, temperature_units),
            .current_wind => try preparedLine(color.cyan, "wind", wind_now, wind_units),
            .current_precipitation => try preparedLine(color.blue, "precipitation", precipitation_now, precipitation_units),
            .low_border => try stdout.print("└--------------------------┘\n", .{}),
        }
    }
}

fn preparedLine(
    colors: []const u8,
    label: []const u8,
    val: f64,
    unit: []const u8,
) !void {
    var val_buf: [32]u8 = undefined;
    const val_str = try std.fmt.bufPrint(&val_buf, "{d:.1}{s}", .{ val, unit });
    const val_visible_len = try std.unicode.utf8CountCodepoints(val_str);
    const visible_len = label.len + 2 + val_visible_len;

    try stdout.print("|{s}{s} \x1b[0m: {s}", .{ colors, label, val_str });
    if (width > visible_len) {
        const space_needed = width - visible_len;
        for (0..space_needed) |_| {
            try stdout.print(" ", .{});
        }
    }
    try stdout.print("|\n", .{});
}

pub const color = struct {
    pub const black = "\x1b[30m";
    pub const red = "\x1b[31m";
    pub const green = "\x1b[32m";
    pub const yellow = "\x1b[33m";
    pub const blue = "\x1b[34m";
    pub const magenta = "\x1b[35m";
    pub const cyan = "\x1b[36m";
    pub const white = "\x1b[37m";
};
