# Professional Ruby App

This is a professional Ruby application that uses Sinatra and SQLite3 to create a web application with Bootstrap styling.

## Features

- **Bootstrap Styling**: The application uses Bootstrap for a clean and modern user interface.
- **User List**: The application queries data from a SQLite3 database and displays a list of users.
- **Contact Form**: The application includes a contact form in a modal dialog.

## Technologies Used

- **Ruby**: The application is written in Ruby.
- **Sinatra**: Sinatra is used as the web application framework.
- **SQLite3**: SQLite3 is used as the database for storing user data.
- **Bootstrap**: Bootstrap is used for styling the web application.

<img width="1868" alt="Screenshot 2024-04-09 at 1 07 05 PM" src="https://github.com/shuddha2021/RubyConnect/assets/81951239/64c10894-acde-4b4f-88dd-0483171ceb69">


## Database Connection![Uploading Screenshot 2024-04-09 at 1.07.05 PM.png…]()


The application connects to a SQLite3 database using the `sqlite3` gem. The database is set up in the `setup_db.rb` file, where a `users` table is created and populated with sample data.

## Project Structure

The project consists of three main files:

- `index.rb`: This is the main HTML file for the web application.
- `app.rb`: This is the main Ruby file that sets up the Sinatra application and routes.
- `setup_db.rb`: This file sets up the SQLite3 database.

## Getting Started

To get started with this project:

1. Clone the repository.
2. Install the required gems with `bundle install`.
3. Set up the database with `ruby setup_db.rb`.
4. Start the Sinatra application with `ruby app.rb`.

## Why This Project Is Useful

This project serves as a great starting point for learning how to create a web application with Ruby and Sinatra. It demonstrates how to set up a SQLite3 database, how to query data from the database, and how to display the data in a web page.

## Contributing

Contributions to this project are welcome. Please fork the repository and create a pull request with your changes.
