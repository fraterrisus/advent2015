password = ARGV[0].dup

class String
  def increment!
    fail 'Only works on strings of length 8' unless self.length == 8
    repl = dup
    (0...self.length).to_a.reverse.each do |i|
      if self[i] == 'z'
        repl[i] = 'a'
      else
        repl[i] = (self[i].ord + 1).chr
        break
      end
    end
    replace(repl)
  end

  def valid?
    return false if match /[iol]/

    # must include a run-of-three (abc, fgh, xyz)
    runofthree = false
    ords = self.split(//).map(&:ord)
    (0...self.length-2).each do |i|
      if (ords[i] == ords[i+1] - 1) &&
        (ords[i] == ords[i+2] - 2)
        runofthree = true
        break
      end
    end
    return false unless runofthree

    # must include two non-overlapping doubles (aabb, ccadd)
    doubles = 0
    idx = 0
    while idx < self.length - 1
      if self[idx] == self[idx+1]
        doubles += 1
        idx += 1
      end
      idx += 1
    end
    return false unless doubles >= 2
    
    true
  end
end

begin
  password.increment!
end while (! password.valid?)
puts password
