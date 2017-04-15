require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new './public/main.db'
	@db.results_as_hash = true
end

def prepare_enrty
	@post_id=params[:post_id]
	@content = @db.execute 'SELECT * FROM Posts where id=?', [@post_id]
	@post_comments = @db.execute 'SELECT * FROM Comments where post_id=? ORDER BY created_date DESC', [@post_id]
end

configure do
	init_db
	@db.execute 'CREATE TABLE IF NOT EXISTS Posts
							(
								`id` INTEGER PRIMARY KEY AUTOINCREMENT,
								`created_date` DATE,
								`content` TEXT
							)'
	@db.execute 'CREATE TABLE IF NOT EXISTS Comments
							(
								`id` INTEGER PRIMARY KEY AUTOINCREMENT,
								`created_date` DATE,
								`post_id` INTEGER,
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
	prepare_enrty
	erb :entry
end

post '/entry/:post_id' do
	@post_id=params[:post_id]
	new_comment = params[:new_comment].gsub("\n", "<br>")

	if new_comment.empty?
		@error = "Enter your comment"
		prepare_enrty
		return erb :entry
	end

	@db.execute 'INSERT INTO Comments (created_date, post_id, content) VALUES (datetime(), ?, ?)', [@post_id, new_comment]

	prepare_enrty
	redirect to('/entry/'+ @post_id)
end

post '/new' do
	new_post = params[:new_post].gsub("\n", "<br>")

	if new_post.empty?
		@error = "Enter your post"
		return erb :new
	end

	@db.execute "INSERT INTO Posts (created_date, content) VALUES (datetime(), '#{new_post}')"

	redirect to '/'
end
