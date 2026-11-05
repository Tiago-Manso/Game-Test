extends GutTest
## NumberFormat: how every game number is shown (spec #2, D-016, D-021).


func test_values_below_1000_print_as_truncated_integers() -> void:
	assert_eq(NumberFormat.format(0.0), "0")
	assert_eq(NumberFormat.format(7.0), "7")
	assert_eq(NumberFormat.format(999.9), "999")
