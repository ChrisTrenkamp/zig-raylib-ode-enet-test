const rl = @import("raylib");
const std = @import("std");
const enet = @cImport({
    @cInclude("enet/enet.h");
});
const ode = @cImport({
    @cInclude("ode/ode.h");
});

pub fn main() anyerror!void {
    const enetClient = enet.enet_host_create(null, 1, 2, 0, 0);
    defer enet.enet_host_destroy(enetClient);
    const odeWorld = ode.dWorldCreate();
    defer ode.dWorldDestroy(odeWorld);
    std.log.info("Hello\n", .{});

    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);

        rl.drawText("Congrats! You created your first window!", 190, 200, 20, .light_gray);
    }
}
