const std = @import("std");
const game = @import("game.zig");
const enet = @cImport({
    @cInclude("enet/enet.h");
});

pub const StopSignal = std.atomic.Value(bool);

pub fn main() anyerror!void {
    try game.initEnet();
    defer game.deinitEnet();

    const host = try createServer(enet.ENET_HOST_ANY);
    defer enet.enet_host_destroy(host);

    var stop_signal = StopSignal.init(true);
    try runServer(host, &stop_signal);
}

pub fn createServer(host_listen: u16) anyerror![*c]enet.struct__ENetHost {
    const address = enet.ENetAddress{
        .host = host_listen,
        .port = @as(c_short, game.SERVER_PORT),
    };

    const host = enet.enet_host_create(&address, 1000, 2, game.MAX_UDP_PACKET_SIZE * game.GAME_TICKS_PER_SECOND, 0);

    if (host == null) {
        return game.GameError.NetworkHostCreateFailed;
    }

    return host;
}

pub fn runServer(host: [*c]enet.struct__ENetHost, stop_signal: *StopSignal) anyerror!void {
    var event = enet.ENetEvent{};

    while (stop_signal.load(std.builtin.AtomicOrder.unordered)) {
        if (enet.enet_host_service(host, &event, 1000) > 0) {
            switch (event.type) {
                enet.ENET_EVENT_TYPE_CONNECT => {
                    std.log.info("client connected", .{});
                },
                else => {
                    std.log.info("unknown packet {}", .{event});
                },
            }
        }
    }

    std.log.info("server closed", .{});
}
