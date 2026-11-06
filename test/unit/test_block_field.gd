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


func test_damage_below_hp_lowers_hp_and_emits_block_damaged() -> void:
	watch_signals(_field)
	_field.damage(1, 3.0)
	assert_eq(_field.hp(1), 7.0, "hp after 3 damage")
	assert_true(_field.has_block(1), "block survives")
	assert_signal_emit_count(_field, "block_damaged", 1)
	assert_signal_emitted_with_parameters(_field, "block_damaged", [1, 7.0])
	assert_signal_not_emitted(_field, "block_broken")
	assert_eq(_field.destroyed_count, 0, "nothing destroyed")


func test_damage_reaching_zero_breaks_the_block_once() -> void:
	watch_signals(_field)
	_field.damage(2, 4.0)
	_field.damage(2, 6.0)
	assert_false(_field.has_block(2), "slot 2 is empty")
	assert_eq(_field.destroyed_count, 1, "destroyed count")
	assert_signal_emit_count(_field, "block_broken", 1)
	assert_signal_emitted_with_parameters(_field, "block_broken", [2, 1.0])
	assert_signal_emit_count(_field, "block_damaged", 1, "only the first, non-breaking hit")


func test_overkill_breaks_the_block_and_spares_the_others() -> void:
	watch_signals(_field)
	_field.damage(0, 1000.0)
	assert_false(_field.has_block(0), "slot 0 is empty")
	assert_signal_emit_count(_field, "block_broken", 1)
	assert_signal_not_emitted(_field, "block_damaged")
	for slot: int in range(1, 5):
		assert_eq(_field.hp(slot), 10.0, "slot %d untouched" % slot)


func test_damage_to_an_empty_slot_changes_nothing() -> void:
	_field.damage(3, 10.0)
	var before: Array = _snapshot()
	watch_signals(_field)
	_field.damage(3, 5.0)
	assert_eq(_snapshot(), before, "field unchanged")
	_assert_no_signals()


func test_damage_to_an_invalid_slot_changes_nothing() -> void:
	var before: Array = _snapshot()
	watch_signals(_field)
	for slot: int in [-1, 5, 100]:
		_field.damage(slot, 5.0)
		assert_false(_field.has_block(slot), "invalid slot %d has no block" % slot)
	assert_eq(_snapshot(), before, "field unchanged")
	_assert_no_signals()


func test_zero_negative_or_nan_damage_changes_nothing() -> void:
	var before: Array = _snapshot()
	watch_signals(_field)
	for amount: float in [0.0, -5.0, -INF, NAN]:
		_field.damage(0, amount)
	assert_eq(_snapshot(), before, "field unchanged")
	_assert_no_signals()


## Every slot's [has_block, hp, max_hp, gold], then destroyed_count.
func _snapshot() -> Array:
	var result: Array = []
	for slot: int in _field.slot_count():
		result.append(
			[_field.has_block(slot), _field.hp(slot), _field.max_hp(slot), _field.gold(slot)]
		)
	result.append(_field.destroyed_count)
	return result


func _assert_no_signals() -> void:
	assert_signal_not_emitted(_field, "block_damaged")
	assert_signal_not_emitted(_field, "block_broken")
	assert_signal_not_emitted(_field, "block_spawned")
