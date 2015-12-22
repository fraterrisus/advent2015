def tokenize_symbols(str)
  tokens = str.gsub(/([A-Z])/, ',\1').split(/,/)
  tokens.shift
  tokens
end

subs = File.readlines('input.txt')
target = subs.pop.chomp
while (! subs.last.match(/\=\>/)) ; subs.pop ; end
@reactions = {}
subs.each do |sub|
  sub.chomp!
  k,v = sub.split(/\s*\=\>\s*/)
  @reactions[k] = [] unless @reactions.key?(k)
  @reactions[k] << tokenize_symbols(v)
end

tokens = tokenize_symbols target

@been_here = {}

def been_here?(symbols)
  return false

  ptr = @been_here
  sym = symbols.dup
  while (x = sym.shift)
    return false unless ptr.key? x
    ptr = ptr[x]
  end
  ptr.key?(:mark)
end

def am_here(symbols)
  return nil

  ptr = @been_here
  sym = symbols.dup
  while (x = sym.shift)
    ptr[x] = {} unless ptr.key? x
    ptr = ptr[x]
  end
  ptr[:mark] = true
  nil
end

def array_find(haystack, needle)
  i = 0
  while (j = haystack.drop(i).index(needle[0]))
    i += j
    return i if haystack[i, needle.length] == needle
    i += 1
  end
  return nil
end

def count_beens(hash)
  count = 0
  count += 1 if hash.key? :mark
  hash.each do |k,v|
    count += count_beens(v) if v.is_a? Hash
  end
  count
end

@count = 0
@linelength = 0
def log(line)
=begin
  @count += 1
  if @count == 10000
    print "."
    @linelength += 1
    if @linelength == 79
      puts
      puts "@been_here contains #{count_beens(@been_here)} keys"
      @linelength = 0
    end
    @count = 0
  end
=end
end

@time_now = Time.now.utc
def print_dots
  @count += 1
  if @count == 10000
    print "."
    @linelength += 1
    if @linelength == 80
      time_then = @time_now
      @time_now = Time.now.utc
      puts " %.2f s (%.2f iter/s)" % [ (@time_now - time_then), (10000.0 / (@time_now - time_then)) ]
      @linelength = 0
    end
    @count = 0
  end
end

def chemsearch_list(target)
  best = 2 * target.length
  worklist = [ { list: target, steps: 0 } ]
  while worklist.any?
    print_dots
    item = worklist.pop
    steps = item[:steps]
    list = item[:list]
    if steps >= best
      log "[#{steps}] better path already found"
      next
    end
    if list.length == 1
      if list == [ 'e' ]
        puts "[#{steps}] found a path"
        best = [ best, steps ].min
      else
        log "[#{steps}] dead end"
        next
      end
    end
    if been_here?(list)
      log "[#{steps}] been here"
      next
    end
    log "[#{steps}] called on #{list}"
    am_here list
    @reactions.each do |short, v|
      v.each do |long|
        index = 0
        while (j = array_find(list.drop(index), long))
          index += j
          pre = list.take(index) + [ short ] + list.drop(index + long.length)
          worklist << { list: pre, steps: steps+1 }
          index += 1
        end
      end
    end
    log "[#{steps}] best so far: #{best}"
  end
  best
end

def chemsearch(post, best, steps = 0)
  if steps >= best
    log "[#{steps}] path too long"
    return best
  end
  if post.length == 1
    if post == ['e']
      puts "[#{steps}] found a path"
      return steps
    else
      return best
    end
  end
  if been_here? post
    log "[#{steps}] been here before"
    return best
  end
  log "[#{steps}] Called on #{post}"
  #puts "[#{steps}] Recursing..."
  mybest = best
  am_here post
  @reactions.each do |short, v|
    v.each do |long|
      index = 0
      while (j = array_find(post.drop(index), long))
        index += j
        pre = post.take(index) + [ short ] + post.drop(index + long.length)
        index += 1
        mybest = [ mybest, chemsearch(pre, best, steps+1) ].min
      end
    end
  end
  log "[#{steps}] Returning best answer #{mybest}"
  mybest
end

# tokens = ['H','Ca','F']
#len = chemsearch(tokens, 10000, 0) 
len = chemsearch_list(tokens)
puts "Found a path in #{len} steps"
