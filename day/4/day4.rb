require 'digest'

length = ARGV.shift.to_i
fail 'Please specify a number of leading zeroes' if length.nil?
base = ARGV.shift
fail 'Please specify a base string' if base.nil?

num = -1
dig = ''
while dig[0...length] != '0' * length
  num += 1
  str = "#{base}#{num}"
  md5 = Digest::MD5.new
  md5 << str
  dig = md5.hexdigest
end
puts num
puts str
puts dig
