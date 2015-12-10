code_count = 0
char_count = 0
File.readlines('input.txt').each do |str|
  str.chomp!
  puts str
  chars = str.split //
  code_count += chars.length
  mystring = ''
  mode = :normal
  chars.each do |chr|
    print mode.to_s
    print ' '
    case mode
    when :normal
      case chr
      when '\\'
        mystring = chr
        mode = :slash
      when '"'
        puts '"'
        mystring = ''
      when "\n"
        puts 'newline'
        mystring = ''
      else
        char_count += 1
        puts chr
        mystring = ''
      end
    when :slash
      case chr
      when 'x'
        mystring += chr
        mode = :hexcode1
      when '"', "\\"
        mystring += chr
        char_count += 1
        puts mystring
        mystring = ''
        mode = :normal
      else
        mystring += chr
        puts mystring
        puts "Error: escaped character was not x, \\, or \""
        mystring = ''
        mode = :normal
      end
    when :hexcode1
      mystring += chr
      mode = :hexcode2
    when :hexcode2
      mystring += chr
      char_count += 1
      puts mystring
      mystring = ''
      mode = :normal
    end
  end
  puts "Code count: #{code_count}"
  puts "Char count: #{char_count}"
end
puts "Delta: #{code_count - char_count}"
