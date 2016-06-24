require 'test/unit'
require_relative 'check_lucky_ticket'

class TestMissingNumber < Test::Unit::TestCase
  def test_get_digits_array
    num = 253343
    assert_equal([2,5,3,3,4,3], get_digits_array(num))
  end

  def test_sum
    array = [1,5,4]
    assert_equal(10, sum(array))
  end

  def test_lucky
    ticket = 253343
    assert_equal(true, check_lucky_ticket(ticket))
  end

  def test_unlucky
    ticket = 23334
    assert_equal(false, check_lucky_ticket(ticket))
  end
end
