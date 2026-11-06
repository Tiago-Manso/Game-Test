class_name UnitConfig
extends Resource
## One buyable unit type (spec #3, D-010, D-019). Numbers come from data/balance.tres.

@export var id: StringName = &""
@export var display_name: String = ""
@export var base_cost: float = 0.0
@export var cost_growth: float = 0.0
@export var base_dps: float = 0.0
