# setup_db.rb

require 'sqlite3'

# Open a database
db = SQLite3::Database.new 'my_database.db'

# Create a table
rows = db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY,
    name TEXT,
    email TEXT
  );
SQL

# Insert some sample data
db.execute "INSERT INTO users (name, email) VALUES (?, ?)", ["Alice", "alice@example.com"]
db.execute "INSERT INTO users (name, email) VALUES (?, ?)", ["Bob", "bob@example.com"]
db.execute "INSERT INTO users (name, email) VALUES (?, ?)", ["Charlie", "charlie@example.com"]
db.execute "INSERT INTO users (name, email) VALUES (?, ?)", ["Shuddha", "shuddha@example.com"]

puts 'Database setup complete.'
