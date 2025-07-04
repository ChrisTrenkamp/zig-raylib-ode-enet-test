const std = @import("std");
const enet_lib = @import("deps/enet/build-enet.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const exe = b.addExecutable(.{
        .name = "raylib_test",
        .root_module = exe_mod,
        //.use_lld = false, // There are warnings about linking to the OpenGL library.  This suppresses them.  Is this a bug in Zig?
    });

    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
    });
    const raylib = raylib_dep.module("raylib");
    const raygui = raylib_dep.module("raygui");
    const raylib_artifact = raylib_dep.artifact("raylib");
    exe.linkLibrary(raylib_artifact);
    exe.root_module.addImport("raylib", raylib);
    exe.root_module.addImport("raygui", raygui);

    const ode_dep = b.dependency("ode", .{
        .target = target,
        .optimize = optimize,
        .with_opcode = b.option(
            bool,
            "ode-with-opcode",
            "Build ODE with the old OPCODE trimesh-trimesh collider.",
        ) orelse false,
    });
    const ode_headers = ode_dep.path("include");
    exe.addIncludePath(ode_headers);
    //ode_dep.artifact("ode").addIncludePath(.{ .dependency = .{ .dependency = ode_dep, .sub_path = "" } });

    enet_lib.build(exe);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
