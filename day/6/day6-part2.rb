class LightGrid
end

class DenseGrid < LightGrid
  def self.iterate(x_r, y_r)
    fail unless block_given?
    print '.'
    y_r.each do |y|
      x_r.each do |x|
        yield x,y
      end
    end
  end

  def initialize
    @grid = [0] * 1000 * 1000
  end

  def set(x,y)
    @grid[index(x,y)] += 1
  end

  def clear(x,y)
    @grid[index(x,y)] -= 1 unless @grid[index(x,y)] <= 0
  end

  def flip(x,y)
    @grid[index(x,y)] += 2
  end

  def count
    @grid.reduce(:+)
  end

  private
  def index(x,y)
    x + (y * 1000)
  end
end

grid = DenseGrid.new
#grid = SparseGrid.new

re = Regexp.compile '\A((turn on)|(turn off)|(toggle))\s+(\d+),(\d+)\s+through\s+(\d+),(\d+)\z'
File.readlines('input.txt').each do |cmd|
  cmd.chomp!
  md = cmd.match re
  x_range = Range.new md[5].to_i, md[7].to_i
  y_range = Range.new md[6].to_i, md[8].to_i
  case md[1]
  when 'turn on'
    grid.class.iterate(x_range, y_range) { |x,y| grid.set x,y }
  when 'turn off'
    grid.class.iterate(x_range, y_range) { |x,y| grid.clear x,y }
  when 'toggle'
    grid.class.iterate(x_range, y_range) { |x,y| grid.flip x,y }
  else
    fail "Couldn't parse line: #{cmd}"
  end
end
puts
puts grid.count
