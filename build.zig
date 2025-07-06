const std = @import("std");
const enet_lib = @import("deps/enet/build-enet.zig");
const ode_lib = @import("deps/ode/build-ode.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
        .linux_display_backend = .X11, // raygui has issues with wayland.  Toggling between fullscreen messes up the UI rendering.  Use X11 for now.
    });
    const raylib = raylib_dep.module("raylib");
    const raygui = raylib_dep.module("raygui");
    const raylib_artifact = raylib_dep.artifact("raylib");

    {
        const client_server_mod = b.createModule(.{
            .root_source_file = b.path("src/client_and_server.zig"),
            .target = target,
            .optimize = optimize,
        });
        const client_server_exe = b.addExecutable(.{
            .name = "client_server",
            .root_module = client_server_mod,
            .use_lld = optimize == .Debug,
        });
        client_server_exe.linkLibrary(raylib_artifact);
        client_server_exe.root_module.addImport("raylib", raylib);
        client_server_exe.root_module.addImport("raygui", raygui);

        ode_lib.build(client_server_exe, target, optimize, .{});
        enet_lib.build(client_server_exe, target);

        b.installArtifact(client_server_exe);

        const run_cmd = b.addRunArtifact(client_server_exe);
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);
    }

    {
        const client_mod = b.createModule(.{
            .root_source_file = b.path("src/client.zig"),
            .target = target,
            .optimize = optimize,
        });
        const client_exe = b.addExecutable(.{
            .name = "client",
            .root_module = client_mod,
            .use_lld = optimize == .Debug,
        });
        client_exe.linkLibrary(raylib_artifact);
        client_exe.root_module.addImport("raylib", raylib);
        client_exe.root_module.addImport("raygui", raygui);

        ode_lib.build(client_exe, target, optimize, .{});
        enet_lib.build(client_exe, target);

        b.installArtifact(client_exe);
    }

    {
        const server_mod = b.createModule(.{
            .root_source_file = b.path("src/server.zig"),
            .target = target,
            .optimize = optimize,
        });
        const server_exe = b.addExecutable(.{
            .name = "server",
            .root_module = server_mod,
            .use_lld = optimize == .Debug,
        });
        server_exe.linkLibrary(raylib_artifact);
        server_exe.root_module.addImport("raylib", raylib);
        server_exe.root_module.addImport("raygui", raygui);

        ode_lib.build(server_exe, target, optimize, .{});
        enet_lib.build(server_exe, target);

        b.installArtifact(server_exe);
    }
}
