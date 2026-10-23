const std = @import("std");
const dvui = @import("dvui");

pub const dvui_app: dvui.App = .{
    .config = .{
        .options = .{
            .size = .{ .w = 800, .h = 480 },
            .min_size = .{ .w = 320, .h = 240 },
            .org = "dvui-examples",
            .app = "dvui-rotation-example",
            .title = "DVUI Rotation Example",
        },
    },
    .frameFn = frame,
};

pub const main = dvui.App.main;
pub const panic = dvui.App.panic;
pub const std_options: std.Options = .{
    .logFn = dvui.App.logFn,
};

var checked = false;
var slider: f32 = 0.5;
var clicks: u32 = 0;

fn frame() !dvui.App.Result {
    const backend = dvui.currentWindow().backend.impl;

    var box = dvui.box(@src(), .{ .dir = .vertical }, .{
        .gravity_x = 0.5,
        .gravity_y = 0.5,
        .padding = .all(16),
    });
    defer box.deinit();

    dvui.label(@src(), "Rotation: {d} degrees", .{backend.rotation.degrees()}, .{ .gravity_x = 0.5 });
    const size = dvui.windowRect();
    dvui.label(@src(), "Window: {d}x{d}", .{ size.w, size.h }, .{ .gravity_x = 0.5 });

    if (dvui.button(@src(), "Rotate 90 degrees", .{}, .{ .gravity_x = 0.5, .expand = .horizontal })) {
        backend.rotationTurn();
        // The backend applies the new rotation when the next frame starts.
        dvui.refresh(null, @src(), null);
    }

    if (dvui.button(@src(), "Click me", .{}, .{ .expand = .horizontal })) clicks += 1;
    dvui.label(@src(), "Clicks: {d}", .{clicks}, .{ .gravity_x = 0.5 });
    _ = dvui.checkbox(@src(), &checked, "Checkbox", .{});
    _ = dvui.slider(@src(), .{ .fraction = &slider }, .{ .expand = .horizontal });

    var entry = dvui.textEntry(@src(), .{}, .{ .expand = .horizontal });
    entry.deinit();

    return .ok;
}
