#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean

# Force database setup for Render
echo "Setting up database..."

# Try to create database (will fail if exists, but that's OK)
bundle exec rake db:create || echo "Database already exists or creation not needed"

# Check if users table exists, if not load schema
echo "Checking for users table..."
if ! bundle exec rails runner "ActiveRecord::Base.connection.table_exists?('users')" 2>/dev/null; then
  echo "Users table not found, loading schema..."
  bundle exec rake db:schema:load
else
  echo "Users table exists, running migrations..."
  bundle exec rake db:migrate
fi

echo "Database setup complete"