require 'test/unit'
require_relative 'calc_polish_notation'

class TestCalcPolishNotation < Test::Unit::TestCase
  def test_calculation_sign
    assert_equal(true, calculation_sign?("+"))
  end

  def test_calc_polish_notation
    assert_equal(14.0, calc_polish_notation("5 1 2 + 4 * + 3 -"))
  end
end
