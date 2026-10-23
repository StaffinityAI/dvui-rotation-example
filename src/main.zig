const std = @import("std");
const dvui = @import("dvui");

const Rotation = dvui.backend.Rotation;

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
    .initFn = init,
    .frameFn = frame,
};

pub const main = dvui.App.main;
pub const panic = dvui.App.panic;
pub const std_options: std.Options = .{
    .logFn = dvui.App.logFn,
};

/// Everything the app keeps across runs. The backend stores nothing, so the
/// rotation lives here next to the app's other settings.
const Settings = struct {
    rotation: Rotation = .none,
};

const settings_file = "settings.zon";

var checked = false;
var slider: f32 = 0.5;
var clicks: u32 = 0;

fn init(win: *dvui.Window) !void {
    const backend = win.backend.impl;

    // DVUI_SDL_ROTATION is a one-off override, so it wins over the saved choice.
    if (dvui.App.main_init) |main_init| {
        if (main_init.environ_map.get("DVUI_SDL_ROTATION") != null) return;
    }

    const settings = settingsLoad(backend.io) orelse return;
    backend.rotationSet(settings.rotation);
}

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
        backend.rotationSet(backend.rotationGet().turned());
        settingsSave(backend.io, .{ .rotation = backend.rotationGet() });
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

fn settingsLoad(io: std.Io) ?Settings {
    var buf: [256]u8 = undefined;
    const text = std.Io.Dir.cwd().readFile(io, settings_file, buf[0 .. buf.len - 1]) catch return null;
    buf[text.len] = 0;
    var diag: std.zon.parse.Diagnostics = undefined;
    return std.zon.parse.fromSliceNoAlloc(Settings, .{
        .gpa = dvui.currentWindow().arena(),
        .arena = dvui.currentWindow().arena(),
        .source = buf[0..text.len :0],
        .diagnostics = &diag,
    }) catch null;
}

fn settingsSave(io: std.Io, settings: Settings) void {
    var buf: [256]u8 = undefined;
    var writer: std.Io.Writer = .fixed(&buf);
    std.zon.stringify.serialize(settings, .{}, &writer) catch return;
    std.Io.Dir.cwd().writeFile(io, .{ .sub_path = settings_file, .data = writer.buffered() }) catch |err|
        std.log.warn("cannot save " ++ settings_file ++ ": {t}", .{err});
}
