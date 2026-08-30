const std = @import("std");
const parse = @import("json_parse.zig");

/// Check existence of dir and file of configuration, if doesn't exist - create with stockConfig
pub fn configuration(allocator: std.mem.Allocator) !std.json.Parsed(parse.rawConfig) {
    var path: []const u8 = undefined;

    if (std.process.getEnvVarOwned(allocator, "XDG_CONFIG_HOME")) |xdg_dir| {
        path = try std.fs.path.join(allocator, &[_][]const u8{ xdg_dir, "weazer" });
    } else |_| {
        const home = std.process.getEnvVarOwned(allocator, "HOME") catch |err| switch (err) {
            error.EnvironmentVariableNotFound => return error.NoHome,
            error.OutOfMemory => return error.OutOfMemory,
            else => return error.Impossible,
        };
        path = try std.fs.path.join(allocator, &[_][]const u8{ home, ".config/weazer" });
    }

    std.fs.makeDirAbsolute(path) catch |err| switch (err) {
        error.PathAlreadyExists => {},
        else => return err,
    };

    var dir = try std.fs.openDirAbsolute(path, .{});
    defer dir.close();
    const file = try openOrCreateFile(dir);
    defer file.close();

    const config = try std.fs.File.readToEndAlloc(file, allocator, 1024 * 1024);

    const configuration_data = parse.rawToJSON(parse.rawConfig, allocator, config) catch |err| switch (err) {
        error.SyntaxError, error.UnexpectedToken, error.UnexpectedEndOfInput, error.InvalidCharacter => return error.SyntaxMalformed,
        error.MissingField => return error.SyntaxMissing, //here I change name from missing field, because, maybe in future will be other requried fields
        else => return error.Impossible,
    };
    return configuration_data;
}

pub fn url(allocator: std.mem.Allocator, lat: []const u8, lon: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "https://api.open-meteo.com/v1/forecast?latitude={s}&longitude={s}&current=temperature_2m,wind_speed_10m,precipitation", .{ lat, lon });
}

fn openOrCreateFile(dir: std.fs.Dir) !std.fs.File {
    return dir.openFile("config.json", .{}) catch |err| switch (err) {
        error.FileNotFound => {
            const newFile = try dir.createFile("config.json", .{ .read = true });
            errdefer newFile.close();
            //TODO: when realise flags - change this shit to something else
            try newFile.writeAll(parse.stockConfig);
            try newFile.seekTo(0);
            return newFile;
        },
        else => {
            return err;
        },
    };
}
