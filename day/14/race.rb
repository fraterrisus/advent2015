class Reindeer
  def initialize(_name, _speed, _flytime, _resttime)
    @name = _name
    @speed = _speed
    @flytime = _flytime
    @resttime = _resttime
    @state = :flying
    @counter = _flytime
    @distance = 0
    @points = 0
  end

  def tick
    @distance += @speed if @state == :flying
    @counter -= 1
    if @counter == 0
      if @state == :flying
        @state = :resting
        @counter = @resttime
      else
        @state = :flying
        @counter = @flytime
      end
    end
  end

  def score
    @points += 1
  end

  def name
    @name
  end

  def distance
    @distance
  end

  def points
    @points
  end

  def to_s
    x = "%10s: %7s %3d %4d %4d " % [@name, @state, @counter, @points, @distance]
    x += '.' * (@distance / 50)
    x
  end

end

reindeer = File.readlines('input.txt').map do |x|
  m = x.match /\A(\w+) can fly (\d+) km\/s for (\d+) seconds, but then must rest for (\d+) seconds/
  Reindeer.new(m[1], m[2].to_i, m[3].to_i, m[4].to_i)
end

header = '     Name    State  Ctr  Pts Dist    Tick: '
puts header
puts reindeer
ARGV[0].to_i.times do |i|
  reindeer.each(&:tick)
  reindeer.sort_by!(&:distance)
  max = reindeer.last.distance
  reindeer.each { |r| r.score if r.distance == max }
  #sleep 0.01
  print "\033[#{reindeer.count+1}A"
  print header
  puts i+1
  puts reindeer
end
