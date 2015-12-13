def find_numbers(obj)
  case obj
  when String
    0
  when Fixnum
    obj
  when Array
    obj.map { |x| find_numbers(x) }.reduce(:+)
  when Hash
    # Part 2: ignore any object with a value "red"
    if obj.values.include?('red')
      0 
    else
      obj.values.map { |x| find_numbers x }.reduce(:+)
    end
  else
    fail "Don't know how to handle #{obj.class}"
  end
end

require 'json'
puts find_numbers(JSON.parse(File.read('input.txt')))
