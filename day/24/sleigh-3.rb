packages = File.readlines('input.txt').map(&:to_i)
puts "# packages: #{packages.count}"
total_weight = packages.reduce(:+)
puts "total weight: #{total_weight}"
group_weight = total_weight / 3
puts "group weight: #{group_weight}"

(packages.count - 1).times do |n|
  puts "Looking for group of #{n} packages"
  # 1. Can we build any group of packages that adds up to #{group_weight}?
  options = packages.combination(n).select do |comb|
    comb.reduce(:+) == group_weight
  end
  next unless options.any?
  puts "Found #{options.count} groups of size #{n}"
  # 2. Yes: sort all of the possibilities by entanglement
  options = options.sort { |o| o.reduce(:*) }.reverse
  # 3. From low-to-high entanglement...
  options.each do |comb|
    remaining = packages.dup - comb
    puts "[#{comb.reduce(:*)}] #{comb.inspect} - #{remaining.inspect}"
    # 3a. Look at what's left and make sure we can make two groups of equal weight
    (remaining.count / 2).times do |m|
      leftovers = remaining.combination(m).select do |left|
        (left.reduce(:+) == group_weight) &&
        ((remaining - left).reduce(:+) == group_weight)
      end
      # 3b. If we can (it doesn't matter how) then we have the best option.
      # This is guaranteed because we iterated in order of size of "Group 1"
      # and then in order of entanglement, so this is the first option that is
      # of minimum group size and minimum group entanglement that can be split
      # into three equal-weight groups.
      if leftovers.any?
        puts "[#{comb.reduce(:*)}] #{comb.inspect} - #{leftovers[0].inspect} - #{(remaining - leftovers[0]).inspect}"
        exit
      end
    end
  end
end
