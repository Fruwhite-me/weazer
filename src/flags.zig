const std = @import("std");
pub const CliArg = struct {
    lat: ?[]u8 = null,
    lon: ?[]u8 = null,
};

pub fn parseArg(allocator: std.mem.Allocator) !CliArg {
    var flags = try std.process.argsWithAllocator(allocator);
    _ = flags.skip();
    var res = CliArg{};
    while (flags.next()) |args| {
        if (std.mem.eql(u8, args, "--lat")) {
            const val = flags.next() orelse return error.InputNothing;
            if (std.mem.startsWith(u8, val, "--")) return error.InputNothing;
            res.lat = try allocator.dupe(u8, val);
        } else if (std.mem.eql(u8, args, "--lon")) {
            const val = flags.next() orelse return error.InputNothing;
            if (std.mem.startsWith(u8, val, "--")) return error.InputNothing;
            res.lon = try allocator.dupe(u8, val);
        } else {
            return error.UnknownKey;
        }
    }
    return res;
}
