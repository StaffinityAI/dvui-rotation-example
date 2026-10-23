# dvui-rotation-example

Minimal app to test output rotation in the dvui SDL3 backend.

```sh
zig build run
# start with a fixed rotation (clockwise degrees: 0, 90, 180, 270)
DVUI_SDL_ROTATION=90 zig build run
# persist the rotation chosen with the button in $STATE_DIRECTORY/rotation
STATE_DIRECTORY=$PWD zig build run
```

Check that clicks, slider drags and text input hit the right widgets in every rotation.
