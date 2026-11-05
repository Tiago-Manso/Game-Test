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
