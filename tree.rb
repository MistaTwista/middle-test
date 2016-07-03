class Node < Struct.new(:num, :childrens)
  class << self
    def new_empty(num)
      new(num, [])
    end
  end

  def id
    num
  end

  def inspect
    "num: #{num}, childrens: #{childrens}"
  end

  def weight
    if childrens.any?
      result = 0
      childrens.each do |c|
        result += c.weight
      end
      return num + result
    else
      num
    end
  end

  def add_childrens(*arr)
    childrens.push(*arr)
  end
end

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

# p n1
p n1.weight
# tree = []

# 55
