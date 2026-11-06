extends GutTest
## Field scene: blocks with HP bars driven only by BlockField signals (spec #4, D-023).

const FIELD_SCENE_PATH: String = "res://scenes/field/field.tscn"

var _config: BalanceConfig
var _block_field: BlockField
var _scene: Control


func before_each() -> void:
	_config = BalanceConfig.load_default()
	_block_field = BlockField.new(_config)
	var packed: PackedScene = load(FIELD_SCENE_PATH) as PackedScene
	_scene = add_child_autofree(packed.instantiate()) as Control
	_scene.setup(_block_field)


func test_shows_a_block_with_a_full_hp_bar_per_slot() -> void:
	assert_eq(_scene.block_count(), 5, "five block nodes")
	if _scene.block_count() != 5:
		return
	for slot: int in 5:
		var block: Control = _scene.block_view(slot)
		var bar: ProgressBar = _scene.hp_bar(slot)
		assert_true(block.is_visible_in_tree(), "block %d visible" % slot)
		assert_true(bar.is_visible_in_tree(), "hp bar %d visible" % slot)
		assert_eq(bar.max_value, 10.0, "hp bar %d max" % slot)
		assert_eq(bar.value, 10.0, "hp bar %d value" % slot)


func test_damaging_slot_0_updates_only_its_hp_bar() -> void:
	assert_eq(_scene.block_count(), 5, "five block nodes")
	if _scene.block_count() != 5:
		return
	_block_field.damage(0, 3.0)
	assert_eq(_scene.hp_bar(0).value, 7.0, "slot 0 bar shows 7 hp")
	for slot: int in range(1, 5):
		assert_eq(_scene.hp_bar(slot).value, 10.0, "slot %d bar unchanged" % slot)


func test_broken_block_is_hidden_until_tick_respawns_it() -> void:
	assert_eq(_scene.block_count(), 5, "five block nodes")
	if _scene.block_count() != 5:
		return
	_block_field.damage(0, 10.0)
	assert_false(_scene.block_view(0).is_visible_in_tree(), "block 0 hidden when broken")
	assert_false(_scene.hp_bar(0).is_visible_in_tree(), "hp bar 0 hidden when broken")
	assert_true(_scene.block_view(1).is_visible_in_tree(), "block 1 still shown")
	_block_field.tick(0.25)
	assert_false(_scene.block_view(0).is_visible_in_tree(), "still hidden after 0.25 s")
	_block_field.tick(0.25)
	assert_true(_scene.block_view(0).is_visible_in_tree(), "block 0 back after 0.5 s")
	assert_true(_scene.hp_bar(0).is_visible_in_tree(), "hp bar 0 back after 0.5 s")
	assert_eq(_scene.hp_bar(0).max_value, _config.block_hp(1), "bar max is the new block's hp")
	assert_eq(_scene.hp_bar(0).value, _config.block_hp(1), "bar is full")


func test_field_scene_never_advances_time_itself() -> void:
	var nodes: Array[Node] = [_scene]
	nodes.append_array(_scene.find_children("*", "", true, false))
	for node: Node in nodes:
		assert_false(node.is_processing(), "%s does not process" % node.name)
		assert_false(node.is_physics_processing(), "%s does not physics-process" % node.name)
		var script: Script = node.get_script() as Script
		if script == null:
			continue
		var methods: Array[String] = []
		for method: Dictionary in script.get_script_method_list():
			methods.append(method["name"])
		assert_does_not_have(methods, "_process", "%s has no _process" % node.name)
		assert_does_not_have(methods, "_physics_process", "%s has no _physics_process" % node.name)
		if script is GDScript:
			assert_false(
				(script as GDScript).source_code.contains(".tick("),
				"%s never calls tick" % node.name
			)
