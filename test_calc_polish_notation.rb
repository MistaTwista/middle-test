require 'test/unit'
require_relative 'calc_polish_notation'

class TestCalcPolishNotation < Test::Unit::TestCase
  def test_calculation_sign
    assert_equal(:+, calculation_sign("+"))
    assert_equal(:-, calculation_sign("-"))
    assert_equal(:*, calculation_sign("*"))
    assert_equal(:/, calculation_sign("/"))
    assert_equal(:**, calculation_sign("^"))
  end

  def test_valid_expression
    assert_equal(true, valid_expression?(["5 1 2 + 4 * + 3 -"]))
    assert_equal(true, valid_expression?(["5", "1", "2", "+", "4", "*", "+", "3", "-"]))
    assert_equal(true, valid_expression?(["  5 1 2 + 4 * + 3 -  "]))
    assert_equal(false, valid_expression?(["3 4 2 * 1 5 − 2 3 ^ ^ / +"]))
    assert_equal(false, valid_expression?(["3 4 \\"]))
  end

  def test_calc_polish_notation
    assert_equal(14.0, calc_polish_notation("5 1 2 + 4 * + 3 -"))
    assert_equal(14.0, calc_polish_notation("5", "1", "2", "+", "4", "*", "+", "3", "-"))
    assert_equal(3, calc_polish_notation("3 4 2 * 1 5 - 2 3 ^ ^ / +"))
    assert_equal(25, calc_polish_notation("5 2 ^"))
    assert_equal("Zero division: 5 / 0", calc_polish_notation("5 0 /"))
    assert_equal(0, calc_polish_notation(" "))
    assert_equal(0, calc_polish_notation(""))
  end
end
