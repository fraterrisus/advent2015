def tokenize_symbols(str)
  tokens = str.gsub(/([A-Z])/, ',\1').split(/,/)
  tokens.shift
  tokens
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

@dictionary = {}
@reactions.each do |short,v|
  v.each do |long|
    ptr = @dictionary
    long.each do |symbol|
      ptr[symbol] = {} unless ptr.key? symbol
      ptr = ptr[symbol]
    end
    ptr[:symbol] = short
  end
end

def dict_lookup(list)
  options = []
  head = list
  ptr = @dictionary
  depth = 0
  while ptr.key? head.first
    depth += 1
    ptr = ptr[head.first]
    if ptr.key? :symbol
      options << { symbol: ptr[:symbol], length: depth }
    end
    head = head.drop 1
  end
  options
end

=begin
require 'yaml'
puts @dictionary.to_yaml
puts dict_lookup(["O", "B", "X"]).inspect
exit
=end

=begin
require 'benchmark'
list = tokens
worklist_dict = []
worklist_hash = []
steps = 0
iter = 1000
Benchmark.benchmark do |x|
  x.report("dict") do
    iter.times do
      worklist_dict = []
      index = 0
      head = list
      list.length.times do
        dict_lookup(head).each do |opt|
          pre = list.take(index) + [ opt[:symbol] ] + list.drop(index + opt[:length])
          worklist_dict << { list: pre, steps: steps+1 }
        end
        head = head.drop 1
        index += 1
      end
    end
  end
  x.report("hash") do
    iter.times do
      worklist_hash = []
      @reactions.each do |short, v|
        v.each do |long|
          index = 0
          while (j = array_find(list.drop(index), long))
            index += j
            pre = list.take(index) + [ short ] + list.drop(index + long.length)
            worklist_hash << { list: pre, steps: steps+1 }
            index += 1
          end
        end
      end
    end
  end
end
exit
=end


@been_here = {}

def been_here?(symbols)
  ptr = @been_here
  sym = symbols.dup
  while (x = sym.shift)
    return false unless ptr.key? x
    ptr = ptr[x]
  end
  ptr.key?(:mark)
end

def am_here(symbols)
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
  #puts line
  return
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
end

@time_now = Time.now.utc
def print_dots
  @count += 1
  if @count == 1000
    print "."
    @linelength += 1
    if @linelength == 80
      time_then = @time_now
      @time_now = Time.now.utc
      puts " %.2f s (%.2f iter/s)" % [ (@time_now - time_then), (1000.0 / (@time_now - time_then)) ]
      @linelength = 0
    end
    @count = 0
  end
end

# This method works iteratively (by maintaining a worklist), instead of recursively.
def chemsearch_list(target)
  now = Time.now.utc
  breadth = 0
  laststep = 0
  best = 2 * target.length
  worklist = [ { list: target, steps: 0 } ]
  while worklist.any?
    print_dots
    item = worklist.pop
    #item = worklist.shift

    steps = item[:steps]
    list = item[:list]

=begin
    breadth += 1
    print '.' if breadth % 100 == 0
    if steps != laststep
      duration = Time.now.utc - now
      puts " %d %.2fs (%.2fi/s)" % [ breadth, duration, 1.0 * breadth / duration ]
      now = Time.now.utc
      laststep = steps
      breadth = 0
      print "Step #{laststep} "
    end
=end

    log "[#{steps}] called on #{list}"
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
    am_here list
    # dictionary lookup
    # WTF MATE. This method found the correct path on the FIRST depth-first search path.
    # But if you add temp_worklist.shuffle instead, it keeps on rolling.
    index = 0
    head = list
    new_items = 0
    new_worklist = []
    list.length.times do
      dict_lookup(head).each do |opt|
        pre = list.take(index) + [ opt[:symbol] ] + list.drop(index + opt[:length])
        if ! been_here?(pre)
          new_worklist << { list: pre, steps: steps+1 }
        end
      end
      head = head.drop 1
      index += 1
    end
    worklist += new_worklist
=begin
    # reaction find
    @reactions.each do |short, v|
      v.each do |long|
        index = 0
        while (j = array_find(list.drop(index), long))
          index += j
          pre = list.take(index) + [ short ] + list.drop(index + long.length)
          if been_here?(pre)
            print_dots
          else
            worklist << { list: pre, steps: steps+1 }
          end
          index += 1
        end
      end
    end
=end
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
