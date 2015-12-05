class String
  def nice?
    # Must have a pair of letters that repeats ('ab...ab')
    naughty = true
    (0...(size-2)).each do |i|
      pair = self[i,2]
      rest = self[i+2..-1]
      if rest.include? pair
        naughty = false
        break
      end
    end
    return false if naughty
    
    # Must have at least one letter repeated with a 1ch gap ('x.x')
    arr = chars
    nice = false
    (0...(size-2)).each do |i|
      if arr[i+2] == arr[i]
        nice = true
        break
      end
    end
    nice
  end
end

c = File.readlines('input.txt').select(&:nice?).count
puts "Found #{c} nice words"
