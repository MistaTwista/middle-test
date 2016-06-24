def get_digits_array(num)
  n = num.abs
  [].tap do |result|
    while n > 1
      n, digit = n.divmod 10
      result.unshift digit
    end
  end
end

def sum(array)
  array.reduce(&:+)
end

def check_lucky_ticket(ticket_num)
  digits_array = get_digits_array(ticket_num.to_i)
  center_value = digits_array.length / 2
  offset = digits_array.length % 2
  left_part = digits_array[0...center_value]
  right_part = digits_array[(center_value + offset)..-1]
  sum(left_part) == sum(right_part)
end

puts check_lucky_ticket(ARGV[0]) if ARGV[0]
