#based off ENCHANTED PALACE (c) 1994 MILTON BRADLEY

#Dawn Pattison, initial v 1/28/15

class Princess
	attr_accessor :location, :status, :lantern, :mirror, :key, :name, :found
		def initialize(name)
			rooms = [:stable, :kitchen, :dungeon, :throneroom, :bedroom, :musicroom, :garden]
			@name = name
			@location = ''
			@status = "girl"
			@found = []
			@lantern = rooms[rand(7)]
			rooms.delete(@lantern)
			@mirror = rooms[rand(6)]
			rooms.delete(@mirror)
			@key = rooms[rand(5)]
		end
		
		def turn
			puts ""
			sleep(0.75)
			puts "==========================================================="
			print "Good Queen: #{@name.upcase}, go to a (R)oom, or cast a (S)pell! "
			response = gets.chomp.capitalize
			if response == 'R'
				whereGoing
			elsif response == 'S'
				castSpell
			else
				puts "I can't understand you, #{@name.upcase}!"
			end
		end
		
		def whereGoing
			puts ""
			inventory
			statusGirl
			locationGirl
			puts ""
			puts "Which room would you like to enter?"
			puts ""
			puts "(S)table, (K)itchen, (D)ungeon, (T)hrone Room," 
			print "(G)arden, (B)edroom or (M)usic Room: "
			answer = gets.chomp.upcase
			case answer
				when 'S'
					going = :stable
				when 'K'
					going = :kitchen
				when 'D'
					going = :dungeon
				when 'T'
					going = :throneroom
				when 'G'
					going = :garden
				when 'B'
					going = :bedroom
				else
					going = :musicroom
			end
			goToRoom(going)
		end
		
		def castSpell
			puts " "
			inventory
			statusGirl
			locationGirl
			puts " "
			wand = rand(3)
			frogs = []
			tokens = []
			$princess_list.each do |princess|
				if princess.status == "frog"
					frogs << [princess.name, princess.found] unless @name == princess.name
				end
				
				if princess.found != []
					tokens << [princess.name, princess.found] unless @name == princess.name
				end
			end
			
			if frogs != []
				chosen = frogs[rand(frogs.length)]
				luckyLady = chosen[0]
				upForGrabs = chosen [1]
			else
				luckyLady = ""
				upForGrabs = []
			end
		
			#save princess
			 if wand == 0
					if luckyLady != ''
							modFrog(luckyLady)
					else
						puts "You wave your wand and nothing happens!"
					end
			#save princess/steal her token
			elsif wand == 1
					if luckyLady !=""
						modFrog(luckyLady)
					end
					
					if upForGrabs != []
						modTokens(luckyLady, upForGrabs)
					end
					
					if luckyLady == "" and upForGrabs == []
						puts "You wave your wand...nothing happens!"					
					end
			#steal someone's token
			else
				if tokens != []
					selected = tokens[rand(tokens.length)]
					nameStolen = selected[0]
					tokensStolen = selected [1]
					modTokens(nameStolen, tokensStolen)
				end
			end
		end
		
		def modFrog(luckyLady)
			puts "#{@name.capitalize}, you saved #{luckyLady.capitalize} from the spell!"
				$princess_list.each do |princess|
					if princess.name == luckyLady
						princess.status = 'girl'
					end
				end
		end
		
		def modTokens(playerAtRisk, tokensAtRisk)
				itemStolen = tokensAtRisk[rand(tokensAtRisk.length)]
				puts "#{playerAtRisk.capitalize}, give #{@name.capitalize} a #{itemStolen.upcase}!"
				@found <<  itemStolen
				
				$princess_list.each do |princess|
					if princess.name == playerAtRisk
						princess.found.slice!(princess.found.index(itemStolen))
					end
				end
		
		end
		
		def inventory
			print "Inventory: "
			if found == []
				print "None"
			else
				for i in @found
					print "#{i} "  
				end
			end		
			puts " "
		end
		
		def statusGirl
			
			puts "Status: #{@status}"
			
		
		end
		
		def locationGirl
			if @location == ''
				puts "Location: Entrance"
			else
				puts "Location: #{@location}"
			end
		end
		def goToRoom(room)
			@location = room
			puts " "
			puts "You search the #{@location}."
			search(room)
			x = eval ("$#{room}")
			
			if x.bewitched == 0
				frogSpell(room)
			else
				puts "This room is already bewitched!"
				puts "Turn into a frog!" if @status == "girl"
				puts ""
				@status = "frog"
			end
			
		end
		
		def search(room)
			sleep(2)
			puts " "
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
				puts 'Evil Witch: "There\'s nothing for you here! Ha!"'
			end
			puts ""
		
		end
		
		def frogSpell(room)
			
		chance = rand(3)
		inDanger = []
		$princess_list.each do |princess|
			if princess.location == room
			inDanger.push princess.name if princess.status == "girl"
			end
		end
		if chance == 1 and inDanger != []
			sleep(2)
			x = eval ("$#{room}")
			puts "Evil Witch: Ah ha haa! I hear #{x.sound_effects} and who do I see? #{inDanger.join(", ").upcase} waiting for me! Ah ha haa! Turn into a frog!"
			puts "Pop! Ribbit, ribbit."
			$princess_list.each do |princess|
				princess.status = "frog" if inDanger.include? princess.name
			end
			
			
			rooms = [:stable, :kitchen, :garden, :dungeon, :throneroom, :bedroom, :musicroom]
			rooms.each do |i|
				y = eval("$#{i}")
				y.bewitched = 0
			end
			x.bewitched = 1
	
		end
	
		end
		
