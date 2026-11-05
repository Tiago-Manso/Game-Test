extends GutTest
## Instantiates the main scene and checks its root node.

const MAIN_SCENE_PATH: String = "res://scenes/main/main.tscn"


func test_main_scene_root_is_control_named_main() -> void:
	var packed: PackedScene = load(MAIN_SCENE_PATH) as PackedScene
	assert_not_null(packed, "main scene loads as a PackedScene")
	if packed == null:
		return
	var root: Node = add_child_autofree(packed.instantiate())
	assert_true(root is Control, "root is a Control")
	assert_eq(root.name, &"Main")
