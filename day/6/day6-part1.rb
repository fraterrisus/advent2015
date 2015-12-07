class LightGrid
end

class SparseGrid < LightGrid
  def self.iterate(x_r, y_r)
    fail unless block_given?
    print '.'
    yield x_r,y_r
  end

  def initialize
    @grid = Hash.new
  end

  def set(xs,ys)
    ys.each do |y|
      @grid[y] = [ ] unless @grid.key? y
      @grid[y] += xs.to_a
      @grid[y].uniq!
    end
  end

  def clear(xs,ys)
    ys.to_a.select { |y| @grid.key? y }.each do |y|
      @grid[y] -= xs.to_a
      @grid.delete(y) if @grid[y].count == 0
    end
  end

  def flip(xs,ys)
    ys.each do |y|
      @grid[y] = [ ] unless @grid.key? y
      ex, ne = xs.to_a.partition { |x| @grid[y].include? x }
      clear(ex,[y])
      set(ne,[y])
    end
  end

  def count
    @grid.keys.map { |k| @grid[k].count }.reduce(:+)
  end
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
    @grid = [false] * 1000 * 1000
  end

  def set(x,y)
    @grid[index(x,y)] = true
  end

  def clear(x,y)
    @grid[index(x,y)] = false
  end

  def flip(x,y)
    @grid[index(x,y)] = ! @grid[index(x,y)]
  end

  def count
    @grid.count(true)
  end

  private
  def index(x,y)
    x + (y * 1000)
  end
end

#grid = DenseGrid.new
grid = SparseGrid.new

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
