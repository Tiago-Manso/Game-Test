# art/

Blender source files (`.blend`). Godot ignores this folder (`.gdignore`).

Export the results into the Godot project and commit both:

- 2D sprites / animations: render to PNG sprite sheets in `assets/sprites/<name>/`.
- 3D assets (if ever needed): export glTF binary (`.glb`) to `assets/models/<name>/`.

Keep the same `<name>` for the source and its export, e.g.
`art/player.blend` -> `assets/sprites/player/player_run.png`.
The implementation loop never opens Blender; it only uses the exported files.
