master_boss = {}
File.readlines('input.txt').each do |line|
  key, value = line.chomp.split(/\s*:\s*/)
  master_boss[key] = value.to_i
end

# We can apply all spells the same way (except for :armor); an effect that
# takes place "immediately" like Magic Missile or Drain are equivalent to a
# one-turn effect that take place at the beginning of the boss's turn.
Spell = Struct.new(:duration, :cost, :damage, :healing, :armor, :manaboost)

class GameState
  Debug = false
  HardMode = true

  Spells = {
    missile:  Spell.new(1,  53, 4, 0, 0,   0),
    drain:    Spell.new(1,  73, 2, 2, 0,   0),
    shield:   Spell.new(6, 113, 0, 0, 7,   0),
    poison:   Spell.new(6, 173, 3, 0, 0,   0),
    recharge: Spell.new(5, 229, 0, 0, 0, 101),
  }.freeze


  def debug(x)
    puts x if Debug
  end

  def boss=(x)
    @boss = x
  end

  def player=(x)
    @player = x
  end

  def effects
    @effects
  end

  def manaspent
    @manaspent
  end

  def manaspent=(x)
    @manaspent = x
  end

  def trail=(x)
    @trail = x
  end

  def initialize(bosshp = 0, bossdmg = 0)
    @trail = []
    @boss = { hp: bosshp, damage: bossdmg }
    @player = { hp: 50, armor: 0, mana: 500 }
    @manaspent = 0
    @effects = {}
    Spells.keys.each { |k| @effects[k] = nil }
  end

  def dup
    n = GameState.new
    n.trail = @trail.dup
    n.boss = @boss.dup
    n.player = @player.dup
    @effects.each { |k,v| n.effects[k] = (v.nil?) ? nil : v.dup }
    n.manaspent = @manaspent
    n
  end

  def player_dead?
    @player[:hp] <= 0
  end

  def player_dry?
    @player[:mana] < 53
  end

  def player_heals(x)
    @player[:hp] += x
    debug "Player heals #{x} HP, now has #{@player[:hp]} HP" if x > 0
  end

  def player_manaboost(x)
    @player[:mana] += x
    debug "Player gains #{x} mana, now has #{@player[:mana]}" if x > 0
  end

  def player_shield(arm, dur)
    if arm > 0 
      if dur > 1
        @player[:armor] = arm
        debug "Player shield active, armor = #{arm}"
      else
        @player[:armor] = 0
      end
    end
  end

  def player_damage(x)
    @player[:hp] -= x
    debug "Player takes #{x} damage, now has #{@player[:hp]} HP"
  end

  def boss_dead?
    @boss[:hp] <= 0
  end

  def boss_damage(x)
    @boss[:hp] -= x
    debug "Boss takes #{x} damage, now has #{@boss[:hp]} HP" if x > 0
  end

  def boss_attack
    player_damage [ 1, @boss[:damage] - @player[:armor] ].max
  end

  def inactive_effects
    Spells.keys.select { |k| @effects[k].nil? }
  end

  def active_effects
    Spells.keys.select { |k| ! @effects[k].nil? }
  end

  def add_effect(eff)
    return nil if active_effects.include? eff
    return nil if @player[:mana] < Spells[eff].cost
    @trail << eff
    @effects[eff] = Spells[eff].dup
    @player[:mana] -= @effects[eff].cost
    @manaspent += @effects[eff].cost
    self
  end

  def apply_effects
    @effects.each do |k,v|
      next if v.nil?
      spell_name = k.to_s
      spell_name[0] = spell_name[0].upcase

      boss_damage v.damage
      player_heals v.healing
      player_manaboost v.manaboost
      player_shield v.armor, v.duration

      v.duration -= 1
      debug "#{spell_name} timer is now #{v.duration}"
      @effects[k] = nil if v.duration <= 0
    end
  end

  # Take a GameState and return a list of all the possible GameStates that can
  # result from it.
  def choose_actions
    Spells.keys.map { |spell| self.dup.add_effect spell }.compact
  end

  def player_turn
    debug "* PLAYER TURN"
    player_damage(1) if HardMode
    apply_effects
    choose_actions
  end

  def boss_turn
    debug "* BOSS TURN"
    apply_effects
    boss_attack unless boss_dead?
  end

  def to_s
    [ "Mana: #{@manaspent} Trail: #{@trail.inspect}",
      "Plyr: #{@player.inspect}",
      "Boss: #{@boss.inspect}",
      "Active effects: #{active_effects.inspect}" ].join "\n"
  end

end

# Impossibly large value
best_mana_cost = 1_000_000

# Game start
# Initialize the worklist with all the possible first turns
start_state = GameState.new(master_boss['Hit Points'], master_boss['Damage'])
puts start_state
worklist = start_state.player_turn.shuffle

while (worklist.any?)
  # BFS: ~2:40
  #state = worklist.shift
  # DFS: ~0:25  presumably it gets to prune faster so the memory requirements are lower
  state = worklist.pop
  
  puts '---'
  puts "Worklist size: #{worklist.count}"
  puts "Best mana cost: #{best_mana_cost}"
  puts state

  # If this state has spent more mana than our best solution so far,
  # don't bother chasing it.
  if state.manaspent >= best_mana_cost
    puts "Skipping, already spent more than #{best_mana_cost} mana"
    next
  end

  state.boss_turn

  if state.boss_dead?
    puts "Player wins :) #{state.manaspent} mana spent"
    best_mana_cost = [ state.manaspent, best_mana_cost ].min
    next
  end
  if state.player_dead? || state.player_dry?
    puts "Player loses :("
    next
  end

  new_states = state.player_turn.shuffle

  if state.player_dead?
    puts "Player loses :("
    next
  end
  if state.boss_dead?
    puts "Player wins :) #{state.manaspent} mana spent"
    best_mana_cost = [ state.manaspent, best_mana_cost ].min
    next
  end

  worklist += new_states.select { |st| st.manaspent < best_mana_cost }
end

puts "Best victory: #{best_mana_cost} mana"
