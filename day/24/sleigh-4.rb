packages = File.readlines('input.txt').map(&:to_i)
puts "# packages: #{packages.count}"
total_weight = packages.reduce(:+)
puts "total weight: #{total_weight}"
group_weight = total_weight / 4
puts "group weight: #{group_weight}"

(packages.count - 1).times do |n|
  puts "Looking for group of #{n} packages"
  # 1. Can we build any group of packages that adds up to #{group_weight}?
  group0 = packages.combination(n).select do |comb|
    comb.reduce(:+) == group_weight
  end
  next unless group0.any?
  puts "Found #{group0.count} groups of size #{n}"
  # 2. Yes: sort all of the possibilities by entanglement
  group0 = group0.sort { |o| o.reduce(:*) }.reverse
  # 3. From low-to-high entanglement...
  group0.each do |g0|
    rem0 = packages - g0
    puts "[#{g0.reduce(:*)}] #{g0.inspect} - #{rem0.inspect}"
    # 3a. Look at what's left and make sure we can make three groups of equal weight
    rem0.count.times do |m|
      group1 = rem0.combination(m).select do |left|
        left.reduce(:+) == group_weight
      end
      next unless group1.any?
      puts "Found #{group1.count} subgroups of size #{m}"
      group1.each do |g1|
        rem1 = rem0 - g1
        puts "[#{g0.reduce(:*)}] #{g0.inspect} - #{g1.inspect} - #{rem1.inspect}"
        # 4. Look at what's left again and make sure we can make two groups of equal weight
        rem1.count.times do |l|
          group2 = rem1.combination(l).select do |left|
            (left.reduce(:+) == group_weight) &&
            ((rem1 - left).reduce(:+) == group_weight)
          end
          # 4b. If we can (it doesn't matter how) then we have the best option.
          # This is guaranteed because we iterated in order of size of "Group 1"
          # and then in order of entanglement, so this is the first option that is
          # of minimum group size and minimum group entanglement that can be split
          # into four equal-weight groups.
          if group2.any?
            puts "[#{g0.reduce(:*)}] #{g0.inspect} - #{g1.inspect} - #{group2[0].inspect} - #{(rem1 - group2[0]).inspect}"
            exit
          end
        end
      end
    end
  end
end
