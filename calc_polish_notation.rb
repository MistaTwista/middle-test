def calculation_sign(symbol)
  available_sign_symbols = {
    "+": :+,
    "-": :-,
    "*": :*,
    "/": :/,
    "^": :**,
  }
  available_sign_symbols[symbol.to_sym]
end

def valid_expression?(exp)
  return false unless /[^ \+\-\*\/\^0-9]/.match(exp.strip).nil?
  if exp.is_a?(String)
    return true unless exp.strip.empty?
  end
  false
end

# TODO: ZeroDivisionError handler
def calc_polish_notation(exp)
  return 0 unless valid_expression? exp
  expression = exp.strip.split(" ")
  [].tap do |stack|
    expression.each do |u|
      sign = calculation_sign(u)
      if sign
        stack << stack.pop(2).map(&:to_i).reduce(&sign)
      else
        stack << u
      end
    end
  end.last
end

puts calc_polish_notation(ARGV[0]) if ARGV[0]
