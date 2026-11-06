extends GutTest
## BlockField: blocks in fixed slots that break, respawn and get tougher (spec #4, D-014, D-015).

var _config: BalanceConfig
var _field: BlockField


func before_each() -> void:
	_config = BalanceConfig.load_default()
	_field = BlockField.new(_config)


func test_new_field_has_five_blocks_with_hp_10_and_gold_1() -> void:
	assert_eq(_field.slot_count(), 5, "slot count")
	assert_eq(_field.destroyed_count, 0, "destroyed count starts at 0")
	for slot: int in 5:
		assert_true(_field.has_block(slot), "slot %d has a block" % slot)
		assert_eq(_field.hp(slot), 10.0, "slot %d hp" % slot)
		assert_eq(_field.max_hp(slot), 10.0, "slot %d max hp" % slot)
		assert_eq(_field.gold(slot), 1.0, "slot %d gold" % slot)
