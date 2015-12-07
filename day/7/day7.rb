class Expr
  def initialize(fn, lop, rop)
    @function = fn
    @left = lop
    @right = rop
  end

  def to_s
    rv = "#{@function} #{@right}"
    rv = "#{@left} #{rv}" if @left
    rv
  end

  def evaluate
    puts "Eval: #{@left} #{@function} #{@right}"
    l = eval_wire(@left)
    r = eval_wire(@right)
    puts "Got : #{l} #{@function} #{r}"
    rv = case @function
    when 'LSHIFT'
      l << r
    when 'RSHIFT'
      l >> r
    when 'NOT'
      ~r
    when 'AND'
      l & r
    when 'OR'
      l | r
    else
      fail "Unrecognized operator #{function}"
    end
    puts "Retn: #{rv}"
    rv
  end
end

def eval_wire(id)
  return nil if id.nil?
  return id unless id.is_a? String
  return nil unless $wires.key? id
  case $wires[id]
  when String
    $wires[id] = $wires[$wires[id]].evaluate
    return $wires[id]
  when Fixnum
    return $wires[id]
  when Expr
    $wires[id] = $wires[id].evaluate
    return $wires[id]
  else
    fail "Unrecognized value for #{id}"
  end
end

def try_to_i(s)
  return 0 if s == '0'
  return s if s.to_i == 0
  return s.to_i
end

$wires = Hash.new

File.readlines('input.txt').each do |w|
  target = nil
  expr = nil
  tokens = w.split /\s+/
  if tokens[1] == '->'
    target = tokens[2]
    expr = try_to_i(tokens[0])
  end
  if tokens[2] == '->'
    target = tokens[3]
    expr = Expr.new(tokens[0], nil, try_to_i(tokens[1]))
  end
  if tokens[3] == '->'
    target = tokens[4]
    expr = Expr.new(tokens[1], try_to_i(tokens[0]), try_to_i(tokens[2]))
  end
  if target
    puts "#{target} <- #{expr}"
    $wires[target] = expr
    next
  end
  fail "Unparsed data line: #{w}"
end

puts
puts "a = #{eval_wire('a')}"
