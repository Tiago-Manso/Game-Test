extends GutTest
## NumberFormat: how every game number is shown (spec #2, D-016, D-021).


func test_values_below_1000_print_as_truncated_integers() -> void:
	assert_eq(NumberFormat.format(0.0), "0")
	assert_eq(NumberFormat.format(7.0), "7")
	assert_eq(NumberFormat.format(999.9), "999")


func test_suffix_examples_produce_exact_strings() -> void:
	assert_eq(NumberFormat.format(1234.0), "1.23K")
	assert_eq(NumberFormat.format(12345.0), "12.3K")
	assert_eq(NumberFormat.format(123456.0), "123K")
	assert_eq(NumberFormat.format(999999.0), "999K")
	assert_eq(NumberFormat.format(1000000.0), "1.00M")


func test_suffix_digits_are_truncated_never_rounded_up() -> void:
	assert_eq(NumberFormat.format(1239.0), "1.23K")
	assert_eq(NumberFormat.format(1999.0), "1.99K")
	assert_eq(NumberFormat.format(12399.0), "12.3K")
	assert_eq(NumberFormat.format(199999.0), "199K")


func test_suffix_sequence_is_right_at_its_boundaries() -> void:
	assert_eq(NumberFormat.format(1e12), "1.00T")
	assert_eq(NumberFormat.format(1e15), "1.00aa")
	assert_eq(NumberFormat.format(1e18), "1.00ab")
	# The 27th two-letter suffix, after az. Computed as the spec writes it: the
	# GDScript literal 1e93 parses one ulp below 10^93, which truly is 999az.
	assert_eq(NumberFormat.format(1e15 * pow(1000.0, 26)), "1.00ba")


func test_scientific_examples_produce_exact_strings() -> void:
	assert_eq(NumberFormat.format(1234.0, NumberFormat.Notation.SCIENTIFIC), "1.23e3")
	assert_eq(NumberFormat.format(1000000.0, NumberFormat.Notation.SCIENTIFIC), "1.00e6")


func test_scientific_digits_are_truncated_never_rounded_up() -> void:
	assert_eq(NumberFormat.format(1239.0, NumberFormat.Notation.SCIENTIFIC), "1.23e3")
	assert_eq(NumberFormat.format(1999.0, NumberFormat.Notation.SCIENTIFIC), "1.99e3")


func test_negative_values_format_the_absolute_value_with_a_minus() -> void:
	assert_eq(NumberFormat.format(-7.0), "-7")
	assert_eq(NumberFormat.format(-1234.0), "-1.23K")
	assert_eq(NumberFormat.format(-1234.0, NumberFormat.Notation.SCIENTIFIC), "-1.23e3")


func test_infinity_prints_as_infinity_sign() -> void:
	assert_eq(NumberFormat.format(INF), "∞")
	assert_eq(NumberFormat.format(INF, NumberFormat.Notation.SCIENTIFIC), "∞")
	assert_eq(NumberFormat.format(-INF), "-∞")


func test_nan_prints_as_question_mark() -> void:
	assert_eq(NumberFormat.format(NAN), "?")
	assert_eq(NumberFormat.format(NAN, NumberFormat.Notation.SCIENTIFIC), "?")


func test_value_just_below_a_power_of_1000_does_not_print_1000k() -> void:
	assert_eq(NumberFormat.format(999999.9999999), "999K")


func test_no_power_of_ten_or_value_just_below_it_reaches_a_mantissa_of_1000() -> void:
	for power: int in range(3, 301):
		var exact: float = pow(10.0, power)
		_assert_mantissa(exact, "1")
		if power > 3:
			_assert_mantissa(_previous_float(exact), "9")


## Both notations show 3 significant digits below their limit (1000 for a
## suffix, 10 for scientific), starting with the expected leading digit.
func _assert_mantissa(value: float, leading_digit: String) -> void:
	for notation: NumberFormat.Notation in NumberFormat.Notation.values():
		var text: String = NumberFormat.format(value, notation)
		var mantissa: String = _leading_number(text)
		var limit: float = 10.0 if notation == NumberFormat.Notation.SCIENTIFIC else 1000.0
		assert_true(
			mantissa.begins_with(leading_digit), "%s starts with %s" % [text, leading_digit]
		)
		assert_eq(mantissa.replace(".", "").length(), 3, "3 significant digits in %s" % text)
		assert_lt(mantissa.to_float(), limit, "mantissa of %s" % text)


## The digits and point at the start of a formatted number.
func _leading_number(text: String) -> String:
	var number: String = ""
	for character: String in text:
		if character != "." and not character.is_valid_int():
			break
		number += character
	return number


## The largest float below a positive value: the tiniest possible epsilon.
func _previous_float(value: float) -> float:
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(8)
	bytes.encode_double(0, value)
	bytes.encode_s64(0, bytes.decode_s64(0) - 1)
	return bytes.decode_double(0)
