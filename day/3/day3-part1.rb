@houses = Hash.new
x = 0
y = 0

def visit(x,y)
  print "Visiting (#{x},#{y})"
  idx = hashkey(x,y)
  if @houses[idx].nil?
    @houses[idx] = 1
    print " for the first time"
  else
    @houses[idx] += 1
    print " #visits: #{@houses[idx]}"
  end
  puts
end

def hashkey(x,y)
  "#{x}/#{y}"
end

visit(x,y) # starting location = (0,0)
File.read('input.txt').chomp.split(//).each do |move|
  print "#{move} "
  case move
  when '<'
    x -= 1
  when '>'
    x += 1
  when 'v'
    y -= 1
  when '^'
    y += 1
  else
    fail "Unexpected character #{move}"
  end
  visit(x,y)
end

puts "#houses: #{@houses.keys.count}"
