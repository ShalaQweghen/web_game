require "yaml"

class Hangman
	attr_accessor :board, :player, :config
	attr_reader :incorrect, :turns

	def initialize(name)
		@player = Player.new(name)
		@board = Board.new
		@turns = 0
		@incorrect = []
	end

	def turn
		@turns += 1
	end

	def word_or_letter
		if lose?
			loss
		else
			if @player.pick.length == 1
				show_letter
			elsif @player.pick.length == @board.word.length
				if !win?
					turn
					return "Unlucky guess!"
				elsif win?
					victory
				end
			elsif @player.pick == "save"
				save
			else
				return "Invalid input! Your guess should either be a letter or a word equal to the length of the secret word!"
			end
		end
	end

	def show_letter
		word = @board.word
		guess = @player.pick
		if win?
			victory
		elsif word.include?(guess)
			word.chars.each_with_index do |letter, idx|
				@board.board[idx] = guess if letter == guess
			end
			return "Your guess was correct!"
		else
			@incorrect << guess
			turn
			return "Your guess was not correct!"
		end
	end

	def win?
		true if @player.pick == @board.word || @board.board.join == @board.word
	end

	def victory
		delete_save
		return "Congratulations! You found out the secret word: #{@board.word.upcase}"
	end

	def lose?
		true if @turns == 6
	end

	def loss
		return "It was your unlucky day! The secret word was #{@board.word.upcase}!"
	end

	def save
		config = { name: @player.name, word: @board.word, board: @board.board, incorrect: @incorrect, turns: @turns }
		File.open("lib/saves/#{@player.name}.txt", "w") { |file| file.puts(YAML::dump(config)) } unless File.exists?("lib/saves/#{@player.name}.txt")
		return "Game Saved!"
	end

	def load
		file = File.read("lib/saves/#{@player.name}.txt")
		config = YAML::load(file)
		@player.name = config[:name]
		@board.board = config[:board]
		@board.word = config[:word]
		@incorrect = config[:incorrect]
		@turns = config[:turns]
	end

	def delete_save
		File.delete("lib/saves/#{@player.name}.txt") if File.exists?("lib/saves/#{@player.name}.txt")
	end

	def stickman(turn)
		case turn
		when 1
			return ["/  "]
		when 2
			return ["/ \\"]
		when 3
			return [" | "," | ","/ \\"]
		when 4
			return ["/| "," | ","/ \\"]
		when 5
			return ["/|\\"," | ","/ \\"]
		when 6
			return [" 0 ","/|\\"," | ","/ \\"]
		end
	end

end

class Board
	attr_accessor :word, :board

	def initialize
		@words = File.open("lib/5desk.txt").read.split("\n").delete_if {|n| n.length < 5 || n.length > 12 }
		@word = @words.sample.downcase
		@board = []
		set
	end

	def set
		@word.length.times { @board << "_" }
	end
end

class Player
	attr_accessor :pick, :name

	def initialize(name)
		@name = name
		@pick = nil
	end
end