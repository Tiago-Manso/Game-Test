extends GutTest
## BalanceConfig: every tunable number and the curves that use them (spec #3, D-008, D-020).

## Formula results are compared within this fraction of the expected value.
const RELATIVE_TOLERANCE: float = 1e-9

var _config: BalanceConfig


func before_each() -> void:
	_config = BalanceConfig.load_default()


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


func test_block_hp_grows_exponentially_from_the_defaults() -> void:
	_assert_close(_config.block_hp(0), 10.0, "block_hp(0)")
	_assert_close(_config.block_hp(1), 10.5, "block_hp(1)")
	_assert_close(_config.block_hp(10), 16.2889462678, "block_hp(10)")


func test_block_gold_grows_exponentially_from_the_defaults() -> void:
	_assert_close(_config.block_gold(0), 1.0, "block_gold(0)")
	_assert_close(_config.block_gold(1), 1.045, "block_gold(1)")
	_assert_close(_config.block_gold(10), 1.55296942173, "block_gold(10)")


## Tap level starts at 1, so the tap formulas are checked at levels 1, 2 and 10.
func test_tap_damage_grows_linearly_from_the_defaults() -> void:
	_assert_close(_config.tap_damage(1), 1.0, "tap_damage(1)")
	_assert_close(_config.tap_damage(2), 2.0, "tap_damage(2)")
	_assert_close(_config.tap_damage(10), 10.0, "tap_damage(10)")


func test_tap_upgrade_cost_grows_exponentially_from_the_defaults() -> void:
	_assert_close(_config.tap_upgrade_cost(1), 5.0, "tap_upgrade_cost(1)")
	_assert_close(_config.tap_upgrade_cost(2), 5.35, "tap_upgrade_cost(2)")
	_assert_close(_config.tap_upgrade_cost(10), 9.1922960621, "tap_upgrade_cost(10)")


func test_unit_dps_grows_linearly_from_the_defaults() -> void:
	var units: Array[UnitConfig] = _config.units
	_assert_close(_config.unit_dps(units[0], 1), 1.0, "pistol dps(1)")
	_assert_close(_config.unit_dps(units[0], 10), 10.0, "pistol dps(10)")
	_assert_close(_config.unit_dps(units[1], 1), 8.0, "shotgun dps(1)")
	_assert_close(_config.unit_dps(units[1], 10), 80.0, "shotgun dps(10)")
	_assert_close(_config.unit_dps(units[2], 1), 60.0, "rocket dps(1)")
	_assert_close(_config.unit_dps(units[2], 10), 600.0, "rocket dps(10)")


func test_unit_cost_grows_exponentially_from_the_defaults() -> void:
	var units: Array[UnitConfig] = _config.units
	_assert_close(_config.unit_cost(units[0], 0), 10.0, "pistol cost(0)")
	_assert_close(_config.unit_cost(units[0], 1), 10.7, "pistol cost(1)")
	_assert_close(_config.unit_cost(units[0], 10), 19.6715135729, "pistol cost(10)")
	_assert_close(_config.unit_cost(units[1], 0), 100.0, "shotgun cost(0)")
	_assert_close(_config.unit_cost(units[1], 1), 108.0, "shotgun cost(1)")
	_assert_close(_config.unit_cost(units[1], 10), 215.892499727, "shotgun cost(10)")
	_assert_close(_config.unit_cost(units[2], 0), 1000.0, "rocket cost(0)")
	_assert_close(_config.unit_cost(units[2], 1), 1090.0, "rocket cost(1)")
	_assert_close(_config.unit_cost(units[2], 10), 2367.36367459, "rocket cost(10)")


func test_tap_damage_at_level_1_is_1() -> void:
	assert_eq(_config.tap_damage(1), 1.0)


func test_unit_dps_at_level_0_is_0_for_any_unit() -> void:
	var units: Array[UnitConfig] = _config.units.duplicate()
	var custom: UnitConfig = UnitConfig.new()
	custom.id = &"custom"
	custom.base_dps = 123.0
	units.append(custom)
	for unit: UnitConfig in units:
		assert_eq(_config.unit_dps(unit, 0), 0.0, "%s dps at level 0" % unit.id)


func _assert_close(actual: float, expected: float, label: String) -> void:
	assert_almost_eq(actual, expected, absf(expected) * RELATIVE_TOLERANCE, label)


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
