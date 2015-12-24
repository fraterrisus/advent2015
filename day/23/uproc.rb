imem = File.readlines('input.txt').each(&:chomp!)
ip = 0
regs = [ 0, 0 ]

def parse_instruction(str)
  return nil if str.nil?
  tokens = str.split /\s*,?\s+/
  iword = tokens[0].to_sym
  case iword
  when :hlf, :tpl, :inc
    return { iword: iword, offset: 1, reg: (tokens[1] == 'a') ? 0 : 1 }
  when :jmp
    return { iword: iword, offset: tokens[1].to_i, reg: nil }
  when :jio, :jie
    return { iword: iword, offset: tokens[2].to_i, reg: (tokens[1] == 'a') ? 0 : 1 }
  else
    fail "Error: unrecognized command #{iword}"
  end
  iword
end


while i = parse_instruction(imem.fetch(ip,nil))
  regname = case i[:reg]
            when 0
              'a'
            when 1
              'b'
            when nil
              '-'
            end
  print "[%02d] %3s %1s %+3d  " % [ ip, i[:iword], regname, i[:offset] ]
  case i[:iword]
  when :hlf
    regs[ i[:reg] ] /= 2
    ip += 1
  when :tpl
    regs[ i[:reg] ] *= 3
    ip += 1
  when :inc
    regs[ i[:reg] ] += 1
    ip += 1
  when :jmp
    ip += i[:offset]
  when :jio
    ip += (regs[ i[:reg] ] == 1)  ? i[:offset] : 1
  when :jie
    ip += (regs[ i[:reg] ].even?) ? i[:offset] : 1
  end
  
  puts "a:%06d  b:%06d" % regs
end

puts "Register b = #{regs[1]}"
