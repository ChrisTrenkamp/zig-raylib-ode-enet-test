const std = @import("std");
const server = @import("server.zig");
const client = @import("client.zig");
const game = @import("game.zig");
const enet = @cImport({
    @cInclude("enet/enet.h");
});

pub fn main() anyerror!void {
    try game.initEnet();
    defer game.deinitEnet();

    const host = try server.createServer(enet.ENET_HOST_ANY);
    defer enet.enet_host_destroy(host);

    var stop_signal = server.StopSignal.init(true);

    const server_thread = try std.Thread.spawn(.{}, server.runServer, .{ host, &stop_signal });
    try client.runClient("127.0.0.1");

    stop_signal.store(false, std.builtin.AtomicOrder.unordered);
    server_thread.join();
}
