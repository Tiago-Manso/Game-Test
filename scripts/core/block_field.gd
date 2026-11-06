class_name BlockField
extends RefCounted
## The playfield's blocks in fixed slots (spec #4, D-009, D-014, D-015, architecture 4.2).

signal block_damaged(slot: int, hp: float)
signal block_broken(slot: int, gold: float)
signal block_spawned(slot: int)

var destroyed_count: int = 0


func _init(_config: BalanceConfig, _initial_destroyed_count: int = 0) -> void:
	pass


func slot_count() -> int:
	return 0


func has_block(_slot: int) -> bool:
	return false


func hp(_slot: int) -> float:
	return 0.0


func max_hp(_slot: int) -> float:
	return 0.0


func gold(_slot: int) -> float:
	return 0.0
