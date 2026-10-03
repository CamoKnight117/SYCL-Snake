const std = @import("std");
const Io = std.Io;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const debug_io = Io.Threaded.global_single_threaded.io();

    // This is fine...
    std.debug.print("with init.io:\n", .{});
    doWorkWithSpinner(io);

    // This as well!
    std.debug.print("with single threaded io:\n", .{});
    doWorkWithSpinner(debug_io);
}

fn doWorkWithSpinner(io: Io) void {
    var spinner_future: ?Io.Future(Io.Cancelable!void) = io.concurrent(
        doSpinnerLoop,
        .{io},
    ) catch blk: {
        std.debug.print("WARNING: spinner not available\n", .{});
        break :blk null;
    };
    var work_future = io.async(doABunchOfWork, .{});

    const answer = work_future.await(io);
    if (spinner_future) |*future| future.cancel(io) catch {};

    std.debug.print("answer: {}\n", .{answer});
}

fn doSpinnerLoop(io: Io) Io.Cancelable!void {
    defer std.debug.print("\r \r", .{});
    var i: u64 = 0;
    while (true) : (i += 1) {
        std.debug.print("\r{c}", .{"\\|/-"[i % 4]});
        try io.sleep(.fromMilliseconds(300), .awake);
    }
}

fn doABunchOfWork() u64 {
    var result: u64 = 0;
    for (0..100_000) |i| {
        for (0..100_000) |j| {
            if (@popCount(i) == @popCount(j)) {
                result += 1;
            }
        }
    }
    return result;
}
