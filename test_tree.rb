require 'test/unit'
require_relative 'tree'

class TestTreeResult < Test::Unit::TestCase
  def test_availability_of_a_class
    assert_respond_to(Node.new, :weight)
    assert_respond_to(Node.new, :add_childrens)
  end

  def test_can_be_created_empty
    assert_respond_to(Node, :new_empty)
  end

  def test_tree_sum
    n1 = Node.new_empty(1)
    n2 = Node.new_empty(2)
    n3 = Node.new_empty(3)
    n1.add_childrens(n2, n3)

    n4 = Node.new_empty(4)
    n5 = Node.new_empty(5)
    n2.add_childrens(n4, n5)

    n6 = Node.new_empty(6)
    n7 = Node.new_empty(7)
    n5.add_childrens(n6, n7)

    n8 = Node.new_empty(8)
    n7.add_childrens(n8)

    n9 = Node.new_empty(9)
    n3.add_childrens(n9)
    n10 = Node.new_empty(10)
    n9.add_childrens(n10)

    n11 = Node.new_empty(11)
    n12 = Node.new_empty(12)
    n13 = Node.new_empty(13)
    n10.add_childrens(n11, n12, n13)

    assert_equal(91, n1.weight)
  end
end
