class_name NumberFormat
## Formats game numbers for display (spec #2, D-016).

enum Notation { SUFFIX, SCIENTIFIC }

## Suffixes for the first powers of 1000; after them come two letters: aa, ab, ... zz.
const NAMED_SUFFIXES: Array[String] = ["", "K", "M", "B", "T"]
const LETTER_COUNT: int = 26


static func format(value: float, _notation: Notation = Notation.SUFFIX) -> String:
	if value < 1000.0:
		return str(int(floor(value)))
	var exponent: int = _decimal_exponent(value)
	var digits: String = str(int(floor(value / pow(10.0, exponent - 2))))
	var group: int = exponent / 3
	var integer_digits: int = exponent % 3 + 1
	var mantissa: String = digits.substr(0, integer_digits)
	if integer_digits < 3:
		mantissa += "." + digits.substr(integer_digits)
	return mantissa + _suffix(group)


## Power of ten of the leading digit; log() alone can land one off at exact powers.
static func _decimal_exponent(value: float) -> int:
	var exponent: int = int(floor(log(value) / log(10.0)))
	if value >= pow(10.0, exponent + 1):
		exponent += 1
	elif value < pow(10.0, exponent):
		exponent -= 1
	return exponent


## Suffix for 1000^group: K, M, B, T, then aa, ab, ... az, ba, ... zz.
static func _suffix(group: int) -> String:
	if group < NAMED_SUFFIXES.size():
		return NAMED_SUFFIXES[group]
	var index: int = group - NAMED_SUFFIXES.size()
	var first: String = char("a".unicode_at(0) + index / LETTER_COUNT)
	var second: String = char("a".unicode_at(0) + index % LETTER_COUNT)
	return first + second
