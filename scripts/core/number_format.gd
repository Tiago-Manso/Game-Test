class_name NumberFormat
## Formats game numbers for display (spec #2, D-016).

const SUFFIXES: Array[String] = ["", "K", "M"]


static func format(value: float) -> String:
	if value < 1000.0:
		return str(int(floor(value)))
	var exponent: int = _decimal_exponent(value)
	var digits: String = str(int(floor(value / pow(10.0, exponent - 2))))
	var group: int = exponent / 3
	var integer_digits: int = exponent % 3 + 1
	var mantissa: String = digits.substr(0, integer_digits)
	if integer_digits < 3:
		mantissa += "." + digits.substr(integer_digits)
	return mantissa + SUFFIXES[group]


## Power of ten of the leading digit; log() alone can land one off at exact powers.
static func _decimal_exponent(value: float) -> int:
	var exponent: int = int(floor(log(value) / log(10.0)))
	if value >= pow(10.0, exponent + 1):
		exponent += 1
	elif value < pow(10.0, exponent):
		exponent -= 1
	return exponent
