# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'
ENV['DATABASE_PATH'] = File.join(__dir__, 'test.db')

require 'minitest/autorun'
require 'rack/test'
require_relative '../app'

class RubyConnectTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    File.delete(ENV['DATABASE_PATH']) if File.exist?(ENV['DATABASE_PATH'])
    # Reset thread-local connection
    Thread.current[:ruby_connect_db] = nil
    Database.setup
    Database.seed!
  end

  def teardown
    Thread.current[:ruby_connect_db]&.close
    Thread.current[:ruby_connect_db] = nil
    File.delete(ENV['DATABASE_PATH']) if File.exist?(ENV['DATABASE_PATH'])
  end

  # ── Dashboard ───────────────────────────────────────────
  def test_home_page
    get '/'
    assert last_response.ok?
    assert_includes last_response.body, 'RubyConnect'
    assert_includes last_response.body, 'Alice Johnson'
  end

  def test_search_users
    get '/', q: 'charlie'
    assert last_response.ok?
    assert_includes last_response.body, 'Charlie Kim'
  end

  def test_search_no_results
    get '/', q: 'zzzznotfound'
    assert last_response.ok?
    assert_includes last_response.body, 'No results'
  end

  # ── Create ──────────────────────────────────────────────
  def test_new_user_form
    get '/users/new'
    assert last_response.ok?
    assert_includes last_response.body, 'New User'
  end

  def test_create_user
    post '/users', name: 'Test User', email: 'test@example.com', role: 'member'
    assert last_response.redirect?
    follow_redirect!
    assert_includes last_response.body, 'Test User'
  end

  def test_create_user_invalid_email
    post '/users', name: 'Test', email: 'notanemail', role: 'member'
    assert last_response.ok?
    assert_includes last_response.body, 'valid email'
  end

  def test_create_user_empty_name
    post '/users', name: '', email: 'valid@example.com', role: 'member'
    assert last_response.ok?
    assert_includes last_response.body, 'Name is required'
  end

  def test_create_user_duplicate_email
    post '/users', name: 'Dup', email: 'alice@example.com', role: 'member'
    assert last_response.ok?
    assert_includes last_response.body, 'already exists'
  end

  # ── Edit / Update ──────────────────────────────────────
  def test_edit_user
    get '/users/1/edit'
    assert last_response.ok?
    assert_includes last_response.body, 'Edit User'
  end

  def test_update_user
    post '/users/1', name: 'Alice Updated', email: 'alice@example.com', role: 'admin'
    assert last_response.redirect?
    follow_redirect!
    assert_includes last_response.body, 'Alice Updated'
  end

  def test_edit_nonexistent
    get '/users/99999/edit'
    assert_equal 404, last_response.status
  end

  # ── Delete ──────────────────────────────────────────────
  def test_delete_user
    count_before = Database.user_count
    post '/users/1/delete'
    assert last_response.redirect?
    assert_equal count_before - 1, Database.user_count
  end

  def test_delete_nonexistent
    post '/users/99999/delete'
    assert_equal 404, last_response.status
  end

  # ── Contact ─────────────────────────────────────────────
  def test_contact_form
    post '/contact', contact_name: 'Tester', contact_email: 'tester@example.com', contact_message: 'Hello!'
    assert last_response.redirect?
    follow_redirect!
    assert_includes last_response.body, 'Message sent'
  end

  def test_contact_invalid
    post '/contact', contact_name: '', contact_email: 'bad', contact_message: ''
    assert last_response.redirect?
    follow_redirect!
    assert_includes last_response.body, 'fill in all'
  end

  # ── API ─────────────────────────────────────────────────
  def test_api_users
    get '/api/users'
    assert last_response.ok?
    data = JSON.parse(last_response.body)
    assert data.is_a?(Array)
    assert data.length > 0
  end

  def test_api_user
    get '/api/users/1'
    assert last_response.ok?
    data = JSON.parse(last_response.body)
    assert_equal 1, data['id']
  end

  def test_api_user_not_found
    get '/api/users/99999'
    assert_equal 404, last_response.status
  end

  def test_api_stats
    get '/api/stats'
    assert last_response.ok?
    data = JSON.parse(last_response.body)
    assert data.key?('total')
    assert data.key?('admins')
  end

  # ── 404 ─────────────────────────────────────────────────
  def test_not_found
    get '/nonexistent'
    assert_equal 404, last_response.status
    assert_includes last_response.body, '404'
  end
end
