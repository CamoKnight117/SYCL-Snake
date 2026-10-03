const std = @import("std");
const Io = std.Io;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const debug_io = Io.Threaded.global_single_threaded.io();

    {
        var future = io.async(sleepy, .{ io, 5 });
        try io.sleep(.fromSeconds(2), .awake);
        try future.cancel(io);
    }

    {
        var future = debug_io.async(sleepy, .{ debug_io, 5 });
        try debug_io.sleep(.fromSeconds(2), .awake);
        try future.cancel(debug_io);
    }

    // How can we cancel one of the invocations of sleepy?
    // What happens if you cancel the debug_io invocation of sleepy?
    // Any difference using async vs concurrent?
}

fn sleepy(io: Io, secs: i64) !void {
    std.log.info("sleepy({}) start", .{secs});
    io.sleep(.fromSeconds(secs), .awake) catch |err| {
        std.log.info("sleepy({}) error: {t}", .{ secs, err });
        return err;
    };
    std.log.info("sleepy({}) done", .{secs});
}
