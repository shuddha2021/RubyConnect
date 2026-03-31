# frozen_string_literal: true

require_relative 'lib/database'

puts 'Setting up database...'
Database.setup
Database.seed!
puts "Done. #{Database.user_count} users in database."
