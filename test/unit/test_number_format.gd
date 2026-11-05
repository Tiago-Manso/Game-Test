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
