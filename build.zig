const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dvui_dep = b.dependency("dvui", .{
        .target = target,
        .optimize = optimize,
        .backend = .sdl3,
        // The callbacks entry point (default on macOS/Windows) skips
        // rotationConfigure, so DVUI_SDL_ROTATION would be ignored there.
        .@"sdl3-callbacks" = false,
    });

    const exe = b.addExecutable(.{
        .name = "dvui-rotation-example",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "dvui", .module = dvui_dep.module("dvui_sdl3") }},
        }),
    });
    b.installArtifact(exe);

    const run = b.addRunArtifact(exe);
    run.step.dependOn(b.getInstallStep());
    run.addPassthruArgs();
    b.step("run", "Run the example").dependOn(&run.step);
}
