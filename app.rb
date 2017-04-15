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

get '/entry/:post_id' do
	post_id=params[:post_id]
	erb "#{post_id}"
end

post '/new' do
	@new_post = params[:new_post].gsub("\n", "<br>")

	if @new_post.empty?
		@error = "Enter your post"
	end

	@db.execute 'INSERT INTO Posts (created_date, content) VALUES (datetime(), ?)', [@new_post]
	redirect to '/'
end
