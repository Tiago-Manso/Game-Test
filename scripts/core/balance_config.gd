class_name BalanceConfig
extends Resource
## Every tunable balance number (spec #3, D-008). Values live in data/balance.tres.

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
	return BalanceConfig.new()
