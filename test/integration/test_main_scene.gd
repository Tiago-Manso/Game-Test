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


func test_main_scene_contains_the_field_in_its_upper_part() -> void:
	var packed: PackedScene = load(MAIN_SCENE_PATH) as PackedScene
	var root: Control = add_child_autofree(packed.instantiate()) as Control
	var field: Control = root.get_node_or_null("Field") as Control
	assert_not_null(field, "Main has a Field child")
	if field == null:
		return
	assert_eq(field.scene_file_path, "res://scenes/field/field.tscn", "Field is the field scene")
	assert_lte(field.anchor_bottom, 0.5, "field stays in the upper half")
