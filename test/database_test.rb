# frozen_string_literal: true

require_relative '../lib/database'

ENV['DATABASE_PATH'] ||= File.join(__dir__, '..', 'test_db_unit.db')

require 'minitest/autorun'

class DatabaseTest < Minitest::Test
  def setup
    File.delete(ENV['DATABASE_PATH']) if File.exist?(ENV['DATABASE_PATH'])
    Thread.current[:ruby_connect_db] = nil
    Database.setup
  end

  def teardown
    Thread.current[:ruby_connect_db]&.close
    Thread.current[:ruby_connect_db] = nil
    File.delete(ENV['DATABASE_PATH']) if File.exist?(ENV['DATABASE_PATH'])
  end

  def test_seed
    Database.seed!
    assert Database.user_count > 0
  end

  def test_seed_idempotent
    Database.seed!
    count = Database.user_count
    Database.seed!
    assert_equal count, Database.user_count
  end

  def test_create_and_find
    Database.create_user('Test', 'test@test.com', 'member')
    user = Database.find_user(1)
    assert_equal 'Test', user['name']
    assert_equal 'test@test.com', user['email']
    assert_equal 'member', user['role']
  end

  def test_update
    Database.create_user('Before', 'before@test.com', 'member')
    Database.update_user(1, 'After', 'after@test.com', 'admin')
    user = Database.find_user(1)
    assert_equal 'After', user['name']
    assert_equal 'after@test.com', user['email']
    assert_equal 'admin', user['role']
  end

  def test_delete
    Database.create_user('Del', 'del@test.com', 'viewer')
    assert_equal 1, Database.user_count
    Database.delete_user(1)
    assert_equal 0, Database.user_count
  end

  def test_search
    Database.create_user('Alice', 'alice@a.com', 'admin')
    Database.create_user('Bob', 'bob@b.com', 'member')
    results = Database.search_users('alice', limit: 10, offset: 0)
    assert_equal 1, results.length
    assert_equal 'Alice', results[0]['name']
  end

  def test_email_exists
    Database.create_user('A', 'taken@test.com', 'member')
    assert Database.email_exists?('taken@test.com')
    refute Database.email_exists?('free@test.com')
  end

  def test_email_exists_exclude
    Database.create_user('A', 'taken@test.com', 'member')
    refute Database.email_exists?('taken@test.com', exclude_id: 1)
    assert Database.email_exists?('taken@test.com', exclude_id: 999)
  end

  def test_stats
    Database.seed!
    s = Database.stats
    assert s[:total] > 0
    assert s[:admins] > 0
    assert s[:members] > 0
    assert s[:viewers] > 0
  end

  def test_create_message
    Database.create_message('Tester', 'test@t.com', 'Hello')
    s = Database.stats
    assert_equal 1, s[:messages]
  end
end
