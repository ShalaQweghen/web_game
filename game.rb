require "sinatra"
require "sinatra/reloader" if development?
require_relative "hangman.rb"

get "/" do
	erb :index
end

post "/name" do
	erb :name
end

post "/game" do
	name = params["name"]
	@@game = Hangman.new(name)
	redirect to("/game")
end

get "/game" do
	word = ""
	@@game.board.board.each {|l| word << l << " "}
	erb :game, :locals => { :word => word }
end

post "/show" do
	word = ""
	guess = params["letter"]
	@@game.player.pick = guess
	notice = @@game.show_letter
	@@game.board.board.each { |l| word << l << " "}
	erb :show, :locals => { :word => word, :notice => notice }
end