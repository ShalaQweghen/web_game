require "yaml"

class Hangman
	attr_accessor :board, :player

	def initialize(name)
		@player = Player.new(name)
		@board = Board.new
		@turn = 0
		@incorrect = []
		#options
		#new_or_saved
	end

	def start
		system("clear")
		puts "HANGMAN".center(60)
		puts "\n=============================================================="
		puts "Welcome to the Hangman, #{@player.name.upcase}! Computer will pick a "
		puts "random word for you and you will try to guess what it is by"
		puts "typing a letter each turn. You have 6 turns in total, that is,"
		puts " the number of the parts of our poor stickman. Each turn you "
		puts "can either pick a letter or try to guess the whole word. Let's"
		puts "see if you can prevent him from being hanged!"
		puts "==============================================================\n"
		puts "\n"
		puts "The secret word:".center(60)
	end

	# Controls the game flow
	def proceed
		until win? || lose?
			puts @incorrect.join("-").center(60) # Shows the letter the player guessed incorrectly
			@board.show # Sets the blank spaced and the letter uncovered if any
			stickman(@turn) # Displays the stickman based on the turn number
			@player.guess # Gathers the player's guess
			word_or_letter # Evaluates the player's guess
			loss if lose?
			victory if win?
		end
	end

	def turn
		@turn += 1
	end

	# Checks if the player's guess is a single letter or a word and gives feedback accordingly 
	# and saves the game if requested
	def word_or_letter
		if @player.pick.length == 1
			show_letter
		elsif @player.pick.length == @board.word.length
			if !win?
				puts "\n"
				puts "Unlucky guess!".center(60)
				puts "\n"
				turn
			end
		elsif @player.pick == "save"
			save
		else
			puts "\nInvalid input! Your guess should either be a letter or"
			puts "a word equal to the length of the secret word!\n"
		end
	end

	# Checks if the letter picked by the player is correct and modifies the board accordingly
	def show_letter
		word = @board.word
		guess = @player.pick
		if word.include?(guess)
			#puts "\n"
			#puts "Your guess was correct!".center(60)
			#puts "\n"
			word.chars.each_with_index do |letter, idx|
				@board.board[idx] = guess if letter == guess
			end
			return "Your guess was correct!"
		else
			@incorrect << guess
			#puts "\n"
			#puts "Your guess was not correct!".center(60)
			#puts "\n"
			turn
			return "Your guess was not correct!"
		end
	end

	# Decides whether or not to put the "load save game" option at the beginning of the game
	def options
		if Dir.exists?("../saves")
			puts "Would you like to load a saved game?"
			@choice ||= gets.chomp
		end
	end

	# Saves the necessary game info into a txt file with a file name equal to the player name downcased
	# in a separate folder. If saves folder is not present, creates it.
	def save
		config = {name: @player.name, word: @board.word, board: @board.board, incorrect: @incorrect, turn: @turn}
		Dir.mkdir("../saves") unless Dir.exists?("../saves")
		File.open("../saves/#{@player.name}.txt", "w") { |file| file.puts(YAML::dump(config)) }
	end

	# Checks if the requested saved game is present or not. If present, loads the necessary game info.
	# If not present, starts a new game.
	def load
		if File.exist?("../saves/#{@player.name}.txt")
			file = File.read("../saves/#{@player.name}.txt")
			config = YAML::load(file)
			@player.name = config[:name]
			@board.board = config[:board]
			@board.word = config[:word]
			@incorrect = config[:incorrect]
			@turn = config[:turn]
			proceed
		else
			puts "\n"
			puts "NO SAVED GAMES FOUND!".center(60)
			puts "Starting a new game...".center(60)
			puts "\n"
			sleep 3
			start
			proceed
		end
	end

	# Checks if a player wants to load a saved game or not
	def new_or_saved
		if @choice == "y"
			load
		else
			start
			proceed
		end
	end

	def win?
		true if @player.pick == @board.word || @board.board.join == @board.word
	end

	def victory
		puts "\n"
		puts "Congratulations! You found out the secret word: #{@board.word.upcase}".center(60)
		puts "\n"
	end

	def lose?
		true if @turn == 7
	end

	def loss
		puts "\n"
		puts "It was your unlucky day! Try again soon!".center(60)
		puts "The secret word was #{@board.word.upcase}!".center(60)
		puts "\n"
	end

	# Draws a stickman in accordance with the turn number
	def stickman(turn)
		case turn
		when 1
			puts "\n"
			puts "/  ".center(60)
		when 2
			puts "\n"
			puts "/ \\".center(60)
		when 3
			puts "\n"
			puts " | ".center(60)
			puts " | ".center(60)
			puts "/ \\".center(60)
		when 4
			puts "\n"
			puts "/| ".center(60)
			puts " | ".center(60)
			puts "/ \\".center(60)
		when 5
			puts "\n"
			puts "/|\\".center(60)
			puts " | ".center(60)
			puts "/ \\".center(60)
		when 6
			puts "\n"
			puts " 0 ".center(60)
			puts "/|\\".center(60)
			puts " | ".center(60)
			puts "/ \\".center(60)
		end
	end

end

class Board
	attr_accessor :word, :board

	def initialize
		# Makes the dictionary list ready with words of 5 to 12 letters
		@words = File.open("5desk.txt").read.split("\n").delete_if {|n| n.length < 5 || n.length > 12 }
		@word = @words.sample.downcase
		@board = []
		set
	end

	def set
		@word.length.times { @board << "_" }
	end

	def show
		puts @board.join(" ")#.center(60)
	end
end

class Player
	attr_accessor :pick, :name

	def initialize(name)
		@name = name
		@pick = nil
	end

	def guess
		puts "\nMake your guess! Either a letter or a word!"
		print "If you want to save your game, please type 'save': "
		@pick = gets.chomp
	end
end

#print "Enter your name, please: "
#name = gets.chomp.downcase
#game = Hangman.new(name)