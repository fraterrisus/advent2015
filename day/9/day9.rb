distances = {}
mindist = 0
maxdist = 0

# Build a diagonally symmetric matrix of distances between towns. For ease of
# access, we'll use a hash of hashes so that we can index them with symbols
# instead of doing a lookup to get integer indexes.
#
# In addition, initialize the "mindist" variable to a number that is larger
# than the longest possible path.
File.readlines('input.txt').each do |pair|
  pair.chomp!
  m = pair.match /\A(\w+) to (\w+) = (\d+)\z/
  d1 = m[1].downcase.to_sym
  d2 = m[2].downcase.to_sym
  dist = m[3].to_i
  mindist += dist
  (distances.key? d1) ? distances[d1][d2] = dist : distances[d1] = { d2 => dist }
  (distances.key? d2) ? distances[d2][d1] = dist : distances[d2] = { d1 => dist }
end

puts "Towns: #{distances.keys.length}"
puts "Paths: #{distances.keys.permutation.to_a.length}"

# Use Array#permutation to generate all possible complete paths. Evalutate the
# length of the path by performing lookups from town[i] to town[i+1] along the
# path. If this path is shorter than the best path so far, print it.
#
# This is a brute force algorithm [ O(n!) ] but it's also basically Traveling
# Salesman, so there isn't a better P-time solution.
distances.keys.permutation do |path|
  length = 0
  (0...path.length-1).each do |i|
    length += distances[path[i]][path[i+1]]
  end
  if length < mindist
    mindist = length
    puts "MIN #{mindist}: #{path.inspect}"
  end
  if length > maxdist
    maxdist = length
    puts "MAX #{maxdist}: #{path.inspect}"
  end
end
