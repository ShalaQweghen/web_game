require "sinatra"
require "sinatra/reloader" if development?
require_relative "lib/hangman.rb"

configure do
	enable :sessions
	set :session_secret, 'holala666'
end

get "/" do
	erb :index
end

post "/name" do
	erb :name
end

post "/game" do
	@@name = params["name"]
	if File.exists?("lib/saves/#{@@name}.txt")
		erb :load
	else
		redirect to("/game")
	end
end

post "/new" do
	redirect to("/game")
end

get "/game" do
	@@game = Hangman.new(@@name)
	word = ""
	@@game.board.board.each {|l| word << l << " "}
	erb :game, :locals => { :word => word }
end

post "/load" do
	if File.exists?("lib/saves/#{@@name}.txt")
		@@game = Hangman.new(@@name)
		@@game.load
	end
	redirect to("/show")
end

post "/show" do
	@@guess = params["letter"]
	redirect to("/show")
end

get "/show" do
	unless @@game.turns == 6
		word = ""
		unless @@guess.nil?
			@@game.player.pick = @@guess
			notice = @@game.word_or_letter
		end
		incorrect = ""
		stickman = @@game.stickman(@@game.turns)
		@@game.incorrect.each { |l| incorrect << l << ", " }
		@@game.board.board.each { |l| word << l << " " }
		if @@game.player.pick == @@game.board.word || @@game.board.board.join == @@game.board.word
			notice = @@game.word_or_letter
			erb :win, :locals => { :notice => notice }
		else
			erb :show, :locals => { :word => word, :notice => notice, :incorrect => incorrect, :stickman => stickman }
		end
	else
		notice = @@game.word_or_letter
		erb :fail, :locals => { :notice => notice }
	end
end