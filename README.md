# dvui-rotation-example

Minimal app to test output rotation in the dvui SDL3 backend. Pins the
StaffinityAI dvui fork; switch to the commented `.path = "../"` in
`build.zig.zon` to build against a local checkout.

```sh
zig build run
# start with a fixed rotation (clockwise degrees: 0, 90, 180, 270), ignoring the saved one
DVUI_SDL_ROTATION=90 zig build run
```

The backend does not persist the rotation. The app does, in `src/main.zig`:

- `backend.rotationSet(r)` changes it from the next frame on,
  `backend.rotationGet()` returns the value to save.
- `Rotation` is a plain enum, so it sits in the app's `Settings` struct and is
  written with `std.zon` to `settings.zon` in the current directory.
- `initFn` loads the settings and calls `rotationSet`, so the first frame is already rotated.

Check that clicks, slider drags and text input hit the right widgets in every rotation.
