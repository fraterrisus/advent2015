containers = File.readlines('input.txt').map(&:to_i).sort
options = []
min = containers.count + 1
min_count = 0
containers.count.times do |len|
  print "#{len} "
  this_opts = containers.combination(len).select { |x| x.reduce(:+) == 150 }
  if this_opts.any?
    options += this_opts
    if len < min
      min = len
      min_count = this_opts.count
    end
  end
end
puts
puts "Total combinations: #{options.count}"
puts "Minimum number of containers: #{min}"
puts "Combinations of #{min} containers: #{min_count}" 
