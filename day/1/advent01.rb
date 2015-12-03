floor = 0
entered_basement = false
index = 0
STDIN.readline.split(//).each do |cmd|
  index += 1
  case cmd
  when '('
    floor += 1
  when ')'
    floor -= 1
  else
    raise Exception.new "Unexpected character #{cmd}"
  end
  if (floor < 0) && (entered_basement == false)
    entered_basement = true
    puts "Entered basement at step #{index}"
  end
end
puts "Final floor: #{floor}"

