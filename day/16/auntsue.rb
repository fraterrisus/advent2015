sues = []
File.readlines('input.txt').each do |sue|
  sue.chomp!
  attrs = sue.split(/\s*,\s*/)
  i = attrs.shift
  idx, first_attr = i.split(/\s*:\s*/,2)
  attrs.unshift first_attr
  m = idx.match /Sue (\d+)/
  idx = m[1].to_i
  hash = { index: idx }
  attrs.each do |attr|
    k,v = attr.split /\s*:\s*/
    hash[k.to_sym] = v.to_i
  end
  sues << hash
end

match_attrs = {
  children: 3,
  cats: 7,
  samoyeds: 2,
  pomeranians: 3,
  akitas: 0,
  vizslas: 0,
  goldfish: 5,
  trees: 3,
  cars: 2,
  perfumes: 1,
}

possible_sues = []
sues.each do |sue|
  match = true
  sue.each do |k,v|
    case k
    when :index
      next
    when :cats, :trees
      if v <= match_attrs[k]
        puts "Eliminated sue ##{sue[:index]} because #{k}:#{v} <= #{match_attrs[k]}"
        match = false
        break
      end
    when :pomeranians, :goldfish
      if v >= match_attrs[k]
        puts "Eliminated sue ##{sue[:index]} because #{k}:#{v} >= #{match_attrs[k]}"
        match = false
        break
      end
    else
      if v != match_attrs[k]
        puts "Eliminated sue ##{sue[:index]} because #{k}:#{v} != #{match_attrs[k]}"
        match = false
        break
      end
    end
  end
  possible_sues << sue if match
end

puts possible_sues
