# RubyConnect

A full-featured user management web application built with Ruby, Sinatra, and SQLite3. Modern UI, full CRUD, search & pagination, role-based badges, contact form, dark/light theme, JSON API, and comprehensive test suite — all with zero JavaScript frameworks.

![Ruby](https://img.shields.io/badge/Ruby-3.x-CC342D?logo=ruby&logoColor=fff)
![Sinatra](https://img.shields.io/badge/Sinatra-4.0-000?logo=ruby&logoColor=fff)
![License](https://img.shields.io/badge/License-MIT-blue)
![Status](https://img.shields.io/badge/status-active-brightgreen)

## Features

| Feature | Description |
|---|---|
| **Full CRUD** | Create, read, update, and delete users with server-side validation |
| **Search** | Real-time search across names and emails with result counts |
| **Pagination** | Automatic page splitting for large user lists |
| **Role Badges** | Color-coded admin / member / viewer role badges |
| **KPI Dashboard** | At-a-glance stats strip — total users, admins, members, viewers |
| **Contact Form** | Modal contact form that persists messages to the database |
| **Dark / Light Theme** | System-aware toggle, persisted in localStorage |
| **JSON API** | RESTful API endpoints for programmatic access |
| **Input Validation** | Server-side name, email, and duplicate checks |
| **Flash Messages** | Auto-dismissing success/error notifications |
| **Responsive** | Mobile-first layout; table columns hide gracefully on small screens |
| **Zero JS Frameworks** | Vanilla CSS + JS — no Bootstrap, no jQuery, no build step |
| **Test Suite** | 25+ Minitest tests covering routes, database, and edge cases |

## Architecture

```
app.rb              ← Sinatra routes (web + API), helpers, config
config.ru           ← Rack entry point (for Puma / deployment)
Gemfile             ← Dependencies
Rakefile            ← Database setup task
setup_db.rb         ← Quick seed script
lib/
  database.rb       ← Thread-safe SQLite3 wrapper, all queries
views/
  layout.erb        ← HTML shell, nav, footer, contact modal
  index.erb         ← Dashboard: KPIs, toolbar, table, pagination
  form.erb          ← New / edit user form
  not_found.erb     ← 404 page
public/
  style.css         ← Full design system (CSS custom properties)
  app.js            ← Theme toggle, modal, alert auto-dismiss
test/
  app_test.rb       ← Integration tests (Rack::Test)
  database_test.rb  ← Unit tests for Database module
```

## Getting Started

### Prerequisites

- **Ruby 3.x** — [install](https://www.ruby-lang.org/en/downloads/)
- **Bundler** — `gem install bundler`

### Install & Run

```bash
git clone https://github.com/shuddha2021/RubyConnect.git
cd RubyConnect
bundle install
ruby setup_db.rb        # creates & seeds the database
ruby app.rb             # starts server on http://localhost:4567
```

### Run Tests

```bash
bundle exec ruby test/app_test.rb
bundle exec ruby test/database_test.rb
```

## API Reference

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/users` | All users (JSON array) |
| `GET` | `/api/users/:id` | Single user by ID |
| `GET` | `/api/stats` | Dashboard statistics |

### Example

```bash
curl http://localhost:4567/api/users | jq
curl http://localhost:4567/api/stats | jq
```

## Web Routes

| Method | Path | Description |
|---|---|---|
| `GET` | `/` | Dashboard with search & pagination |
| `GET` | `/users/new` | New user form |
| `POST` | `/users` | Create user |
| `GET` | `/users/:id/edit` | Edit user form |
| `POST` | `/users/:id` | Update user |
| `POST` | `/users/:id/delete` | Delete user |
| `POST` | `/contact` | Submit contact message |

## Customization

| Option | File | What to change |
|---|---|---|
| Port | `app.rb` | Set `PORT` env var or edit `set :port` |
| Theme colors | `public/style.css` | Edit CSS custom properties in `:root` |
| Seed data | `lib/database.rb` | Edit the `seed!` method |
| Roles | `lib/database.rb` + `app.rb` | Add to the CHECK constraint + validation arrays |
| Pagination size | `app.rb` | Change `per = 10` |

## License

MIT
