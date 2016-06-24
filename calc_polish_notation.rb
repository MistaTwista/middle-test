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

def bad_symbols?(exp)
  matcher = /[^ \+\-\*\/\^0-9]/.match(exp)
  puts "Bad symbols detected" unless matcher.nil?
  matcher.nil?
end

def valid_expression?(exp)
  if exp.is_a?(String)
    return false unless bad_symbols?(exp.strip)
    return true unless exp.strip.empty?
  end
  false
end

def calc_polish_notation(exp)
  return 0 unless valid_expression? exp
  expression = exp.strip.split(" ")
  [].tap do |stack|
    expression.each do |u|
      sign = calculation_sign(u)
      if sign
        values = stack.pop(2)
        begin
          stack << values.map(&:to_i).reduce(&sign)
        rescue ZeroDivisionError => e
          return "Zero division: #{values.first} #{sign} #{values.last}"
        end
      else
        stack << u
      end
    end
  end.last
end

puts calc_polish_notation(ARGV[0]) if ARGV[0]
