const rl = @import("raylib");
const rg = @import("raygui");
const std = @import("std");
const game = @import("game.zig");
const enet = @cImport({
    @cInclude("enet/enet.h");
});
const ode = @cImport({
    @cInclude("ode/ode.h");
});

pub const GameState = enum {
    MAIN_MENU,
    PLAYING_GAME,
    PAUSED_GAME,
};

pub const MonitorInfo = struct {
    width: i32,
    height: i32,
};

pub const GameSettings = struct {
    exit: bool,
    game_state: GameState,
    screen_width: i32,
    screen_height: i32,
    windowed_width: i32,
    windowed_height: i32,
    windowed_pos_x: i32,
    windowed_pos_y: i32,
    monitor_info: []MonitorInfo,

    pub fn width_pc(self: GameSettings, pc: f32) f32 {
        return @as(f32, @floatFromInt(self.screen_width)) * pc;
    }

    pub fn height_pc(self: GameSettings, pc: f32) f32 {
        return @as(f32, @floatFromInt(self.screen_height)) * pc;
    }

    pub fn right_align_pc(self: GameSettings, pc: f32) f32 {
        const w = width_pc(self, pc);
        return @as(f32, @floatFromInt(self.screen_width)) - w;
    }
};

pub fn main() anyerror!void {
    try game.initEnet();
    defer game.deinitEnet();

    try runClient("127.0.0.1");
}

pub fn runClient(addr: []const u8) anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const client = enet.enet_host_create(null, 1, 2, 0, game.MAX_UDP_PACKET_SIZE * game.GAME_TICKS_PER_SECOND);

    if (client == null) {
        return game.GameError.NetworkHostCreateFailed;
    }

    defer enet.enet_host_destroy(client);

    var address = enet.ENetAddress{};

    if (enet.enet_address_set_host(&address, try allocator.dupeZ(u8, addr)) != 0) {
        return game.GameError.NetworkInitFailed;
    }

    address.port = game.SERVER_PORT;

    const peer = enet.enet_host_connect(client, &address, 2, 0);

    if (peer == null) {
        return game.GameError.NetworkHostConnectFailed;
    }

    var event = enet.ENetEvent{};

    if (enet.enet_host_service(client, &event, 10000) <= 0) {
        return game.GameError.NetworkHostConnectEventFailed;
    }

    var settings = GameSettings{
        .exit = false,
        .game_state = GameState.MAIN_MENU,
        .screen_width = 800,
        .screen_height = 600,
        .windowed_width = 800,
        .windowed_height = 600,
        .windowed_pos_x = 0,
        .windowed_pos_y = 0,
        .monitor_info = undefined,
    };

    rl.setConfigFlags(.{
        .window_resizable = true,
    });
    rl.initWindow(settings.screen_width, settings.screen_height, "Zig/Raylib/ODE/enet test");
    defer rl.closeWindow();

    settings.monitor_info = getMonitors(allocator);

    rl.setTargetFPS(60);

    defer resetFullscreenSettings();

    while (!settings.exit) {
        switch (settings.game_state) {
            GameState.MAIN_MENU => {
                drawMainMenu(&settings, peer);
            },
            GameState.PLAYING_GAME => {},
            GameState.PAUSED_GAME => {},
        }

        settings.exit = settings.exit or rl.windowShouldClose();
    }
}

fn getMonitors(allocator: std.mem.Allocator) []MonitorInfo {
    const monitor_count = rl.getMonitorCount();

    if (monitor_count == 0) {
        std.log.err("Unable to detect a monitor.\n", .{});
        std.process.exit(1);
    }

    var monitor_info = allocator.alloc(MonitorInfo, @intCast(monitor_count)) catch unreachable;

    for (0..monitor_info.len) |i| {
        monitor_info[i].width = rl.getMonitorWidth(@intCast(i));
        monitor_info[i].height = rl.getMonitorHeight(@intCast(i));
    }

    return monitor_info;
}

fn resetFullscreenSettings() void {
    if (rl.isWindowFullscreen()) {
        rl.toggleFullscreen();
    }
}

fn drawMainMenu(settings: *GameSettings, peer: [*c]enet.struct__ENetPeer) void {
    rl.beginDrawing();
    defer rl.endDrawing();
    rl.clearBackground(.white);

    settings.screen_width = rl.getScreenWidth();
    settings.screen_height = rl.getScreenHeight();

    if (rg.button(.{ .width = settings.width_pc(0.1), .height = settings.height_pc(0.1), .x = settings.width_pc(0.01), .y = settings.height_pc(0.01) }, "Toggle Fullscreen")) {
        const window_pos = rl.getWindowPosition();

        rl.toggleFullscreen();

        if (rl.isWindowFullscreen()) {
            const monitor: usize = @intCast(rl.getCurrentMonitor());

            settings.windowed_width = settings.screen_width;
            settings.windowed_height = settings.windowed_height;
            settings.windowed_pos_x = @intFromFloat(window_pos.x);
            settings.windowed_pos_y = @intFromFloat(window_pos.y);
            settings.screen_width = settings.monitor_info[monitor].width;
            settings.screen_height = settings.monitor_info[monitor].height;

            rl.setWindowSize(settings.screen_width, settings.screen_height);
        } else {
            settings.screen_width = settings.windowed_width;
            settings.screen_height = settings.windowed_height;

            rl.setWindowSize(settings.screen_width, settings.screen_height);
            rl.setWindowPosition(settings.windowed_pos_x, settings.windowed_pos_y);
        }
    }

    if (rg.button(.{ .width = settings.width_pc(0.1), .height = settings.height_pc(0.1), .x = settings.right_align_pc(0.11), .y = settings.height_pc(0.01) }, "Exit")) {
        settings.exit = true;
    }

    if (rg.button(.{ .width = settings.width_pc(0.1), .height = settings.height_pc(0.1), .x = settings.right_align_pc(0.11), .y = settings.height_pc(0.11) }, "Foo")) {
        const payload = "packet";
        const packet = enet.enet_packet_create(payload, payload.len, enet.ENET_PACKET_FLAG_RELIABLE);
        const send_err = enet.enet_peer_send(peer, 0, packet);
        if (send_err != 0) {
            std.log.err("Failed to send packet: {}", .{send_err});
        }
    }
}
