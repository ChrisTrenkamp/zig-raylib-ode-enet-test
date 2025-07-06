const std = @import("std");
const enet = @cImport({
    @cInclude("enet/enet.h");
});

pub const SERVER_PORT: u16 = 6969;
pub const MAX_UDP_PACKET_SIZE = 500;
pub const GAME_TICKS_PER_SECOND = 30;

pub const GameError = error{
    NetworkInitFailed,
    NetworkHostCreateFailed,
    NetworkHostConnectFailed,
    NetworkHostConnectEventFailed,
};

pub fn initEnet() anyerror!void {
    const init_err = enet.enet_initialize();

    if (init_err != 0) {
        std.log.err("Failed to initialize enet.  Error code: {}", .{init_err});
        return GameError.NetworkInitFailed;
    }
}

pub fn deinitEnet() void {
    enet.enet_deinitialize();
}
