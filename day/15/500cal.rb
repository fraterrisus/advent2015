class Ilist < Hash

  @@calcounts = {}

  def calcounts
    @@calcounts
  end

  def self.set_calcounts(cc)
    fail unless cc.is_a? Hash
    @@calcounts = cc
  end

  def randomize!
    new_calcounts = @@calcounts.dup
    new_calcounts.each do |cal,cnt|
      ings = self.keys.select { |k| self[k][:calories] == cal }
      tot = 0
      amt = 0
      i = 0
      ings.each do |k|
        max = cnt + 1 - tot - (ings.count - i)
        if (i == ings.count - 1)
          amt = max
        else
          amt = Random.rand(max)+1
        end
        tot += amt
        self[k][:amount] = amt
        i += 1
      end
    end
  end

  def score
    total = {}
    keys.each do |k|
      self[k].each do |a,v|
        next if a == :amount || a == :calories
        total[a] = 0 unless total.key? a
        total[a] += v * self[k][:amount]
      end
    end

    result = 1
    total.each do |k,v|
      if (v <= 0)
        result = 0
      else
        result *= v
      end
    end
    result
  end

  def dup
    newlist = Ilist.new
    each do |k,v|
      newlist[k] = v.dup
    end
    newlist
  end

  def to_s
    s = '['
    s += self.map { |k,v| "%2d" % v[:amount] }.join ','
    s << "] : #{score}"
  end
end

ilist = Ilist.new

### 0. Read baseline data from the input file
File.readlines('input.txt').each do |ing|
  ing.chomp!
  key, attribute_list = ing.split /\s*:\s*/
  ilist[key] = {}
  tokens = attribute_list.split /\s*,\s*/
  tokens.each do |t|
    attribute, value = t.split /\s+/
    ilist[key][attribute.to_sym] = value.to_i
  end
end

### 1. Use Gaussian elimination to determine the relative counts of each class
#of calories. We can't deal with more than two different calorie values across
#the N ingredients, because we only have a system of two equations (ax+by = 500
#calories, a+b = 100 oz)
cals = ilist.map { |k,v| v[:calories] }.uniq
fail unless cals.count == 2
matrix = [ 
  cals + [ 500 ], 
  ([ 1 ] * cals.count) + [ 100 ]
]
while (matrix[0][0] != 0)
  matrix[1].count.times do |i|
    matrix[0][i] -= matrix[1][i]
  end
end
values = []
values[1] = matrix[0][2] / matrix[0][1]
values[0] = matrix[1][2] - values[1]
calcounts = {}
cals.each_with_index { |k,i| calcounts[k] = values[i] }
puts calcounts.inspect

Ilist.set_calcounts calcounts

### 1. Randomly find a non-zero solution
s = 0
while s == 0 do
  ilist.randomize!
  s = ilist.score
  puts ilist
end

### 2. Hill-climb (search all neighboring solutions for a better one)
done = false
while (!done) do
  #puts "Loop #{ilist.map { |k,v| v[:amount] }} = #{s}"
  done = true
  max_s = s
  max_ilist = {}
  new_ilist = {}
  ilist.keys.each do |k1|
    ilist.keys.select { |k| ilist[k][:calories] == ilist[k1][:calories] }.each do |k2|
      next if k2 == k1
      new_ilist = ilist.dup
      new_ilist[k1][:amount] += 1
      new_ilist[k2][:amount] -= 1
      new_s = new_ilist.score
      #puts "Try  #{new_ilist.map { |k,v| v[:amount] }} = #{new_s}"
      if new_s > max_s
        max_s = new_s
        max_ilist = new_ilist
      end
    end
  end
  if max_s > s
    #puts "Best #{max_ilist.map { |k,v| v[:amount] }} = #{max_s}"
    ilist = max_ilist
    s = max_s
    done = false
  end
  puts ilist
end

### 3. In theory we could re-run this a couple of times with different random
#inputs, but because of the parabolic nature of the evaluation function it
#seems like there will only be one optimum.
