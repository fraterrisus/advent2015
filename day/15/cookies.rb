class Ilist < Hash
  def randomize!
    tot = 0
    amt = 0
    cnt = count
    i = 0
    each do |k,v|
      max = 101 - tot - (cnt - i)
      if (i == cnt-1)
        amt = max
      else
        amt = Random.rand(max)+1
      end
      tot += amt
      v[:amount] = amt
      i += 1
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
    ilist.keys.each do |k2|
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
