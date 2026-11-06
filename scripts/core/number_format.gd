class_name NumberFormat
## Formats game numbers for display (spec #2, D-016). Every on-screen number
## goes through here so the notation can be switched in one place (D-021).

enum Notation { SUFFIX, SCIENTIFIC }

## Below this, numbers print as whole numbers with no suffix.
const SUFFIX_THRESHOLD: float = 1000.0
const SIGNIFICANT_DIGITS: int = 3
## Suffixes for the first powers of 1000; after them come two letters: aa, ab, ... zz.
## The largest float (~1.8e308) needs only up to "dt", so zz is never passed.
const NAMED_SUFFIXES: Array[String] = ["", "K", "M", "B", "T"]
const LETTER_COUNT: int = 26
const INFINITY_TEXT: String = "∞"
const NAN_TEXT: String = "?"


static func format(value: float, notation: Notation = Notation.SUFFIX) -> String:
	if is_nan(value):
		return NAN_TEXT
	if value < 0.0:
		return "-" + format(-value, notation)
	if is_inf(value):
		return INFINITY_TEXT
	if value < SUFFIX_THRESHOLD:
		return str(floori(value))
	var exponent: int = _decimal_exponent(value)
	var digits: String = str(_leading_digits(value, exponent))
	if notation == Notation.SCIENTIFIC:
		return _scientific(digits, exponent)
	return _suffixed(digits, exponent)


## Power of ten of the leading digit; log() alone can land one off at exact powers.
static func _decimal_exponent(value: float) -> int:
	var exponent: int = floori(log(value) / log(10.0))
	if value >= pow(10.0, exponent + 1):
		exponent += 1
	elif value < pow(10.0, exponent):
		exponent -= 1
	return exponent


## The first 3 digits of value, truncated. 10^exponent <= value < 10^(exponent + 1),
## so they lie in 100..999; the clamp undoes float error in the division.
static func _leading_digits(value: float, exponent: int) -> int:
	var digits: int = floori(value / pow(10.0, exponent - (SIGNIFICANT_DIGITS - 1)))
	return clampi(digits, 100, 999)


## "1.23e3": one digit, point, the other two, then the exponent.
static func _scientific(digits: String, exponent: int) -> String:
	return digits.left(1) + "." + digits.substr(1) + "e" + str(exponent)


## "1.23K", "12.3K", "123K": the point moves with the exponent inside its group of 3.
static func _suffixed(digits: String, exponent: int) -> String:
	var integer_digits: int = posmod(exponent, 3) + 1
	var mantissa: String = digits.left(integer_digits)
	if integer_digits < SIGNIFICANT_DIGITS:
		mantissa += "." + digits.substr(integer_digits)
	return mantissa + _suffix(floori(exponent / 3.0))


## Suffix for 1000^group: K, M, B, T, then aa, ab, ... az, ba, ... zz.
static func _suffix(group: int) -> String:
	if group < NAMED_SUFFIXES.size():
		return NAMED_SUFFIXES[group]
	var index: int = group - NAMED_SUFFIXES.size()
	var letter_a: int = "a".unicode_at(0)
	var first: String = char(letter_a + floori(float(index) / LETTER_COUNT))
	var second: String = char(letter_a + posmod(index, LETTER_COUNT))
	return first + second
