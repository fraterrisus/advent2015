# For the love of god don't ever monkeypatch core objects.
# On the other hand, if you're going to do it, inventing a
# new method is not as terrible.
class String
  def nice?
    # Can't contain any of these strings
    %w(ab cd pq xy).each do |comb|
      return false if include? comb
    end
    # Must have at least three vowels
    return false unless count('aeiou') >= 3
    # Must have at least one repeated letter ('xx')
    arr = chars
    (0...(size-1)).each do |i|
      return true if arr[i+1] == arr[i]
    end
    return false
  end
end

c = File.readlines('input.txt').select(&:nice?).count
puts "Found #{c} nice words"
