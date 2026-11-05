extends GutTest
## Checks the display, input and run settings in project.godot (D-007, D-022).

const VIEWPORT_WIDTH: int = 540
const VIEWPORT_HEIGHT: int = 960
const MAIN_SCENE_PATH: String = "res://scenes/main/main.tscn"


func test_viewport_is_540_by_960() -> void:
	assert_eq(ProjectSettings.get_setting("display/window/size/viewport_width"), VIEWPORT_WIDTH)
	assert_eq(ProjectSettings.get_setting("display/window/size/viewport_height"), VIEWPORT_HEIGHT)


func test_window_is_resizable() -> void:
	assert_true(ProjectSettings.get_setting("display/window/size/resizable"))


func test_stretch_mode_is_canvas_items() -> void:
	assert_eq(ProjectSettings.get_setting("display/window/stretch/mode"), "canvas_items")


func test_stretch_aspect_is_keep_width() -> void:
	assert_eq(ProjectSettings.get_setting("display/window/stretch/aspect"), "keep_width")


func test_handheld_orientation_is_portrait() -> void:
	assert_eq(
		ProjectSettings.get_setting("display/window/handheld/orientation"),
		DisplayServer.SCREEN_PORTRAIT
	)


func test_mouse_emulates_touch() -> void:
	assert_true(ProjectSettings.get_setting("input_devices/pointing/emulate_touch_from_mouse"))


func test_main_scene_is_main_tscn() -> void:
	assert_eq(_main_scene_path(), MAIN_SCENE_PATH)


## The editor may store the main scene as a uid:// reference; compare as a path.
func _main_scene_path() -> String:
	var setting: String = ProjectSettings.get_setting("application/run/main_scene", "")
	if setting.begins_with("uid://"):
		return ResourceUID.get_id_path(ResourceUID.text_to_id(setting))
	return setting
