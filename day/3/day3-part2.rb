class Santa
  @@houses = Hash.new

  def initialize
    @x = 0
    @y = 0
  end

  def move(ch)
    print "#{ch} "
    case ch
    when '<'
      @x -= 1
    when '>'
      @x += 1
    when 'v'
      @y -= 1
    when '^'
      @y += 1
    else
      fail "Unexpected character #{ch}"
    end
    self.class.visit(@x,@y)
  end

  def self.houses
    @@houses
  end

  def self.hashkey(x,y)
    "#{x}/#{y}"
  end

  def self.visit(x,y)
    print "Visiting (#{x},#{y})"
    idx = hashkey(x,y)
    if @@houses[idx].nil?
      @@houses[idx] = 1
      print " for the first time"
    else
      @@houses[idx] += 1
      print " #visits: #{@@houses[idx]}"
    end
    puts
  end

  def self.count
    houses.keys.count
  end
end

robo_santas_turn = false
realsanta = Santa.new
robosanta = Santa.new

Santa.visit(0,0)
Santa.visit(0,0)

File.read('input.txt').chomp.split(//).each do |move|
  (robo_santas_turn) ? robosanta.move(move) : realsanta.move(move)
  robo_santas_turn = !robo_santas_turn
end

puts "#houses: #{Santa.count}"
