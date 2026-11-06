extends Control
## The playfield: one placeholder block with an HP bar per BlockField slot (spec #4, D-023).
## Updates only on BlockField signals; never advances time itself (A-03).

## Blocks per row; the rest wrap to the next row (5 slots -> 3 above 2).
@export var slots_per_row: int = 3
@export var block_size: Vector2 = Vector2(120.0, 120.0)
@export var block_color: Color = Color(0.85, 0.45, 0.25)
@export var hp_bar_height: float = 14.0
@export var block_spacing: int = 24

var _field: BlockField
var _blocks: Array[ColorRect] = []
var _bars: Array[ProgressBar] = []

@onready var _rows: VBoxContainer = $Rows


## Shows `field` and follows its signals from now on.
func setup(field: BlockField) -> void:
	_field = field
	_build_slots(field.slot_count())
	for slot: int in field.slot_count():
		_show_slot(slot)
	field.block_damaged.connect(_on_block_damaged)
	field.block_broken.connect(_on_block_broken)
	field.block_spawned.connect(_on_block_spawned)


func block_count() -> int:
	return _blocks.size()


## The block node of `slot` (a coloured square for now).
func block_view(slot: int) -> Control:
	return _blocks[slot]


func hp_bar(slot: int) -> ProgressBar:
	return _bars[slot]


func _build_slots(count: int) -> void:
	var row: HBoxContainer = null
	for slot: int in count:
		if slot % slots_per_row == 0:
			row = HBoxContainer.new()
			row.alignment = BoxContainer.ALIGNMENT_CENTER
			row.mouse_filter = Control.MOUSE_FILTER_IGNORE
			row.add_theme_constant_override("separation", block_spacing)
			_rows.add_child(row)
		row.add_child(_new_slot(slot))


## A fixed-size cell, so a hidden block leaves its place empty instead of shifting the others.
func _new_slot(slot: int) -> VBoxContainer:
	var cell: VBoxContainer = VBoxContainer.new()
	cell.name = "Slot%d" % slot
	cell.custom_minimum_size = Vector2(block_size.x, block_size.y + hp_bar_height)
	cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cell.add_theme_constant_override("separation", 0)
	var block: ColorRect = ColorRect.new()
	block.name = "Block"
	block.custom_minimum_size = block_size
	block.color = block_color
	cell.add_child(block)
	var bar: ProgressBar = ProgressBar.new()
	bar.name = "HpBar"
	bar.custom_minimum_size = Vector2(block_size.x, hp_bar_height)
	bar.step = 0.0
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cell.add_child(bar)
	_blocks.append(block)
	_bars.append(bar)
	return cell


## Shows the block in `slot` with a bar at its current HP, or nothing when it's empty.
func _show_slot(slot: int) -> void:
	var shown: bool = _field.has_block(slot)
	if shown:
		_bars[slot].max_value = _field.max_hp(slot)
		_bars[slot].value = _field.hp(slot)
	_blocks[slot].visible = shown
	_bars[slot].visible = shown


func _on_block_damaged(slot: int, hp: float) -> void:
	_bars[slot].value = hp


func _on_block_broken(slot: int, _gold: float) -> void:
	_show_slot(slot)


func _on_block_spawned(slot: int) -> void:
	_show_slot(slot)
