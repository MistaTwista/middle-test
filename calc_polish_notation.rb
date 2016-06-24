def calculation_sign?(symbol)
  %w(+ - * / ^).include? symbol
end

# Отрицательные числа
# ^ ??
# Если передано пустое выражение = 0
# 3 4 2 * 1 5 − 2 3 ^ ^ / +
def calc_polish_notation(exp)
  expression = exp.split(" ")
  [].tap do |stack|
    expression.each do |u|
      if calculation_sign? u
        stack << stack.pop(2).map(&:to_i).reduce(&u.to_sym)
      else
        stack << u
      end
    end
  end.last
end

puts calc_polish_notation(ARGV[0]) if ARGV[0]
