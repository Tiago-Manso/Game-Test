class_name BlockField
extends RefCounted
## The playfield's blocks in fixed slots (spec #4, D-009, D-014, D-015, architecture 4.2).

signal block_damaged(slot: int, hp: float)
signal block_broken(slot: int, gold: float)
signal block_spawned(slot: int)

var destroyed_count: int = 0

var _config: BalanceConfig
var _occupied: Array[bool] = []
var _hp: PackedFloat64Array = PackedFloat64Array()
var _max_hp: PackedFloat64Array = PackedFloat64Array()
var _gold: PackedFloat64Array = PackedFloat64Array()


func _init(config: BalanceConfig, initial_destroyed_count: int = 0) -> void:
	_config = config
	destroyed_count = initial_destroyed_count
	var count: int = config.slot_count
	_occupied.resize(count)
	_hp.resize(count)
	_max_hp.resize(count)
	_gold.resize(count)
	for slot: int in count:
		_spawn(slot)


func slot_count() -> int:
	return _occupied.size()


## False for an empty slot and for an index outside 0 .. slot_count() - 1.
func has_block(slot: int) -> bool:
	return slot >= 0 and slot < _occupied.size() and _occupied[slot]


func hp(slot: int) -> float:
	return _hp[slot]


func max_hp(slot: int) -> float:
	return _max_hp[slot]


func gold(slot: int) -> float:
	return _gold[slot]


## Lowers the block's HP in `slot`; at HP <= 0 the block breaks. Overkill is lost.
## Does nothing for an empty or invalid slot, or an amount that isn't > 0 (NaN included).
func damage(slot: int, amount: float) -> void:
	if not (amount > 0.0) or not has_block(slot):
		return
	_hp[slot] -= amount
	if _hp[slot] > 0.0:
		block_damaged.emit(slot, _hp[slot])
		return
	_occupied[slot] = false
	_hp[slot] = 0.0
	destroyed_count += 1
	block_broken.emit(slot, _gold[slot])


func _spawn(slot: int) -> void:
	_occupied[slot] = true
	_max_hp[slot] = _config.block_hp(destroyed_count)
	_hp[slot] = _max_hp[slot]
	_gold[slot] = _config.block_gold(destroyed_count)
