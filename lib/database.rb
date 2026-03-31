# frozen_string_literal: true

require 'sqlite3'

# Thread-safe SQLite3 wrapper with connection pooling.
module Database
  DB_PATH = ENV.fetch('DATABASE_PATH') { File.join(__dir__, '..', 'ruby_connect.db') }

  module_function

  def db
    Thread.current[:ruby_connect_db] ||= begin
      conn = SQLite3::Database.new(DB_PATH)
      conn.results_as_hash = true
      conn.execute('PRAGMA journal_mode=WAL')
      conn.execute('PRAGMA foreign_keys=ON')
      conn
    end
  end

  # ─── Schema ───────────────────────────────────────────────
  def setup
    db.execute_batch(<<~SQL)
      CREATE TABLE IF NOT EXISTS users (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        name       TEXT    NOT NULL CHECK(length(name) BETWEEN 1 AND 100),
        email      TEXT    NOT NULL UNIQUE,
        role       TEXT    NOT NULL DEFAULT 'member' CHECK(role IN ('admin','member','viewer')),
        created_at TEXT    NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT    NOT NULL DEFAULT (datetime('now'))
      );

      CREATE TABLE IF NOT EXISTS messages (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        name       TEXT NOT NULL,
        email      TEXT NOT NULL,
        body       TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      );
    SQL
  end

  # ─── Seed data ────────────────────────────────────────────
  def seed!
    return if db.get_first_value('SELECT COUNT(*) FROM users').to_i > 0

    users = [
      ['Alice Johnson',    'alice@example.com',    'admin'],
      ['Bob Martinez',     'bob@example.com',      'member'],
      ['Charlie Kim',      'charlie@example.com',  'member'],
      ['Diana Patel',      'diana@example.com',    'viewer'],
      ['Ethan O\'Brien',   'ethan@example.com',    'member'],
      ['Fiona Chen',       'fiona@example.com',    'admin'],
      ['George Nakamura',  'george@example.com',   'viewer'],
      ['Hannah Lee',       'hannah@example.com',   'member'],
      ['Ivan Petrov',      'ivan@example.com',     'member'],
      ['Julia Santos',     'julia@example.com',    'viewer'],
      ['Kevin Müller',     'kevin@example.com',    'member'],
      ['Laura Eriksson',   'laura@example.com',    'member'],
      ['Shuddha Chowdhury','shuddha@example.com', 'admin'],
    ]

    db.transaction do |conn|
      users.each do |name, email, role|
        conn.execute('INSERT INTO users (name, email, role) VALUES (?, ?, ?)', [name, email, role])
      end
    end
  end

  # ─── Queries ──────────────────────────────────────────────
  def all_users(limit:, offset:)
    db.execute('SELECT * FROM users ORDER BY id DESC LIMIT ? OFFSET ?', [limit, offset])
  end

  def search_users(query, limit:, offset:)
    like = "%#{query}%"
    db.execute(
      'SELECT * FROM users WHERE name LIKE ? OR email LIKE ? ORDER BY id DESC LIMIT ? OFFSET ?',
      [like, like, limit, offset]
    )
  end

  def user_count
    db.get_first_value('SELECT COUNT(*) FROM users').to_i
  end

  def search_count(query)
    like = "%#{query}%"
    db.get_first_value('SELECT COUNT(*) FROM users WHERE name LIKE ? OR email LIKE ?', [like, like]).to_i
  end

  def find_user(id)
    db.execute('SELECT * FROM users WHERE id = ?', [id]).first
  end

  def email_exists?(email, exclude_id: nil)
    if exclude_id
      db.get_first_value('SELECT COUNT(*) FROM users WHERE email = ? AND id != ?', [email, exclude_id]).to_i > 0
    else
      db.get_first_value('SELECT COUNT(*) FROM users WHERE email = ?', [email]).to_i > 0
    end
  end

  def create_user(name, email, role)
    db.execute('INSERT INTO users (name, email, role) VALUES (?, ?, ?)', [name, email, role])
  end

  def update_user(id, name, email, role)
    db.execute(
      "UPDATE users SET name = ?, email = ?, role = ?, updated_at = datetime('now') WHERE id = ?",
      [name, email, role, id]
    )
  end

  def delete_user(id)
    db.execute('DELETE FROM users WHERE id = ?', [id])
  end

  def create_message(name, email, body)
    db.execute('INSERT INTO messages (name, email, body) VALUES (?, ?, ?)', [name, email, body])
  end

  def stats
    total = db.get_first_value('SELECT COUNT(*) FROM users').to_i
    admins = db.get_first_value("SELECT COUNT(*) FROM users WHERE role = 'admin'").to_i
    members = db.get_first_value("SELECT COUNT(*) FROM users WHERE role = 'member'").to_i
    viewers = db.get_first_value("SELECT COUNT(*) FROM users WHERE role = 'viewer'").to_i
    messages = db.get_first_value('SELECT COUNT(*) FROM messages').to_i
    { total: total, admins: admins, members: members, viewers: viewers, messages: messages }
  end
end
