master_boss = {}
File.readlines('input.txt').each do |line|
  key, value = line.chomp.split(/\s*:\s*/)
  master_boss[key] = value.to_i
end

master_player = {
  'Hit Points' => 100,
  'Damage' => 0,
  'Armor' => 0,
}


dam_costs = [8, 10, 25, 40, 74]
arm_costs = [0, 13, 31, 53, 75, 102]
dam_rings = [25, 50, 100]
arm_rings = [20, 40, 80]


arm_total_cost = [ ]
arm_total_cost[0] = [ arm_costs.dup + ([nil] * 5) ]
arm_total_cost[1] = [ Array.new(10), Array.new(10), Array.new(10) ]
3.times do |i|
  armor_bonus = i + 1
  arm_total_cost[1][i] = (arm_costs \
    .map { |x| x + arm_rings[i] } \
    + ([nil] * 5)) \
    .rotate(-1 * armor_bonus)
end
arm_total_cost[2] = [ Array.new(10), Array.new(10), Array.new(10) ]
[0,1,2].combination(2).each_with_index do |c,i|
  armor_bonus = c[0] + c[1] + 2
  arm_total_cost[2][i] = (arm_costs \
    .map { |x| x + arm_rings[c[0]] + arm_rings[c[1]] } \
    + ([nil] * 5)) \
    .rotate(-1 * armor_bonus)
end

puts
puts 'Armor costs: (min 0)'
puts '0 rings: ' + arm_total_cost[0][0].inspect
puts '1 ring : ' + arm_total_cost[1][0].inspect
puts '         ' + arm_total_cost[1][1].inspect
puts '         ' + arm_total_cost[1][2].inspect
puts '2 rings: ' + arm_total_cost[2][0].inspect
puts '         ' + arm_total_cost[2][1].inspect
puts '         ' + arm_total_cost[2][2].inspect

dam_total_cost = [ ]
dam_total_cost[0] = [ dam_costs.dup + ([nil] * 5) ]
dam_total_cost[1] = [ Array.new(10), Array.new(10), Array.new(10) ]
3.times do |i|
  damor_bonus = i + 1
  dam_total_cost[1][i] = (dam_costs \
    .map { |x| x + dam_rings[i] } \
    + ([nil] * 5)) \
    .rotate(-1 * damor_bonus)
end
dam_total_cost[2] = [ Array.new(10), Array.new(10), Array.new(10) ]
[0,1,2].combination(2).each_with_index do |c,i|
  damor_bonus = c[0] + c[1] + 2
  dam_total_cost[2][i] = (dam_costs \
    .map { |x| x + dam_rings[c[0]] + dam_rings[c[1]] } \
    + ([nil] * 5)) \
    .rotate(-1 * damor_bonus)
end

puts
puts 'Damage costs: (min 4)'
puts '0 rings: ' + dam_total_cost[0][0].inspect
puts '1 ring : ' + dam_total_cost[1][0].inspect
puts '         ' + dam_total_cost[1][1].inspect
puts '         ' + dam_total_cost[1][2].inspect
puts '2 rings: ' + dam_total_cost[2][0].inspect
puts '         ' + dam_total_cost[2][1].inspect
puts '         ' + dam_total_cost[2][2].inspect

arm_best_cost = []
arm_best_cost[0] = arm_total_cost[0][0].dup
arm_best_cost[1] = 
  (arm_total_cost[0] + arm_total_cost[1]) \
  .transpose.map { |r| r.compact.min }
arm_best_cost[2] = 
  (arm_total_cost[0] + arm_total_cost[1] + arm_total_cost[2]) \
  .transpose.map { |r| r.compact.min }

puts
puts 'Best armor costs:'
puts '0 rings: ' + arm_best_cost[0].inspect
puts '1 ring : ' + arm_best_cost[1].inspect
puts '2 rings: ' + arm_best_cost[2].inspect

dam_best_cost = []
dam_best_cost[0] = dam_total_cost[0][0].dup
dam_best_cost[1] = 
  (dam_total_cost[0] + dam_total_cost[1]) \
  .transpose.map { |r| r.compact.min }
dam_best_cost[2] = 
  (dam_total_cost[0] + dam_total_cost[1] + dam_total_cost[2]) \
  .transpose.map { |r| r.compact.min }

puts
puts 'Best damage costs:'
puts '0 rings: ' + dam_best_cost[0].inspect
puts '1 ring : ' + dam_best_cost[1].inspect
puts '2 rings: ' + dam_best_cost[2].inspect


player = master_player.dup
boss = master_boss.dup

puts
bestval = 100000
player['Armor'] = 0
while player['Armor'] < 11
  player['Damage'] = 4
  while player['Damage'] < 14
    boss_dpt = [ 1, boss['Damage'] - player['Armor'] ].max
    boss_win = (1.0 * player['Hit Points'] / boss_dpt).ceil

    player_dpt = [ 1, player['Damage'] - boss['Armor'] ].max
    player_win = (1.0 * boss['Hit Points'] / player_dpt).ceil

    if player_win <= boss_win
      puts "Player wins with Arm:#{player['Armor']} Dmg:#{player['Damage']}"
      a = player['Armor']
      d = player['Damage']
      [0,1,2].each do |r|
        next if arm_best_cost[r][a].nil?
        next if dam_best_cost[2-r][d-4].nil?
        print "A:#{a}(#{r}) "
        print "D:#{d}(#{2-r}) "
        print "=> $"
        value = arm_best_cost[r][a] + dam_best_cost[2-r][d-4]
        puts value
        bestval = [ value, bestval ].min
      end
    end
    player['Damage'] += 1
  end
  player['Armor'] += 1
end

puts
puts "To win, spend $#{bestval}"
