const std = @import("std");

const ENET_SRC = "deps/enet/src/";

pub fn build(
    exe: *std.Build.Step.Compile,
) void {
    exe.root_module.addCMacro("HAS_FCNTL", "1");
    exe.root_module.addCMacro("HAS_POLL", "1");
    exe.root_module.addCMacro("HAS_GETNAMEINFO", "1");
    exe.root_module.addCMacro("HAS_GETADDRINFO", "1");
    exe.root_module.addCMacro("HAS_GETHOSTBYNAME_R", "1");
    exe.root_module.addCMacro("HAS_GETHOSTBYADDR_R", "1");
    exe.root_module.addCMacro("HAS_INET_PTON", "1");
    exe.root_module.addCMacro("HAS_INET_NTOP", "1");
    exe.root_module.addCMacro("HAS_MSGHDR_FLAGS", "1");
    exe.root_module.addCMacro("HAS_SOCKLEN_T", "1");

    exe.addIncludePath(.{ .cwd_relative = ENET_SRC ++ "include" });

    exe.addCSourceFiles(.{ .files = &[_][]const u8{
        ENET_SRC ++ "callbacks.c",
        ENET_SRC ++ "compress.c",
        ENET_SRC ++ "host.c",
        ENET_SRC ++ "list.c",
        ENET_SRC ++ "packet.c",
        ENET_SRC ++ "peer.c",
        ENET_SRC ++ "protocol.c",
        ENET_SRC ++ "unix.c",
        ENET_SRC ++ "win32.c",
    } });

    exe.linkLibC();
}
