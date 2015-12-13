scores = { }
maxvalue = 0

File.readlines('input.txt').each do |pair|
  pair.chomp!
  m = pair.match /\A(\w+) would (gain|lose) (\d+) happiness units by sitting next to (\w+)\.\z/
  n1 = m[1].downcase.to_sym
  n2 = m[4].downcase.to_sym
  v = m[3].to_i
  maxvalue -= v
  v = -v if m[2] == 'lose'
  if scores.key? n1
    scores[n1][n2] = v
  else
    scores[n1] = { n2 => v }
  end
end

# Part 2: add 0pt relationships between you and everyone else
scores[:me] = { }
scores.keys.each do |k|
  scores[k][:me] = 0
  scores[:me][k] = 0
end
# End part 2 changes

scores.keys.permutation.each do |perm|
  value = 0
  perm.each_with_index do |k,i|
    n1 = perm[(i - 1) % perm.count]
    n2 = perm[(i + 1) % perm.count]
    value += scores[k][n1]
    value += scores[k][n2]
  end
  if value > maxvalue
    maxvalue = value
    puts "maxvalue: #{maxvalue} #{perm}"
  end
end
