Status: done

Round 1 security review of issue #1 "Project skeleton", HEAD 2e6aeff.

VERDICT: NO BLOCKING ISSUES

## Critical
(none)

## Important
(none)

## Minor
- [S1-m1] general - GUT (addons/gut/) carries editor-only code that shells out (gui/RunExternally.gd: OS.execute / OS.execute_with_pipe on the Godot binary; gui/about.gd: OS.shell_open on link metadata) and test/ holds test scripts. None of it runs in the game today (no autoload; plugin is editor-only), but a future export would ship it unless filtered. export_presets.cfg is git-ignored, so the filter would not be versioned either. Suggested fix (for the later export-presets issue, out of scope here): exclude `addons/gut/*` and `test/*` in every export preset's exclude filter, and consider versioning export_presets.cfg (it holds no secrets unless signing credentials are put in it - keep those in env/editor settings).

## What I ran
- Upstream provenance: `git clone --depth 1 --branch v9.5.0 https://github.com/bitwes/Gut.git` -> tag resolves to 8255c6305761754748f9fd641da5fd8f51c1708a (matches implementer log); `diff -rq <upstream>/addons/gut addons/gut` -> no differences (byte-identical, incl. the .import/.uid files).
- grep sweep of addons/gut for network (HTTPRequest/HTTPClient/TCP/UDP/WebSocket), OS.execute/create_process/shell_open, Expression, str_to_var/bytes_to_var, file deletion: only editor GUI hits (above) and version_conversion.gd deleting GUT's own hard-coded user:// config files (guarded by begins_with('user://')). No network code.
- Reviewed project.godot, scenes/main/main.tscn, test/unit/test_project_settings.gd, test/integration/test_main_scene.gd: no file I/O, no user input parsing, no data-driven load paths (load() uses a constant), no autoloads, no secrets (grep for key/token/secret/password: none).
- Own worktree at 2e6aeff: import exit 0; `gdlint scenes scripts test` exit 0; `gdformat --check scenes scripts test` exit 0; GUT run exit 0, 8/8 tests passed, 11 asserts.
