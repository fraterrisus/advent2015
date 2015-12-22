require 'prime'

def factors_of(number)
  primes, powers = number.prime_division.transpose
  exponents = powers.map{|i| (0..i).to_a}
  divisors = exponents.shift.product(*exponents).map do |powers|
    primes.zip(powers).map{|prime, power| prime ** power}.inject(:*)
  end
  divisors.sort
end

def how_many_presents(house_num)
  # part 1
  #factors_of(house_num).reduce(:+) * 10
  # part 2
  factors_of(house_num).select { |x| house_num < x * 50 }.reduce(:+) * 11
end

limit = ARGV.shift.to_i
puts "Limit: #{limit}"
house_num = 1
presents = 10

@linelen = 0
def print_dot
  print '.'
  puts if @linelen == 80
end

start = Time.now.utc
lap = start
puts
while presents < limit
  house_num += 1
  presents = how_many_presents house_num
  if (house_num % 1000 == 0)
    finish = Time.now.utc
    print "\033[1A"
    puts "%d %.2f %.3f" % [ house_num, finish-start, finish-lap ]
    lap = finish
  end
end
puts "#{house_num}: #{presents}"
