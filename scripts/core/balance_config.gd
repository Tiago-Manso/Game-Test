class_name BalanceConfig
extends Resource
## Every tunable balance number (spec #3, D-008). Values live in data/balance.tres.

const DEFAULT_PATH: String = "res://data/balance.tres"

@export var slot_count: int = 0
@export var respawn_delay: float = 0.0
@export var autosave_interval: float = 0.0
@export var block_base_hp: float = 0.0
@export var block_hp_growth: float = 0.0
@export var block_base_gold: float = 0.0
@export var block_gold_growth: float = 0.0
@export var tap_base_damage: float = 0.0
@export var tap_base_cost: float = 0.0
@export var tap_cost_growth: float = 0.0
@export var units: Array[UnitConfig] = []


static func load_default() -> BalanceConfig:
	return load(DEFAULT_PATH) as BalanceConfig


## HP of the block spawned after `n` blocks have been destroyed.
func block_hp(n: int) -> float:
	return block_base_hp * pow(block_hp_growth, n)


## Gold paid by the block spawned after `n` blocks have been destroyed.
func block_gold(n: int) -> float:
	return block_base_gold * pow(block_gold_growth, n)


## Tap damage at `level` (level starts at 1).
func tap_damage(level: int) -> float:
	return tap_base_damage * level


## Cost to raise tap damage from `level` to `level + 1`.
func tap_upgrade_cost(level: int) -> float:
	return tap_base_cost * pow(tap_cost_growth, level - 1)


## Damage per second of `unit` at `level` (level 0 = not owned).
func unit_dps(unit: UnitConfig, level: int) -> float:
	return unit.base_dps * level


## Cost to raise `unit` from `level` to `level + 1`.
func unit_cost(unit: UnitConfig, level: int) -> float:
	return unit.base_cost * pow(unit.cost_growth, level)


func unit_by_id(_id: StringName) -> UnitConfig:
	return null
