# frozen_string_literal: true

require 'sinatra'
require 'sinatra/json'
require 'sqlite3'
require 'json'
require 'securerandom'
require_relative 'lib/database'

# ─── Configuration ────────────────────────────────────────────
set :port, ENV.fetch('PORT', 4567).to_i
set :bind, '0.0.0.0'
set :erb, escape_html: true
set :public_folder, File.join(__dir__, 'public')
set :views, File.join(__dir__, 'views')

enable :sessions
set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(32) }

configure do
  Database.setup
end

# ─── Helpers ──────────────────────────────────────────────────
helpers do
  def flash(type, message)
    session[:flash] = { type: type, message: message }
  end

  def consume_flash
    msg = session.delete(:flash)
    msg
  end

  def h(text)
    Rack::Utils.escape_html(text.to_s)
  end

  def valid_email?(email)
    email.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
  end

  def valid_name?(name)
    name.is_a?(String) && name.strip.length.between?(1, 100)
  end
end

# ─── Web Routes ───────────────────────────────────────────────

# Dashboard — list users with search & pagination
get '/' do
  page = [params.fetch('page', 1).to_i, 1].max
  per = 10
  search = params['q'].to_s.strip
  offset = (page - 1) * per

  if search.empty?
    @users = Database.all_users(limit: per, offset: offset)
    @total = Database.user_count
  else
    @users = Database.search_users(search, limit: per, offset: offset)
    @total = Database.search_count(search)
  end

  @page = page
  @per = per
  @search = search
  @total_pages = [(@total.to_f / per).ceil, 1].max
  @stats = Database.stats
  erb :index
end

# New user form
get '/users/new' do
  @user = { name: '', email: '', role: 'member' }
  erb :form
end

# Create user
post '/users' do
  name = params['name'].to_s.strip
  email = params['email'].to_s.strip
  role = %w[admin member viewer].include?(params['role']) ? params['role'] : 'member'

  unless valid_name?(name)
    flash(:error, 'Name is required (1–100 characters).')
    @user = { name: name, email: email, role: role }
    return erb(:form)
  end

  unless valid_email?(email)
    flash(:error, 'Please enter a valid email address.')
    @user = { name: name, email: email, role: role }
    return erb(:form)
  end

  if Database.email_exists?(email)
    flash(:error, 'A user with that email already exists.')
    @user = { name: name, email: email, role: role }
    return erb(:form)
  end

  Database.create_user(name, email, role)
  flash(:success, "User \"#{name}\" created successfully.")
  redirect '/'
end

# Edit user form
get '/users/:id/edit' do
  @user = Database.find_user(params['id'].to_i)
  halt 404, erb(:not_found) unless @user
  erb :form
end

# Update user
post '/users/:id' do
  id = params['id'].to_i
  @user = Database.find_user(id)
  halt 404, erb(:not_found) unless @user

  name = params['name'].to_s.strip
  email = params['email'].to_s.strip
  role = %w[admin member viewer].include?(params['role']) ? params['role'] : @user['role']

  unless valid_name?(name)
    flash(:error, 'Name is required (1–100 characters).')
    @user = { 'id' => id, 'name' => name, 'email' => email, 'role' => role }
    return erb(:form)
  end

  unless valid_email?(email)
    flash(:error, 'Please enter a valid email address.')
    @user = { 'id' => id, 'name' => name, 'email' => email, 'role' => role }
    return erb(:form)
  end

  if Database.email_exists?(email, exclude_id: id)
    flash(:error, 'A user with that email already exists.')
    @user = { 'id' => id, 'name' => name, 'email' => email, 'role' => role }
    return erb(:form)
  end

  Database.update_user(id, name, email, role)
  flash(:success, "User \"#{name}\" updated successfully.")
  redirect '/'
end

# Delete user
post '/users/:id/delete' do
  id = params['id'].to_i
  user = Database.find_user(id)
  halt 404, erb(:not_found) unless user

  Database.delete_user(id)
  flash(:success, "User \"#{user['name']}\" deleted.")
  redirect '/'
end

# Contact form submission
post '/contact' do
  name = params['contact_name'].to_s.strip
  email = params['contact_email'].to_s.strip
  message = params['contact_message'].to_s.strip

  if name.empty? || !valid_email?(email) || message.empty?
    flash(:error, 'Please fill in all contact fields with valid data.')
    redirect '/'
  end

  Database.create_message(name, email, message)
  flash(:success, 'Message sent! We\'ll get back to you soon.')
  redirect '/'
end

# ─── API Routes (JSON) ───────────────────────────────────────
get '/api/users' do
  json Database.all_users(limit: 100, offset: 0)
end

get '/api/users/:id' do
  user = Database.find_user(params['id'].to_i)
  halt 404, json({ error: 'not found' }) unless user
  json user
end

get '/api/stats' do
  json Database.stats
end

# ─── Error Pages ──────────────────────────────────────────────
not_found do
  erb :not_found
end
