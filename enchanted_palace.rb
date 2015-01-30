# based off ENCHANTED PALACE (c) 1994 MILTON BRADLEY
# Dawn Pattison, initial v 1/28/15

# Princess class stores player attributes and contains many game functions
class Princess
  attr_accessor :location, :status, :lantern, :mirror, :key, :name, :found
  def initialize(name)
    rooms = [:stable, :kitchen, :dungeon, :throneroom, \
                  :bedroom, :musicroom, :garden]
    @name = name
    @location = ''
    @status = 'girl'
    @found = []
    @lantern = rooms[rand(7)]
    rooms.delete(@lantern)
    @mirror = rooms[rand(6)]
    rooms.delete(@mirror)
    @key = rooms[rand(5)]
  end
  # Offers choice: Search or spell?
  def turn
    choice = queen_request
    if choice == 'R'
      where_going
    elsif choice == 'S'
      cast_spell
    else
      puts "I can't understand you, #{@name.upcase}!"
    end
  end
  # Queen indicates player turn
  def queen_request
    puts ''
    sleep(0.75)
    puts '==========================================================='
    print "Good Queen: #{@name.upcase}, go to a (R)oom, or cast a (S)pell! "
    gets.chomp.capitalize 
  end
  # If searching room, offers choices.
  def where_going
    print_attributes
    puts 'Which room would you like to enter?'
    puts '(S)table, (K)itchen, (D)ungeon, (T)hrone Room,'
    print '(G)arden, (B)edroom or (M)usic Room: '
    answer = gets.chomp.upcase
    room_hash = { 'S' => :stable, 'K' => :kitchen, 'D' => :dungeon, \
                           'T' => :throneroom, 'G' => :garden, 'B' => :bedroom, \
                           'M' => :musicroom }
    going = room_hash[answer]
    go_to_room(going)
  end
  # Prints princess attributes
  def print_attributes
    inventory
    status_girl
    location_girl
  end
  # Princess  enters room, searches. runs frog spell.
  def go_to_room(room)
    @location = room
    puts "You search the #{@location}."
    search(room)
    x = eval("$#{room}")
    if x.bewitched == 0
      frog_spell(room)
    else
      puts 'This room is already bewitched!'
      puts 'Turn into a frog!' if @status == 'girl'
      @status = 'frog'
    end
  end
  # Princess searches room for items.
  def search(room)
    sleep(2)
    puts ' '
    x = eval ("$#{room}")
    if @lantern == room
      puts "You found a LANTERN in the #{x.name}."
      @found << :lantern
    elsif @key == room
      puts "You found a KEY in the #{x.name}."
      @found << :key
    elsif @mirror == room
      puts "You found a MIRROR in the #{x.name}."
      @found << :mirror
    else
      puts 'Evil Witch: There\'s nothing for you here! Ha!'
    end
    puts ''
  end
  # 1 in 3 chance room is bewitched
  def frog_spell(room)
    chance = rand(3)
    in_danger = []
    $princess_list.each do |princess|
      if princess.location == room
        in_danger.push princess.name if princess.status == 'girl'
      end
    end
    return unless chance == 1 && in_danger != []
    sleep(2)
    x = eval ("$#{room}")
    puts "Evil Witch: Ah ha haa! I hear #{x.sound_effects} " \
      "and who do I see? #{in_danger.join(', ').upcase}" \
      ' waiting for me! Ah ha haa! Turn into a frog!'
    puts 'Pop! Ribbit, ribbit.'
    $princess_list.each do |princess|
      princess.status = 'frog' if in_danger.include? princess.name
    end
    rooms = [:stable, :kitchen, :garden, :dungeon, \
    :throneroom, :bedroom, :musicroom]
    rooms.each do |i|
      y = eval("$#{i}")
      y.bewitched = 0
    end
    x.bewitched = 1 
  end
  # if casting spell, one of three scenarios can happen 1)save your friend
  # 2) save your friend and steal her token, 3) steal someone's token
  def cast_spell
    puts ' '
    print_attributes
    puts ' '
    wand = rand(3)
    frogs = []
    tokens = []
    $princess_list.each do |princess|
      if princess.status == 'frog'
        frogs << [princess.name, princess.found] unless @name == princess.name
      end
      if princess.found != []
        tokens << [princess.name, princess.found] unless @name == princess.name
      end
    end
    if frogs != []
      chosen = frogs[rand(frogs.length)]
      lucky_lady = chosen[0]
      up_for_grabs = chosen [1]
    else
      lucky_lady = ''
      up_for_grabs = []
    end
    # Save princess
    if wand == 0
      if lucky_lady != ''
        mod_frog(lucky_lady)
      else
        puts 'You wave your wand and nothing happens!'
      end
    # Save princess/steal her token
    elsif wand == 1
      mod_frog(lucky_lady) if lucky_lady != ''
      mod_tokens(lucky_lady, up_for_grabs) if up_for_grabs != []
      if lucky_lady == '' && up_for_grabs == []
        puts 'You wave your wand...nothing happens!'
      end
    # Steal someone's token
    else
      if tokens != []
        selected = tokens[rand(tokens.length)]
        name_stolen = selected[0]
        tokens_stolen = selected [1]
        mod_tokens(name_stolen, tokens_stolen)
      else
        puts 'You wave your wand! Nothing happens!'
      end
    end
  end

  # Rescues fellow princess from the spell
  def mod_frog(lucky_lady)
    puts "#{@name.capitalize}, you saved #{lucky_lady.capitalize} from the spell!"
    $princess_list.each do |princess|
      princess.status = 'girl' if princess.name == lucky_lady
    end
  end
  # Has selected player give token to princess
  def mod_tokens(player_at_risk, tokens_at_risk)
    item_stolen = tokens_at_risk[rand(tokens_at_risk.length)]
    puts "#{player_at_risk.capitalize}, give #{@name.capitalize}" \
      " a #{item_stolen.upcase}!"
    @found <<  item_stolen
    $princess_list.each do |princess|
      if princess.name == player_at_risk
        princess.found.slice!(princess.found.index(item_stolen))
      end
    end
  end