end

class Room
	attr_accessor :name, :reference, :sound_effects, :bewitched
	def initialize(reference, name, sound_effects, bewitched = 0)
		@reference = reference
		@name = name
		@sound_effects = sound_effects
		@bewitched = bewitched
		
	end
end

class Game
	attr_accessor :princess_list, :princesses
	def initialize
		princesses = [:rose, :sky, :violet, :amber]
		remove = []
		$princess_list = []
		puts ""
		puts "===========================================================".center(60)
		puts "Welcome to ENCHANTED PALACE! ".center(60)
		puts ""
		puts "Your objective: find a lantern, mirror, and key hidden inside.".center(60)
		puts "Then free the Good Queen, banish the Evil Witch and be crowned".center(60)
		puts "Princess of the Kingdom!".center(60)
		sleep(0.5)
		puts " "
		puts "Remember, frogs are not much use to the Queen!".center(60)
		sleep 1
		puts ''
		puts "===========================================================".center(60)
		sleep(1)
		puts 'Good Queen: "Who will help me?"'
		princesses.each do |princess|
			puts "#{princess.capitalize}? Y/N"
			response = gets.chomp.upcase
			if response == 'Y'
				$princess_list << Princess.new(princess)				
			else
				remove << princess
			end		
		end
		for i in remove
			princesses.delete(i)
		end	
		@princesses = princesses
		puts " "
		puts "==========================================================="
		sleep(1.5)
		print "Evil Witch: "
		
		if princesses.length == 1
			print princesses[0].to_s.upcase + ", "
		elsif princesses.length == 2
			print princesses.join(" and ").upcase + ", "
		else
			print princesses[0...princesses.length-1].join(", ").upcase + ", and #{princesses[-1].upcase}."	
		
		
		end
		
		puts "I have your Queen."
		puts "You'll never save her!"
		puts " "
		puts "*evil laugh*"
		
		$stable = Room.new(:stable, "Stable", "horses neighing")
		$kitchen = Room.new(:kitchen, "Kitchen", "bubbling stew")
		$dungeon = Room.new(:dungeon, "Dungeon", "prisoners moaning")
		$throneroom = Room.new(:throneroom, "Throne Room", "trumpets playing")
		$garden = Room.new(:garden, "Garden", "birds chirping")
		$bedroom = Room.new(:bedroom, "Bedroom", "snoring")
		$musicroom = Room.new(:musicroom, "Music Room", "music playing")
		
	
	def play
		catch :winner  do
				while true
					$princess_list.each do |princess|
						throw :winner, princess.name if princess.found !=[] and princess.found.include? :key and princess.found.include? :mirror and princess.found.include? :lantern and princess.status == "girl"
						testing = []
						$princess_list.each do |girl|
							
							testing << girl.name if girl.status == "frog"
						end
						
						throw :winner, "Evil Witch" if testing.length == @princesses.length
						
						princess.turn
					end	
					
				end
		end
	end
	
	def closingNotes(winner)
		puts "=======================================================".center(60)
		sleep(2)
		puts "Good Queen: #{winner.capitalize}, you have collected a mirror, lantern, and key!".center(60)
		puts "Come to the tower! Help me!".center(60)
		sleep(2)
		puts "Evil Witch: No! Don't!".center(60)
		sleep(2)
		print "Press any key to cast a spell, freeing the Queen: ".center(60)
		gets.chomp
		puts "*Evil Witch falls from the tower.*".center(60)
		sleep(1)
		puts "AHHHHHHHHHHHHHHHHH!".center(60)
		puts "".center(60)
		sleep(2)
		puts "Good Queen: #{winner.capitalize}, you saved me!".center(60)
		puts "You are the Princess of the Kingdom!".center(60)
		puts "".center(60)
		puts "=======================================================".center(60)
		
	
	end
	
	def witchWins(winner)
	puts "=======================================================".center(60)
	sleep(2)
	puts "All the princesses have been turned to frogs!".center(60)
	puts "The Evil Witch wins!".center(60)
	sleep(1)
	puts "GAME OVER".center(60)
	puts  "=======================================================".center(60)
	
	puts ""
	
	end
	
	winner = play
	if winner == "Evil Witch" 
		witchWins(winner)
	else
		closingNotes(winner)
		
	end
	
end	

end

z = Game.new
