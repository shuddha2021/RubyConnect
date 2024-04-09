# app.rb

require 'sinatra'
require 'sqlite3'

# Open a database
db = SQLite3::Database.new 'my_database.db'

# Route for the home page
get '/' do
  # Query data from the database
  @users = db.execute "SELECT * FROM users"
  erb :index
end
