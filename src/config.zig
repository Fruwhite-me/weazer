const std = @import("std");
const parse = @import("json_parse.zig");

/// Check existence of dir and file of configuration, if doesn't exist - create with stockConfig
pub fn configuration(allocator: std.mem.Allocator) !std.json.Parsed(parse.rawConfig) {
    var path: []u8 = undefined;
    // TODO: add support here for mac and w*ndows(bookmark)
    if (std.process.getEnvVarOwned(allocator, "XDG_CONFIG_HOME")) |xdgDir| {
        path = try std.fs.path.join(allocator, &[_][]const u8{ xdgDir, "weazer" });
    } else |_| {
        const home = std.process.getEnvVarOwned(allocator, "HOME") catch |err| switch (err) {
            error.EnvironmentVariableNotFound => return error.NoHome,
            error.OutOfMemory => return error.OutOfMemory,
            error.InvalidWtf8 => return error.Imposible,
        };
        path = try std.fs.path.join(allocator, &[_][]const u8{ home, ".config/weazer" });
    }

    std.fs.makeDirAbsolute(path) catch |err| switch (err) {
        error.PathAlreadyExists => {},
        else => return error.Imposible,
    };

    var dir = try std.fs.openDirAbsolute(path, .{});
    defer dir.close();

    const file = dir.openFile("config.json", .{}) catch |err| switch (err) {
        error.FileNotFound => blk: {
            std.debug.print("config created, change acсording to README\n \n", .{});
            const newFile = try dir.createFile("config.json", .{ .read = true });
            //TODO: when realise flags - change this shit to something else
            try newFile.writeAll(parse.stockConfig);
            try newFile.seekTo(0);
            break :blk newFile;
        },
        else => return err,
    };
    defer file.close();

    const config = try std.fs.File.readToEndAlloc(file, allocator, 1024 * 1024);

    const configurationData = parse.rawToJSON(parse.rawConfig, allocator, config) catch |err| switch (err) {
        error.SyntaxError, error.UnexpectedToken, error.UnexpectedEndOfInput, error.InvalidCharacter => return error.SyntaxMalformed,
        error.MissingField => return error.SyntaxMissing, //here I change name from missing field, because, maybe in furure will be other reqaried fields
        else => return error.Imposible,
    };
    return configurationData;
}
