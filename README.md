# Professional Ruby App

This is a professional web application built using Ruby, Sinatra, and SQLite3. It demonstrates how to create a dynamic web app with a clean and responsive user interface using Bootstrap styling.

## Features

- Navigation bar with links to the home page and a contact modal
- Main container displaying a greeting message and a button to change the greeting
- User list fetched from the SQLite3 database and displayed dynamically
- Contact modal with a form for users to send messages
- Responsive design using Bootstrap classes and custom CSS styles

## Technologies Used

- Ruby: The primary programming language used for server-side logic and database interactions.
- Sinatra: A lightweight web framework for Ruby that allows easy creation of web applications.
- SQLite3: A relational database management system used for storing and retrieving data.
- HTML: The markup language used for structuring the web pages.
- CSS: Used for styling the web pages and creating a visually appealing user interface.
- Bootstrap: A popular CSS framework that provides pre-built components and responsive grid system.
- JavaScript: Used for adding interactivity to the web pages, such as changing the greeting message.

## Database Connection

The application connects to an SQLite3 database named `my_database.db`. The database connection is established in the `app.rb` file using the following code:

```ruby
db = SQLite3::Database.new 'my_database.db'
Setup_db.rb File
The setup_db.rb file is responsible for creating the users table in the database and inserting some sample data. It can be run separately to initialize the database.

Project Structure
app.rb: The main application file that defines the routes and handles the database queries.
views/index.erb: The HTML template for the home page, which includes the navigation bar, main container, user list, and contact modal.
setup_db.rb: A script to set up the SQLite3 database and populate it with sample data.
my_database.db: The SQLite3 database file that stores the user data.
Getting Started
Make sure you have Ruby and SQLite3 installed on your system.
Clone this repository to your local machine.
Navigate to the project directory in your terminal.
Run bundle install to install the required dependencies.
Run ruby setup_db.rb to set up the database and populate it with sample data.
Run ruby app.rb to start the Sinatra server.
Open your web browser and visit http://localhost:4567 to see the application in action.
Why This Project Is Useful
This project serves as a great starting point for building professional web applications using Ruby and Sinatra. It demonstrates how to:

Create a dynamic web application with server-side rendering using Sinatra and ERB templates.
Connect to and interact with an SQLite3 database to store and retrieve data.
Use Bootstrap to create a responsive and visually appealing user interface.
Implement a contact form within a modal dialog.
Structure a Ruby web application with separate files for routes, views, and database setup.
By exploring and extending this project, developers can learn how to build robust and interactive web applications using Ruby and popular web development technologies.
