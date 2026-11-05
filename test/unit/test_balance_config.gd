extends GutTest
## BalanceConfig: every tunable number and the curves that use them (spec #3, D-008, D-020).


func test_load_default_values_match_the_spec_table() -> void:
	var config: BalanceConfig = BalanceConfig.load_default()
	assert_not_null(config, "default config loads")
	if config == null:
		return
	assert_eq(config.slot_count, 5)
	assert_eq(config.respawn_delay, 0.5)
	assert_eq(config.autosave_interval, 10.0)
	assert_eq(config.block_base_hp, 10.0)
	assert_eq(config.block_hp_growth, 1.05)
	assert_eq(config.block_base_gold, 1.0)
	assert_eq(config.block_gold_growth, 1.045)
	assert_eq(config.tap_base_damage, 1.0)
	assert_eq(config.tap_base_cost, 5.0)
	assert_eq(config.tap_cost_growth, 1.07)


func test_load_default_has_pistol_shotgun_rocket_in_order() -> void:
	var units: Array[UnitConfig] = BalanceConfig.load_default().units
	assert_eq(units.size(), 3, "three units")
	if units.size() != 3:
		return
	_assert_unit(units[0], &"pistol", "Pistol", 10.0, 1.07, 1.0)
	_assert_unit(units[1], &"shotgun", "Shotgun", 100.0, 1.08, 8.0)
	_assert_unit(units[2], &"rocket", "Rocket", 1000.0, 1.09, 60.0)


func _assert_unit(
	unit: UnitConfig, id: StringName, display_name: String, cost: float, growth: float, dps: float
) -> void:
	assert_not_null(unit, "unit %s is set" % id)
	if unit == null:
		return
	assert_eq(unit.id, id)
	assert_eq(unit.display_name, display_name)
	assert_eq(unit.base_cost, cost, "%s base_cost" % id)
	assert_eq(unit.cost_growth, growth, "%s cost_growth" % id)
	assert_eq(unit.base_dps, dps, "%s base_dps" % id)
