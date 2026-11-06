extends Control
## The playfield: one placeholder block with an HP bar per BlockField slot (spec #4, D-023).


func setup(_field: BlockField) -> void:
	pass


func block_count() -> int:
	return 0


func block_view(_slot: int) -> Control:
	return null


func hp_bar(_slot: int) -> ProgressBar:
	return null
