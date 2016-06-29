module PolishNotation
  AVAILABLE_SIGN_SYMBOLS = {
    '+': :+,
    '-': :-,
    '*': :*,
    '/': :/,
    '^': :**,
  }.freeze
end

def calculation_sign(symbol)
  PolishNotation::AVAILABLE_SIGN_SYMBOLS[symbol.to_sym]
end

def bad_symbols?(exp)
  matcher = /[^ \+\-\*\/\^0-9]/.match(exp.join(' '))
  puts 'Bad symbols detected' unless matcher.nil?
  !matcher.nil?
end

def valid_expression?(exp)
  !bad_symbols?(exp) && exp.any?
end

def prepare_expression(exp)
  exp.flatten!
  exp = exp[0].strip.split(" ") if exp.length == 1
  exp
end

def calc_polish_notation(*exp)
  exp = prepare_expression(exp)
  return 0 unless valid_expression? exp
  [].tap do |stack|
    exp.each do |u|
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

puts calc_polish_notation(ARGV) if ARGV
