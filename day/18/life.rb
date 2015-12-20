class LifeCell
  @state = false

  def initialize(state)
    @state = state
  end

  def alive?
    @state
  end

  def lives
    @state = true
  end

  def dies
    @state = false
  end

  def to_s
    (@state) ? '#' : '.'
  end
end

class LifeBoard
  # Part 2 of the puzzle adds a "bug" where the corners are all stuck on.
  # Set this to TRUE to run the solution for part 2.
  CORNER_BUG = false

  def initialize
    @cells = []
  end

  def try_alive?(x,y)
    return false if y < 0 || y >= @cells.count || @cells[y].nil?
    return false if x < 0 || x >= @cells[y].count || @cells[y][x].nil?
    @cells[y][x].alive?
  end

  def cells
    @cells
  end

  def live_count
    @cells.map { |r| r.select(&:alive?).count }.reduce(:+)
  end

  def step
    # Create a "next step" state so that our updates are consistent on the
    # "current board", then update the entire board at once. This is pretty
    # memory heavy because we're creating new objects each time, but worrying
    # about space efficiency isn't the Ruby way! *thumbs up*
    new_board = LifeBoard.new

    # (Note: I also tried creating LifeBoard#dup, but that got wiped when I was
    # debugging #step. Not sure if it's any more efficient to generate a copy
    # board and then modify only the cells that change.

    @cells.each_with_index do |r,y|
      new_board.cells[y] = []
      r.each_with_index do |c,x|
        on = 0
        [x-1, x, x+1].each do |i|
          [y-1, y, y+1].each do |j|
            next if i == x && j == y # Don't count myself
            on += 1 if try_alive?(i,j)
          end
        end
        if c.alive?
          new_board.cells[y][x] = LifeCell.new(on == 2 || on == 3)
        else
          new_board.cells[y][x] = LifeCell.new(on == 3)
        end
      end
    end

    if LifeBoard::CORNER_BUG
      new_board.cells.first.first.lives
      new_board.cells.first.last.lives
      new_board.cells.last.first.lives
      new_board.cells.last.last.lives
    end

    # Move the "new" state to the "current" object.
    @cells = new_board.cells
  end

  def self.from_file(filename)
    board = LifeBoard.new()
    File.readlines(filename).each_with_index do |line,y|
      line.chomp!
      tokens = line.split //
      board.cells[y] = []
      tokens.each_with_index do |t,x|
        case t
        when '#'
          board.cells[y][x] = LifeCell.new(true)
        when '.'
          board.cells[y][x] = LifeCell.new(false)
        else
          fail "Unrecognized token #{token} at (#{x},#{y})"
        end
      end
    end
    board
  end

  def to_s
    @cells.map { |y| y.map(&:to_s).join('') }.join("\n")
  end
end

board = LifeBoard.from_file('input.txt')
100.times do |i|
  board.step
  #File.write "log#{i}.txt", board.to_s
  puts "#{i+1}: #{board.live_count}"
end
