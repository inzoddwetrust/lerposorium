require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new './public/main.db'
	@db.results_as_hash = true
end

configure do
	init_db
	@db.execute 'CREATE TABLE IF NOT EXISTS Posts
							(
								`id` INTEGER PRIMARY KEY AUTOINCREMENT,
								`created_date` DATE,
								`content` TEXT
							)'
end

before do
	init_db
end

get '/' do
	@content = @db.execute 'SELECT * FROM Posts ORDER BY id DESC'
	erb :index
end

get '/new' do
  erb :new
end

post '/new' do
	@new_post = params[:new_post]

	if @new_post.empty?
		@error = "Enter your post"
		return erb :new
	end

	@db.execute 'INSERT INTO Posts (created_date, content) VALUES (datetime(), ?)', [@new_post]
	erb "#{@new_post.gsub("\n", "<br>")}"
end
