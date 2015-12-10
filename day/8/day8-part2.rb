old_chars = 0
new_chars = 0
File.readlines('input.txt').each do |str|
  str.chomp!
  puts str + " #{str.length}"
  newstring = ''
  str.split(//).each do |c|
    case c
    when '"'
      print 'quote '
      newstring += '\\' + '"'
    when '\\'
      print 'slash '
      newstring += '\\' + '\\'
    else
      print c + ' '
      newstring += c
    end
  end
  puts
  newstring = "\"#{newstring}\""
  puts newstring + " #{newstring.length}"
  old_chars += str.length
  new_chars += newstring.length
end
puts "Old: #{old_chars}"
puts "New: #{new_chars}"
puts "Delta: #{new_chars - old_chars}"
