class_name NumberFormat
## Formats game numbers for display (spec #2, D-016).


static func format(value: float) -> String:
	return str(int(floor(value)))
