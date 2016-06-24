require 'test/unit'
require_relative 'file_parser'

class TestFileParser < Test::Unit::TestCase
  def test_availability_of_a_class
    assert_respond_to(FileParser.new, :parse)
  end

  def test_bad_file_name
    assert_raise ArgumentError do
      FileParser.new("n.txt").parse
    end
  end

  def test_good_file_name
    assert_equal(true, FileParser.new("numbers.txt").parse)
  end
end
