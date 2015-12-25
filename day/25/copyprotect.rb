instruction = File.read 'input.txt'

dest_y = instruction.match(/row (\d+)/)[1].to_i
dest_x = instruction.match(/column (\d+)/)[1].to_i

puts "Generating code at (#{dest_x}, #{dest_y})"
x = 1
y = 1
code = 20151125

# Use the power of modulus!
# B and N are prime, so (a b mod n)(b mod n)(b mod n)... = a(b^x) mod n for arbitrary x

fake_dest_y = dest_x + dest_y - 1
# Generate the value at (1,y)
while y < fake_dest_y
  code = code * (252533 ** y)
  code = code % 33554393
  y += 1
  puts "(#{x},#{y}): #{code}"
end
# Figure out how many more steps we need (b^x)
distance_to_target = dest_x - 1
while distance_to_target > 0
  # Do it in small batches so we don't overflow a Fixnum
  [1000, 100, 10, 1].each do |delta|
    if distance_to_target >= delta
      code = code * (252533 ** delta)
      code = code % 33554393
      x += delta
      y -= delta
      distance_to_target -= delta
      break
    end
  end
  puts "(#{x},#{y}): #{code}"
end

# In theory we could also do this by computing the sequence number directly;
# triangular number N can be computed as N+1-choose-2, which gets us close, and
# then we could walk in from there. This method just makes sure that we never
# take more than about 10,000 steps at a time, which I'm a little bit surprised
# doesn't pose a problem for arbitrary precision in Ruby.
