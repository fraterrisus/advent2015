input = ARGV[0]
fail 'Input required' if input.nil?

iterations = ARGV[1].to_i
iterations = 40 if iterations == 0

iterations.times do
  tokens = input.split(//).map(&:to_i)
  digits = [ { count: nil, digit: nil } ]
  tokens.each do |t|
    if digits.last[:digit] == t
      digits.last[:count] += 1
    else
      digits << { count: 1, digit: t }
    end
  end
  digits.shift
  output = ''
  digits.each do |d|
    output << d[:count].to_s
    output << d[:digit].to_s
  end
  #puts output
  puts "length: #{output.length}"
  input = output
end