# Prints player's inventory
  def inventory
    print 'Inventory: '
    if found == []
      print 'None'
    else
      @found.each { |i| print "#{i} " }
    end		
    puts ' '
  end
  # prints player's status
  def status_girl
    puts "Status: #{@status}"	
  end
  # prints player's location
  def location_girl
    if @location == ''
      puts 'Location: Entrance'
    else
      puts "Location: #{@location}"
    end
  end
end
# Room class
class Room
  attr_accessor :name, :reference, :sound_effects, :bewitched
  def initialize(reference, name, sound_effects, bewitched = 0)
    @reference = reference
    @name = name
    @sound_effects = sound_effects
    @bewitched = bewitched
  end
end
# Game class. Runs opening script, loops through princesses, closing script
class Game
  attr_accessor :princess_list, :princesses
  def initialize
    princesses = [:rose, :sky, :violet, :amber]
    remove = []
    $princess_list = []
    puts ''
    puts '=========================================================='.center(60)
    puts 'Welcome to ENCHANTED PALACE! '.center(60)
    puts ''
    puts 'Your objective: find a lantern, mirror, and key '.center(60)
    puts 'hidden inside.  The free the Good Queen, banish the Evil Witch, '.center(60)
    puts 'and be crowned Princess of the Kingdom!'.center(60)
    sleep(0.5)
    puts ' '
    puts 'Remember, frogs are not much use to the Queen!'.center(60)
    sleep 1
    puts ''
    puts '=========================================================='.center(60)
    sleep(1)
    puts 'Good Queen: Who will help me?'
    princesses.each do |princess|
      puts "#{princess.capitalize}? Y/N"
      response = gets.chomp.upcase
      if response == 'Y'
        $princess_list << Princess.new(princess)
      else
        remove << princess
      end		
    end
    remove.each { |i| princesses.delete(i) }
    @princesses = princesses
    puts ' '
    puts '==========================================================='
    sleep(1.5)
    print 'Evil Witch: '
    if princesses.length == 1
      print princesses[0].to_s.upcase + ', '
    elsif princesses.length == 2
      print princesses.join(' and ').upcase + ', '
    else
      print princesses[0...princesses.length-1].join(', ').upcase + ", and #{ princesses[-1].upcase }."
    end
    puts 'I have your Queen.'
    puts 'You\'ll never save her!'
    puts ' '
    puts '*evil laugh*'
  end	
  def play
    catch :winner do
      loop do
        $princess_list.each do |princess|
          throw :winner, princess.name if princess.found != [] and princess.found.include? :key and princess.found.include? :mirror and princess.found.include? :lantern and princess.status == 'girl'
          testing = []
          $princess_list.each do |girl|
            testing << girl.name if girl.status == 'frog'
          end
          throw :winner, 'Evil Witch' if testing.length == @princesses.length
          princess.turn
        end
      end
    end
  end
  
  def final_decision
   winner_game = play
    if winner_game == 'Evil Witch'
      witch_wins
    else
      closing_notes(winner_game)
    end
  end
  
  def closing_notes(winner)
    puts '======================================================='.center(60)
    sleep(2)
    puts "Good Queen: #{winner.capitalize}, you have collected " \
      'a mirror, lantern, and key!'.center(60)
    puts 'Come to the tower! Help me!'.center(60)
    sleep(2)
    puts 'Evil Witch: No! Don\'t!'.center(60)
    sleep(2)
    print 'Press any key to cast a spell, freeing the Queen: '.center(60)
    gets.chomp
    puts '*Evil Witch falls from the tower.*'.center(60)
    sleep(1)
    puts 'AHHHHHHHHHHHHHHHHH!'.center(60)
    puts ''.center(60)
    sleep(2)
    puts "Good Queen: #{winner.capitalize}, you saved me!".center(60)
    puts 'You are the Princess of the Kingdom!'.center(60)
    puts ''.center(60)
    puts '======================================================='.center(60)
  end
  # Runs if all princesses turn to frogs
  def witch_wins
    puts '======================================================='.center(60)
    sleep(2)
    puts 'All the princesses have been turned to frogs!'.center(60)
    puts 'The Evil Witch wins!'.center(60)
    sleep(1)
    puts 'GAME OVER'.center(60)
    puts '======================================================='.center(60)
    puts ''
  end
  
end
z = Game.new
$stable = Room.new(:stable, 'Stable', 'horses neighing')
$kitchen = Room.new(:kitchen, 'Kitchen', 'bubbling stew')
$dungeon = Room.new(:dungeon, 'Dungeon', 'prisoners moaning')
$throneroom = Room.new(:throneroom, 'Throne Room', 'trumpets playing')
$garden = Room.new(:garden, 'Garden', 'birds chirping')
$bedroom = Room.new(:bedroom, 'Bedroom', 'snoring')
$musicroom = Room.new(:musicroom, 'Music Room', 'music playing')
z.final_decision
