subs = File.readlines('input.txt')
puts subs.count
calibration = subs.pop.chomp
while (! subs.last.match(/\=\>/)) ; subs.pop ; end
reactions = {}
subs.each do |sub|
  sub.chomp!
  k,v = sub.split(/\s*\=\>\s*/)
  reactions[k] = [] unless reactions.key?(k)
  reactions[k] << v
end
#tokens = calibration.gsub(/([A-Z])/, ',\1').split(/,/)
#tokens.shift
created = []
reactions.each do |k,v|
  start = 0
  done = false
  while (!done)
    done = true
    calibration.match(k,start) do |m|
      #puts "Found #{k} at #{m.begin(0)}"
      v.each do |repl|
        #puts "Replacing #{calibration[m.begin(0)...m.end(0)]} with #{repl}"
        postreact = calibration.dup
        postreact[m.begin(0)...m.end(0)] = repl
        #puts "Adding:"
        #puts "  #{postreact}"
        created << postreact
      end
      start = m.end(0)
      done = false
    end
  end
end
puts "Calibration count: #{created.uniq.count}"

